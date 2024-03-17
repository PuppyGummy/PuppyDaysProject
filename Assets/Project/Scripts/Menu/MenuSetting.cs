using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.EventSystems;
using UnityEngine.UI;
using UnityEngine.Events;
using TMPro;

public class MenuSetting : Selectable, ISubmitHandler
{
    public Image Lkey, Rkey;
    public TMP_Text options, text;
    public UnityEvent onSelected;
    public UnityEvent onSubmit;

    public override void OnSelect(BaseEventData eventData)
    {
        SetHighlight();
        if (onSelected != null)
            onSelected.Invoke();
    }

    public override void OnDeselect(BaseEventData eventData)
    {
        SetNormal();
    }

    public override void OnPointerEnter(PointerEventData eventData)
    {
        SetHighlight();
    }

    public override void OnPointerExit(PointerEventData eventData)
    {
        if (EventSystem.current.currentSelectedGameObject != this.gameObject)
        {
            SetNormal();
        }
    }

    public void SetHighlight()
    {
        if (Lkey != null && Rkey != null && options != null)
        {
            Lkey.color = Color.black;
            Rkey.color = Color.black;
            options.color = Color.black;
        }

        text.color = Color.black;
    }

    public void SetNormal()
    {
        if (Lkey != null && Rkey != null && options != null)
        {
            Lkey.color = new Color32(200, 200, 200, 255);
            Rkey.color = new Color32(200, 200, 200, 255);
            options.color = new Color32(200, 200, 200, 255);
        }

        text.color = new Color32(200, 200, 200, 255);
    }

    public void OnSubmit(BaseEventData eventData)
    {
        if (onSubmit != null)
            onSubmit.Invoke();
    }
}
