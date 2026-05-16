using UnityEngine;
using System.Net;
using System.Net.Sockets;
using System.Text;
using System.Threading;

public class FreeHandController : MonoBehaviour
{
    [Header("Network Configuration")]
    public JoystickController joystickController; // REQUIRED: Drag JoystickController here
    public int cameraPort = 5007;   // Port for camera tracking (x, y, z position)
    
    private UdpClient cameraClient;
    private Thread cameraThread;
    
    [Header("Hand Transform")]
    public Transform handTransform; // The hand/sword transform to control
    
    [Header("Position Settings")]
    public Vector3 positionMultiplier = new Vector3(2f, 2f, 2f); // Scale camera space to world space
    public Vector3 positionOffset = Vector3.zero; // Offset for centering
    public bool invertX = false;
    public bool invertY = false;
    public bool invertZ = false;
    
    [Header("Position Smoothing")]
    public float positionSmoothing = 10f;
    public bool enablePositionSmoothing = true;
    
    [Header("Rotation Settings")]
    public float rotationSmoothing = 10f;
    public Vector3 rotationMultiplier = new Vector3(1f, 1f, 1f);
    public Vector3 rotationOffset = Vector3.zero;
    
    [Header("Axis Mapping")]
    [Tooltip("Remap MPU axes to hand orientation")]
    public AxisMapping pitchAxis = AxisMapping.X;
    public AxisMapping rollAxis = AxisMapping.Z;
    public AxisMapping yawAxis = AxisMapping.Y;
    public bool invertPitch = false;
    public bool invertRoll = false;
    public bool invertYaw = false;
    
    [Header("Movement Bounds (Optional)")]
    public bool useMovementBounds = false;
    public Vector3 minBounds = new Vector3(-2f, -1f, -2f);
    public Vector3 maxBounds = new Vector3(2f, 2f, 2f);
    
    [Header("Swing Detection")]
    public bool enableSwingDetection = true;
    public float swingThreshold = 50f;
    public float swingCooldown = 0.3f;
    
    [Header("Visual Feedback")]
    public TrailRenderer swordTrail;
    public ParticleSystem swingEffect;
    public LineRenderer debugLine; // Optional: shows hand path
    
    [Header("Debug")]
    public bool showDebugInfo = false;
    public bool showGizmos = true;
    
    // Private variables - MPU Data
    private float targetPitch, targetRoll, targetYaw;
    private int targetStickX, targetStickY, targetButtonState;
    private Vector3 mpuAngles;
    
    // Private variables - Camera Position Data
    private float cameraX = -1f, cameraY = -1f, cameraZ = -1f;
    private Vector3 targetPosition = Vector3.zero;
    private Vector3 smoothedPosition = Vector3.zero;
    private bool ballDetected = false;
    
    // Swing detection
    private Vector3 lastAngles;
    private float lastSwingTime;
    
    // Public access
    [HideInInspector] public Vector3 handPosition;
    [HideInInspector] public Vector3 handRotation;
    [HideInInspector] public float swingSpeed;
    [HideInInspector] public bool isSwinging = false;
    
    public enum AxisMapping { X, Y, Z, NegX, NegY, NegZ }
    
    void Start()
    {
        // Validate JoystickController reference
        if (joystickController == null)
        {
            Debug.LogError("JoystickController reference is missing! Please drag it in the inspector.");
            enabled = false;
            return;
        }
        
        // Use this transform if handTransform not assigned
        if (handTransform == null)
        {
            handTransform = transform;
            Debug.LogWarning("Hand Transform not assigned, using this transform.");
        }
        
        smoothedPosition = handTransform.localPosition;
        InitUDP();
    }
    
    private void InitUDP()
    {
        // No need to initialize MPU client - we get data from JoystickController
        Debug.Log("MPU data will be read from JoystickController");
        
        // Initialize Camera UDP client only
        try
        {
            cameraClient = new UdpClient(cameraPort);
            cameraThread = new Thread(new ThreadStart(ReceiveCameraData));
            cameraThread.IsBackground = true;
            cameraThread.Start();
            Debug.Log($"Listening for Camera data on port {cameraPort}");
        }
        catch (System.Exception e)
        {
            Debug.LogError($"Failed to start Camera UDP client: {e.Message}");
        }
    }
    
