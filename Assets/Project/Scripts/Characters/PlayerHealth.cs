using UnityEngine;
using UnityEngine.UI;

public class PlayerHealth : MonoBehaviour
{
    public float maxHunger = 100f;
    public float hungerDecreaseRate = 0.05f;  // 饥饿度减少速率
    public float maxHealth = 3f;
    public float healthDecreaseRate = 1f;  // 生命值减少速率
    public float healthDecreaseTime = 1f;  // 减少生命值的时间间隔


    [SerializeField] private float currentHunger;
    [SerializeField] private float currentHealth;
    private float healthDecreaseTimer;

    [SerializeField] private Image hungerBar;
    [SerializeField] private Image[] hearts;


    void Start()
    {
        currentHunger = maxHunger;
        currentHealth = maxHealth;
        healthDecreaseTimer = healthDecreaseTime;

        // 启动定时器，每秒钟减少饥饿度
        InvokeRepeating("DecreaseHunger", 1f, 1f);
    }

    void Update()
    {
        // 处理角色死亡逻辑
        if (currentHunger <= 0)
        {
            if (currentHealth > 0)
                DecreaseHealth();
        }

        // 这里可以添加其他输入和交互逻辑
    }

    public void DecreaseHunger()
    {
        // 减少饥饿度
        currentHunger -= hungerDecreaseRate;

        // 确保饥饿度不会小于零
        currentHunger = Mathf.Max(0f, currentHunger);
        // 更新饥饿度条
        hungerBar.fillAmount = currentHunger / maxHunger;
    }

    public void DecreaseHealth()
    {
        // 更新减少生命值的计时器
        healthDecreaseTimer -= Time.deltaTime;

        // 如果计时器达到零，减少生命值并重置计时器
        if (healthDecreaseTimer <= 0f)
        {
            // 每秒减少生命值
            currentHealth -= healthDecreaseRate;

            if (!(currentHealth < 0))
                hearts[(int)currentHealth].color = new Color(0.5f, 0.5f, 0.5f, 1f);

            // 确保生命值不会小于零
            currentHealth = Mathf.Max(0f, currentHealth);

            // 重置计时器
            healthDecreaseTimer = healthDecreaseTime;
        }
        // 这里可以添加处理角色死亡的逻辑
        if (currentHealth == 0)
        {
            Debug.Log("角色死亡");
            // 可以在这里添加其他处理角色死亡的逻辑，比如重新开始游戏或显示游戏结束画面
        }
    }
    public void IncreaseHealth(float amount)
    {
        // 增加生命值
        currentHealth += amount;

        // 确保生命值不会大于最大值
        currentHealth = Mathf.Min(maxHealth, currentHealth);

        // 更新生命值条
        for (int i = 0; i < hearts.Length; i++)
        {
            if (i < currentHealth)
                hearts[i].color = new Color(1f, 1f, 1f, 1f);
        }
    }
    public void IncreaseHunger(float amount)
    {
        // 增加饥饿度
        currentHunger += amount;

        // 确保饥饿度不会大于最大值
        currentHunger = Mathf.Min(maxHunger, currentHunger);

        // 更新饥饿度条
        hungerBar.fillAmount = currentHunger / maxHunger;
    }
}
