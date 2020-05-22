using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class GPUInstanceTest : MonoBehaviour
{
    public GameObject box_prefab;
    public GameObject capsule_prefab;
    public int instanceCount = 1000;

    private List<GameObject> goList = new List<GameObject>();
    private float posRange = 20f;

    public void CreateBoxes()
    {
        goList.Capacity = instanceCount;
        for (int i = 0; i < instanceCount; ++i)
        {
            GameObject go = Instantiate(box_prefab);
            go.transform.position = new Vector3(Random.Range(-posRange, posRange), Random.Range(-posRange, posRange), Random.Range(-posRange, posRange));
            goList.Add(go);
        }
    }

    public void CreateCapsules()
    {
        goList.Capacity = instanceCount;
        for (int i = 0; i < instanceCount; ++i)
        {
            GameObject go = Instantiate(capsule_prefab);
            go.transform.position = new Vector3(Random.Range(-posRange, posRange), Random.Range(-posRange, posRange), Random.Range(-posRange, posRange));
            goList.Add(go);
        }
    }

    public void ClearAll()
    {
        for (int i = 0; i < goList.Count; ++i)
        {
            Destroy(goList[i]);
        }
        goList.Clear();
    }
}
