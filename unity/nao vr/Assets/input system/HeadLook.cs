using UnityEngine;

public class MPUHeadLook : MonoBehaviour
{
    [Header("Controller Reference")]
    public JoystickController controller; // Reference to JoystickController for MPU data
    
    [Header("Rotation Settings")]
    public float sensitivity = 1.0f;
    public float smoothing = 10f;
    
    [Header("Rotation Limits")]
    public bool usePitchLimits = true;
    public float minPitch = -80f; // Look down limit
    public float maxPitch = 80f;  // Look up limit
    
    public bool useYawLimits = false;
    public float minYaw = -90f;
    public float maxYaw = 90f;
    
    [Header("Axis Configuration")]
    [Tooltip("Invert pitch if looking up/down is reversed")]
    public bool invertPitch = false;
    [Tooltip("Invert yaw if left/right is reversed")]
    public bool invertYaw = false;
    
    [Header("Debug")]
    public bool showDebugInfo = false;
    
    // Private variables
    private Vector3 currentRotation = Vector3.zero;
    private Vector3 targetRotation = Vector3.zero;

    void Start()
    {
        if (controller == null)
        {
            Debug.LogError("MPUHeadLook: JoystickController reference is missing!");
            enabled = false;
            return;
        }
        
        // Initialize with current rotation
        currentRotation = transform.localEulerAngles;
        
        // Normalize angles to -180 to 180 range
        if (currentRotation.x > 180) currentRotation.x -= 360;
        if (currentRotation.y > 180) currentRotation.y -= 360;
    }

    void Update()
    {
        if (controller == null) return;
        
        // Get MPU angles from controller
        Vector3 mpuAngles = controller.mpuAngles;
        
        // Extract pitch and yaw (assuming mpuAngles = (pitch, yaw, roll))
        float pitch = mpuAngles.x * sensitivity * (invertPitch ? -1f : 1f);
        float yaw = mpuAngles.y * sensitivity * (invertYaw ? -1f : 1f);
        
        // Apply limits
        if (usePitchLimits)
        {
            pitch = Mathf.Clamp(pitch, minPitch, maxPitch);
        }
        
        if (useYawLimits)
        {
            yaw = Mathf.Clamp(yaw, minYaw, maxYaw);
        }
        
        // Set target rotation (NO ROLL - keep Z at 0)
        targetRotation = new Vector3(pitch, yaw, 0f);
        
        // Smooth interpolation
        currentRotation = Vector3.Lerp(currentRotation, targetRotation, Time.deltaTime * smoothing);
        
        // Apply rotation (LOCAL rotation so it doesn't affect player body)
        transform.localRotation = Quaternion.Euler(currentRotation);
        
        // Debug info
        if (showDebugInfo)
        {
            Debug.Log($"Head Look - Pitch: {pitch:F1}° | Yaw: {yaw:F1}°");
        }
    }
    
    // Calibration - call this to reset head to neutral position
    [ContextMenu("Calibrate Head Position")]
    public void Calibrate()
    {
        currentRotation = Vector3.zero;
        targetRotation = Vector3.zero;
        transform.localRotation = Quaternion.identity;
        Debug.Log("Head position calibrated to neutral");
    }
}