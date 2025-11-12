#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "CustomStructs.hlsl"

// 实现sigmoid函数用于阴影计算
float sigmoid(float x, float offset, float smoothness) {
    float adjustedX = x - offset;
    // sigmoid函数公式: 1 / (1 + exp(-x))
    return 1.0 / (1.0 + exp(-adjustedX * smoothness));
}

float4 SampleShadowRamp(Texture2D ramp, SamplerState rampSampler, float2 uv)
{
    return SAMPLE_TEXTURE2D(ramp, rampSampler, uv);
}



float4 DecodeAlbedoTexture(Texture2D albedoTex, SamplerState albedoTexSampler, float2 uv)
{
    return SAMPLE_TEXTURE2D(albedoTex, albedoTexSampler, uv);
}

NormalTexData DecodeNormalTexture(Texture2D normalTex, SamplerState normalTexSampler, float2 uv, float3 tangentWS,float3 bitangentWS, float3 normalWS, float bumpScale)
{
    NormalTexData output;
    float3 normalTS = 0;

    float3 normalPacked = SAMPLE_TEXTURE2D(normalTex, normalTexSampler, uv).rgb;
    normalTS.xy = normalPacked.xy * 2.0 - 1.0;
    normalTS.z = max(1.0e-16, sqrt(1.0 - saturate(dot(normalTS.xy, normalTS.xy))));
    normalTS.xy *= bumpScale;

    output.normalWS = normalize(TransformTangentToWorld(normalTS,real3x3(tangentWS, bitangentWS, normalWS)));
    output.diffuseBias = normalPacked.z;

    return output;
}

MTexData DecodeMTexture(Texture2D mTex, SamplerState mTexSampler, float2 uv)
{
    MTexData output;

    float4 mTexData = SAMPLE_TEXTURE2D(mTex, mTexSampler, uv);
    output.materialID = max(0, 4 - floor(mTexData.r * 5));
    /* 
    * mTexData.r = 0.1 ---> materialID = 4
    * mTexData.r = 0.3 ---> materialID = 3
    * mTexData.r = 0.5 ---> materialID = 2
    * mTexData.r = 0.7 ---> materialID = 1
    * mTexData.r = 0.9 ---> materialID = 0
    */
    output.metallic = mTexData.g;
    output.smoothness = mTexData.b;
    output.specular = mTexData.a;

    return output;
}


float Decode360SDFTexture(Texture2D sdfTex, SamplerState sdfTexSampler, float2 uv)
{
    return SAMPLE_TEXTURE2D(sdfTex, sdfTexSampler, uv).x;
}

float4 Decode2DSDFTexture(Texture2D sdfTex, SamplerState sdfTexSampler, float2 uv)
{
    return SAMPLE_TEXTURE2D(sdfTex, sdfTexSampler, uv);
}


float CalculateAlbedoRampPart1(float baseAttenuation, float albedoSoomthness, float adder1, float adder2)
{
    return (baseAttenuation + adder1) / albedoSoomthness + adder2;
}

float CalculateAlbedoRampPart2(float attenuation, float lastAttenuation)
{
    return saturate(min(lastAttenuation, 1 - attenuation));
}



float4 SelectByMaterialID(float materialID, float4 option1, float4 option2, float4 option3, float4 option4, float4 option5)
{
    /* 
     * materialID = 0 ---> option1
     * materialID = 1 ---> option2
     * materialID = 2 ---> option3
     * materialID = 3 ---> option4
     * materialID = 4 ---> option5
     */
    return (materialID > 0
                ? (materialID > 1 ? (materialID > 2 ? (materialID > 3 ? option5 : option4) : option3) : option2)
                : option1);
}


