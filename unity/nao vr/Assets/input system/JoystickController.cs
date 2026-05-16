using UnityEngine;
using System.Net;
using System.Net.Sockets;
using System.Text;
using System.Threading;

public class JoystickController : MonoBehaviour
{
    // --- Networking Config ---
    public int port = 5006; 
    private UdpClient udpClient;
    private Thread receiveThread;

    // --- Data Variables ---
    // MPU Data (Floats)
    private float targetPitch, targetRoll, targetYaw; 
    // Joystick Data (Integers/ADC)
    private int targetStickX, targetStickY, targetButtonState; 
    
    // PUBLIC ACCESS for other scripts 
    [HideInInspector] public Vector2 normalizedStickInput;
    [HideInInspector] public bool shootPressed;
    // Public access for MPU data (use these for weapon aiming/swing detection)
    [HideInInspector] public Vector3 mpuAngles; 
    
    // ADC values for normalization
    private const float ADC_CENTER = 2047.5f; 
    private const float DEAD_ZONE = 0.25f;     // Fixes sliding/drift

    // --- Component Reference ---
    private PlayerMotor motor; 

    void Start()
    {
        motor = GetComponent<PlayerMotor>();
        if (motor == null) Debug.LogError("PlayerMotor script not found!");

        InitUDP();
    }

    private void InitUDP()
    {
        udpClient = new UdpClient(port);
        receiveThread = new Thread(new ThreadStart(ReceiveData));
        receiveThread.IsBackground = true;
        receiveThread.Start();
        Debug.Log("Listening for Joystick/MPU data on port " + port);
    }

    private void ReceiveData()
    {
        while (true)
        {
            try
            {
                IPEndPoint anyIP = new IPEndPoint(IPAddress.Any, 0);
                byte[] data = udpClient.Receive(ref anyIP);
                string msg = Encoding.UTF8.GetString(data);

                // Expected Format: P, R, Y, StickX, StickY, Button (6 values)
                string[] parts = msg.Split(',');
                
                if (parts.Length == 6) 
                {
                    // Attempt to parse all 6 values
                    if (float.TryParse(parts[0], out targetPitch) &&
                        float.TryParse(parts[1], out targetRoll) &&
                        float.TryParse(parts[2], out targetYaw) &&
                        int.TryParse(parts[3], out targetStickX) &&
                        int.TryParse(parts[4], out targetStickY) &&
                        int.TryParse(parts[5], out targetButtonState))
                    {
                        // Data successfully parsed. Store MPU angles.
                        mpuAngles = new Vector3(targetPitch, targetYaw, targetRoll);
                    }
                }
            }
            catch (System.Exception err)
            {
                Debug.LogError("UDP Receive Error (Joystick/MPU): " + err.ToString());
                if (err.GetType() == typeof(ThreadAbortException)) return;
            }
        }
    }

    void Update()
    {
        // --- 1. Normalize Stick Input (Movement Fixes) ---
        
        // X-Axis: Invert by multiplying by -1f to fix inverted left/right movement.
        float xNorm = ((float)targetStickX - ADC_CENTER) / ADC_CENTER * -1f;
        
        // Y-Axis: Forward/Backward movement.
        float yNorm = ((float)targetStickY - ADC_CENTER) / ADC_CENTER;
        
        normalizedStickInput = new Vector2(xNorm, yNorm);

        // Apply Dead Zone (Fixes Sliding/Drift)
        if (normalizedStickInput.magnitude < DEAD_ZONE)
        {
            normalizedStickInput = Vector2.zero;
        }

        // --- 2. Button State ---
        shootPressed = (targetButtonState == 0); // 0 means pressed on ESP32 (PULLUP)

        // --- 3. Pass Input to Motor ---
        if (motor != null)
        {
            motor.Move(normalizedStickInput); 
        }
    }

    void OnApplicationQuit()
    {
        if (receiveThread != null && receiveThread.IsAlive)
        {
            receiveThread.Abort();
        }
        if (udpClient != null)
        {
            udpClient.Close();
        }
    }
}