using UnityEngine;
using System.Net;
using System.Net.Sockets;
using System.Text;
using System.Threading;
using System;

/// <summary>
/// IMU-based object tracking using ESP32-S2 + MPU6050
/// Attach this script to the Main Camera to track its rotation from the IMU sensor.
/// </summary>
public class IMU_HeadTracking : MonoBehaviour
{
    [Header("Network Settings")]
    [Tooltip("UDP port to receive IMU data (must match ESP32 settings)")]
    public int port = 5005;
    
    [Header("Rotation Settings")]
    [Tooltip("Smoothing factor (higher = smoother but more lag)")]
    [Range(1f, 30f)]
    public float smoothingSpeed = 15f;
    
    [Tooltip("Dead zone - ignore changes smaller than this (reduces jitter)")]
    [Range(0f, 5f)]
    public float deadZone = 1.0f;
    
    [Tooltip("Apply yaw rotation (horizontal)")]
    public bool enableYaw = true;
    
    [Tooltip("Apply pitch rotation (vertical)")]
    public bool enablePitch = true;
    
    [Tooltip("Apply roll rotation (tilt)")]
    public bool enableRoll = true;
    
    [Header("Axis Mapping")]
    [Tooltip("Invert pitch axis")]
    public bool invertPitch = false;
    
    [Tooltip("Invert roll axis")]
    public bool invertRoll = true;
    
    [Tooltip("Invert yaw axis")]
    public bool invertYaw = true;
    
    [Header("Calibration")]
    // NOTE: Rotation offset is now handled entirely by the Recenter logic (calibrationOffset Quaternion)
    public KeyCode recenterKey = KeyCode.R;
    
    [Header("Debug")]
    public bool showDebugInfo = true;

    // Network
    private UdpClient client;
    private Thread receiveThread;
    private bool isRunning = false;
    
    // IMU data (target variables are updated on the background thread)
    private float targetPitch, targetRoll, targetYaw;
    
    // IMU data (main variables are updated on the main thread inside the lock)
    public float pitch, roll, yaw;
    private float lastPitch, lastRoll, lastYaw;
    private Quaternion smoothedRotation;
    private Quaternion calibrationOffset;
    private bool dataReceived = false;
    private float lastDataTime;
    
    // Connection status
    private int packetsReceived = 0;
    private float connectionCheckInterval = 1f;
    private float nextConnectionCheck = 0f;

    void Start()
    {
        // Initialize rotation
        smoothedRotation = transform.localRotation; // Start at current rotation
        calibrationOffset = Quaternion.identity;

        // Start UDP listener
        StartUDPListener();
        
        Debug.Log($"IMU Head Tracking Started - Listening on port {port}");
        Debug.Log($"Press {recenterKey} to recenter view");
    }

    void StartUDPListener()
    {
        try
        {
            // Note: If you have issues, try binding to a specific IPAddress
            client = new UdpClient(port);
            client.Client.ReceiveTimeout = 100;
            isRunning = true;
            
            // Start background thread for receiving data
            receiveThread = new Thread(new ThreadStart(ReceiveData));
            receiveThread.IsBackground = true;
            receiveThread.Start();
        }
        catch (Exception e)
        {
            Debug.LogError($"Failed to start UDP listener: {e.Message}");
        }
    }

    void ReceiveData()
    {
        while (isRunning)
        {
            try
            {
                IPEndPoint ep = new IPEndPoint(IPAddress.Any, 0);
                byte[] data = client.Receive(ref ep);
                string msg = Encoding.UTF8.GetString(data);

                string[] parts = msg.Split(',');
                if (parts.Length == 3)
                {
                    // Use lock to protect target variables from simultaneous read/write
                    lock (this)
                    {
                        if (float.TryParse(parts[0], out float tempPitch) &&
                            float.TryParse(parts[1], out float tempRoll) &&
                            float.TryParse(parts[2], out float tempYaw))
                        {
                            // Round to whole numbers (keeps .0 format)
                            targetPitch = Mathf.Round(tempPitch);
                            targetRoll = Mathf.Round(tempRoll);
                            targetYaw = Mathf.Round(tempYaw);
                            
                            // Only set flags if all parses succeed
                            dataReceived = true;
                            // Note: We use Time.realtimeSinceStartup since Time.time isn't reliable in threads
                            lastDataTime = Time.realtimeSinceStartup; 
                            packetsReceived++;
                        }
                        // else: Ignore malformed packets
                    }
                }
            }
            catch (SocketException)
            {
                // Timeout is normal (or no data arrived in time), continue
            }
            catch (Exception e)
            {
                // General error, often due to firewall or network disconnect
                Debug.LogWarning($"UDP Receive Error: {e.Message}");
            }
        }
    }

