using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ShadowController : MonoBehaviour
{
    private GameObject player;

    public static ShadowController Instance { get; private set; }

    // Start is called before the first frame update
    void Start()
    {
        player = GameObject.FindGameObjectWithTag("Player");

        if (Instance != null)
        {
            Destroy(this.gameObject);
            return;
        }

        Instance = this;
        GameObject.DontDestroyOnLoad(this.gameObject);
    }

    // Update is called once per frame
    void Update()
    {
        if(!this.gameObject.transform.position.Equals(player.transform.position))
            Move();
    }
    void Move()
    {
        if(player.GetComponent<PlayerController2D>().isFalling || player.GetComponent<PlayerController2D>().isJumping)
        {
            this.gameObject.transform.position = new Vector3(player.transform.position.x,
                                                             this.gameObject.transform.position.y,
                                                             this.gameObject.transform.position.z);
        }
        else
        {
            this.gameObject.transform.position = new Vector3(player.transform.position.x,
                                                             player.transform.position.y,
                                                             player.transform.position.z);
        }
    }
}
