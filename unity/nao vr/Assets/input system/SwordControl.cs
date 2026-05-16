using UnityEngine;

public class HandSwordController : MonoBehaviour
{
    [Header("References")]
    public JoystickController stickData; // Drag Player Root (with JoystickController) here
    
    [Header("Hand/Sword Settings")]
    public bool controlHand = true; // True = control hand, False = control sword directly
    public Transform handTransform; // Optional: reference to hand bone/transform
    public Transform swordTransform; // Optional: reference to sword transform
    
    [Header("Rotation Mapping")]
    [Tooltip("Swap/invert axes to match your physical controller orientation")]
    public Vector3 axisMultiplier = new Vector3(1f, 1f, 1f); // Invert axes: use -1
    public Vector3 axisSwap = new Vector3(0, 1, 2); // 0=X, 1=Y, 2=Z - reorder axes
    
    [Header("Rotation Offsets")]
    [Tooltip("Offset to match neutral hand position")]
    public Vector3 rotationOffset = Vector3.zero;
    
    [Header("Smoothing & Limits")]
    public float smoothing = 10f;
    public bool useLimits = false;
    public Vector3 minAngles = new Vector3(-90, -90, -90);
    public Vector3 maxAngles = new Vector3(90, 90, 90);
    
    [Header("Swing Detection")]
    public bool detectSwing = false;
    public float swingThreshold = 100f; // Degrees per second
    private Vector3 lastAngles;
    private float swingSpeed;
    
    [Header("Debug")]
    public bool showDebugInfo = false;

    void Start()
    {
        if (stickData == null)
        {
            Debug.LogError("JoystickController reference is missing!");
            enabled = false;
            return;
        }
        
        lastAngles = stickData.mpuAngles;
    }

    void Update()
    {
        // Get current MPU angles (Pitch, Yaw, Roll)
        Vector3 rawAngles = stickData.mpuAngles;
        
        // --- 1. Axis Swapping ---
        // Remap axes based on how you hold the controller
        Vector3 swappedAngles = new Vector3(
            rawAngles[(int)axisSwap.x] * axisMultiplier.x,
            rawAngles[(int)axisSwap.y] * axisMultiplier.y,
            rawAngles[(int)axisSwap.z] * axisMultiplier.z
        );
        
        // --- 2. Apply Offset ---
        Vector3 finalAngles = swappedAngles + rotationOffset;
        
        // --- 3. Apply Limits (Optional) ---
        if (useLimits)
        {
            finalAngles.x = Mathf.Clamp(finalAngles.x, minAngles.x, maxAngles.x);
            finalAngles.y = Mathf.Clamp(finalAngles.y, minAngles.y, maxAngles.y);
            finalAngles.z = Mathf.Clamp(finalAngles.z, minAngles.z, maxAngles.z);
        }
        
        // --- 4. Swing Detection ---
        if (detectSwing)
        {
            Vector3 angleDelta = rawAngles - lastAngles;
            swingSpeed = angleDelta.magnitude / Time.deltaTime;
            
            if (swingSpeed > swingThreshold)
            {
                OnSwingDetected(swingSpeed);
            }
            
            lastAngles = rawAngles;
        }
        
        // --- 5. Apply Rotation ---
        Quaternion targetRotation = Quaternion.Euler(finalAngles);
        
        if (controlHand && handTransform != null)
        {
            // Control hand (sword follows hand naturally)
            handTransform.localRotation = Quaternion.Slerp(
                handTransform.localRotation, 
                targetRotation, 
                Time.deltaTime * smoothing
            );
        }
        else if (!controlHand && swordTransform != null)
        {
            // Control sword directly
            swordTransform.localRotation = Quaternion.Slerp(
                swordTransform.localRotation, 
                targetRotation, 
                Time.deltaTime * smoothing
            );
        }
        else
        {
            // Fallback: control this transform
            transform.localRotation = Quaternion.Slerp(
                transform.localRotation, 
                targetRotation, 
                Time.deltaTime * smoothing
            );
        }
        
        // --- 6. Debug Info ---
        if (showDebugInfo)
        {
            Debug.Log($"Raw: {rawAngles} | Final: {finalAngles} | Swing: {swingSpeed:F1}°/s");
        }
    }
    
    // Called when a swing is detected
    private void OnSwingDetected(float speed)
    {
        // You can trigger attack animations, damage, effects here
        if (showDebugInfo)
        {
            Debug.Log($"SWING DETECTED! Speed: {speed:F1}°/s");
        }
        
        // Example: Trigger animation
        // GetComponent<Animator>()?.SetTrigger("Swing");
        
        // Example: Apply damage to enemies in range
        // DealDamageInRange(speed);
    }
    
    // Optional: Calibration function (call this when hand is in neutral position)
    public void CalibrateNeutralPosition()
    {
        rotationOffset = -stickData.mpuAngles;
        Debug.Log($"Calibrated! Offset set to: {rotationOffset}");
    }
    
    // Optional: Get current swing speed (for other scripts)
    public float GetSwingSpeed()
    {
        return swingSpeed;
    }
}