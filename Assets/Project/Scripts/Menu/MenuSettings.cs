using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Audio;
using UnityEngine.UI;
using TMPro;
using Yarn.Unity;
using UnityEngine.EventSystems;
using UnityEngine.Localization;
using UnityEngine.Localization.Settings;

public class MenuSettings : MonoBehaviour
{
    public AudioMixer audioMixer;
    public LineView lineView;
    public TMP_Text resolutionOption;
    public TMP_Text fullscreenOption;
    public TMP_Text languageOption;
    public MenuSetting resolutionSetting;
    public MenuSetting fullscreenSetting;
    public MenuSetting languageSetting;
    public MenuSetting speedSetting;
    public MenuSetting sfxSetting;
    public MenuSetting bgmSetting;

    public Slider musicSlider;
    public Slider SFXSlider;
    public Slider speedSlider;
    public TextLineProvider provider;
    public MenuSetting firstSelected;

    Resolution[] resolutions;

    private List<string> resolutionOptions = new List<string>();

    private int optionSize;
    private int currentOption;
    private int defaultResolution;

    private bool isFullscreen;
    private bool isEnglish;

    // Start is called before the first frame update
    private void Start()
    {
        EventSystem.current.SetSelectedGameObject(null);
        EventSystem.current.SetSelectedGameObject(firstSelected.gameObject);

        // firstSelected.SetHighlight();

        isFullscreen = Screen.fullScreen;
        if (Screen.fullScreen)
        {
            fullscreenOption.text = LocalizationSettings.StringDatabase.GetLocalizedString("UI text", "Key_Yes");
        }
        else
        {
            fullscreenOption.text = LocalizationSettings.StringDatabase.GetLocalizedString("UI text", "Key_No");
        }

        if(LocalizationSettings.SelectedLocale.Equals(LocalizationSettings.AvailableLocales.GetLocale("en")))
        {
            languageOption.text = "English";
        }
        else if (LocalizationSettings.SelectedLocale.Equals(LocalizationSettings.AvailableLocales.GetLocale("zh-Hans")))
        {
            languageOption.text = "简体中文";
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
        if (EventSystem.current.currentSelectedGameObject == resolutionSetting.gameObject)
        {
            if (Input.GetKeyDown(KeyCode.A))
            {
                SetPreviousResolution();
            }
            if (Input.GetKeyDown(KeyCode.D))
            {
                SetNextResolution();
            }
        }
        else if (EventSystem.current.currentSelectedGameObject == fullscreenSetting.gameObject)
        {
            if (Input.GetKeyDown(KeyCode.A) || Input.GetKeyDown(KeyCode.D))
            {
                SetFullscreen();
            }
        }
        else if (EventSystem.current.currentSelectedGameObject == languageSetting.gameObject)
        {
            if (Input.GetKeyDown(KeyCode.A) || Input.GetKeyDown(KeyCode.D))
            {
                SetLanguage();
            }
        }
        else if (EventSystem.current.currentSelectedGameObject == speedSlider.gameObject)
        {
            speedSetting.SetHighlight();
        }
        else if (EventSystem.current.currentSelectedGameObject == SFXSlider.gameObject)
        {
            sfxSetting.SetHighlight();
        }
        else if (EventSystem.current.currentSelectedGameObject == musicSlider.gameObject)
        {
            bgmSetting.SetHighlight();
        }

        if (EventSystem.current.currentSelectedGameObject != speedSlider.gameObject)
        {
            speedSetting.SetNormal();
        }
        if (EventSystem.current.currentSelectedGameObject != SFXSlider.gameObject)
        {
            sfxSetting.SetNormal();
        }
        if (EventSystem.current.currentSelectedGameObject != musicSlider.gameObject)
        {
            bgmSetting.SetNormal();
        }
        
    }

    public void SetMusicVolume(float volume)
    {
        musicSlider.value = volume;
    }

    public void SetSFXVolume(float volume)
    {
        SFXSlider.value = volume;
    }

    public void SetTextSpeed(float speed)
    {
        speedSlider.value = speed;
    }

    public void SetFullscreen()
    {
        UIAudio.Instance.PlayChangeSettings();
        isFullscreen = !isFullscreen;

        if (isFullscreen)
        {
            fullscreenOption.text = LocalizationSettings.StringDatabase.GetLocalizedString("UI text", "Key_Yes");
        }
        else
        {
            fullscreenOption.text = LocalizationSettings.StringDatabase.GetLocalizedString("UI text", "Key_No");
        }
    }

    public void SetLanguage()
    {
        UIAudio.Instance.PlayChangeSettings();
        isEnglish = !isEnglish;

        if (isEnglish)
        {
            languageOption.text = "English";
            provider.textLanguageCode = "en";
            LocalizationSettings.SelectedLocale = LocalizationSettings.AvailableLocales.GetLocale("en");
        }
        else
        {
            languageOption.text = "简体中文";
            provider.textLanguageCode = "zh-Hans";
            LocalizationSettings.SelectedLocale = LocalizationSettings.AvailableLocales.GetLocale("zh-Hans");
        }
    }

    public void SetPreviousResolution()
    {
        optionSize = resolutions.Length;
        PreviousOption(resolutionOption, resolutionOptions);
    }
    public void SetNextResolution()
    {
        optionSize = resolutions.Length;
        NextOption(resolutionOption, resolutionOptions);
    }
    public void SetDefault()
    {
        Resolution resolution = resolutions[defaultResolution];
        currentOption = defaultResolution;
        Screen.SetResolution(resolution.width, resolution.height, Screen.fullScreen);
        resolutionOption.text = resolutions[defaultResolution].width + " x " + resolutions[defaultResolution].height;

        languageOption.text = "English";
        provider.textLanguageCode = "en";
        LocalizationSettings.SelectedLocale = LocalizationSettings.AvailableLocales.GetLocale("en");

        Screen.fullScreen = true;
        fullscreenOption.text = LocalizationSettings.StringDatabase.GetLocalizedString("UI text", "Key_Yes");

        audioMixer.SetFloat("musicVolume", 0);
        musicSlider.value = 0;
        audioMixer.SetFloat("SFXVolume", 0);
        SFXSlider.value = 0;
        lineView.typewriterEffectSpeed = 20;
        speedSlider.value = 20;

        UIAudio.Instance.PlayHitButton();
    }
    public void ApplyChanges()
    {
        //set music and sfx volume
        audioMixer.SetFloat("musicVolume", musicSlider.value);
        audioMixer.SetFloat("SFXVolume", SFXSlider.value);

        //set text speed
        lineView.typewriterEffectSpeed = speedSlider.value;

        //set resolution
        Resolution resolution = resolutions[currentOption];
        Screen.SetResolution(resolution.width, resolution.height, Screen.fullScreen);

        //set fullscreen
        //NOTICE: changing the order of the line above and the line below will
        //disable the function of fullscreen
        //cuz setting the resolution will also set the fullscreen mode
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

    public void SaveAndQuit()
    {
        UIAudio.Instance.PlayHitButton();

        Application.Quit();
    }
}
