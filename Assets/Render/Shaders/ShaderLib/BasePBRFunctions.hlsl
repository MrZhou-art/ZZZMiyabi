#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/BRDF.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/GlobalIllumination.hlsl"

half3 NPREnvironmentBRDFSpecular(BRDFData brdfData, half fresnelTerm)
{
    float surfaceReduction = 1.0 / (brdfData.roughness2 + 1.0);
    return half3(surfaceReduction * lerp(brdfData.specular, brdfData.grazingTerm, fresnelTerm));
}

half3 NPREnvironmentBRDF(BRDFData brdfData, half3 indirectDiffuse, half3 indirectSpecular, half fresnelTerm)
{
    half3 c = indirectDiffuse * brdfData.diffuse;
    c += indirectSpecular * NPREnvironmentBRDFSpecular(brdfData, fresnelTerm);
    return c;
}


half NPRDirectBRDFSpecular(BRDFData brdfData, half3 normalWS, half3 lightDirectionWS, half3 viewDirectionWS)
{
    float3 halfDir = SafeNormalize(float3(lightDirectionWS) + float3(viewDirectionWS));

    float NoH = saturate(dot(normalWS, halfDir));
    half LoH = saturate(dot(lightDirectionWS, halfDir));

    float d = NoH * NoH * brdfData.roughness2MinusOne + 1.00001f;

    half LoH2 = LoH * LoH;
    half specularTerm = brdfData.roughness2 / ((d * d) * max(0.1h, LoH2) * brdfData.normalizationTerm);

    return specularTerm;
}

half3 NPRGlobalIllumination(BRDFData brdfData, half3 bakedGI, half3 normalWS, half3 viewDirectionWS, half occlusion = 1.0f)
{
    half3 reflectVector = reflect(-viewDirectionWS, normalWS);
    //half NoV = saturate(dot(normalWS, viewDirectionWS));
    //去掉菲涅尔的计算，因为会有等距边缘光
    half fresnelTerm = 0;// Pow4(1.0 - NoV);

    //half3 indirectSpecular = NPRMatcapReflection(brdfData.perceptualRoughness);
    half3 indirectDiffuse = bakedGI * occlusion;
    half3 indirectSpecular = GlossyEnvironmentReflection(reflectVector, brdfData.perceptualRoughness, 1);
    
    half3 color = NPREnvironmentBRDF(brdfData, indirectDiffuse, indirectSpecular, fresnelTerm);
    
    return color;
}
