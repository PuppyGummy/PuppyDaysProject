using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlayerController3D : MonoBehaviour
{
    // public static PlayerController3D Instance { get; private set; }

    [SerializeField]
    private float speed = 2f;
    public Rigidbody rigidBody = null;

    public Vector3 movement;
    private Vector2 movementInput;
    private CharacterFollow characterFollow;
    public float sniffRadius = 5f; // 检测半径
    public LayerMask hiddenLayer; // 隐藏物体的层

    private void Awake()
    {
        // if (Instance != null)
        // {
        //     Destroy(this.gameObject);
        //     return;
        // }

        // Instance = this;
        // GameObject.DontDestroyOnLoad(this.gameObject);
    }

    private void Start()
    {
        rigidBody = GetComponent<Rigidbody>();
        characterFollow = GetComponent<CharacterFollow>();
    }

    private void Update()
    {
        if (characterFollow.dialogueRunner.IsDialogueRunning == true)
            return;
        // Vertical
        float inputY = 0;
        if (Input.GetKey(KeyCode.UpArrow) || Input.GetKey(KeyCode.W))
            inputY = 1;
        else if (Input.GetKey(KeyCode.DownArrow) || Input.GetKey(KeyCode.S))
            inputY = -1;

        // Horizontal
        float inputX = 0;
        if (Input.GetKey(KeyCode.RightArrow) || Input.GetKey(KeyCode.D))
        {
            inputX = 1;
            transform.localScale = Vector3.one;
        }
        else if (Input.GetKey(KeyCode.LeftArrow) || Input.GetKey(KeyCode.A))
        {
            inputX = -1;
            transform.localScale = new Vector3(-1, 1, 1);
        }
        if (Input.GetKeyDown(KeyCode.K))
        {
            // Play sniffing animation
            DetectHiddenObjects();
        }


        // Normalize
        movement = new Vector3(inputX, 0, inputY).normalized;
    }

    private void FixedUpdate()
    {
        if (characterFollow.isFollowing)
            return;
        rigidBody.velocity = movement * speed;
    }

    private void OnLevelWasLoaded(int level)
    {
        FindStartPosition();
    }

    private void FindStartPosition()
    {
        transform.position = GameObject.FindWithTag("StartPos").transform.position;
    }

    private void DetectHiddenObjects()
    {
        Collider[] hiddenObjects = Physics.OverlapSphere(transform.position, sniffRadius, hiddenLayer);

        foreach (Collider obj in hiddenObjects)
        {
            obj.GetComponent<SpriteRenderer>().enabled = true;
        }
    }
}