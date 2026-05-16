using UnityEngine;
using UnityEngine.AI;

public class ImprovedEnemyAI : MonoBehaviour, IDamageable
{
    [Header("References")]
    public NavMeshAgent agent;
    public Transform player;
    public Animator animator; // Optional
    
    [Header("Layers")]
    public LayerMask whatIsGround;
    public LayerMask whatIsPlayer;
    
    [Header("Health")]
    public float maxHealth = 100f;
    private float currentHealth;
    
    [Header("Patrolling")]
    public Vector3 walkPoint;
    private bool walkPointSet;
    public float walkPointRange = 10f;
    
    [Header("Attacking")]
    public float timeBetweenAttacks = 2f;
    private bool alreadyAttacked;
    public GameObject projectile;
    public Transform attackPoint; // Where projectile spawns
    
    [Header("Detection Ranges")]
    public float sightRange = 20f;
    public float attackRange = 10f;
    private bool playerInSightRange;
    private bool playerInAttackRange;
    
    [Header("Visual Feedback")]
    public Renderer bodyRenderer;
    public Color damageFlashColor = Color.red;
    private Color originalColor;
    private float flashTimer = 0f;
    private float flashDuration = 0.1f;
    
    [Header("Death")]
    public GameObject deathEffectPrefab;
    public float destroyDelay = 2f;
    private bool isDead = false;
    
    [Header("Audio")]
    public AudioClip attackSound;
    public AudioClip hurtSound;
    public AudioClip deathSound;
    private AudioSource audioSource;

    void Awake()
    {
        // Find player if not assigned
        if (player == null)
        {
            GameObject playerObj = GameObject.FindGameObjectWithTag("Player");
            if (playerObj != null)
            {
                player = playerObj.transform;
            }
            else
            {
                Debug.LogError("Enemy: Player not found!");
            }
        }
        
        // Get components
        if (agent == null)
        {
            agent = GetComponent<NavMeshAgent>();
        }
        
        if (bodyRenderer == null)
        {
            bodyRenderer = GetComponentInChildren<Renderer>();
        }
        
        if (bodyRenderer != null)
        {
            originalColor = bodyRenderer.material.color;
        }
        
        audioSource = GetComponent<AudioSource>();
        if (audioSource == null)
        {
            audioSource = gameObject.AddComponent<AudioSource>();
        }
        
        // Initialize
        currentHealth = maxHealth;
    }

    void Update()
    {
        if (isDead || player == null) return;
        
        // Check ranges
        playerInSightRange = Physics.CheckSphere(transform.position, sightRange, whatIsPlayer);
        playerInAttackRange = Physics.CheckSphere(transform.position, attackRange, whatIsPlayer);
        
        // State machine
        if (!playerInSightRange && !playerInAttackRange)
        {
            Patrolling();
        }
        else if (playerInSightRange && !playerInAttackRange)
        {
            ChasePlayer();
        }
        else if (playerInAttackRange && playerInSightRange)
        {
            AttackPlayer();
        }
        
        // Handle damage flash
        if (flashTimer > 0)
        {
            flashTimer -= Time.deltaTime;
            if (flashTimer <= 0 && bodyRenderer != null)
            {
                bodyRenderer.material.color = originalColor;
            }
        }
    }

    void Patrolling()
    {
        if (!walkPointSet)
        {
            SearchWalkPoint();
        }
        
        if (walkPointSet)
        {
            agent.SetDestination(walkPoint);
        }
        
        Vector3 distanceToWalkPoint = transform.position - walkPoint;
        
        if (distanceToWalkPoint.magnitude < 1f)
        {
            walkPointSet = false;
        }
        
        // Animation
        if (animator != null)
        {
            animator.SetBool("isWalking", true);
            animator.SetBool("isChasing", false);
        }
    }

    void SearchWalkPoint()
    {
        float randomZ = Random.Range(-walkPointRange, walkPointRange);
        float randomX = Random.Range(-walkPointRange, walkPointRange);
        
        walkPoint = new Vector3(
            transform.position.x + randomX,
            transform.position.y,
            transform.position.z + randomZ
        );
        
        if (Physics.Raycast(walkPoint, -transform.up, 2f, whatIsGround))
        {
            walkPointSet = true;
        }
    }

    void ChasePlayer()
    {
        agent.SetDestination(player.position);
        
        // Animation
        if (animator != null)
        {
            animator.SetBool("isWalking", false);
            animator.SetBool("isChasing", true);
        }
    }

    void AttackPlayer()
    {
        agent.SetDestination(transform.position);
        
        transform.LookAt(player);
        
        if (!alreadyAttacked)
        {
            PerformAttack();
            
            alreadyAttacked = true;
            Invoke(nameof(ResetAttack), timeBetweenAttacks);
        }
        
        // Animation
        if (animator != null)
        {
            animator.SetBool("isWalking", false);
            animator.SetBool("isChasing", false);
            animator.SetTrigger("attack");
        }
    }

    void PerformAttack()
    {
        if (projectile != null)
        {
            Vector3 spawnPos = attackPoint != null ? attackPoint.position : transform.position + transform.forward;
            
            Rigidbody rb = Instantiate(projectile, spawnPos, Quaternion.identity).GetComponent<Rigidbody>();
            if (rb != null)
            {
                rb.AddForce(transform.forward * 32f, ForceMode.Impulse);
                rb.AddForce(transform.up * 8f, ForceMode.Impulse);
            }
        }
        
        // Play attack sound
        if (attackSound != null && audioSource != null)
        {
            audioSource.PlayOneShot(attackSound);
        }
    }

    void ResetAttack()
    {
        alreadyAttacked = false;
    }

    // Implement IDamageable interface
    public void TakeDamage(float damage)
    {
        if (isDead) return;
        
        currentHealth -= damage;
        
        // Visual feedback
        FlashDamage();
        
        // Play hurt sound
        if (hurtSound != null && audioSource != null)
        {
            audioSource.PlayOneShot(hurtSound);
        }
        
        Debug.Log($"{gameObject.name} took {damage} damage. Health: {currentHealth}/{maxHealth}");
        
        if (currentHealth <= 0)
        {
            Die();
        }
    }

    void FlashDamage()
    {
        if (bodyRenderer != null)
        {
            bodyRenderer.material.color = damageFlashColor;
            flashTimer = flashDuration;
        }
    }

    void Die()
    {
        if (isDead) return;
        isDead = true;
        
        Debug.Log($"{gameObject.name} died!");
        
        // Disable AI
        agent.enabled = false;
        
        // Play death sound
        if (deathSound != null && audioSource != null)
        {
            audioSource.PlayOneShot(deathSound);
        }
        
        // Spawn death effect
        if (deathEffectPrefab != null)
        {
            Instantiate(deathEffectPrefab, transform.position, Quaternion.identity);
        }
        
        // Death animation
        if (animator != null)
        {
            animator.SetTrigger("death");
        }
        
        // Disable collider
        Collider col = GetComponent<Collider>();
        if (col != null)
        {
            col.enabled = false;
        }
        
        // Destroy after delay
        Destroy(gameObject, destroyDelay);
    }

    // Public methods
    public float GetHealthPercent()
    {
        return currentHealth / maxHealth;
    }

    public bool IsDead()
    {
        return isDead;
    }

    void OnDrawGizmosSelected()
    {
        Gizmos.color = Color.red;
        Gizmos.DrawWireSphere(transform.position, attackRange);
        
        Gizmos.color = Color.yellow;
        Gizmos.DrawWireSphere(transform.position, sightRange);
    }
}