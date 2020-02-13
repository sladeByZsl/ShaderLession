﻿Shader "Custom/FlatShadow"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0

		_Stencil("Stencil", float) = 2
		_ShadowColor("ShadowColor",Color) = (0,0,0,0)
		_Plane("Plane", vector) = (0,1,0,0)
		_LightDir("LightDir", vector) = (1,1,1,1)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Standard noshadow

        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0

        sampler2D _MainTex;

        struct Input
        {
            float2 uv_MainTex;
        };

        half _Glossiness;
        half _Metallic;
        fixed4 _Color;

        // Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
        // See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
        // #pragma instancing_options assumeuniformscaling
        UNITY_INSTANCING_BUFFER_START(Props)
            // put more per-instance properties here
        UNITY_INSTANCING_BUFFER_END(Props)

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            // Albedo comes from a texture tinted by color
            fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
            o.Albedo = c.rgb;
            // Metallic and smoothness come from slider variables
            o.Metallic = _Metallic;
            o.Smoothness = _Glossiness;
            o.Alpha = c.a;
        }
        ENDCG

		pass 
		{
			Stencil
			{
				Ref[_Stencil]
				Comp NotEqual
				Pass replace
			}
			ZWrite off
			Blend srcalpha oneminussrcalpha
			Offset -1,-1
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			struct appdata 
			{
				float4 vertex:POSITION;
			};

			struct v2f
			{
				float4 pos:POSITION;
			};

			fixed4 _ShadowColor;
			half4 _Plane;
			half4 _LightDir;

			v2f vert(appdata v) 
			{
				v2f o;
				float4 worldPos = mul(unity_ObjectToWorld, v.vertex);
				float t =  (_Plane.w - dot(worldPos.xyz, _Plane.xyz))/ dot(_LightDir.xyz, _Plane.xyz);
				worldPos.xyz = worldPos.xyz + t * _LightDir.xyz;
				o.pos = mul(unity_MatrixVP, worldPos);
				return o;
			}

			fixed4 frag(v2f i) : SV_Target
			{
				return _ShadowColor;
			}
			ENDCG
		}
    }
    FallBack "Diffuse"
}
