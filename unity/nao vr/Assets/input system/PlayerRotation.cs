using UnityEngine;

/// <summary>
/// Optional: Rotates player body to follow head yaw when looking far left/right
/// Only attach this if you want the player body to turn when looking around
/// </summary>
public class PlayerBodyRotation : MonoBehaviour
{
    [Header("References")]
    public Transform headTransform; // Camera/Head transform
    public JoystickController controller;
    
    [Header("Body Rotation Settings")]
    [Tooltip("Angle threshold before body starts rotating (e.g., 45° means body rotates after looking 45° left/right)")]
    public float rotationThreshold = 45f;
    
    [Tooltip("How fast the body rotates to match head")]
    public float bodyRotationSpeed = 5f;
    
    [Tooltip("Enable this if you want body to always follow head yaw")]
    public bool alwaysFollowHead = false;
    
    [Header("Debug")]
    public bool showDebugInfo = false;
    
    private float targetBodyYaw = 0f;

    void Start()
    {
        if (controller == null)
        {
            Debug.LogError("PlayerBodyRotation: Controller reference missing!");
            enabled = false;
            return;
        }
        
        if (headTransform == null)
        {
            Debug.LogWarning("PlayerBodyRotation: Head transform not set. Trying to find main camera...");
            headTransform = Camera.main?.transform;
            
            if (headTransform == null)
            {
                Debug.LogError("PlayerBodyRotation: Could not find head transform!");
                enabled = false;
            }
        }
        
        // Initialize body yaw to current rotation
        targetBodyYaw = transform.eulerAngles.y;
    }

    void LateUpdate()
    {
        if (controller == null || headTransform == null) return;
        
        // Get head's local yaw rotation
        float headLocalYaw = headTransform.localEulerAngles.y;
        
        // Normalize to -180 to 180
        if (headLocalYaw > 180) headLocalYaw -= 360;
        
        if (alwaysFollowHead)
        {
            // Body always follows head yaw
            targetBodyYaw = controller.mpuAngles.y;
        }
        else
        {
            // Only rotate body when head looks beyond threshold
            if (Mathf.Abs(headLocalYaw) > rotationThreshold)
            {
                // Calculate how much to rotate body
                float excessYaw = headLocalYaw - Mathf.Sign(headLocalYaw) * rotationThreshold;
                targetBodyYaw += excessYaw * Time.deltaTime * bodyRotationSpeed;
                
                // Also adjust head to compensate
                Vector3 headRot = headTransform.localEulerAngles;
                headRot.y = Mathf.Sign(headLocalYaw) * rotationThreshold;
                headTransform.localEulerAngles = headRot;
            }
        }
        
        // Apply body rotation smoothly
        Quaternion targetRotation = Quaternion.Euler(0f, targetBodyYaw, 0f);
        transform.rotation = Quaternion.Slerp(
            transform.rotation,
            targetRotation,
            Time.deltaTime * bodyRotationSpeed
        );
        
        if (showDebugInfo)
        {
            Debug.Log($"Body Yaw: {targetBodyYaw:F1}° | Head Local Yaw: {headLocalYaw:F1}°");
        }
    }
}