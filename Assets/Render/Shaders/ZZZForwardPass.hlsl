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
    
#if defined(IS_FACE)
    float2 uv2 : TEXCOORD2;
#endif
    
    float3 normalOS : NORMAL;
    float4 tangentOS : TANGENT;
};

struct Varyings
{
    float4 positionCS : SV_POSITION;
    float3 positionWS : TEXCOORD0;
    float2 uv   : TEXCOORD1;
    
#if defined(IS_FACE)
    float2 uv2  : TEXCOORD2;
#endif
    
    float3 normalWS     : TEXCOORD3;
    float3 tangentWS    : TEXCOORD4;
    float3 bitangentWS  : TEXCOORD5;

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

    output.uv   = input.uv;
    
#if defined(IS_FACE)
    output.uv2  = input.uv2;
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

    #ifdef DYNAMICLIGHTMAP_ON
    output.dynamicLightmapUV = float2(0.0f, 0.0f);
    #endif
    
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
    float3 headForwardDirWS = _HeadForward;
    float3 headLeftDirWS = _HeadLeft;
    float3 headUpDirWS = normalize(cross(headLeftDirWS, headForwardDirWS));
    
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
    
    
#endif
    
    float3 lightColor = mainLight.color;

    float diffuseBias = normalTexData.diffuseBias;
    float3 normalWS = normalTexData.normalWS;

    /* M Texture Data
    R: 区域 ID
       金属,裙子和鞋 : 0
       皮肤        : 0.3 
       丝袜        : 0.5 
       外衣        : 0.7 
       内衣 : 1
    G: 金属度
    B: 身体的光滑度, 头发的高光遮罩
    A: 高光度, 头发区域
    */
#if defined(USE_M_TEXTURE)
    
    float materialID = mTexData.materialID;
    float specular = lerp(0, mTexData.specular, _SpecularIntensity);
    float metallic = lerp(0, mTexData.metallic, _MetallicIntensity);
    float smoothness = lerp(0, mTexData.smoothness, _SmoothnessIntensity);

#else    
    
    float materialID = 0;
    float specular = _Specular;
    float metallic = _Metallic;
    float smoothness = _Smoothness;
    
#endif
    
    float NoL = dot(normalWS, lightDirWS);
    float NoV = dot(normalWS, viewDirWS);
    float NoH = dot(normalWS, halfDirWS);
    float HoV = dot(halfDirWS, viewDirWS);

    ///////////////////////////////////////////////////////////////////////////////
    //                             Cel Shading                                   //
    ///////////////////////////////////////////////////////////////////////////////

    float3 albedoColor = 0;
    float3 faceColor = 0;
    
    // ---------- for debug ---------
#if defined(USE_WORLD_SPACE_ORIENTATION)
    
    headForwardDirWS = float3(0.0, 0.0, 1.0); 
    headLeftDirWS = float3(-1.0, 0.0, 0.0); 
    headUpDirWS = float3(0.0, 1.0, 0.0);

#endif

    // ----------------- SDF -------------------
#if defined(IS_FACE)
    // ---------------- 2D SDF ----------------
#if defined(USE_2D_SDF)

    // ----------------------------
    // For the world-space light direction, remove its parallel component
    // along the head up direction to yield a horizontal projection vector perpendicular to the head
    float3 HorizontalLightDirWS = normalize(lightDirWS - dot(lightDirWS, headUpDirWS) * headUpDirWS);

    // float isRightSide = step(0.0, dot(lightDirWS.xz, headLeftDirWS.xz));
    float cosTheta = dot(HorizontalLightDirWS, -headLeftDirWS);
    float isRightSide = step(0.0, cosTheta);
    float linearTheta = FastAtan2(cosTheta, dot(-headForwardDirWS, HorizontalLightDirWS)) / PI;
    float angleThreshold = lerp(1 - linearTheta, 1 + linearTheta, step(linearTheta, 0.0));
    
    
    float2 uv_inverseX = float2(1.0 - uv.x, uv.y);
    float2 sdfTexUV = lerp(uv, uv_inverseX, isRightSide);

    float4 sdf = Decode2DSDFTexture(_2DSDFTex, sampler_2DSDFTex, sdfTexUV);
    float angleMapping  = sdf.r;
    float angleFunction = sdf.g;
    // float angle         = sdf.b; // No useful for now
    float angleMapMask  = sdf.a;
    
    // ---------------- 360 SDF ----------------
#else

    float SDFThreshold = Calculate360SDFThreshold(
        _360SDFTex,
        sampler_360SDFTex,
        input.uv2,
        lightDirWS,
        headForwardDirWS,
        headLeftDirWS,
        headUpDirWS);

    faceColor = lerp(_SDFShadowColor, _SDFBrightColor, SDFThreshold) * albedo;
    

#endif
    
#endif
    
    
    // ---------------- Albedo ----------------
    // TODO: Face Can't use sigmoid attenuation and Ramp Attenuation, this will be fixed in the future???
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
    AttenuationData attenuationData;
#if defined(IS_FACE)

    attenuationData = CalculateAttenuation(_AlbedoSmoothness, NoL, diffuseBias + _DiffuseOffset,
        angleFunction, angleMapping, angleThreshold, angleMapMask);

    // attenuationData = CalculateFaceAttenuation(_AlbedoSmoothness, angleFunction, angleMapping, angleThreshold);
    
#else
        
    attenuationData = CalculateRegularAttenuation(_AlbedoSmoothness, NoL, diffuseBias + _DiffuseOffset);
    
#endif
    
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
        attenuationData,
        lightColor);

    albedoColor = albedoColor * albedo.rgb;

#endif


    // ---------------- PBR ---------------- 
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
    
    // bakedGI = SAMPLE_GI(input.staticLightmapUV, input.dynamicLightmapUV, input.vertexSH, normalWS);
    bakedGI = SAMPLE_GI(input.staticLightmapUV, float2(0,0), input.vertexSH, normalWS);
    
#else
    
    // bakedGI = SAMPLE_GI(input.staticLightmapUV, input.vertexSH, normalWS);
    bakedGI = SAMPLE_GI(float2(0,0), input.vertexSH, normalWS);
    
#endif
    
    half3 GlobalIllumination = ZZZGlobalIllumination(brdfData, bakedGI, normalWS, viewDirWS);

    // ---------------- Final Stage ---------------- 
#ifdef DEBUG_MODE
    
    // float3 smoothNormalWS = DecodeUVProjectionSmoothNormal(uv1, input.tangentWS, input.bitangentWS, input.normalWS);
    
    float2 noiseSampleUV = uv;
    noiseSampleUV = noiseSampleUV * _NoiseTillOffset.xy + _NoiseTillOffset.zw;
    float perlinNoise = perlin_noise(noiseSampleUV);
    
    float3 f0 = lerp(0.04, albedo.rgb, metallic);
    float3 directBRDTest = DirectPBR(clamp(NoL, 0, 1), NoV, NoH, HoV, albedo.rgb, metallic, 1 - smoothness, f0, lightColor);

    // return half4(bakedGI, 1);

    return half4(albedoColor, 1.0);
    
#endif

    return float4(albedoColor, 1.0);
}
