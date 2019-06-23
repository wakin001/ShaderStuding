using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class BSCImageEffect : MonoBehaviour
{
    #region Variables

    public Shader curShader;
    private Material curMaterial;

    public float brightnessAmount = 1.0f;
    public float saturationAmount = 1.0f;
    public float contrastAmount = 1.0f;

    #endregion

    #region Properties

    Material material
    {
        get
        {
            if (curMaterial == null)
            {
                curMaterial = new Material(curShader);
                curMaterial.hideFlags = HideFlags.HideAndDontSave;
            }
            return curMaterial;
        }
    }

    #endregion

    // Start is called before the first frame update
    void Start()
    {
        if (!SystemInfo.supportsImageEffects)
        {
            enabled = false;
            return;
        }
        if (!curShader && !curShader.isSupported)
        {
            enabled = false;
            return;
        }
    }

    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if (curShader != null)
        {
            material.SetFloat("_BrightnessAmount", brightnessAmount);
            material.SetFloat("_satAmount", saturationAmount);
            material.SetFloat("_conAmount", contrastAmount);
            Graphics.Blit(source, destination, material);
        }
        else
        {
            Graphics.Blit(source, destination);
        }
    }

    private void Update()
    {
        brightnessAmount = Mathf.Clamp(brightnessAmount, 0f, 2f);
        saturationAmount = Mathf.Clamp(saturationAmount, 0f, 2f);
        contrastAmount = Mathf.Clamp(contrastAmount, 0f, 2f);
    }

    private void OnDisable()
    {
        if (curMaterial)
        {
            DestroyImmediate(curMaterial);
        }
    }
}
