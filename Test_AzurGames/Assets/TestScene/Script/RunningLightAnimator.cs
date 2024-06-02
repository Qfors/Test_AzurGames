using UnityEngine;

public class RunningLightAnimator : MonoBehaviour
{
    public Material runningLightMaterial;
    private Material instanceMaterial;
    private float randomOffset;
    private float randomLightSpeed;
    private float randomBrightLightSpeed;
    private float directionMultiplier;

    void Start()
    {
        // Создаем копию материала для каждого объекта
        instanceMaterial = new Material(runningLightMaterial);
        GetComponent<Renderer>().material = instanceMaterial;

        // Назначаем случайное смещение каждому объекту
        randomOffset = Random.Range(0f, 1f);
        instanceMaterial.SetFloat("_RandomOffset", randomOffset);

        // Назначаем случайную скорость огоньков каждому объекту
        randomLightSpeed = Random.Range(0.1f, 0.5f); // Диапазон скорости можно изменить по необходимости
        randomBrightLightSpeed = Random.Range(0.1f, 0.5f); // Диапазон скорости можно изменить по необходимости
        instanceMaterial.SetFloat("_LightSpeed", randomLightSpeed);
        instanceMaterial.SetFloat("_BrightLightSpeed", randomBrightLightSpeed);

        // Назначаем случайное направление каждому объекту
        directionMultiplier = Random.Range(0, 2) == 0 ? 1.0f : -1.0f;
        instanceMaterial.SetFloat("_DirectionMultiplier", directionMultiplier);
    }

    void Update()
    {
        float customTime = Time.time;
        instanceMaterial.SetFloat("_CustomTime", customTime);
    }
}
