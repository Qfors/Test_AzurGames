Shader "Azur/ToonyRim"
{
    Properties
    {
        //TOONY COLORS
        _Color("Color", Color) = (1,1,1,1)
        _HColor("Highlight Color", Color) = (0.785,0.785,0.785,1.0)
        _SColor("Shadow Color", Color) = (0.195,0.195,0.195,1.0)

        //DIFFUSE
        _MainTex("Main Texture (RGB) Spec/MatCap Mask (A) ", 2D) = "white" {}

        //TOONY COLORS RAMP
        _RampThreshold("Ramp Threshold", Range(0,1)) = 0.5
        _RampSmooth("Ramp Smoothing", Range(0.01,1)) = 0.1

        //RIM LIGHT
        _RimColor("Rim Color", Color) = (0.8,0.8,0.8,0.6)
        _RimMin("Rim Min", Range(0,1)) = 0.5
        _RimMax("Rim Max", Range(0,1)) = 1.0
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        CGPROGRAM
        #pragma surface surf ToonyColor nodirlightmap vertex:vert noforwardadd halfasview
        #pragma target 2.0

        fixed4 _Color;

        //Highlight/Shadow Colors
        fixed4 _HColor;
        fixed4 _SColor;

        sampler2D _MainTex;

        //Lighting Ramp
        sampler2D _Ramp;

        fixed4 _RimColor;
        fixed _RimMin;
        fixed _RimMax;

        float _RampThreshold;
        float _RampSmooth;

        struct Input
        {
            half2 uv_MainTex : TEXCOORD0;
            fixed rim;
        };

        void vert(inout appdata_full v, out Input o)
        {
            UNITY_INITIALIZE_OUTPUT(Input, o);

            float3 viewDir = normalize(ObjSpaceViewDir(v.vertex));

            half rim = 1.0f - saturate(dot(viewDir, v.normal));
            o.rim = smoothstep(_RimMin, _RimMax, rim) * _RimColor.a;
        }

        void surf(Input IN, inout SurfaceOutput o)
        {
            half4 main = tex2D(_MainTex, IN.uv_MainTex);
            o.Albedo = main.rgb * _Color.rgb;
            o.Alpha = main.a * _Color.a;

            o.Emission += IN.rim * _RimColor.rgb;
        }

        inline half4 LightingToonyColor(SurfaceOutput s, half3 lightDir, half atten)
        {
            fixed ndl = max(0, dot(s.Normal, lightDir) * 0.5 + 0.5);
            fixed3 ramp = smoothstep(_RampThreshold - _RampSmooth * 0.5, _RampThreshold + _RampSmooth * 0.5, ndl);
            _SColor = lerp(_HColor, _SColor, _SColor.a);
            ramp = lerp(_SColor.rgb, _HColor.rgb, ramp);
            fixed4 c;
            c.rgb = s.Albedo * _LightColor0.rgb * ramp;
            c.a = s.Alpha;
            return c;
        }

        ENDCG
    }
    FallBack "Diffuse"
}
