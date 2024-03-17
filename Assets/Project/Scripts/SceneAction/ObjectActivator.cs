using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ObjectActivator : MonoBehaviour
{
    [SerializeField] private Animator anim;
    private CharacterFollow character;
    public bool isNPC = false;
    private void Start()
    {
        if (isNPC)
            character = GetComponentInParent<CharacterFollow>();
    }

    private void OnTriggerEnter(Collider collision)
    {
        if (collision.gameObject.tag == "Player")
        {
            if (isNPC)
                if (character.isFollowing || character.isLeading)
                    return;
            transform.GetChild(0).gameObject.SetActive(true);
            anim.SetTrigger("start");
            UIAudio.Instance.PlayAction();
        }
    }
    private void OnTriggerStay(Collider collision)
    {
        anim.SetBool("isStay", true);
    }
    private IEnumerator OnTriggerExit(Collider collision)
    {
        anim.SetBool("isStay", false);
        anim.SetBool("isExit", true);

        yield return new WaitForSeconds(0.25f);
        transform.GetChild(0).gameObject.SetActive(false);
    }
}
