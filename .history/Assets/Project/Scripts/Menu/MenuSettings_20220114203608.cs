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
//TODO?: 添加鼠标操作
//TODO: 添加切换语言选项

public class MenuSettings : MonoBehaviour
{
    public static MenuSettings Instance;
    public AudioMixer audioMixer;
    public TMP_Text resolutionOption;
    public TMP_Text fullscreenOption;
    public MenuSetting resolutionSetting;
    public MenuSetting fullscreenSetting;
    public Slider musicSlider;
    public Slider SFXSlider;
    public TextLineProvider provider;
    //[SerializeField] UIAudio UIPlayer = null;

    Resolution[] resolutions;

    private List<string> resolutionOptions = new List<string>();
    //[SerializeField] private TMP_Text[] settingsText;
    //[SerializeField] private MenuSetting[] settings;

    private int optionSize;
    private int currentOption;
    //private int currentSetting;
    //private int settingSize;
    private int defaultResolution;

    private bool isFullscreen;
    //private string temp;

    private string yes, no;


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

        if (provider.textLanguageCode == "en")
        {
            yes = "yes";
            no = "no";
        }
        else if (provider.textLanguageCode == "zh-Hans")
        {
            yes = "是";
            no = "否";
        }

        //settingSize = settingsText.Length;
        //temp = settingsText[currentSetting].text;
        //settings[currentSetting].text = settings[currentSetting].text.Insert(0, "- ");
        //settings[currentSetting].text += " -";
        //settingsText[currentSetting].text = settingsText[currentSetting].text.Insert(0, "<u>");
        //settingsText[currentSetting].text += "</u>";

        isFullscreen = Screen.fullScreen;
        if (Screen.fullScreen)
        {
            fullscreenOption.text = yes;
        }
        else
        {
            fullscreenOption.text = no;
        }

        resolutions = Screen.resolutions;
        for (int i = 0; i < resolutions.Length; i++)
        {
            string option = resolutions[i].width + " x " + resolutions[i].height;
            resolutionOptions.Add(option);

            if (resolutions[i].width == Screen.width &&
                resolutions[i].height == Screen.height)
            {
                currentOption = i;
            }
        }
        defaultResolution = currentOption;
        resolutionOption.text = resolutions[defaultResolution].width + " x " + resolutions[defaultResolution].height;
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
        if (GameIsPaused)
        {
            if (Input.anyKeyDown)
                Debug.Log("EventSystem.current.currentSelectedGameObject = " + EventSystem.current.currentSelectedGameObject);
            if (EventSystem.current.currentSelectedGameObject == resolutionSetting)
            {
                Debug.Log("SetResolution();");
                SetResolution();
            }
            else if (EventSystem.current.currentSelectedGameObject == fullscreenSetting)
            {
                Debug.Log("SetFullscreen();");
                SetFullscreen();
            }
        }
    }

    public void SetMusicVolume(float volume)
    {
        musicSlider.value = volume;
    }

    public void SetSFXolume(float volume)
    {
        SFXSlider.value = volume;
    }

    public void SetFullscreen()
    {
        if (Input.GetKeyDown(KeyCode.A) || Input.GetKeyDown(KeyCode.D))
        {
            UIAudio.Instance.PlayChangeSettings();
            isFullscreen = !isFullscreen;
        }

        if (isFullscreen)
        {
            fullscreenOption.text = yes;
        }
        else
        {
            fullscreenOption.text = no;
        }
    }

    public void SetResolution()
    {
        optionSize = resolutions.Length;
        ChangeOptions(resolutionOption, resolutionOptions);
    }
    public void SetDefault()
    {
        Resolution resolution = resolutions[defaultResolution];
        currentOption = defaultResolution;
        Screen.SetResolution(resolution.width, resolution.height, Screen.fullScreen);
        resolutionOption.text = resolutions[defaultResolution].width + " x " + resolutions[defaultResolution].height;

        Screen.fullScreen = true;
        fullscreenOption.text = yes;

        audioMixer.SetFloat("musicVolume", 0);
        musicSlider.value = 0;
        audioMixer.SetFloat("SFXVolume", 0);
        SFXSlider.value = 0;

        UIAudio.Instance.PlayHitButton();
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
    private void ChangeOptions(TMP_Text option, List<string> options)
    {

        if (Input.GetKeyDown(KeyCode.D))
        {
            UIAudio.Instance.PlayChangeSettings();
            currentOption = (currentOption + 1) % optionSize;
            option.text = options[currentOption];
        }
        if (Input.GetKeyDown(KeyCode.A))
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
    }
    //private void ChangeSettings()
    //{
    //    if (Input.GetKeyDown(KeyCode.S))
    //    {
    //        //settingsText[currentSetting].text = temp;

    //        currentSetting = (currentSetting + 1) % settingSize;

    //        //temp = settingsText[currentSetting].text;
    //        //settings[currentSetting].text = settings[currentSetting].text.Insert(0, "- ");
    //        //settings[currentSetting].text += " -";
    //        //settingsText[currentSetting].text = settingsText[currentSetting].text.Insert(0, "<u>");
    //        //settingsText[currentSetting].text += "</u>";
    //    }
    //    if (Input.GetKeyDown(KeyCode.W))
    //    {
    //        //settingsText[currentSetting].text = temp;

    //        if (currentSetting == 0)
    //        {
    //            currentSetting = settingSize - 1;
    //        }
    //        else
    //        {
    //            currentSetting = (Mathf.Abs(currentSetting - 1) % settingSize);
    //        }

    //        //temp = settingsText[currentSetting].text;
    //        //settings[currentSetting].text = settings[currentSetting].text.Insert(0, "- ");
    //        //settings[currentSetting].text += " -";
    //        //settingsText[currentSetting].text = settingsText[currentSetting].text.Insert(0, "<u>");
    //        //settingsText[currentSetting].text += "</u>";
    //    }
    //}
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
