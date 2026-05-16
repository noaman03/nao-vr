using UnityEngine;
using System.Collections;
using System.Collections.Generic;
using UnityEngine.AI;

public class EnemySpawner : MonoBehaviour
{
    [Header("References")]
    public GameObject enemyPrefab; // Drag your enemy prefab here
    public Transform player; // Drag player transform here
    
    [Header("Spawn Settings")]
    [Tooltip("Minimum distance from player to spawn enemies")]
    public float minSpawnDistance = 15f;
    
    [Tooltip("Maximum distance from player to spawn enemies")]
    public float maxSpawnDistance = 30f;
    
    [Tooltip("How high to check for ground when spawning")]
    public float spawnHeightCheck = 50f;
    
    [Tooltip("Layer mask for ground detection")]
    public LayerMask groundLayer;
    
    [Header("Wave Settings")]
    [Tooltip("Number of enemies to spawn per wave")]
    public int enemiesPerWave = 5;
    
    [Tooltip("Time between waves (seconds)")]
    public float timeBetweenWaves = 10f;
    
    [Tooltip("Increase enemies per wave")]
    public bool scaleDifficulty = true;
    
    [Tooltip("Extra enemies added per wave")]
    public int enemyIncreasePerWave = 2;
    
    [Tooltip("Maximum enemies per wave")]
    public int maxEnemiesPerWave = 20;
    
    [Header("Continuous Spawning")]
    [Tooltip("Keep spawning enemies continuously")]
    public bool continuousSpawning = true;
    
    [Tooltip("Maximum enemies alive at once")]
    public int maxEnemiesAlive = 10;
    
    [Tooltip("Time between individual spawns (continuous mode)")]
    public float spawnInterval = 3f;
    
    [Header("Spawn Validation")]
    [Tooltip("Maximum attempts to find valid spawn point")]
    public int maxSpawnAttempts = 20;
    
    [Tooltip("Minimum distance between spawned enemies")]
    public float minDistanceBetweenEnemies = 3f;
    
    [Header("Debug")]
    public bool showDebugInfo = true;
    public bool showSpawnGizmos = true;
    
    // Private variables
    private int currentWave = 0;
    private int enemiesAlive = 0;
    private List<GameObject> spawnedEnemies = new List<GameObject>();
    private List<Vector3> recentSpawnPoints = new List<Vector3>();
    private bool isSpawning = false;

    void Start()
    {
        if (player == null)
        {
            player = GameObject.FindGameObjectWithTag("Player")?.transform;
            if (player == null)
            {
                Debug.LogError("EnemySpawner: Player reference not found!");
                enabled = false;
                return;
            }
        }
        
        if (enemyPrefab == null)
        {
            Debug.LogError("EnemySpawner: Enemy prefab not assigned!");
            enabled = false;
            return;
        }
        
        if (continuousSpawning)
        {
            StartCoroutine(ContinuousSpawnRoutine());
        }
        else
        {
            StartCoroutine(WaveSpawnRoutine());
        }
    }

    void Update()
    {
        // Clean up destroyed enemies from list
        spawnedEnemies.RemoveAll(enemy => enemy == null);
        enemiesAlive = spawnedEnemies.Count;
    }

    // Continuous spawning mode
    IEnumerator ContinuousSpawnRoutine()
    {
        while (true)
        {
            if (enemiesAlive < maxEnemiesAlive)
            {
                SpawnEnemy();
                yield return new WaitForSeconds(spawnInterval);
            }
            else
            {
                yield return new WaitForSeconds(1f); // Check again in 1 second
            }
        }
    }

    // Wave-based spawning mode
    IEnumerator WaveSpawnRoutine()
    {
        while (true)
        {
            yield return new WaitForSeconds(timeBetweenWaves);
            
            // Wait for all enemies to be defeated before next wave
            while (enemiesAlive > 0)
            {
                yield return new WaitForSeconds(1f);
            }
            
            SpawnWave();
        }
    }

    void SpawnWave()
    {
        currentWave++;
        
        // Calculate enemies for this wave
        int enemiesToSpawn = enemiesPerWave;
        if (scaleDifficulty)
        {
            enemiesToSpawn += (currentWave - 1) * enemyIncreasePerWave;
            enemiesToSpawn = Mathf.Min(enemiesToSpawn, maxEnemiesPerWave);
        }
        
        if (showDebugInfo)
        {
            Debug.Log($"Wave {currentWave} starting! Spawning {enemiesToSpawn} enemies.");
        }
        
        // Spawn all enemies for this wave
        StartCoroutine(SpawnWaveEnemies(enemiesToSpawn));
    }

    IEnumerator SpawnWaveEnemies(int count)
    {
        isSpawning = true;
        recentSpawnPoints.Clear();
        
        for (int i = 0; i < count; i++)
        {
            SpawnEnemy();
            yield return new WaitForSeconds(0.5f); // Small delay between spawns
        }
        
        isSpawning = false;
    }

