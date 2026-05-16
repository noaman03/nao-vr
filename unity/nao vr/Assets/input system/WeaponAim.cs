using UnityEngine;

public class WeaponAim : MonoBehaviour
{
    [Header("Controller Script")]
    public JoystickController controller;
    
    [Header("Settings")]
    public float aimRotationSpeed = 25f; // Faster response for aiming
    public float maxVerticalAngle = 80f; 
    public bool invertPitch = true;

    // To maintain smooth vertical rotation limits
    private float verticalRotation = 0f; 

    void Start()
    {
        if (controller == null)
        {
            Debug.LogError("WeaponAim: Controller reference is missing! Aiming disabled.");
            enabled = false;
        }
    }

    void Update()
    {
        if (controller == null) return;
        
        // --- 1. Get raw MPU angles ---
        // MPU Pitch and Roll are suitable for vertical/side aiming adjustments.
        float rawPitch = controller.mpuAngles.x; 
        float rawRoll = controller.mpuAngles.z;
        
        // --- 2. Vertical Aiming (Pitch) ---
        
        // Apply inversion if needed
        float pitchDirection = invertPitch ? -1f : 1f;

        // The MPU Pitch angle is directly the desired angle.
        // We smooth the rotation and clamp it.
        verticalRotation = Mathf.Lerp(verticalRotation, rawPitch * pitchDirection, Time.deltaTime * aimRotationSpeed);
        verticalRotation = Mathf.Clamp(verticalRotation, -maxVerticalAngle, maxVerticalAngle); 
        
        // Apply vertical rotation to the CAMERA
        // Note: We use LocalRotation because the camera is a child of the Player Body
        transform.localRotation = Quaternion.Euler(verticalRotation, 0f, 0f);


        // --- 3. Lateral Aiming (Optional Roll/Joystick) ---
        // If you want the camera to tilt/roll slightly with the physical stick:
        // transform.localRotation *= Quaternion.Euler(0f, 0f, rawRoll * 0.5f); 
    }
}