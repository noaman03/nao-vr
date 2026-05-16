using UnityEngine;

public class WeaponSwitcher : MonoBehaviour
{
    [Header("Controller Input")]
    public JoystickController controller; // Drag your Player Root here
    public IMU_HeadTracking imuHeadTracking; // Drag IMU component here

    [Header("Weapon Models")]
    public GameObject gunModel;
    public GameObject swordModel;

    [Header("Gun Mode Scripts (Stick Aim)")]
    public MonoBehaviour gunAimScript;   // e.g., WeaponAim
    public MonoBehaviour gunBodyScript;  // e.g., MPULook

    [Header("Sword Mode Scripts (Head Look + Sword Angle)")]
    public MonoBehaviour headLookScript; // e.g., HeadLook
    public MonoBehaviour swordControlScript; // e.g., SwordControl

    // --- Double Click Variables ---
    private bool lastButtonState = false;
    private float lastClickTime = 0f;
    public float doubleClickSpeed = 0.3f; // Max time between clicks to count as double

    // State
    private bool isSwordMode = false;

    void Start()
    {
        // Try to find controller if not assigned
        if (controller == null) controller = GetComponent<JoystickController>();
        
        // Start with Gun Mode (IMU disabled)
        if (imuHeadTracking) imuHeadTracking.enabled = false;
        SetGunMode();
    }

    void Update()
    {
        if (controller == null) return;

        // --- Double Click Logic ---
        
        // 1. Get current state of the button
        bool isPressed = controller.shootPressed;

        // 2. Detect the moment the button goes DOWN (False -> True)
        if (isPressed && !lastButtonState)
        {
            // Check how much time passed since the last click
            if (Time.time - lastClickTime < doubleClickSpeed)
            {
                // It's a Double Click! Switch weapons.
                ToggleWeapon();
                lastClickTime = 0f; // Reset so a 3rd click doesn't trigger it again
            }
            else
            {
                // It's a Single Click (so far). Record the time.
                lastClickTime = Time.time;
            }
        }

        // 3. Update last state for the next frame
        lastButtonState = isPressed;
    }

    public void ToggleWeapon()
    {
        isSwordMode = !isSwordMode;

        if (isSwordMode)
            SetSwordMode();
        else
            SetGunMode();
    }

    void SetGunMode()
    {
        Debug.Log("Switched to GUN Mode");

        if(gunModel) gunModel.SetActive(true);
        if(swordModel) swordModel.SetActive(false);

        if(gunAimScript) gunAimScript.enabled = true;
        if(gunBodyScript) gunBodyScript.enabled = true;

        if(headLookScript) headLookScript.enabled = false;
        if(swordControlScript) swordControlScript.enabled = false;
        
        if(imuHeadTracking) imuHeadTracking.enabled = false;
    }

    void SetSwordMode()
    {
        Debug.Log("Switched to SWORD Mode");

        if(gunModel) gunModel.SetActive(false);
        if(swordModel) swordModel.SetActive(true);

        if(gunAimScript) gunAimScript.enabled = false;
        if(gunBodyScript) gunBodyScript.enabled = false;

        if(headLookScript) headLookScript.enabled = true;
        if(swordControlScript) swordControlScript.enabled = true;
        
        if(imuHeadTracking) imuHeadTracking.enabled = true;
        
        Camera.main.transform.localRotation = Quaternion.identity; 
    }
}