    // No longer needed - we get MPU data from JoystickController
    // private void ReceiveMPUData() { ... }
    
    // Thread: Receive Camera data (X, Y, Z position)
    private void ReceiveCameraData()
    {
        while (true)
        {
            try
            {
                IPEndPoint anyIP = new IPEndPoint(IPAddress.Any, 0);
                byte[] data = cameraClient.Receive(ref anyIP);
                string msg = Encoding.UTF8.GetString(data);
                
                // Expected Format: X, Y, Z (normalized 0-1, or -1 if not detected)
                string[] parts = msg.Split(',');
                
                if (parts.Length == 3)
                {
                    if (float.TryParse(parts[0], out cameraX) &&
                        float.TryParse(parts[1], out cameraY) &&
                        float.TryParse(parts[2], out cameraZ))
                    {
                        ballDetected = (cameraX >= 0 && cameraY >= 0 && cameraZ >= 0);
                    }
                }
            }
            catch (System.Exception err)
            {
                if (err.GetType() != typeof(ThreadAbortException))
                {
                    Debug.LogError("Camera UDP Error: " + err.Message);
                }
                else return;
            }
        }
    }
    
    void Update()
    {
        // Get MPU data from JoystickController
        if (joystickController != null)
        {
            mpuAngles = joystickController.mpuAngles;
        }
        
        UpdatePosition();
        UpdateRotation();
        
        if (enableSwingDetection)
        {
            DetectSwing();
        }
        
        // Update public variables
        handPosition = handTransform.localPosition;
        handRotation = handTransform.localRotation.eulerAngles;
        
        // Debug info
        if (showDebugInfo)
        {
            Debug.Log($"Pos: {handPosition} | Rot: {mpuAngles} | Detected: {ballDetected}");
        }
        
        // Update debug line
        if (debugLine != null && ballDetected)
        {
            debugLine.SetPosition(0, handTransform.position);
            debugLine.SetPosition(1, handTransform.position + handTransform.forward * 0.5f);
        }
    }
    
    private void UpdatePosition()
    {
        if (!ballDetected) return;
        
        // Convert camera coordinates (0-1) to world space
        // Camera Y is typically inverted (0 at top, 1 at bottom)
        Vector3 rawPos = new Vector3(
            cameraX - 0.5f,  // Center around 0
            -(cameraY - 0.5f),  // Invert Y and center
            cameraZ - 0.5f   // Center around 0
        );
        
        // Apply inversions
        if (invertX) rawPos.x *= -1;
        if (invertY) rawPos.y *= -1;
        if (invertZ) rawPos.z *= -1;
        
        // Scale to world space
        targetPosition = Vector3.Scale(rawPos, positionMultiplier) + positionOffset;
        
        // Apply bounds
        if (useMovementBounds)
        {
            targetPosition.x = Mathf.Clamp(targetPosition.x, minBounds.x, maxBounds.x);
            targetPosition.y = Mathf.Clamp(targetPosition.y, minBounds.y, maxBounds.y);
            targetPosition.z = Mathf.Clamp(targetPosition.z, minBounds.z, maxBounds.z);
        }
        
        // Apply smoothing
        if (enablePositionSmoothing)
        {
            smoothedPosition = Vector3.Lerp(
                smoothedPosition,
                targetPosition,
                Time.deltaTime * positionSmoothing
            );
            handTransform.localPosition = smoothedPosition;
        }
        else
        {
            handTransform.localPosition = targetPosition;
            smoothedPosition = targetPosition;
        }
    }
    
    private void UpdateRotation()
    {
        // Map axes according to settings
        Vector3 mappedAngles = new Vector3(
            GetMappedValue(mpuAngles, pitchAxis) * (invertPitch ? -1 : 1),
            GetMappedValue(mpuAngles, yawAxis) * (invertYaw ? -1 : 1),
            GetMappedValue(mpuAngles, rollAxis) * (invertRoll ? -1 : 1)
        );
        
        // Apply multipliers and offset
        mappedAngles = Vector3.Scale(mappedAngles, rotationMultiplier) + rotationOffset;
        
        // Smooth rotation
        Quaternion targetRotation = Quaternion.Euler(mappedAngles);
        handTransform.localRotation = Quaternion.Slerp(
            handTransform.localRotation,
            targetRotation,
            Time.deltaTime * rotationSmoothing
        );
    }
    