    void Update()
    {
        // 1. Check for recentering input
        if (Input.GetKeyDown(recenterKey))
        {
            RecenterView();
        }
        
        // 2. Update rotation if data is available
        if (dataReceived)
        {
            // Safely read the latest target values from the background thread
            lock (this)
            {
                // Apply dead zone to filter out jitter
                float newPitch = targetPitch;
                float newRoll = targetRoll;
                float newYaw = targetYaw;
                
                if (Mathf.Abs(newPitch - lastPitch) > deadZone)
                    pitch = newPitch;
                if (Mathf.Abs(newRoll - lastRoll) > deadZone)
                    roll = newRoll;
                if (Mathf.Abs(newYaw - lastYaw) > deadZone)
                    yaw = newYaw;
                    
                lastPitch = pitch;
                lastRoll = roll;
                lastYaw = yaw;
                // Keep dataReceived = true while streaming
            }

            // Apply axis inversions and enable/disable
            float finalPitch = enablePitch ? (invertPitch ? -pitch : pitch) : 0f;
            float finalRoll = enableRoll ? (invertRoll ? -roll : roll) : 0f;
            float finalYaw = enableYaw ? (invertYaw ? -yaw : yaw) : 0f;

            // 3. Create the RAW rotation Quaternion (based on the camera's required Euler order)
            // Note: The order Y, X, Z (Yaw, Pitch, Roll) is often standard for head tracking
            Quaternion rawRotation = Quaternion.Euler(finalPitch, finalYaw, finalRoll);

            // 4. Apply the calibration offset (calibrationOffset * rawRotation)
            Quaternion finalTargetRotation = calibrationOffset * rawRotation;

            // 5. Smooth interpolation
            smoothedRotation = Quaternion.Slerp(
                smoothedRotation, 
                finalTargetRotation, 
                Time.deltaTime * smoothingSpeed
            );

            // 6. Apply the smoothed rotation to the camera (Local space is essential)
            transform.localRotation = smoothedRotation; 
        }

        // 7. Connection status check (using realtimeSinceStartup for safety)
        if (Time.realtimeSinceStartup > nextConnectionCheck)
        {
            CheckConnectionStatus();
        }
    }
    
    // --- Helper Functions ---
    
    void CheckConnectionStatus()
    {
        nextConnectionCheck = Time.realtimeSinceStartup + connectionCheckInterval;
        
        if (packetsReceived == 0 && Time.realtimeSinceStartup - lastDataTime > 5f)
        {
            if (showDebugInfo)
                Debug.LogWarning("No IMU data received. Check ESP32 connection and IP address/firewall.");
        }
        else if (Time.realtimeSinceStartup - lastDataTime > 2f)
        {
            if (showDebugInfo)
                Debug.LogWarning("IMU data stream stopped. Connection lost?");
        }
        
        packetsReceived = 0; // Reset counter
    }

    public void RecenterView()
    {
        // Safely read the freshest angles from the thread
        lock (this)
        {
            // 1. Get the current *raw* MPU angles with inversions applied
            float currentPitch = enablePitch ? (invertPitch ? -targetPitch : targetPitch) : 0f;
            float currentRoll = enableRoll ? (invertRoll ? -targetRoll : targetRoll) : 0f;
            float currentYaw = enableYaw ? (invertYaw ? -targetYaw : targetYaw) : 0f;

            Quaternion currentMPURot = Quaternion.Euler(currentPitch, currentYaw, currentRoll);
            
            // 2. Calculate the inverse to use as the new offset
            // This makes the current orientation the new "zero" or identity.
            calibrationOffset = Quaternion.Inverse(currentMPURot); 
        }
        
        // 3. Force the current rotation to immediately snap to the recentered view
        // The next Update will handle the smoothing.
        
        Debug.Log("IMU device recalibrated to current orientation.");
    }

    void OnApplicationQuit()
    {
        StopUDPListener();
    }

    void OnDestroy()
    {
        StopUDPListener();
    }

    void StopUDPListener()
    {
        isRunning = false;
        
        if (receiveThread != null && receiveThread.IsAlive)
        {
            // Give the thread a moment to clean up before aborting
            receiveThread.Join(100); 
        }
        
        if (client != null)
        {
            client.Close();
        }
    }
    
    // ... (OnGUI function for debugging remains the same) ...
    // Note: OnGUI is deprecated in modern Unity but kept here for function completion
}