AttenuationData CalculateRegularAttenuation(float albedoSmoothness, float NoL, float diffuseOffset)
{
    AttenuationData attenuationData;
    
    float baseAttenuation = (NoL + diffuseOffset) * 1.5;
    albedoSmoothness = max(0.0001, albedoSmoothness) * 1.5;
    
    // ShadowFade
    float tempShadowFade = CalculateAlbedoRampPart1(baseAttenuation, 1 - albedoSmoothness, 1.5, 0.0);
    attenuationData.shadowFade = CalculateAlbedoRampPart2(tempShadowFade, 1.0);
    // Shadow
    float tempShadow = CalculateAlbedoRampPart1(baseAttenuation, albedoSmoothness, 0.5, 0.5);
    attenuationData.shadow = CalculateAlbedoRampPart2(tempShadow, tempShadowFade);
    // ShallowFade
    float tempShallowFade = CalculateAlbedoRampPart1(baseAttenuation, albedoSmoothness, 0.0, 0.5);
    attenuationData.shallowFade = CalculateAlbedoRampPart2(tempShallowFade, tempShadow);
    // Shallow
    float tempShallow = CalculateAlbedoRampPart1(baseAttenuation, albedoSmoothness, -0.5, 0.5);
    attenuationData.shallow  = CalculateAlbedoRampPart2(tempShallow, tempShallowFade);
    // SSS
    float tempSSS = CalculateAlbedoRampPart1(baseAttenuation, albedoSmoothness, -0.5, -0.5);
    attenuationData.sss = CalculateAlbedoRampPart2(tempSSS, tempShallow);
    // Front
    float tempFront = CalculateAlbedoRampPart1(baseAttenuation, albedoSmoothness, -2.0, 1.5);
    attenuationData.front = CalculateAlbedoRampPart2(tempFront, tempSSS);
    // Forward
    attenuationData.forward = saturate(tempFront);

    return attenuationData;
}


AttenuationData CalculateFaceAttenuation(float albedoSmoothness, float angleFunction, float angleMapping, float angleThreshold)
{
    // Never tamper with these magic numbers.
    float angleFunctionRange = saturate(angleFunction * 2.5f - 0.25f);
    angleFunctionRange = max(lerp(albedoSmoothness, 0.025f, angleFunctionRange), 0.00001f);
    angleThreshold = (1.2f * angleMapping - 0.6f)/ (4 * angleFunctionRange + 1) + 0.6f - angleThreshold;

    float shadowAttenuation = angleThreshold / angleFunctionRange;
    float brightnessAttenuation = 8.0f * angleThreshold - 16.0f * angleFunctionRange;

    AttenuationData faceAttenuationData;
    faceAttenuationData.shadowFade = saturate(1 - shadowAttenuation);
    faceAttenuationData.shadow = 0.0f;
    faceAttenuationData.shallowFade = 0.0f;
    faceAttenuationData.shallow = 0.0f;
    faceAttenuationData.sss = min(saturate(shadowAttenuation), saturate(1.0f - (shadowAttenuation - 1.0f)));
    faceAttenuationData.front = min(saturate(shadowAttenuation - 1.0f), saturate(1.0f - brightnessAttenuation));
    faceAttenuationData.forward = saturate(brightnessAttenuation);

    return faceAttenuationData;
}


AttenuationData CalculateAttenuation(float albedoSmoothness, float NoL, float diffuseOffset, float angleFunction, float angleMapping, float angleThreshold, float angleMapMask)
{
    AttenuationData attenuationData;
    AttenuationData faceAttenuationData = CalculateFaceAttenuation(albedoSmoothness, angleFunction, angleMapping, angleThreshold);
    AttenuationData regularAttenuationData = CalculateRegularAttenuation(albedoSmoothness, NoL, diffuseOffset);
    
    attenuationData.shadowFade  = lerp(regularAttenuationData.shadowFade , faceAttenuationData.shadowFade , angleMapMask);
    attenuationData.shadow      = lerp(regularAttenuationData.shadow     , faceAttenuationData.shadow     , angleMapMask);
    attenuationData.shallowFade = lerp(regularAttenuationData.shallowFade, faceAttenuationData.shallowFade, angleMapMask);
    attenuationData.shallow     = lerp(regularAttenuationData.shallow    , faceAttenuationData.shallow    , angleMapMask);
    attenuationData.sss         = lerp(regularAttenuationData.sss        , faceAttenuationData.sss        , angleMapMask);
    attenuationData.front       = lerp(regularAttenuationData.front      , faceAttenuationData.front      , angleMapMask);
    attenuationData.forward     = lerp(regularAttenuationData.forward    , faceAttenuationData.forward    , angleMapMask);
    
    return attenuationData;
}

float3 DepthAttenuation(float3 color, float depth)
{
    float averageColor = max(dot(color, float3(0.333f, 0.333f, 0.333f)), 0.00001f);
    float depthThreshold = saturate(depth * 18.0f);

    return lerp(color/averageColor, color, saturate(depthThreshold));
}



