using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Bloom : PostEffectBase
{
    public Shader bloomShader;
    private Material bllomMat = null;
    public Material material
    {
        get
        {
            bllomMat = CreateMaterial(bloomShader, bllomMat);
            return bllomMat;
        }
    }

    [Range(0, 4)]
    public int iterations = 3;

    [Range(0.2f, 3f)]
    public float blurSpeed = 0.6f;

    // downSample越大，需要处理的像素数越少，模糊程度越大，性能也越好。但过大的downSample可能会使图像像素化。
    [Range(1, 8)]
    public int downSample = 2;

    [Range(0f, 4f)]
    public float luminanceThreshold = 0.6f;

    /// <summary>
    /// Version 3.
    /// Use iterations for large blur.
    /// </summary>
    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if (material != null)
        {
            int width = source.width / downSample;
            int height = source.height / downSample;

            RenderTexture buffer0 = RenderTexture.GetTemporary(width, height, 0);
            buffer0.filterMode = FilterMode.Bilinear;

            // render the vertical pass
            // 使用material中的shader中的第一个pass来提取图像中的较亮区域，存储在buffer0中。
            Graphics.Blit(source, buffer0, material, 0);

            // 高斯模糊
            for (int i = 0; i < iterations; ++i)
            {
                material.SetFloat("_BlurSize", 1f + i * blurSpeed);

                RenderTexture buffer1 = RenderTexture.GetTemporary(width, height, 0);

                // render the vertical pass
                Graphics.Blit(buffer0, buffer1, material, 1);
                buffer0 = buffer1;
                buffer1 = RenderTexture.GetTemporary(width, height, 0);

                // render the horizonal pass
                Graphics.Blit(buffer0, buffer1, material, 2);

                RenderTexture.ReleaseTemporary(buffer0);
                buffer0 = buffer1;
            }

            // 把高斯模糊得到的texture传给material
            material.SetTexture("_Bloom", buffer0);
            // 使用shader的第四个pass来进行混合，存在destination中。
            Graphics.Blit(source, destination, material, 3);

            RenderTexture.ReleaseTemporary(buffer0);
        }
        else
        {
            Graphics.Blit(source, destination);
        }
    }
}
