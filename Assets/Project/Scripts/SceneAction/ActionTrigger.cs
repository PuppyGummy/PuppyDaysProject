using UnityEngine;

public class ActionTrigger : MonoBehaviour
{
    [SerializeField] private SceneAction sceneAction = null;

    private Collider2D hitbox;
    private Vector2 hitpoint;

    // Start is called before the first frame update
    void Start()
    {
        GetComponent<SpriteRenderer>().sprite = sceneAction.GetActionIcon();

        hitbox = GetComponent<Collider2D>();
    }

    // Update is called once per frame
    void Update()
    {
        if (PauseMenu.GameIsPaused)
        {
            this.gameObject.SetActive(false);
        }

        // if (Input.GetMouseButtonDown(0))
        // {
        //     hitpoint = Camera.main.ScreenToWorldPoint(Input.mousePosition);

        //     if (hitbox.OverlapPoint(hitpoint) && sceneAction.isActiveAndEnabled)
        //     {
        //         sceneAction.Interact();

        //         this.gameObject.SetActive(false);
        //     }
        // }
        if (Input.GetKeyDown(KeyCode.Return))
        {
            if (sceneAction.isActiveAndEnabled)
            {

                sceneAction.Interact();

                this.gameObject.SetActive(false);
            }
        }
    }
    public void Interact()
    {
        sceneAction.Interact();
    }
}
