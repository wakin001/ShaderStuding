using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MotionBlur : PostEffectBase
{
    public Shader motionBlurShader;
    private Material motionBlurMat = null;
    public Material material
    {
        get
        {
            motionBlurMat = CreateMaterial(motionBlurShader, motionBlurMat);
            return motionBlurMat;
        }
    }

    [Range(0.0f, 1f)]
    public float blurAmount = 0.5f;

    // 保存之前图像叠加的结果
    private RenderTexture accumulationTexture;

    private void OnDisable()
    {
        DestroyImmediate(accumulationTexture);
    }

    /// <summary>
    /// Version 3.
    /// Use iterations for large blur.
    /// </summary>
    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if (material != null)
        {
            if (accumulationTexture == null ||
                accumulationTexture.width != source.width ||
                accumulationTexture.height != source.height)
            {
                DestroyImmediate(accumulationTexture);

                accumulationTexture = new RenderTexture(source.width, source.height, 0);
                // 表示这个变量不会显示在Hierarchy中, 也不会保存到场景中
                accumulationTexture.hideFlags = HideFlags.HideAndDontSave;
                Graphics.Blit(source, accumulationTexture);
            }

            // We are accumulating motion over frames without clear/discard by design, so silence any performance warnings from Unity
            // 表明需要进行一个渲染纹理的恢复操作（restore operation）。恢复操作发生在渲染到纹理而该纹理又没有被提前清空或销毁的情况下。
            accumulationTexture.MarkRestoreExpected();

            material.SetFloat("_BlurAmount", 1f - blurAmount);


            Graphics.Blit(source, accumulationTexture, material);
            Graphics.Blit(accumulationTexture, destination);
        }
        else
        {
            Graphics.Blit(source, destination);
        }
    }
}
