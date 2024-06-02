using UnityEngine;

public class ScreenNoiseAnimator : MonoBehaviour
{
    public Material material;

    void Update()
    {
        if (material != null)
        {
            material.SetFloat("_CustomTime", Time.time);
        }
    }
}
