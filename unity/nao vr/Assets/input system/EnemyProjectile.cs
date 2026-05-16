using UnityEngine;

public class EnemyProjectile : MonoBehaviour
{
    [Header("Damage")]
    public float damage = 10f;
    
    [Header("Lifetime")]
    public float lifetime = 5f;
    
    [Header("Effects")]
    public GameObject hitEffect;
    public AudioClip hitSound;
    
    private bool hasHit = false;

    void Start()
    {
        // Destroy after lifetime
        Destroy(gameObject, lifetime);
    }

    void OnCollisionEnter(Collision collision)
    {
        if (hasHit) return;
        hasHit = true;
        
        // Check if hit player
        if (collision.gameObject.CompareTag("Player"))
        {
            // Try to damage player
            IDamageable damageable = collision.gameObject.GetComponent<IDamageable>();
            if (damageable != null)
            {
                damageable.TakeDamage(damage);
                Debug.Log($"Projectile hit player for {damage} damage!");
            }
        }
        
        // Spawn hit effect
        if (hitEffect != null)
        {
            GameObject effect = Instantiate(hitEffect, transform.position, Quaternion.identity);
            Destroy(effect, 2f);
        }
        
        // Play hit sound
        if (hitSound != null)
        {
            AudioSource.PlayClipAtPoint(hitSound, transform.position);
        }
        
        // Destroy projectile
        Destroy(gameObject);
    }
}