    private float GetMappedValue(Vector3 angles, AxisMapping mapping)
    {
        switch (mapping)
        {
            case AxisMapping.X: return angles.x;
            case AxisMapping.Y: return angles.y;
            case AxisMapping.Z: return angles.z;
            case AxisMapping.NegX: return -angles.x;
            case AxisMapping.NegY: return -angles.y;
            case AxisMapping.NegZ: return -angles.z;
            default: return 0f;
        }
    }
    
    private void DetectSwing()
    {
        if (Time.time - lastSwingTime < swingCooldown) return;
        
        Vector3 angleDelta = mpuAngles - lastAngles;
        swingSpeed = angleDelta.magnitude / Time.deltaTime;
        
        if (swingSpeed > swingThreshold)
        {
            OnSwingDetected(swingSpeed);
            lastSwingTime = Time.time;
        }
        
        lastAngles = mpuAngles;
    }
    
    private void OnSwingDetected(float speed)
    {
        isSwinging = true;
        Debug.Log($"Swing detected! Speed: {speed:F1}°/s");
        
        if (swordTrail != null)
        {
            swordTrail.emitting = true;
            Invoke(nameof(DisableTrail), 0.3f);
        }
        
        if (swingEffect != null)
        {
            swingEffect.Play();
        }
    }
    
    private void DisableTrail()
    {
        if (swordTrail != null)
        {
            swordTrail.emitting = false;
        }
        isSwinging = false;
    }
    
    // Calibration
    [ContextMenu("Calibrate Position")]
    public void CalibratePosition()
    {
        if (ballDetected)
        {
            positionOffset = -targetPosition;
            Debug.Log($"Position calibrated. Offset: {positionOffset}");
        }
        else
        {
            Debug.LogWarning("Cannot calibrate: ball not detected!");
        }
    }
    
    [ContextMenu("Calibrate Rotation")]
    public void CalibrateRotation()
    {
        rotationOffset = -mpuAngles;
        Debug.Log($"Rotation calibrated. Offset: {rotationOffset}");
    }
    
    [ContextMenu("Reset All Calibration")]
    public void ResetCalibration()
    {
        positionOffset = Vector3.zero;
        rotationOffset = Vector3.zero;
        Debug.Log("All calibration reset");
    }
    
    void OnDrawGizmos()
    {
        if (!showGizmos || handTransform == null) return;
        
        // Draw hand position
        Gizmos.color = ballDetected ? Color.green : Color.red;
        Gizmos.DrawWireSphere(handTransform.position, 0.1f);
        
        // Draw orientation axes
        Gizmos.color = Color.red;
        Gizmos.DrawRay(handTransform.position, handTransform.right * 0.3f);
        Gizmos.color = Color.green;
        Gizmos.DrawRay(handTransform.position, handTransform.up * 0.3f);
        Gizmos.color = Color.blue;
        Gizmos.DrawRay(handTransform.position, handTransform.forward * 0.5f);
        
        // Draw movement bounds
        if (useMovementBounds)
        {
            Gizmos.color = Color.yellow;
            Vector3 boundsCenter = (minBounds + maxBounds) / 2f;
            Vector3 boundsSize = maxBounds - minBounds;
            Gizmos.DrawWireCube(handTransform.parent.TransformPoint(boundsCenter), boundsSize);
        }
    }
    
    void OnApplicationQuit()
    {
        if (cameraThread != null && cameraThread.IsAlive)
        {
            cameraThread.Abort();
        }
        
        if (cameraClient != null)
        {
            cameraClient.Close();
        }
    }
    
    // Public getters
    public bool IsBallDetected() => ballDetected;
    public float GetSwingSpeed() => swingSpeed;
    public Vector3 GetRawCameraPosition() => new Vector3(cameraX, cameraY, cameraZ);
}