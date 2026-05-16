using UnityEngine;
using System.Collections.Generic;

public class SwordDamage : MonoBehaviour
{
    [Header("References")]
    public FreeHandController FreeHandController; // Reference to hand controller
    public Transform swordTip; // Drag the tip of the sword here
    public Transform swordBase; // Drag the base/hilt of the sword here
    
    [Header("Damage Settings")]
    public float baseDamage = 20f;
    public float swingSpeedMultiplier = 0.5f; // Extra damage per degree/sec
    public float minSwingSpeedForDamage = 50f; // Minimum swing speed to deal damage
    
    [Header("Hit Detection")]
    public LayerMask damageableLayers; // What can the sword hit?
    public float hitCheckRadius = 0.1f; // Radius for sphere cast along blade
    public int bladeSegments = 5; // More = better detection, more performance cost
    
    [Header("Cooldown")]
    public float hitCooldown = 0.2f; // Time between hits on same target
    private Dictionary<Collider, float> lastHitTime = new Dictionary<Collider, float>();
    
    [Header("Effects")]
    public GameObject hitEffectPrefab; // Particle effect on hit
    public AudioClip hitSound; // Sound on hit
    public AudioClip swingSound; // Sound on swing
    private AudioSource audioSource;
    
    [Header("Trail Effect")]
    public TrailRenderer trailRenderer; // Optional sword trail
    public float trailMinSpeed = 80f; // Speed needed to show trail
    
    [Header("Debug")]
    public bool showDebugGizmos = true;
    public Color gizmoColor = Color.red;
    
    // Internal state
    private bool isSwinging = false;
    private float currentSwingSpeed = 0f;
    private Vector3 lastTipPosition;
    private HashSet<Collider> hitThisSwing = new HashSet<Collider>();

    void Start()
    {
        // Setup audio
        audioSource = GetComponent<AudioSource>();
        if (audioSource == null)
        {
            audioSource = gameObject.AddComponent<AudioSource>();
        }
        audioSource.playOnAwake = false;
        audioSource.spatialBlend = 1f; // 3D sound
        
        // Validate references
        if (FreeHandController == null)
        {
            Debug.LogError("FreeHandController reference missing!");
        }
        
        if (swordTip == null || swordBase == null)
        {
            Debug.LogWarning("Sword tip/base not set. Using sword transform as fallback.");
            swordTip = transform;
            swordBase = transform;
        }
        
        lastTipPosition = swordTip.position;
        
        // Disable trail initially
        if (trailRenderer != null)
        {
            trailRenderer.emitting = false;
        }
    }

    void Update()
    {
        // Get swing speed from hand controller
        if (FreeHandController != null)
        {
            currentSwingSpeed = FreeHandController.GetSwingSpeed();
        }
        
        // Detect swing start
        if (!isSwinging && currentSwingSpeed > minSwingSpeedForDamage)
        {
            OnSwingStart();
        }
        
        // Detect swing end
        if (isSwinging && currentSwingSpeed < minSwingSpeedForDamage * 0.5f)
        {
            OnSwingEnd();
        }
        
        // Update trail effect
        UpdateTrailEffect();
        
        // Perform hit detection during swing
        if (isSwinging)
        {
            CheckForHits();
        }
        
        // Update last position
        lastTipPosition = swordTip.position;
    }

    private void OnSwingStart()
    {
        isSwinging = true;
        hitThisSwing.Clear();
        
        // Play swing sound
        if (swingSound != null && audioSource != null)
        {
            audioSource.PlayOneShot(swingSound, 0.5f);
        }
        
        Debug.Log($"Swing started! Speed: {currentSwingSpeed:F1}°/s");
    }

    private void OnSwingEnd()
    {
        isSwinging = false;
        
        if (trailRenderer != null)
        {
            trailRenderer.emitting = false;
        }
        
        Debug.Log("Swing ended.");
    }

