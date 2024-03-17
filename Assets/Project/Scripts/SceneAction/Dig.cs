using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class Dig : SceneAction
{
    public SpriteRenderer item;

    public override void Interact()
    {
        StartCoroutine(DigHole());
    }

    public IEnumerator DigHole()
    {
        item.enabled = true;
        item.transform.GetChild(0).gameObject.SetActive(true);
        Animator anim = item.GetComponent<Animator>();
        // 播放挖洞动画
        // CharacterManager.Instance.currentCharacter.SetAnimation(PlayerController3D.Instance.dig, true, 1f);
        // 播放挖洞音效
        // AudioManager.Instance.PlaySound("Dig");
        // 播放挖洞粒子效果
        // ParticleManager.Instance.PlayParticle("Dig", transform.position);
        // 显示道具
        anim.SetTrigger("Start");
        //wait until animation is finished
        yield return new WaitForSeconds(anim.GetCurrentAnimatorStateInfo(0).length);
        // destory parent
        Destroy(item.transform.parent.gameObject);
    }
}
