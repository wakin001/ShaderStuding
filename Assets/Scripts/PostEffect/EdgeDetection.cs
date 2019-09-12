using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class EdgeDetection : PostEffectBase
{
    public Shader edgeDetectShader;
    private Material edgeDetectMat = null;
    public Material material
    {
        get
        {
            edgeDetectMat = CreateMaterial(edgeDetectShader, edgeDetectMat);
            return edgeDetectMat;
        }
    }

    [Range(0f, 1f)]
    public float edgesOnly = 0f;
    public Color edgeColor = Color.black;
    public Color backgroundColor = Color.white;

    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if (material != null)
        {
            material.SetFloat("_EdgeOnly", edgesOnly);
            material.SetColor("_EdgeColor", edgeColor);
            material.SetColor("_BackgroundColor", backgroundColor);

            Graphics.Blit(source, destination, material);
        }
        else
        {
            Graphics.Blit(source, destination);
        }
    }
}
