Shader "Custom/ScreenNoiseShader"
{
    Properties
    {
        _MainTex ("Main Texture", 2D) = "white" {}
        _NoiseTex ("Noise Texture", 2D) = "white" {}
        _Distortion ("Distortion Amount", Range(0, 0.1)) = 0.05
        _NoiseAmount ("Noise Amount", Range(0, 1)) = 0.5
        _Speed ("Speed", Range(0, 10)) = 1.0
        _CustomTime ("Custom Time", Float) = 0.0
        _HorizontalSpeed ("Horizontal Speed", Range(0, 10)) = 1.0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
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
            sampler2D _NoiseTex;
            float _Distortion;
            float _NoiseAmount;
            float _Speed;
            float _CustomTime;
            float _HorizontalSpeed;

            v2f vert (appdata_t v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float2 uv = i.uv;

                // ??????????? ?????, ????? ???????? ??????? ????????
                float timeNormalized = frac(_CustomTime * _Speed);

                // ????????? ????????? ?????? ? ????
                float2 noiseUV = uv;
                noiseUV.x += timeNormalized * _HorizontalSpeed;
                noiseUV.y += timeNormalized * _Speed;

                // ????????? ??? ? ????????? UV
                float noise = tex2D(_NoiseTex, noiseUV).r;
                uv.y += noise * _Distortion;

                // ?????????? ???????? ????????
                fixed4 col = tex2D(_MainTex, uv);

                // ????????? ???
                float noiseValue = tex2D(_NoiseTex, noiseUV).r;
                col.rgb += noiseValue * _NoiseAmount;

                return col;
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}
