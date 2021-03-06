using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Audio;
using UnityEngine.UI;
using TMPro;
using DG.Tweening;
using Yarn.Unity;
using UnityEngine.EventSystems;

//TODO: 实现save＆quit
//TODO: 添加切换语言选项

public class PauseMenu : MonoBehaviour
{
    public static PauseMenu Instance;

    public static bool GameIsPaused = false;

    public RectTransform pauseMenuUI;
    public Ease animEase;

    // Start is called before the first frame update
    private void Start()
    {
        if (Instance != null)
        {
            Destroy(this.gameObject);
            return;
        }

        Instance = this;
        GameObject.DontDestroyOnLoad(this.gameObject);
    }

    private void Update()
    {
        if (Input.GetKeyDown(KeyCode.Escape))
        {
            if (GameIsPaused)
            {
                Resume();
            }
            else
            {
                Pause();
            }
        }
    }

        public void ApplyChanges()
    {
        //set music and sfx volume
        audioMixer.SetFloat("musicVolume", musicSlider.value);
        audioMixer.SetFloat("SFXVolume", SFXSlider.value);

        //set resolution
        Resolution resolution = resolutions[currentOption];
        Screen.SetResolution(resolution.width, resolution.height, Screen.fullScreen);

        //set fullscreen
        //NOTICE: changing the order of the line above and the line below will
        //disable the function of fullscreen
        //cuz when setting the resolution will also set the fullscreen mode
        Screen.fullScreen = isFullscreen;

        UIAudio.Instance.PlayHitButton();
    }

    public void NextOption(TMP_Text option, List<string> options)
    {
        UIAudio.Instance.PlayChangeSettings();
        currentOption = (currentOption + 1) % optionSize;
        option.text = options[currentOption];
    }
    public void PreviousOption(TMP_Text option, List<string> options)
    {
        UIAudio.Instance.PlayChangeSettings();
        if (currentOption == 0)
        {
            currentOption = optionSize - 1;
            option.text = options[currentOption];
        }
        else
        {
            currentOption = (Mathf.Abs(currentOption - 1) % optionSize);
            option.text = options[currentOption];
        }
    }
    public void Resume()
    {
        pauseMenuUI.GetChild(0).DOScaleY(0, 0.3f).From(1).OnStepComplete(() =>
        {
            pauseMenuUI.gameObject.SetActive(false);
        });

        Time.timeScale = 1f;

        AudioSource[] audios = FindObjectsOfType<AudioSource>();
        foreach (AudioSource a in audios)
        {
            a.Play();
        }

        GameIsPaused = false;
    }

    public void Pause()
    {
        pauseMenuUI.gameObject.SetActive(true);
        pauseMenuUI.GetChild(0).DOScaleY(1, 0.3f).From(0).SetUpdate(true);

        Time.timeScale = 0f;

        AudioSource[] audios = FindObjectsOfType<AudioSource>();
        foreach (AudioSource a in audios)
        {
            a.Pause();
        }

        GameIsPaused = true;
    }
    public void SaveAndQuit()
    {
        //saving...
        //其实应该是quit to title
        UIAudio.Instance.PlayHitButton();

        Application.Quit();
    }
}
