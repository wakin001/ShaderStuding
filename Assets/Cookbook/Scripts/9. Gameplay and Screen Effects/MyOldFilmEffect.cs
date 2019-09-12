﻿using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class MyOldFilmEffect : MonoBehaviour
{
    #region Variables

    public Shader oldFilmShader;

    public float OldFilmEffectAmount = 1.0f;
    public float contrast = 3.0f;
    public float distortion = 0.2f;
    public float cubicDistortion = 0.6f;
    public float scale = 0.8f;

    public Color sepiaColor = Color.white;
    public Texture2D vignetteTexture;
    public float vignetteAmount = 1.0f;

    public Texture2D scratchesTexture;
    public float scratchesYSpeed = 10f;
    public float scratchesXSpeed = 10f;

    public Texture2D dustTexture;
    public float dustYSpeed = 10f;
    public float dustXSpeed = 10f;


    private Material curMaterial;
    private float randomValue;


    #endregion

    #region Properties

    Material material
    {
        get
        {
            if (curMaterial == null)
            {
                curMaterial = new Material(oldFilmShader);
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
        if (!oldFilmShader && !oldFilmShader.isSupported)
        {
            enabled = false;
            return;
        }
    }

    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if (oldFilmShader != null)
        {
            material.SetColor("_SepiaColor", sepiaColor);
            material.SetFloat("_VignetteAmount", vignetteAmount);
            material.SetFloat("_EffectAmount", OldFilmEffectAmount);
            material.SetFloat("_Contrast", contrast);
            material.SetFloat("_cubicDistortion", cubicDistortion);
            material.SetFloat("_distortion", distortion);
            material.SetFloat("_scale", scale);

            if (vignetteTexture)
            {
                material.SetTexture("_VignetteTex", vignetteTexture);
            }

            if (scratchesTexture)
            {
                material.SetTexture("_ScratchesTex", scratchesTexture);
                material.SetFloat("_ScratchesYSpeed", scratchesYSpeed);
                material.SetFloat("_ScratchesXSpeed", scratchesXSpeed);
            }

            if (dustTexture)
            {
                material.SetTexture("_DustTex", dustTexture);
                material.SetFloat("_dustYSpeed", dustYSpeed);
                material.SetFloat("_dustXSpeed", dustXSpeed);
                material.SetFloat("_RandomValue", randomValue);
            }
            Graphics.Blit(source, destination, material);
        }
        else
        {
            Graphics.Blit(source, destination);
        }
    }

    private void Update()
    {
        vignetteAmount = Mathf.Clamp01(vignetteAmount);
        OldFilmEffectAmount = Mathf.Clamp(OldFilmEffectAmount, 0f, 1.5f);
        randomValue = Random.Range(-1f, 1f);
        contrast = Mathf.Clamp(contrast, 0f, 4f);
        distortion = Mathf.Clamp(distortion, -1f, 1f);
        cubicDistortion = Mathf.Clamp(cubicDistortion, -1f, 1f);
        scale = Mathf.Clamp(scale, 0f, 1f);
    }

    private void OnDisable()
    {
        if (curMaterial)
        {
            DestroyImmediate(curMaterial);
        }
    }
}