    private void CheckForHits()
    {
        // Check along the blade for hits using multiple sphere casts
        Vector3 bladeStart = swordBase.position;
        Vector3 bladeEnd = swordTip.position;
        
        for (int i = 0; i < bladeSegments; i++)
        {
            float t = i / (float)(bladeSegments - 1);
            Vector3 checkPoint = Vector3.Lerp(bladeStart, bladeEnd, t);
            
            // Sphere cast for hits
            Collider[] hits = Physics.OverlapSphere(checkPoint, hitCheckRadius, damageableLayers);
            
            foreach (Collider hit in hits)
            {
                // Skip if we already hit this collider this swing
                if (hitThisSwing.Contains(hit)) continue;
                
                // Skip if on cooldown
                if (lastHitTime.ContainsKey(hit) && 
                    Time.time - lastHitTime[hit] < hitCooldown)
                {
                    continue;
                }
                
                // Don't hit ourselves
                if (hit.transform.IsChildOf(transform.root))
                {
                    continue;
                }
                
                // Process the hit
                ProcessHit(hit, checkPoint);
            }
        }
    }

    private void ProcessHit(Collider hitCollider, Vector3 hitPoint)
    {
        // Mark as hit this swing
        hitThisSwing.Add(hitCollider);
        lastHitTime[hitCollider] = Time.time;
        
        // Calculate damage based on swing speed
        float damage = baseDamage + (currentSwingSpeed * swingSpeedMultiplier);
        
        // Try to apply damage to IDamageable interface
        IDamageable damageable = hitCollider.GetComponent<IDamageable>();
        if (damageable != null)
        {
            damageable.TakeDamage(damage);
            Debug.Log($"Hit {hitCollider.name} for {damage:F1} damage!");
        }
        else
        {
            // Fallback: try SendMessage (legacy method)
            hitCollider.SendMessage("TakeDamage", damage, SendMessageOptions.DontRequireReceiver);
            Debug.Log($"Hit {hitCollider.name} (SendMessage fallback)");
        }
        
        // Spawn hit effect
        if (hitEffectPrefab != null)
        {
            GameObject effect = Instantiate(hitEffectPrefab, hitPoint, Quaternion.identity);
            Destroy(effect, 2f);
        }
        
        // Play hit sound
        if (hitSound != null && audioSource != null)
        {
            audioSource.PlayOneShot(hitSound, 0.8f);
        }
        
        // Optional: Apply force to rigidbody
        Rigidbody rb = hitCollider.GetComponent<Rigidbody>();
        if (rb != null)
        {
            Vector3 forceDirection = (hitPoint - swordBase.position).normalized;
            rb.AddForce(forceDirection * currentSwingSpeed * 0.1f, ForceMode.Impulse);
        }
    }

    private void UpdateTrailEffect()
    {
        if (trailRenderer == null) return;
        
        // Enable trail when swinging fast enough
        if (currentSwingSpeed > trailMinSpeed)
        {
            trailRenderer.emitting = true;
        }
        else
        {
            trailRenderer.emitting = false;
        }
    }

    // Optional: Manual damage trigger (for button-based attacks)
    public void TriggerDamage()
    {
        if (!isSwinging)
        {
            OnSwingStart();
        }
    }

    // Clean up old entries in hit cooldown dictionary
    void LateUpdate()
    {
        // Remove old entries to prevent memory leak
        List<Collider> toRemove = new List<Collider>();
        foreach (var kvp in lastHitTime)
        {
            if (Time.time - kvp.Value > hitCooldown * 2)
            {
                toRemove.Add(kvp.Key);
            }
        }
        foreach (var col in toRemove)
        {
            lastHitTime.Remove(col);
        }
    }

    // Debug visualization
    void OnDrawGizmos()
    {
        if (!showDebugGizmos || swordTip == null || swordBase == null) return;
        
        Gizmos.color = gizmoColor;
        
        // Draw blade segments
        Vector3 bladeStart = swordBase.position;
        Vector3 bladeEnd = swordTip.position;
        
        for (int i = 0; i < bladeSegments; i++)
        {
            float t = i / (float)(bladeSegments - 1);
            Vector3 checkPoint = Vector3.Lerp(bladeStart, bladeEnd, t);
            Gizmos.DrawWireSphere(checkPoint, hitCheckRadius);
        }
        
        // Draw blade line
        Gizmos.color = isSwinging ? Color.green : Color.yellow;
        Gizmos.DrawLine(bladeStart, bladeEnd);
    }
}

// Interface for damageable objects
public interface IDamageable
{
    void TakeDamage(float damage);
}