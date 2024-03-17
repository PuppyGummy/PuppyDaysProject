using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class NPCSingleton : MonoBehaviour
{
    public static NPCSingleton Instance { get; private set; }

    private void Awake()
    {
        if (Instance != null)
        {
            Destroy(this.gameObject);
            return;
        }

        Instance = this;
    }
}
