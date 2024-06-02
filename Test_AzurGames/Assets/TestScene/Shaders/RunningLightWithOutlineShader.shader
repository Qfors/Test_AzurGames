Shader "Custom/RunningLightWithOutlineShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _OutlineColor ("Outline Color", Color) = (0,0,0,1)
        _OutlineWidth ("Outline Width", Range(0.0, 0.03)) = 0.005
        _LightColor ("Light Color", Color) = (1,1,1,1)
        _BrightLightColor ("Bright Light Color", Color) = (1,1,0,1)
        _LightSpeed ("Light Speed", Range(0,10)) = 1.0
        _LightWidth ("Light Width", Range(0,1)) = 0.1
        _BrightLightSpeed ("Bright Light Speed", Range(0,10)) = 1.0
        _BrightLightWidth ("Bright Light Width", Range(0,1)) = 0.05
        _CustomTime ("Custom Time", Float) = 0.0
        _RandomOffset ("Random Offset", Float) = 0.0
        _DirectionMultiplier ("Direction Multiplier", Float) = 1.0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        // Первый проход - контур
        Pass
        {
            Name "Outline"
            Tags { "LightMode"="Always" }
            Cull Front
            ZWrite On
            ZTest LEqual
            ColorMask RGB
            Blend SrcAlpha OneMinusSrcAlpha

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            struct appdata_t
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float4 pos : POSITION;
                float4 color : COLOR;
            };

            float _OutlineWidth;
            float4 _OutlineColor;

            v2f vert(appdata_t v)
            {
                // Расширение вершин вдоль нормалей для создания контура
                v2f o;
                float3 norm = mul((float3x3) unity_ObjectToWorld, v.normal);
                o.pos = UnityObjectToClipPos(v.vertex + norm * _OutlineWidth);
                o.color = _OutlineColor;
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                return i.color;
            }
            ENDCG
        }

        // Второй проход - основной объект с бегущим огоньком
        Pass
        {
            Name "MainPass"
            Tags { "LightMode"="ForwardBase" }
            Cull Back
            ZWrite On
            ZTest LEqual
            ColorMask RGB

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            struct appdata_t
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float4 _LightColor;
            float4 _BrightLightColor;
            float _LightSpeed;
            float _LightWidth;
            float _BrightLightSpeed;
            float _BrightLightWidth;
            float _CustomTime;
            float _RandomOffset;
            float _DirectionMultiplier;

            v2f vert(appdata_t v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                float2 uv = i.uv;
                float mainLightPos = frac((_CustomTime + _RandomOffset) * _LightSpeed * _DirectionMultiplier);
                float brightLightPos = frac((_CustomTime + _RandomOffset) * _BrightLightSpeed * _DirectionMultiplier);

                float mainLightDistance = abs(uv.x - mainLightPos);
                float mainLightEffect = smoothstep(_LightWidth, 0.0, mainLightDistance);

                float brightLightDistance = abs(uv.x - brightLightPos);
                float brightLightEffect = smoothstep(_BrightLightWidth, 0.0, brightLightDistance);

                half4 col = tex2D(_MainTex, uv);
                col.rgb = lerp(col.rgb, _LightColor.rgb, mainLightEffect);
                col.rgb = lerp(col.rgb, _BrightLightColor.rgb, brightLightEffect);
                return col;
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}
