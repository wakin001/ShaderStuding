using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class GaussianBlurTargetTexture : MonoBehaviour
{
    private Camera camera;
    private RenderTexture screenCopyRT;

    //public Shader gaussBlurShader;
    //private Material gaussBlurMat = null;
    //public Material material
    //{
    //    get
    //    {
    //        gaussBlurMat = CreateMaterial(gaussBlurShader, gaussBlurMat);
    //        return gaussBlurMat;
    //    }
    //}

    [Range(0, 4)]
    public int iterations = 3;

    [Range(0.2f, 3f)]
    public float blurSpeed = 0.6f;

    // downSample越大，需要处理的像素数越少，模糊程度越大，性能也越好。但过大的downSample可能会使图像像素化。
    [Range(1, 8)]
    public int downSample = 2;



    private void OnEnable()
    {
        camera = GetComponent<Camera>();
        RenderTexture.ReleaseTemporary(screenCopyRT);
        screenCopyRT = RenderTexture.GetTemporary(camera.pixelWidth, camera.pixelHeight, 16);
        Shader.SetGlobalTexture("_GrabTempTex", screenCopyRT);
        camera.targetTexture = screenCopyRT;
    }
}
