using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.EventSystems;
using UnityEngine.UI;
using UnityEngine.Events;
using TMPro;

public class MenuSetting : Selectable, ISubmitHandler
{
    // public Image Lkey, Rkey;
    // public TMP_Text options, text;
    // public Slider volume;
    // public UnityEvent onSelected;
    public UnityEvent onSubmit;

    // public override void OnSelect(BaseEventData eventData)
    // {
    //     if (Lkey != null && Rkey != null && options != null)
    //     {
    //         Lkey.color = Color.black;
    //         Rkey.color = Color.black;
    //         options.color = Color.black;
    //     }
    //     if (volume != null)
    //     {
    //         volume.Select();
    //     }
    //     text.color = Color.black;

    //     if (onSelected != null)
    //         onSelected.Invoke();

    //     // text.fontStyle = FontStyles.Underline;
    // }

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

        // text.fontStyle ^= FontStyles.Underline;
    }

    public override void OnPointerEnter(PointerEventData eventData)
    {
        if (Lkey != null && Rkey != null && options != null)
        {
            Lkey.color = Color.black;
            Rkey.color = Color.black;
            options.color = Color.black;
        }
        text.color = Color.black;

        // text.fontStyle |= FontStyles.Underline;
    }

    public override void OnPointerExit(PointerEventData eventData)
    {
        if (Lkey != null && Rkey != null && options != null)
        {
            Lkey.color = Color.grey;
            Rkey.color = Color.grey;
            options.color = Color.grey;
        }
        text.color = Color.grey;

        // text.fontStyle ^= FontStyles.Underline;
    }

    public void OnSubmit(BaseEventData eventData)
    {
        if (onSubmit != null)
            onSubmit.Invoke();
    }
}
