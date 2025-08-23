#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "CustomStructs.hlsl"

float4 DecodeAlbedoTexture(Texture2D albedoTex, SamplerState albedoTexSampler, float2 uv)
{
    return SAMPLE_TEXTURE2D(albedoTex, albedoTexSampler, uv);
}

NormalTexData DecodeNormalTexture(Texture2D normalTex, SamplerState normalTexSampler, float2 uv, float3 tangentWS,float3 bitangentWS, float3 normalWS, float bumpScale)
{
    NormalTexData output;
    float3 normalTS = 0;

    float3 normalPacked = SAMPLE_TEXTURE2D(normalTex, normalTexSampler, uv);
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
    output.metallic = mTexData.g;
    output.smoothness = mTexData.b;
    output.metalMask = mTexData.a;

    return output;
}

float CalculateAlbedoRampPart1(float baseAttenuation, float albedoSoomthness, float adder1, float adder2)
{
    return (baseAttenuation + adder1) / albedoSoomthness + adder2;
}

float CalculateAlbedoRampPart2(float attenuation, float lastAttenuation)
{
    return saturate(min(lastAttenuation, 1 - attenuation));
}

float4 SelectByMaterialID(int materialID, float4 option1, float4 option2, float4 option3, float4 option4, float4 option5)
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

AttenuationData CalculateAttenuation(float albedoSmoothness, float NoL, float diffuseOffset)
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

float3 CalculateAlbedo(
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
    // Tinting
    float3 shadowFadeColor  = attenuation.shadowFade  * ShadowFadeTint.rgb  * ShadowColor.rgb;
    float3 shadowColor      = attenuation.shadow      * ShadowTint.rgb      * ShadowColor.rgb;
    float3 shallowFadeColor = attenuation.shallowFade * ShallowFadeTint.rgb * ShallowColor.rgb;
    float3 shallowColor     = attenuation.shallow     * ShallowTint.rgb     * ShallowColor.rgb;
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