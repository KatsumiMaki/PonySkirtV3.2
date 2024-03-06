// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "aaa"
{
	Properties
	{
		_Color0("Color 0", Color) = (0.9339623,0.3127893,0.7708302,0)
		_Alpha("Alpha", Range( 0 , 3)) = 0
		[HideInInspector]_TextureSample0("Texture Sample 0", 2D) = "black" {}
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "Transparent+0" "IgnoreProjector" = "True" "IsEmissive" = "true"  }
		Cull Back
		CGINCLUDE
		#include "UnityShaderVariables.cginc"
		#include "UnityPBSLighting.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		#ifdef UNITY_PASS_SHADOWCASTER
			#undef INTERNAL_DATA
			#undef WorldReflectionVector
			#undef WorldNormalVector
			#define INTERNAL_DATA half3 internalSurfaceTtoW0; half3 internalSurfaceTtoW1; half3 internalSurfaceTtoW2;
			#define WorldReflectionVector(data,normal) reflect (data.worldRefl, half3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal)))
			#define WorldNormalVector(data,normal) half3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal))
		#endif
		#undef TRANSFORM_TEX
		#define TRANSFORM_TEX(tex,name) float4(tex.xy * name##_ST.xy + name##_ST.zw, tex.z, tex.w)
		struct Input
		{
			float3 worldPos;
			float3 worldNormal;
			INTERNAL_DATA
			float3 uv_texcoord;
		};

		uniform float4 _Color0;
		uniform sampler2D _TextureSample0;
		uniform float _Alpha;


		float3 PerturbNormal107_g10( float3 surf_pos, float3 surf_norm, float height, float scale )
		{
			// "Bump Mapping Unparametrized Surfaces on the GPU" by Morten S. Mikkelsen
			float3 vSigmaS = ddx( surf_pos );
			float3 vSigmaT = ddy( surf_pos );
			float3 vN = surf_norm;
			float3 vR1 = cross( vSigmaT , vN );
			float3 vR2 = cross( vN , vSigmaS );
			float fDet = dot( vSigmaS , vR1 );
			float dBs = ddx( height );
			float dBt = ddy( height );
			float3 vSurfGrad = scale * 0.05 * sign( fDet ) * ( dBs * vR1 + dBt * vR2 );
			return normalize ( abs( fDet ) * vN - vSurfGrad );
		}


		float4 CalculateContrast( float contrastValue, float4 colorTarget )
		{
			float t = 0.5 * ( 1.0 - contrastValue );
			return mul( float4x4( contrastValue,0,0,t, 0,contrastValue,0,t, 0,0,contrastValue,t, 0,0,0,1 ), colorTarget );
		}

		float3 mod2D289( float3 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }

		float2 mod2D289( float2 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }

		float3 permute( float3 x ) { return mod2D289( ( ( x * 34.0 ) + 1.0 ) * x ); }

		float snoise( float2 v )
		{
			const float4 C = float4( 0.211324865405187, 0.366025403784439, -0.577350269189626, 0.024390243902439 );
			float2 i = floor( v + dot( v, C.yy ) );
			float2 x0 = v - i + dot( i, C.xx );
			float2 i1;
			i1 = ( x0.x > x0.y ) ? float2( 1.0, 0.0 ) : float2( 0.0, 1.0 );
			float4 x12 = x0.xyxy + C.xxzz;
			x12.xy -= i1;
			i = mod2D289( i );
			float3 p = permute( permute( i.y + float3( 0.0, i1.y, 1.0 ) ) + i.x + float3( 0.0, i1.x, 1.0 ) );
			float3 m = max( 0.5 - float3( dot( x0, x0 ), dot( x12.xy, x12.xy ), dot( x12.zw, x12.zw ) ), 0.0 );
			m = m * m;
			m = m * m;
			float3 x = 2.0 * frac( p * C.www ) - 1.0;
			float3 h = abs( x ) - 0.5;
			float3 ox = floor( x + 0.5 );
			float3 a0 = x - ox;
			m *= 1.79284291400159 - 0.85373472095314 * ( a0 * a0 + h * h );
			float3 g;
			g.x = a0.x * x0.x + h.x * x0.y;
			g.yz = a0.yz * x12.xz + h.yz * x12.yw;
			return 130.0 * dot( m, g );
		}


		float3 PerturbNormal107_g9( float3 surf_pos, float3 surf_norm, float height, float scale )
		{
			// "Bump Mapping Unparametrized Surfaces on the GPU" by Morten S. Mikkelsen
			float3 vSigmaS = ddx( surf_pos );
			float3 vSigmaT = ddy( surf_pos );
			float3 vN = surf_norm;
			float3 vR1 = cross( vSigmaT , vN );
			float3 vR2 = cross( vN , vSigmaS );
			float fDet = dot( vSigmaS , vR1 );
			float dBs = ddx( height );
			float dBt = ddy( height );
			float3 vSurfGrad = scale * 0.05 * sign( fDet ) * ( dBs * vR1 + dBt * vR2 );
			return normalize ( abs( fDet ) * vN - vSurfGrad );
		}


		inline half4 LightingUnlit( SurfaceOutput s, half3 lightDir, half atten )
		{
			return half4 ( 0, 0, 0, s.Alpha );
		}

		void surf( Input i , inout SurfaceOutput o )
		{
			o.Normal = float3(0,0,1);
			float3 ase_worldPos = i.worldPos;
			float3 ase_worldViewDir = normalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float3 surf_pos107_g10 = ase_worldPos;
			float3 ase_worldNormal = WorldNormalVector( i, float3( 0, 0, 1 ) );
			float3 surf_norm107_g10 = ase_worldNormal;
			float3 uvs_TexCoord88 = i.uv_texcoord;
			uvs_TexCoord88.xy = i.uv_texcoord.xy * float2( 1,2 );
			float2 panner13 = ( 1.0 * _Time.y * float2( 0,-0.3 ) + uvs_TexCoord88.xy);
			float4 tex2DNode89 = tex2D( _TextureSample0, panner13 );
			float height107_g10 = tex2DNode89.r;
			float scale107_g10 = 0.2;
			float3 localPerturbNormal107_g10 = PerturbNormal107_g10( surf_pos107_g10 , surf_norm107_g10 , height107_g10 , scale107_g10 );
			float3 temp_output_14_0 = localPerturbNormal107_g10;
			float fresnelNdotV4 = dot( normalize( temp_output_14_0 ), ase_worldViewDir );
			float fresnelNode4 = ( 0.3 + 5.0 * pow( max( 1.0 - fresnelNdotV4 , 0.0001 ), 5.0 ) );
			float fresnelNdotV15 = dot( normalize( temp_output_14_0 ), ase_worldViewDir );
			float fresnelNode15 = ( 0.0 + 5.0 * pow( max( 1.0 - fresnelNdotV15 , 0.0001 ), 5.0 ) );
			float clampResult10 = clamp( fresnelNode4 , 0.0 , -(fresnelNode15*1.0 + -1.0) );
			float4 temp_cast_2 = ((clampResult10*1.0 + -0.4)).xxxx;
			float4 temp_output_55_0 = CalculateContrast(3.0,temp_cast_2);
			float2 panner49 = ( 1.0 * _Time.y * float2( 0,-0.1 ) + uvs_TexCoord88.xy);
			float simplePerlin2D44 = snoise( panner49*100.0 );
			simplePerlin2D44 = simplePerlin2D44*0.5 + 0.5;
			float clampResult46 = clamp( (simplePerlin2D44*-40.0 + 2.0) , 0.0 , 1.0 );
			float4 clampResult58 = clamp( ( ( clampResult46 * 20 ) * (tex2DNode89*2.0 + -0.5) ) , float4( 0,0,0,0 ) , float4( 1,1,1,0 ) );
			o.Emission = ( _Color0 + temp_output_55_0 + clampResult58 ).rgb;
			float3 surf_pos107_g9 = ase_worldPos;
			float3 surf_norm107_g9 = ase_worldNormal;
			float height107_g9 = tex2DNode89.r;
			float scale107_g9 = 0.05;
			float3 localPerturbNormal107_g9 = PerturbNormal107_g9( surf_pos107_g9 , surf_norm107_g9 , height107_g9 , scale107_g9 );
			float fresnelNdotV20 = dot( normalize( localPerturbNormal107_g9 ), ase_worldViewDir );
			float fresnelNode20 = ( 0.0 + 100.0 * pow( max( 1.0 - fresnelNdotV20 , 0.0001 ), 3.2 ) );
			float clampResult25 = clamp( ( -(fresnelNode20*1.0 + -1.0) + 0.5 ) , 0.2 , 1.0 );
			float clampResult24 = clamp( clampResult10 , 0.0 , clampResult25 );
			float3 ase_normWorldNormal = normalize( ase_worldNormal );
			float fresnelNdotV62 = dot( ase_normWorldNormal, ase_worldViewDir );
			float fresnelNode62 = ( 0.0 + 3.0 * pow( max( 1.0 - fresnelNdotV62 , 0.0001 ), 1.0 ) );
			float clampResult65 = clamp( fresnelNode62 , 0.2 , 1.0 );
			float4 clampResult66 = clamp( ( ( (clampResult24*3.0 + -0.25) + clampResult58 + temp_output_55_0 ) * _Alpha * clampResult65 ) , float4( 0,0,0,0 ) , float4( 1,0,0,0 ) );
			o.Alpha = clampResult66.r;
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf Unlit alpha:fade keepalpha fullforwardshadows 

		ENDCG
		Pass
		{
			Name "ShadowCaster"
			Tags{ "LightMode" = "ShadowCaster" }
			ZWrite On
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0
			#pragma multi_compile_shadowcaster
			#pragma multi_compile UNITY_PASS_SHADOWCASTER
			#pragma skip_variants FOG_LINEAR FOG_EXP FOG_EXP2
			#include "HLSLSupport.cginc"
			#if ( SHADER_API_D3D11 || SHADER_API_GLCORE || SHADER_API_GLES || SHADER_API_GLES3 || SHADER_API_METAL || SHADER_API_VULKAN )
				#define CAN_SKIP_VPOS
			#endif
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "UnityPBSLighting.cginc"
			sampler3D _DitherMaskLOD;
			struct v2f
			{
				V2F_SHADOW_CASTER;
				float3 customPack1 : TEXCOORD1;
				float4 tSpace0 : TEXCOORD2;
				float4 tSpace1 : TEXCOORD3;
				float4 tSpace2 : TEXCOORD4;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};
			v2f vert( appdata_full v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID( v );
				UNITY_INITIALIZE_OUTPUT( v2f, o );
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO( o );
				UNITY_TRANSFER_INSTANCE_ID( v, o );
				Input customInputData;
				float3 worldPos = mul( unity_ObjectToWorld, v.vertex ).xyz;
				half3 worldNormal = UnityObjectToWorldNormal( v.normal );
				half3 worldTangent = UnityObjectToWorldDir( v.tangent.xyz );
				half tangentSign = v.tangent.w * unity_WorldTransformParams.w;
				half3 worldBinormal = cross( worldNormal, worldTangent ) * tangentSign;
				o.tSpace0 = float4( worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x );
				o.tSpace1 = float4( worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y );
				o.tSpace2 = float4( worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z );
				o.customPack1.xyz = customInputData.uv_texcoord;
				o.customPack1.xyz = v.texcoord;
				TRANSFER_SHADOW_CASTER_NORMALOFFSET( o )
				return o;
			}
			half4 frag( v2f IN
			#if !defined( CAN_SKIP_VPOS )
			, UNITY_VPOS_TYPE vpos : VPOS
			#endif
			) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				Input surfIN;
				UNITY_INITIALIZE_OUTPUT( Input, surfIN );
				surfIN.uv_texcoord = IN.customPack1.xyz;
				float3 worldPos = float3( IN.tSpace0.w, IN.tSpace1.w, IN.tSpace2.w );
				half3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				surfIN.worldPos = worldPos;
				surfIN.worldNormal = float3( IN.tSpace0.z, IN.tSpace1.z, IN.tSpace2.z );
				surfIN.internalSurfaceTtoW0 = IN.tSpace0.xyz;
				surfIN.internalSurfaceTtoW1 = IN.tSpace1.xyz;
				surfIN.internalSurfaceTtoW2 = IN.tSpace2.xyz;
				SurfaceOutput o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutput, o )
				surf( surfIN, o );
				#if defined( CAN_SKIP_VPOS )
				float2 vpos = IN.pos;
				#endif
				half alphaRef = tex3D( _DitherMaskLOD, float3( vpos.xy * 0.25, o.Alpha * 0.9375 ) ).a;
				clip( alphaRef - 0.01 );
				SHADOW_CASTER_FRAGMENT( IN )
			}
			ENDCG
		}
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18935
438;169;1114;473;1901.391;256.7914;1;True;True
Node;AmplifyShaderEditor.TextureCoordinatesNode;88;-1991.359,193.9323;Inherit;False;0;-1;3;3;2;SAMPLER2D;;False;0;FLOAT2;1,2;False;1;FLOAT2;0,0;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PannerNode;13;-1696.479,112.7275;Inherit;False;3;0;FLOAT2;1,1;False;2;FLOAT2;0,-0.3;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;89;-1437.09,-123.0405;Inherit;True;Property;_TextureSample0;Texture Sample 0;2;1;[HideInInspector];Create;True;0;0;0;False;0;False;-1;None;b9b58e34ad210da4fa975ced7b82cdd7;True;0;False;black;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.FunctionNode;26;-1057.187,285.8845;Inherit;False;Normal From Height;-1;;9;1942fe2c5f1a1f94881a33d532e4afeb;0;2;20;FLOAT;0;False;110;FLOAT;0.05;False;2;FLOAT3;40;FLOAT3;0
Node;AmplifyShaderEditor.PannerNode;49;-1085.006,790.4791;Inherit;False;3;0;FLOAT2;1,1;False;2;FLOAT2;0,-0.1;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.FresnelNode;20;-571.5563,691.3987;Inherit;True;Standard;WorldNormal;ViewDir;True;True;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;100;False;3;FLOAT;3.2;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;14;-1056.73,141.3467;Inherit;False;Normal From Height;-1;;10;1942fe2c5f1a1f94881a33d532e4afeb;0;2;20;FLOAT;0;False;110;FLOAT;0.2;False;2;FLOAT3;40;FLOAT3;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;44;-487.9843,1140.145;Inherit;True;Simplex2D;True;False;2;0;FLOAT2;0,0;False;1;FLOAT;100;False;1;FLOAT;0
Node;AmplifyShaderEditor.FresnelNode;15;-581.1675,317.9958;Inherit;True;Standard;WorldNormal;ViewDir;True;True;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;5;False;3;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;21;-229.2372,867.1056;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;-1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;45;-199.376,1135.668;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;-40;False;2;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;16;-193.5942,608.2917;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;-1;False;1;FLOAT;0
Node;AmplifyShaderEditor.NegateNode;22;18.02691,821.7183;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;23;181.3005,736.9592;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;46;75.12403,1138.468;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.NegateNode;17;0.7444992,527.4658;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FresnelNode;4;-586.1005,14.16037;Inherit;True;Standard;WorldNormal;ViewDir;True;True;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0.3;False;2;FLOAT;5;False;3;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;57;266.1365,834.7792;Inherit;False;3;0;COLOR;0,0,0,0;False;1;FLOAT;2;False;2;FLOAT;-0.5;False;1;COLOR;0
Node;AmplifyShaderEditor.ScaleNode;50;379.4438,1044.727;Inherit;False;20;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;25;303.7718,574.407;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0.2;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;10;145.64,291.0945;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;53;564.266,964.3345;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;19;310.2429,225.2593;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;-0.4;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;24;402.2962,389.4143;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;27;583.0407,387.7812;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;3;False;2;FLOAT;-0.25;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;58;715.9055,845.9252;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;1,1,1,0;False;1;COLOR;0
Node;AmplifyShaderEditor.FresnelNode;62;748.5174,1032.244;Inherit;True;Standard;WorldNormal;ViewDir;True;True;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;3;False;3;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleContrastOpNode;55;584.2819,170.1858;Inherit;False;2;1;COLOR;0,0,0,0;False;0;FLOAT;3;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;51;961.7866,558.2052;Inherit;False;3;3;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ClampOpNode;65;1070.525,797.0303;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0.2;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;61;838.0035,307.0725;Inherit;False;Property;_Alpha;Alpha;1;0;Create;True;0;0;0;False;0;False;0;3;0;3;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;59;1212.732,435.2597;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;FLOAT;0.5283019;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;1;567.3607,-107.7958;Inherit;False;Property;_Color0;Color 0;0;0;Create;True;0;0;0;False;0;False;0.9339623,0.3127893,0.7708302,0;0.9339623,0.3127892,0.7708302,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ClampOpNode;66;1386.144,359.109;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;1,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;18;918.5468,-18.68629;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;5;-1353.277,144.931;Inherit;False;Simplex3D;True;False;2;0;FLOAT3;0,0,0;False;1;FLOAT;4;False;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;1606.451,63.00789;Float;False;True;-1;2;ASEMaterialInspector;0;0;Unlit;aaa;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Transparent;0;True;True;0;False;Transparent;;Transparent;All;18;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;2;5;False;-1;10;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;True;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;13;0;88;0
WireConnection;89;1;13;0
WireConnection;26;20;89;0
WireConnection;49;0;88;0
WireConnection;20;0;26;0
WireConnection;14;20;89;0
WireConnection;44;0;49;0
WireConnection;15;0;14;0
WireConnection;21;0;20;0
WireConnection;45;0;44;0
WireConnection;16;0;15;0
WireConnection;22;0;21;0
WireConnection;23;0;22;0
WireConnection;46;0;45;0
WireConnection;17;0;16;0
WireConnection;4;0;14;0
WireConnection;57;0;89;0
WireConnection;50;0;46;0
WireConnection;25;0;23;0
WireConnection;10;0;4;0
WireConnection;10;2;17;0
WireConnection;53;0;50;0
WireConnection;53;1;57;0
WireConnection;19;0;10;0
WireConnection;24;0;10;0
WireConnection;24;2;25;0
WireConnection;27;0;24;0
WireConnection;58;0;53;0
WireConnection;55;1;19;0
WireConnection;51;0;27;0
WireConnection;51;1;58;0
WireConnection;51;2;55;0
WireConnection;65;0;62;0
WireConnection;59;0;51;0
WireConnection;59;1;61;0
WireConnection;59;2;65;0
WireConnection;66;0;59;0
WireConnection;18;0;1;0
WireConnection;18;1;55;0
WireConnection;18;2;58;0
WireConnection;5;0;13;0
WireConnection;0;2;18;0
WireConnection;0;9;66;0
ASEEND*/
//CHKSM=9D518B1AB6D2A3EBCCBC85DA20867305651696AE