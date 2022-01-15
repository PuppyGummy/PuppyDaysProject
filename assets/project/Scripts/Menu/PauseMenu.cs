using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using DG.Tweening;

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
}
