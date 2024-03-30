using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.AI;
using System;
using Yarn.Unity;
using Spine.Unity;
using DG.Tweening;


public class CharacterFollow : MonoBehaviour
{
    public NavMeshAgent agent;
    // public Transform target;
    public bool isFollowing = false;
    public bool isLeading = false;
    private PlayerController3D currentCharacter;
    public DialogueRunner dialogueRunner = null;

    public SkeletonAnimation skeletonAnimation;
    public AnimationReferenceAsset idle, move, jump, doumao;
    private Spine.TrackEntry trackEntry;
    private string currentAnimation;
    private float ticker;
    private const float TICK_TIME = 10f;
    private Animator animator;
    private string currentState;
    // Start is called before the first frame update
    void Start()
    {
        skeletonAnimation = GetComponent<SkeletonAnimation>();
        dialogueRunner = FindObjectOfType<DialogueRunner>();
        agent = GetComponent<NavMeshAgent>();
        currentCharacter = GetComponent<PlayerController3D>();
        animator = GetComponent<Animator>();
    }

    // Update is called once per frame
    void Update()
    {
        if (dialogueRunner != null && skeletonAnimation != null)
        {
            if (dialogueRunner.IsDialogueRunning == true)
            {
                SetAnimation(idle, true, 1f);
                ticker = 0;
                return;
            }
        }

        UpdateAnim();

        if (!isFollowing)
            return;
        Follow();
        if (agent.velocity.x * transform.localScale.x < 0)
        {
            transform.localScale = new Vector3(-transform.localScale.x, transform.localScale.y, transform.localScale.z);
        }
    }
    void LateUpdate()
    {
        // transform.localEulerAngles = new Vector3(45, 0, 0);
    }

    private void Follow()
    {
        agent.SetDestination(CharacterManager.Instance.currentCharacter.transform.position);
    }
    public void SwitchCharacter()
    {
        CharacterManager.Instance.currentCharacter.enabled = false;
        CharacterManager.Instance.currentCharacter.GetComponent<NavMeshAgent>().enabled = true;
        CharacterManager.Instance.currentCharacter.GetComponent<CharacterFollow>().isFollowing = true;
        CharacterManager.Instance.currentCharacter.GetComponent<CharacterFollow>().isLeading = false;
        CharacterManager.Instance.currentCharacter = currentCharacter;
        isFollowing = false;
        isLeading = true;
        currentCharacter.enabled = true;
        currentCharacter.GetComponent<NavMeshAgent>().enabled = false;
        GetComponent<NavMeshAgent>().enabled = false;
        CharacterManager.Instance.virtualCamera.m_Follow = currentCharacter.transform;
    }
    public void UpdateAnim()
    {
        // if (!grounded)
        // {
        //     SetAnimation(jump, false, 1f);
        //     ticker = 0;
        // }
        if (skeletonAnimation == null)
        {
            // if (animator != null)
            // {
            //     if (currentCharacter.rigidBody.velocity.magnitude > 0.1f || agent.velocity.magnitude > 0.1f)
            //     {
            //         // ChangeAnimationState("Walk");
            //         gameObject.transform.DOMove(new Vector3(CharacterManager.Instance.currentCharacter.transform.position.x, CharacterManager.Instance.currentCharacter.transform.position.y + 0.2f, CharacterManager.Instance.currentCharacter.transform.position.z), 0.3f);
            //     }
            //     else
            //     {
            //         // ChangeAnimationState("Idle");
            //     }
            // }
            // else
            {
                return;
            }
        }
        if (currentCharacter.rigidBody.velocity.magnitude > 0.1f || agent.velocity.magnitude > 0.1f)
        {
            SetAnimation(move, true, 1f);
            ticker = 0;
        }
        else
        {
            ticker += Time.deltaTime;
            if (ticker >= TICK_TIME)
            {
                SetAnimation(doumao, false, 1f);
                ticker = 0;
            }
            else
            {
                if (currentAnimation != doumao.name)
                {
                    SetAnimation(idle, true, 1f);
                }
            }
        }
    }
    public void SetAnimation(AnimationReferenceAsset animation, bool loop, float timeScale)
    {
        if (animation.name.Equals(currentAnimation))
        {
            return;
        }
        currentAnimation = animation.name;
        trackEntry = skeletonAnimation.state.SetAnimation(0, animation, loop);
        trackEntry.TimeScale = timeScale;
        if (animation.name.Equals(doumao.name))
        {
            trackEntry.Complete += TrackEntry_Complete;
        }
    }

    private void TrackEntry_Complete(Spine.TrackEntry trackEntry)
    {
        ticker = 0;
        SetAnimation(idle, true, 1f);
    }
    private void ChangeAnimationState(string newState)
    {
        if (currentState == newState) return;
        animator.Play(newState);
        currentState = newState;
    }
}