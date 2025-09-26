// ----------- Build in Functions --------------
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"



// -------------- Base Functions --------------
#include "Assets/Render/Shaders/ShaderLib/BaseNPRFunctions.hlsl"
#include "Assets/Render/Shaders/ShaderLib/BasePBRFunctions.hlsl"

// for debug
float2 hash22(float2 p)
{
    p = float2(dot(p, float2(127.1, 311.7)), dot(p, float2(269.5, 183.3)));
    return -1.0 + 2.0 * frac(sin(p) * 43758.5453123);
}

float2 hash21(float2 p)
{
    float h = dot(p, float2(127.1, 311.7));
    return -1.0 + 2.0 * frac(sin(h) * 43758.5453123);
}

//perlin
float perlin_noise(float2 p)
{
    float2 pi = floor(p);
    float2 pf = p - pi;
    float2 w = pf * pf * (3.0 - 2.0 * pf);
    return lerp(lerp(dot(hash22(pi + float2(0.0, 0.0)), pf - float2(0.0, 0.0)),
                     dot(hash22(pi + float2(1.0, 0.0)), pf - float2(1.0, 0.0)), w.x),
                lerp(dot(hash22(pi + float2(0.0, 1.0)), pf - float2(0.0, 1.0)),
                     dot(hash22(pi + float2(1.0, 1.0)), pf - float2(1.0, 1.0)), w.x), w.y);
}


//---------------- Structs ---------------------
struct Attributes
{
    float4 positionOS : POSITION;
    float2 uv : TEXCOORD0;
    
#if defined(DEBUG_MODE)
    
    float2 uv1 : TEXCOORD1; // for debug
    float4 color : COLOR; // for debug
    
#endif
    
    float3 normalOS : NORMAL;
    float4 tangentOS : TANGENT;
};

struct Varyings
{
    float4 positionCS : SV_POSITION;
    float3 positionWS : TEXCOORD0;
    float2 uv : TEXCOORD1;

#if defined(DEBUG_MODE)
    
    float2 uv1 : TEXCOORD7; // for debug
    float4 color : TEXCOORD5; // for debug
    
#endif
    
    float3 normalWS : TEXCOORD2;
    float3 tangentWS : TEXCOORD3;
    float3 bitangentWS : TEXCOORD4;

    DECLARE_LIGHTMAP_OR_SH(staticLightmapUV, vertexSH, 8);
#ifdef DYNAMICLIGHTMAP_ON
    
    float2  dynamicLightmapUV : TEXCOORD9; // Dynamic lightmap UVs
    
#endif
};

// ---------------- Uniform Variable ---------------------
#include "Assets/Render/Shaders/ShaderLib/UniformVarable.hlsl"

// ---------------- Vertex Shader ---------------------
Varyings ZZZVert(Attributes input)
{
    Varyings output;

    output.uv = input.uv;
#if defined(DEBUG_MODE)

    output.uv1 = input.uv1; // for debug
    output.color = input.color; // for debug
    
#endif

    VertexPositionInputs positionInputs = GetVertexPositionInputs(input.positionOS.xyz);
    output.positionCS = positionInputs.positionCS;
    output.positionWS = positionInputs.positionWS;

    VertexNormalInputs normalInputs = GetVertexNormalInputs(input.normalOS, input.tangentOS);
    output.normalWS = normalInputs.normalWS;
    output.tangentWS = normalInputs.tangentWS;
    output.bitangentWS = normalInputs.bitangentWS;

    // TODO: vertexSH
    output.vertexSH = 0;


    return output;
}