float3 CalculateAlbedo(
    float depth,
    float3 ShadowColor,
    float3 ShallowColor,
    float3 ShadowFadeTint,
    float3 ShadowTint,
    float3 ShallowFadeTint,
    float3 ShallowTint,
    float3 SSSTint,
    float3 FrontTint,
    AttenuationData attenuation,
    float3 lightColor)
{
    float3 shadowAttenuationColor   = DepthAttenuation(ShadowColor.rgb, depth);
    float3 shadllowAttenuationColor = DepthAttenuation(ShallowColor.rgb, depth);
    
    // Tinting
    float3 shadowFadeColor  = attenuation.shadowFade  * ShadowFadeTint.rgb  * shadowAttenuationColor;
    float3 shadowColor      = attenuation.shadow      * ShadowTint.rgb      * shadowAttenuationColor;
    float3 shallowFadeColor = attenuation.shallowFade * ShallowFadeTint.rgb * shadllowAttenuationColor;
    float3 shallowColor     = attenuation.shallow     * ShallowTint.rgb     * shadllowAttenuationColor;
    float3 sssColor         = attenuation.sss         * SSSTint.rgb         * ShallowColor.rgb;
    float3 frontColor       = attenuation.front       * FrontTint.rgb       * ShallowColor.rgb;
    float3 forwardColor     = attenuation.forward;
                
    float3 mainShadow = shadowFadeColor + shadowColor + shallowFadeColor + shallowColor;
    float3 mainFront = sssColor + frontColor + forwardColor;

    // TODO: Envirnoment Light
    mainShadow += 0.05;
    mainFront *= lightColor;

    return mainShadow + mainFront;
}


float Calculate360SDFThreshold(
    Texture2D _360SDFTex,
    SamplerState sampler_360SDFTex,
    float2 uv,
    float3 lightDirWS,
    float3 headForwardDirWS,
    float3 headLeftDirWS,
    float3 headUpDirWS)
{
#define ROW 9
#define ROW_MINUS_ONE 8
    
    float cosTheta = dot(lightDirWS.xz, headForwardDirWS.xz);
    float cosPhi = dot(lightDirWS.xy, headUpDirWS.xy);
    float isRightSide = step(0.0, dot(lightDirWS.xz, headLeftDirWS.xz));

    float2 cosAngle = float2(cosTheta, cosPhi);
    float2 linearAngle = 1 - acos(cosAngle) * 57.295799 / 180;
    linearAngle *= ROW_MINUS_ONE;
    
    // Decode SDF Texture
    float2 uv_inverseX = float2(1.0 - uv.x, uv.y);
    float2 sdfTexUV = lerp(uv, uv_inverseX, isRightSide) / ROW;

    float ThetaWeight   = frac(linearAngle.x);
    float PhiWeight     = frac(linearAngle.y);
    float2 linearAngle_0 = floor(linearAngle);
    float2 linearAngle_1 = floor(linearAngle) + 1;

    float2 bais0_0 = min(float2(linearAngle_0.x, linearAngle_0.y), 8.0) / ROW;
    float2 bais1_0 = min(float2(linearAngle_1.x, linearAngle_0.y), 8.0) / ROW;
    float2 bais0_1 = min(float2(linearAngle_0.x, linearAngle_1.y), 8.0) / ROW;
    float2 bais1_1 = min(float2(linearAngle_1.x, linearAngle_1.y), 8.0) / ROW;

    float2 sdfTexUV0_0 = sdfTexUV + bais0_0;
    float2 sdfTexUV1_0 = sdfTexUV + bais1_0;
    float2 sdfTexUV0_1 = sdfTexUV + bais0_1;
    float2 sdfTexUV1_1 = sdfTexUV + bais1_1;

    float4 SDF = float4(
        Decode360SDFTexture(_360SDFTex, sampler_360SDFTex, sdfTexUV0_0),
        Decode360SDFTexture(_360SDFTex, sampler_360SDFTex, sdfTexUV1_0),
        Decode360SDFTexture(_360SDFTex, sampler_360SDFTex, sdfTexUV0_1),
        Decode360SDFTexture(_360SDFTex, sampler_360SDFTex, sdfTexUV1_1)
    );

    float2 lerpSDF = float2(
        lerp(SDF.x, SDF.y, ThetaWeight),
        lerp(SDF.z, SDF.w, ThetaWeight)
    );

    return step(lerp(lerpSDF.x, lerpSDF.y, PhiWeight), 0.5);
}