    public void SpawnEnemy()
    {
        Vector3 spawnPosition;
        if (TryGetValidSpawnPosition(out spawnPosition))
        {
            GameObject enemy = Instantiate(enemyPrefab, spawnPosition, Quaternion.identity);
            spawnedEnemies.Add(enemy);
            recentSpawnPoints.Add(spawnPosition);
            
            // Optional: Add spawn effect
            SpawnEffect(spawnPosition);
            
            if (showDebugInfo)
            {
                Debug.Log($"Enemy spawned at {spawnPosition}. Total alive: {enemiesAlive + 1}");
            }
        }
        else
        {
            if (showDebugInfo)
            {
                Debug.LogWarning("Failed to find valid spawn position after max attempts.");
            }
        }
    }

    bool TryGetValidSpawnPosition(out Vector3 position)
    {
        for (int attempt = 0; attempt < maxSpawnAttempts; attempt++)
        {
            // Random angle around player
            float angle = Random.Range(0f, 360f);
            float distance = Random.Range(minSpawnDistance, maxSpawnDistance);
            
            // Calculate position around player
            Vector3 direction = new Vector3(
                Mathf.Cos(angle * Mathf.Deg2Rad),
                0,
                Mathf.Sin(angle * Mathf.Deg2Rad)
            );
            
            Vector3 candidatePosition = player.position + direction * distance;
            
            // Raycast down to find ground
            candidatePosition.y += spawnHeightCheck;
            
            RaycastHit hit;
            if (Physics.Raycast(candidatePosition, Vector3.down, out hit, spawnHeightCheck * 2, groundLayer))
            {
                Vector3 groundPosition = hit.point + Vector3.up * 0.5f; // Slightly above ground
                
                // Validate position
                if (IsValidSpawnPosition(groundPosition))
                {
                    position = groundPosition;
                    return true;
                }
            }
        }
        
        position = Vector3.zero;
        return false;
    }

    bool IsValidSpawnPosition(Vector3 position)
    {
        // Check distance from player
        float distanceToPlayer = Vector3.Distance(position, player.position);
        if (distanceToPlayer < minSpawnDistance || distanceToPlayer > maxSpawnDistance)
        {
            return false;
        }
        
        // Check distance from other recently spawned enemies
        foreach (Vector3 spawnPoint in recentSpawnPoints)
        {
            if (Vector3.Distance(position, spawnPoint) < minDistanceBetweenEnemies)
            {
                return false;
            }
        }
        
        // Check if position is blocked by objects
        Collider[] colliders = Physics.OverlapSphere(position, 1f);
        foreach (Collider col in colliders)
        {
            // Check for player
            if (col.transform == player || col.transform.root == player.root)
            {
                return false;
            }
            
            // Check for other enemies
            if (col.GetComponent<NavMeshAgent>() != null || 
                col.GetComponent<ImprovedEnemyAI>() != null)
            {
                return false;
            }
        }
        
        return true;
    }

    void SpawnEffect(Vector3 position)
    {
        // Optional: Add particle effect or animation
        // Example:
        // GameObject effect = Instantiate(spawnEffectPrefab, position, Quaternion.identity);
        // Destroy(effect, 2f);
    }

    // Public methods for external control
    public void SpawnEnemiesAtCount(int count)
    {
        StartCoroutine(SpawnWaveEnemies(count));
    }

    public void ClearAllEnemies()
    {
        foreach (GameObject enemy in spawnedEnemies)
        {
            if (enemy != null)
            {
                Destroy(enemy);
            }
        }
        spawnedEnemies.Clear();
        enemiesAlive = 0;
    }

    public void SetSpawnRate(float newInterval)
    {
        spawnInterval = newInterval;
    }

    public int GetEnemiesAlive()
    {
        return enemiesAlive;
    }

    public int GetCurrentWave()
    {
        return currentWave;
    }

    // Debug visualization
    void OnDrawGizmos()
    {
        if (!showSpawnGizmos || player == null) return;
        
        // Draw spawn range
        Gizmos.color = Color.yellow;
        DrawCircle(player.position, minSpawnDistance, 32);
        
        Gizmos.color = Color.red;
        DrawCircle(player.position, maxSpawnDistance, 32);
        
        // Draw recent spawn points
        Gizmos.color = Color.green;
        foreach (Vector3 point in recentSpawnPoints)
        {
            Gizmos.DrawWireSphere(point, 1f);
        }
    }

    void DrawCircle(Vector3 center, float radius, int segments)
    {
        float angleStep = 360f / segments;
        Vector3 prevPoint = center + new Vector3(radius, 0, 0);
        
        for (int i = 1; i <= segments; i++)
        {
            float angle = i * angleStep * Mathf.Deg2Rad;
            Vector3 newPoint = center + new Vector3(
                Mathf.Cos(angle) * radius,
                0,
                Mathf.Sin(angle) * radius
            );
            Gizmos.DrawLine(prevPoint, newPoint);
            prevPoint = newPoint;
        }
    }
}