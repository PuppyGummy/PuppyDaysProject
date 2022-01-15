using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.EventSystems;
using UnityEngine.UI;
using UnityEngine.Events;

public class MenuSetting : Selectable, ISubmitHandler
{
    public Image Lkey, Rkey;
    public TMPro.TMP_Text options, text;
    public Slider volume;
    public UnityEvent onSubmit;
    private string temp;

    protected override void Awake()
    {
        temp = text.text;
    }

    public override void OnSelect(BaseEventData eventData)
    {
        if (Lkey != null && Rkey != null && options != null)
        {
            Lkey.color = Color.black;
            Rkey.color = Color.black;
            options.color = Color.black;
        }
        if (volume != null)
        {
            volume.Select();
        }
        text.color = Color.black;

        text.fonts
    }

    public override void OnDeselect(BaseEventData eventData)
    {
        if (Lkey != null && Rkey != null && options != null)
        {
            Lkey.color = Color.grey;
            Rkey.color = Color.grey;
            options.color = Color.grey;
        }
        if (volume != null)
        {
            // volume.
        }
        text.color = Color.grey;

        text.text = temp;
    }

    public void OnSubmit(BaseEventData eventData)
    {
        onSubmit.Invoke();
    }
}
