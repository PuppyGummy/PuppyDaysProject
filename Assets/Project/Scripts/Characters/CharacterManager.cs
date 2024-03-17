using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Cinemachine;

public class CharacterManager : MonoBehaviour
{
    public static CharacterManager Instance { get; private set; }
    public PlayerController3D currentCharacter;
    public CinemachineVirtualCamera virtualCamera;

    // Start is called before the first frame update
    void Start()
    {
        if (Instance != null)
        {
            Debug.LogError("More than one CharacterManager in scene!");
            return;
        }
        Instance = this;
    }

    // Update is called once per frame
    void Update()
    {

    }

}
