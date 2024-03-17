using System.Collections.Generic;
using UnityEngine;

public class EatFood : SceneAction
{
    public float hungerRestoreAmount = 10f;

    public override void Interact()
    {
        Eat(hungerRestoreAmount);
    }

    public void Eat(float amount)
    {
        // play eat animation
        CharacterManager.Instance.currentCharacter.GetComponent<PlayerHealth>().IncreaseHunger(amount);
    }
}
