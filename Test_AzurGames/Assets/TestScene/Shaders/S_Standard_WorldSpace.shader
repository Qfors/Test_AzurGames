Shader "Custom/S_Standard_WorldSpace"
{
    Properties
    {
        _Side("Side", 2D) = "white" {}
        _Top("Top", 2D) = "white" {}
        _Bottom("Bottom", 2D) = "white" {}
        _SideScale("Side Scale", Float) = 2
        _TopScale("Top Scale", Float) = 2
        _BottomScale("Bottom Scale", Float) = 2
        _BackgroundColor("Background Color", Color) = (1, 1, 1, 1)
        _TextureColor("Texture Color", Color) = (1, 1, 1, 1)
    }

    SubShader
    {
        Tags
        {
            "Queue" = "Geometry"
            "IgnoreProjector" = "False"
            "RenderType" = "Opaque"
        }

        Cull Back
        ZWrite On

        CGPROGRAM
        #pragma surface surf Lambert
        #pragma exclude_renderers flash

        sampler2D _Side, _Top, _Bottom;
        float _SideScale, _TopScale, _BottomScale;
        float4 _BackgroundColor;
        float4 _TextureColor;

        struct Input
        {
            float3 worldPos;
            float3 worldNormal;
        };

        void surf(Input IN, inout SurfaceOutput o)
        {
            float3 projNormal = saturate(pow(IN.worldNormal * 1.4, 4));

            // SIDE X
            float3 x = tex2D(_Side, frac(IN.worldPos.zy * _SideScale)) * abs(IN.worldNormal.x);
            if (x.x + x.y + x.z < 2.9)
                x = _TextureColor;
            else
                x = _BackgroundColor;

            // TOP / BOTTOM
            float3 y = 0;
            if (IN.worldNormal.y > 0)
            {
                y = tex2D(_Top, frac(IN.worldPos.zx * _TopScale)) * abs(IN.worldNormal.y);
                if (y.x + y.y + y.z < 2.9)
                    y = _TextureColor;
                else
                    y = _BackgroundColor;
            }
            else
            {
                y = tex2D(_Bottom, frac(IN.worldPos.zx * _BottomScale)) * abs(IN.worldNormal.y);
            }

            // SIDE Z	
            float3 z = tex2D(_Side, frac(IN.worldPos.xy * _SideScale)) * abs(IN.worldNormal.z);
            if (z.x + z.y + z.z < 2.9)
                z = _TextureColor;
            else
                z = _BackgroundColor;

            o.Albedo = z;
            o.Albedo = lerp(o.Albedo, x, projNormal.x);
            o.Albedo = lerp(o.Albedo, y, projNormal.y);
            // o.Albedo *= _BackgroundColor;
        }
        ENDCG
    }
    Fallback "Diffuse"
}