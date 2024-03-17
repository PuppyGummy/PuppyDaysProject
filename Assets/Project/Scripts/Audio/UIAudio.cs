using System.Collections;
using System.Collections.Generic;
using UnityEngine;

//[CreateAssetMenu(menuName = "UIAudio")]
public class UIAudio : MonoBehaviour
{
    public static UIAudio Instance;

    [SerializeField] private AudioSource actionAudioSource = null;
    [SerializeField] private AudioSource optionsAudioSource = null;

    [Header("Audio Clips")]
    [SerializeField] AudioClip action = null;
    [SerializeField] AudioClip options = null;
    [SerializeField] AudioClip dialogue = null;
    [SerializeField] AudioClip changeSettings = null;
    [SerializeField] AudioClip hitButton = null;

    private void Awake()
    {
        if (Instance != null)
        {
            Destroy(this.gameObject);
            return;
        }

        Instance = this;
    }

    public void PlayAction()
    {
        actionAudioSource.PlayOneShot(action);
    }

    public void PlayOptions()
    {
        optionsAudioSource.PlayOneShot(options);
    }

    public void PlayDialogue()
    {
        optionsAudioSource.PlayOneShot(dialogue);
    }
    public void PlayChangeSettings()
    {
        optionsAudioSource.PlayOneShot(changeSettings);
    }
    public void PlayHitButton()
    {
        optionsAudioSource.PlayOneShot(hitButton);
    }
}
