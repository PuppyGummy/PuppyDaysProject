using UnityEngine;
using UnityEngine.SceneManagement;
using UnityEngine.UI;
using DG.Tweening;

public class LoadLevel : SceneAction
{
    public int levelNumber;
    public string levelName;

    public Image fader;
    public bool useIntegerToLoadLevel = false;

    public override void Interact()
    {
        FadeIn();
    }

    private void Start()
    {
        fader.gameObject.SetActive(true);

        fader.DOFade(0, 1f).From(1).OnStepComplete(() =>
            {
                fader.gameObject.SetActive(false);
            });
    }


    void LoadScene()
    {
        if (useIntegerToLoadLevel)
        {
            SceneManager.LoadScene(levelNumber);
        }
        else
        {
            SceneManager.LoadScene(levelName);
        }
    }

    public void FadeIn()
    {
        fader.gameObject.SetActive(true);

        fader.DOFade(1, 0.5f).From(0).OnStepComplete(() =>
        {
            Invoke("LoadScene", 0.5f);
        });

    }
}