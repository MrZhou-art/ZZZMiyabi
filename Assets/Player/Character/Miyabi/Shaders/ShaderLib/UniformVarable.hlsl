#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

// Texture
TEXTURE2D(_AlbedoMap);       SAMPLER(sampler_AlbedoMap);
TEXTURE2D(_NormalTex);     SAMPLER(sampler_NormalTex);
TEXTURE2D(_MTex);       SAMPLER(sampler_MTex);

// Switch
int _IsFace;
int _IsBody;
int _IsHair;

// Albedo
float _DiffuseOffset;
float _AlbedoSmoothness;
            
// Albedo Color
float4 _ShadowColor1;
float4 _ShadowColor2;
float4 _ShadowColor3;
float4 _ShadowColor4;
float4 _ShadowColor5;
float4 _ShallowColor1;
float4 _ShallowColor2;
float4 _ShallowColor3;
float4 _ShallowColor4;
float4 _ShallowColor5;

float4 _PostShadowFadeTint;
float4 _PostShadowTint;
float4 _PostShallowFadeTint;
float4 _PostShallowTint;
float4 _PostSSSTint;
float4 _PostFrontTint;

// Normal 
float _BumpScale;