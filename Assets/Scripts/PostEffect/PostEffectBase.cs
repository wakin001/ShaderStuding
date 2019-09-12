using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
[RequireComponent(typeof(Camera))]
public class PostEffectBase : MonoBehaviour
{
    // Start is called before the first frame update
    void Start()
    {
        CheckResources();
    }

    protected void CheckResources()
    {
        bool isSupported = CheckSupport();
        if (!isSupported)
        {
            NotSupported();
        }
    }

    protected bool CheckSupport()
    {
        if (!SystemInfo.supportsImageEffects || !SystemInfo.supportsRenderTextures)
        {
            Debug.LogWarning("This platform doesn't support image effects or render textures.");
            return false;
        }
        return true;
    }

    protected void NotSupported()
    {
        enabled = false;
    }

    protected Material CreateMaterial(Shader shader, Material material)
    {
        if (shader == null || !shader.isSupported)
        {
            return null;
        }
        if (material != null && material.shader == shader)
        {
            return material;
        }
        material = new Material(shader);
        if (material != null)
        {
            material.hideFlags = HideFlags.DontSave;
        }
        return material;
    }
}
