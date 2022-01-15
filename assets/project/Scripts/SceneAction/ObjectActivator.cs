using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ObjectActivator : MonoBehaviour
{
    [SerializeField] private Animator anim;

    private void OnTriggerEnter2D(Collider2D collision)
    {
        transform.GetChild(0).gameObject.SetActive(true);
        anim.SetTrigger("start");
        UIAudio.Instance.PlayAction();
    }
    private void OnTriggerStay2D(Collider2D collision)
    {
        anim.SetBool("isStay",true);
    }
    private IEnumerator OnTriggerExit2D(Collider2D collision)
    {
        anim.SetBool("isStay", false);
        anim.SetBool("isExit", true);

        yield return new WaitForSeconds(0.25f);
        transform.GetChild(0).gameObject.SetActive(false);
    }
}
