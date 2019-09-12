using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class GaussianBlur : PostEffectBase
{
    public Shader gaussBlurShader;
    private Material gaussBlurMat = null;
    public Material material
    {
        get
        {
            gaussBlurMat = CreateMaterial(gaussBlurShader, gaussBlurMat);
            return gaussBlurMat;
        }
    }

    [Range(0, 4)]
    public int iterations = 3;

    [Range(0.2f, 3f)]
    public float blurSpeed = 0.6f;

    // downSample越大，需要处理的像素数越少，模糊程度越大，性能也越好。但过大的downSample可能会使图像像素化。
    [Range(1, 8)]
    public int downSample = 2;


    //private void OnRenderImage(RenderTexture source, RenderTexture destination)
    //{
    //    if (material != null)
    //    {
    //        RenderTexture buffer = RenderTexture.GetTemporary(source.width, source.height, 0);

    //        // render the vertical pass
    //        Graphics.Blit(source, buffer, material, 0);

    //        // render the horizonal pass
    //        Graphics.Blit(buffer, destination, material, 1);

    //        RenderTexture.ReleaseTemporary(buffer);
    //    }
    //    else
    //    {
    //        Graphics.Blit(source, destination);
    //    }
    //}

    /// <summary>
    /// Version 2.
    /// Scale the render texture.
    /// </summary>
    //private void OnRenderImage(RenderTexture source, RenderTexture destination)
    //{
    //    if (material != null)
    //    {
    //        RenderTexture buffer = RenderTexture.GetTemporary(source.width / downSample, source.height / downSample, 0);
    //        buffer.filterMode = FilterMode.Bilinear;

    //        // render the vertical pass
    //        Graphics.Blit(source, buffer, material, 0);

    //        // render the horizonal pass
    //        Graphics.Blit(buffer, destination, material, 1);

    //        RenderTexture.ReleaseTemporary(buffer);
    //    }
    //    else
    //    {
    //        Graphics.Blit(source, destination);
    //    }
    //}


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
            Graphics.Blit(source, buffer0);

            for (int i = 0; i < iterations; ++i)
            {
                material.SetFloat("_BlurSize", 1f + i * blurSpeed);

                RenderTexture buffer1 = RenderTexture.GetTemporary(width, height, 0);

                // render the vertical pass
                Graphics.Blit(buffer0, buffer1, material, 0);
                buffer0 = buffer1;
                buffer1 = RenderTexture.GetTemporary(width, height, 0);

                // render the horizonal pass
                Graphics.Blit(buffer0, buffer1, material, 1);

                RenderTexture.ReleaseTemporary(buffer0);
                buffer0 = buffer1;
            }

            Graphics.Blit(buffer0, destination);
            RenderTexture.ReleaseTemporary(buffer0);
        }
        else
        {
            Graphics.Blit(source, destination);
        }
    }
}
