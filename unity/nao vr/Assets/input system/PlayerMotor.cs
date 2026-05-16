using UnityEngine;

public class PlayerMotor : MonoBehaviour
{
    // --- Configurable Variables ---
    public float speed = 5.0f;
    public float gravity = -9.81f; // Standard Unity gravity (applied constantly)
    
    // --- Component References ---
    private CharacterController controller;
    private Vector3 currentMovement = Vector3.zero;
    private float verticalVelocity = 0f; // For gravity

    void Start()
    {
        controller = GetComponent<CharacterController>();
        if (controller == null)
        {
            Debug.LogError("CharacterController component missing on PlayerMotor object. Please add one!");
        }
    }

    // This method is called by the JoystickController in its Update()
    public void Move(Vector2 inputVector)
    {
        // 1. Calculate Movement Vector (Relative to Player's Orientation)
        
        // inputVector.y is Forward/Backward (Z-axis local)
        // inputVector.x is Left/Right (X-axis local)
        
        Vector3 forwardMovement = transform.forward * inputVector.y;
        Vector3 sideMovement = transform.right * inputVector.x;
        
        // Combine, normalize, and scale by speed.
        // We use inputVector.magnitude to allow analog movement speed.
        currentMovement = (forwardMovement + sideMovement).normalized * speed * inputVector.magnitude;
    }

    // Update is fine for CharacterController movement
    void Update()
    {
        if (controller != null)
        {
            // 2. Handle Gravity
            if (controller.isGrounded)
            {
                verticalVelocity = 0f; // Reset if grounded
            }
            
            // Apply gravity constantly
            verticalVelocity += gravity * Time.deltaTime;
            
            // 3. Combine and Execute Movement
            Vector3 finalMovement = currentMovement;
            finalMovement.y = verticalVelocity; // Add gravity to the movement vector

            // Use the CharacterController's Move function
            controller.Move(finalMovement * Time.deltaTime);
        }
    }
} 