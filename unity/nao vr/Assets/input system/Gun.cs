using UnityEngine;
using UnityEngine.UI;

public class Gun : MonoBehaviour
{
    // --- Custom Controller Reference ---
    [Header("Custom Controller Input")]
    // Assign the GameObject containing the JoystickController script in the Inspector!
    public JoystickController controller; 
    
    // --- Existing Public Properties ---
    public float damage = 10f;
    public float range = 100f;
    public float impactForce = 30f;
    public Camera fpsCam;
    public ParticleSystem muzzleFlash;
    public GameObject impactEffect;
    public GameObject crosshair;

    // --- Private/Cached References ---
    private RectTransform crosshairRect;
    private Canvas crosshairCanvas;

    // --- Firing Rate Properties (Added for better control) ---
    [Header("Firing Rate")]
    public float fireRate = 0.15f;
    private float nextFireTime;

    void Start()
    {
        // --- Safety Check for Custom Controller ---
        if (controller == null)
        {
            Debug.LogError("Gun: The JoystickController reference is missing. Shooting disabled!");
            enabled = false;
            return;
        }

        // --- Crosshair Initialization ---
        if (crosshair != null)
        {
            crosshair.SetActive(true);
            crosshairRect = crosshair.GetComponent<RectTransform>();
            crosshairCanvas = crosshair.GetComponentInParent<Canvas>();
        }

        // Ensure the camera is set up correctly (usually the camera attached to the Player Look script)
        if (fpsCam == null)
        {
            fpsCam = Camera.main;
            if (fpsCam == null)
            {
                Debug.LogError("Gun: Main Camera not found. Cannot shoot accurately.");
            }
        }
    }
    
    // Update is called once per frame
    void Update()
    {
        // --- 1. Custom Controller Input Check (REPLACEMENT FOR KEYBOARD INPUT) ---
        
        // Check if the custom button is pressed AND the fire rate allows firing
        if(controller.shootPressed && Time.time > nextFireTime)
        {
            nextFireTime = Time.time + fireRate;
            Shoot();
        }

        // 2. Original Keyboard Input (Optional: Keep this line if you want both inputs)
        // if(Input.GetButtonDown("Fire1")){ Shoot(); }
    }

    public void Shoot()
    {
        muzzleFlash.Play();

        RaycastHit hit;
        // The default point if the raycast hits nothing (max range)
        Vector3 targetPoint = fpsCam.transform.position + fpsCam.transform.forward * range; 

        // --- Perform Raycast (The actual shot) ---
        if (Physics.Raycast(fpsCam.transform.position, fpsCam.transform.forward, out hit, range))
        {
            Debug.Log(hit.transform.name);
            
            // --- Damage Application ---
            Target target = hit.transform.GetComponent<Target>();
            if (target != null)
            {
                target.TakeDamage(damage);
            }
            
            // --- Physics Impact ---
            if (hit.rigidbody != null)
            {
                hit.rigidbody.AddForce(-hit.normal * impactForce);
            }
            
            // --- Impact Visual Effect ---
            GameObject ImpactGo = Instantiate(impactEffect, hit.point, Quaternion.LookRotation(hit.normal));
            Destroy(ImpactGo, 2f);

            // Update the target point to the actual hit location
            targetPoint = hit.point;
        }

        // --- Crosshair Placement ---
        if (crosshair != null)
        {
            // Move the crosshair visual to the projected hit location (or max range)
            MoveCrosshairToWorldPoint(targetPoint);
        }
    }

    private void MoveCrosshairToWorldPoint(Vector3 worldPoint)
    {
        // ... (Original working crosshair logic remains unchanged) ...
        if (crosshairRect != null && crosshairCanvas != null)
        {
            // It's a UI element: convert world point to canvas local point
            Vector2 screenPoint = fpsCam.WorldToScreenPoint(worldPoint);
            RectTransform canvasRect = crosshairCanvas.GetComponent<RectTransform>();
            Vector2 localPoint;
            Camera camForCanvas = crosshairCanvas.renderMode == RenderMode.ScreenSpaceOverlay ? null : fpsCam;
            RectTransformUtility.ScreenPointToLocalPointInRectangle(canvasRect, screenPoint, camForCanvas, out localPoint);
            crosshairRect.anchoredPosition = localPoint;
        }
        else if (crosshair != null)
        {
            // Not a UI element: place the object at world point
            crosshair.transform.position = worldPoint;
            crosshair.transform.LookAt(fpsCam.transform);
        }
    }
}