// ---------------- Fragment Shader ---------------------
float4 ZZZFrag(Varyings input) : SV_Target
{
    // ------ Main Vector ------
    Light mainLight = GetMainLight();
    float3 lightDirWS = normalize(mainLight.direction);
    float3 viewDirWS = normalize(_WorldSpaceCameraPos - input.positionWS);
    float3 halfDirWS = normalize(lightDirWS + viewDirWS);

    // ------ Texture Data ------
    // Albedo Texture
    float4 albedo = DecodeAlbedoTexture(_AlbedoMap, sampler_AlbedoMap, input.uv);

#ifdef IS_FACE
    
    NormalTexData normalTexData;
    normalTexData.normalWS = input.normalWS;
    normalTexData.diffuseBias = 0;

    MTexData mTexData;
    mTexData.materialID = 0;
    mTexData.metallic   = 0;
    mTexData.smoothness = 0;
    mTexData.specular   = 0;
    
#else
    
    // Decode Normal Texture
    NormalTexData normalTexData = DecodeNormalTexture(_NormalTex, sampler_NormalTex, input.uv, input.tangentWS,
                                                      input.bitangentWS, input.normalWS, _BumpScale);

    // Decode M Texture
    MTexData mTexData = DecodeMTexture(_MTex, sampler_MTex, input.uv);
    
#endif



    // ------ Base Data ------
    float2 uv = input.uv;
    
#if defined(DEBUG_MODE)
    
    float2 uv1 = input.uv1; // for debug
    
#endif
    
    float3 lightColor = mainLight.color;

    float diffuseBias = normalTexData.diffuseBias;
    float3 normalWS = normalTexData.normalWS;

    float materialID = mTexData.materialID;
    float metallic = lerp(0, mTexData.metallic, _Metallic);
    float smoothness = lerp(0, mTexData.smoothness, _Smoothness);
    float specular = mTexData.specular;

    float NoL = dot(normalWS, lightDirWS);
    float NoV = dot(normalWS, viewDirWS);
    float NoH = dot(normalWS, halfDirWS);
    float HoV = dot(halfDirWS, viewDirWS);

    ///////////////////////////////////////////////////////////////////////////////
    //                             Cel Shading                                   //
    ///////////////////////////////////////////////////////////////////////////////

    // Albedo
    float3 albedoColor = 0;


#if defined(USE_SIGMOID_ATTENUATION) || defined(USE_RAMP_ATTENUATION)

    float halfLambert = clamp(NoL * 0.5 + 0.5, 0, 1);
    
#endif

#ifdef USE_SIGMOID_ATTENUATION

    float shadowArea = sigmoid(1 - halfLambert, _SigmoidAttenuationOffset, _SigmoidAttenuationSmoothness * 10) *
        _SigmoidAttenuationStrength;
    float3 sigmoidShadow = lerp(1, _SigmoidAttenuationColor.rgb, shadowArea);
    albedoColor = albedo.rgb * sigmoidShadow;


#endif


#ifdef USE_RAMP_ATTENUATION

    halfLambert = clamp(pow(halfLambert, _RampAttenuationSmoothness) + _RampAttenuationOffset, 0.0001, 0.9999);
    float3 shadowRamp = SampleShadowRamp(_RampTex, sampler_RampTex, float2(halfLambert, materialID / 4)).rgb *
        _RampAttenuationStrength;
    albedoColor = albedo.rgb * shadowRamp;

#endif

#ifdef USE_LINEAR_PARTITIONED_ATTENUATION

    // attenuation
    AttenuationData attenuation = CalculateAttenuation(_AlbedoSmoothness, NoL, diffuseBias + _DiffuseOffset);

    // Select Color by MaterialID
    float4 selectedShadowColor = SelectByMaterialID(materialID, _ShadowColor1, _ShadowColor2, _ShadowColor3,
                                                    _ShadowColor4, _ShadowColor5);
    float4 selectedShallowColor = SelectByMaterialID(materialID, _ShallowColor1, _ShallowColor2, _ShallowColor3,
                                                     _ShallowColor4, _ShallowColor5);

    // Tinting
    albedoColor = CalculateAlbedo(
        selectedShadowColor.rgb,
        selectedShallowColor.rgb,
        _PostShadowFadeTint.rgb,
        _PostShadowTint.rgb,
        _PostShallowFadeTint.rgb,
        _PostShallowTint.rgb,
        _PostSSSTint.rgb,
        _PostFrontTint.rgb,
        attenuation,
        lightColor);

    albedoColor = albedoColor * albedo.rgb;

#endif


    // PBR
    NPRSurfaceData surfaceData;
    ZZZInitializeSurfaceData(albedo, specular, metallic, smoothness, _Cutoff, surfaceData);

    BRDFData brdfData;
    ZZZInitializeBRDFData(surfaceData.albedo, surfaceData.metallic, surfaceData.specular, surfaceData.smoothness,
                          surfaceData.alpha, brdfData);

    // TODO: fresnelTerm
    // half3 EnvironmentBRDFSpecular = ZZZEnvironmentBRDFSpecular(brdfData, fresnelTerm);

    // TODO: indirectDiffuse, indirectSpecular
    // half3 EnvironmentBRDF = ZZZEnvironmentBRDF(brdfData, indirectDiffuse, indirectSpecular, viewDirWS);

    half DirectBRDFSpecular = ZZZDirectBRDFSpecular(brdfData, normalWS, lightDirWS, viewDirWS);


    half3 bakedGI = 0;

    // TODO: dynamicLightmapUV
#if defined(DYNAMICLIGHTMAP_ON)
    
    bakedGI = SAMPLE_GI(input.staticLightmapUV, input.dynamicLightmapUV, input.vertexSH, normalWS);
    
#else
    
    // bakedGI = SAMPLE_GI(input.staticLightmapUV, input.vertexSH, normalWS);
    bakedGI = SAMPLE_GI(float2(0,0), input.vertexSH, normalWS);
    
#endif
    
    half3 GlobalIllumination = ZZZGlobalIllumination(brdfData, bakedGI, normalWS, viewDirWS);
    
#ifdef DEBUG_MODE
    
    // float3 smoothNormalWS = DecodeUVProjectionSmoothNormal(uv1, input.tangentWS, input.bitangentWS, input.normalWS);
    
    float2 noiseSampleUV = uv;
    noiseSampleUV = noiseSampleUV * _NoiseTillOffset.xy + _NoiseTillOffset.zw;
    float perlinNoise = perlin_noise(noiseSampleUV);
    
    // float3 f0 = lerp(0.04, albedo.rgb, metallic);
    // float3 directBRDTest = DirectPBR(clamp(NoL, 0, 1), NoV, NoH, HoV, albedo, metallic, 1 - smoothness, f0, lightColor);
    
    return half4(perlinNoise.xxx, 1);

#endif

    return float4(albedoColor, 1.0);
}
