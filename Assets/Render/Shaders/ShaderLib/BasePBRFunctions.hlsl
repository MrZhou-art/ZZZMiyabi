#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/BRDF.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/GlobalIllumination.hlsl"

struct NPRSurfaceData
{
    float3 albedo;
    float3 specular;
    float  metallic;
    float  smoothness;
    // half3 normalTS;
    // half3 emission;
    // half  occlusion;
    float  alpha;
    // half  clearCoatMask;
    // half  clearCoatSmoothness;
};



void ZZZInitializeSurfaceData(float4 albedo, float3 specular, float metallic, float smoothness, float cutOff,out NPRSurfaceData outSurfaceData)
{
    outSurfaceData.alpha = AlphaDiscard(albedo.a, cutOff);
    outSurfaceData.albedo = AlphaModulate(albedo.rgb, outSurfaceData.alpha);

    #if _SPECULAR_SETUP
    // M Texture 只有 a 通道为 specular
    outSurfaceData.metallic = half(1.0);
    outSurfaceData.specular = specular.rrr;
    #else
    outSurfaceData.metallic = metallic;
    outSurfaceData.specular = half3(0.0, 0.0, 0.0);
    #endif

    outSurfaceData.smoothness = smoothness; 
}

void ZZZInitializeBRDFData(float3 albedo, float metallic, float3 specular, float smoothness, float alpha, out BRDFData brdfData)
{
    InitializeBRDFData(albedo, metallic, specular, smoothness, alpha, brdfData);
}



half3 ZZZEnvironmentBRDFSpecular(BRDFData brdfData, half fresnelTerm)
{
    float surfaceReduction = 1.0 / (brdfData.roughness2 + 1.0);
    return half3(surfaceReduction * lerp(brdfData.specular, brdfData.grazingTerm, fresnelTerm));
}

half3 ZZZEnvironmentBRDF(BRDFData brdfData, half3 indirectDiffuse, half3 indirectSpecular, half fresnelTerm)
{
    half3 c = indirectDiffuse * brdfData.diffuse;
    c += indirectSpecular * ZZZEnvironmentBRDFSpecular(brdfData, fresnelTerm);
    return c;
}



half ZZZDirectBRDFSpecular(BRDFData brdfData, half3 normalWS, half3 lightDirectionWS, half3 viewDirectionWS)
{
    float3 halfDir = SafeNormalize(float3(lightDirectionWS) + float3(viewDirectionWS));

    float NoH = saturate(dot(normalWS, halfDir));
    half LoH = saturate(dot(lightDirectionWS, halfDir));

    float d = NoH * NoH * brdfData.roughness2MinusOne + 1.00001f;

    half LoH2 = LoH * LoH;
    half specularTerm = brdfData.roughness2 / ((d * d) * max(0.1h, LoH2) * brdfData.normalizationTerm);

    return specularTerm;
}

half3 ZZZGlobalIllumination(BRDFData brdfData, half3 bakedGI, half3 normalWS, half3 viewDirectionWS, half occlusion = 1.0f)
{
    half3 reflectVector = reflect(-viewDirectionWS, normalWS);
    half NoV = saturate(dot(normalWS, viewDirectionWS));
    //half NoV = saturate(dot(normalWS, viewDirectionWS));
    //去掉菲涅尔的计算，因为会有等距边缘光
    // half fresnelTerm = 0; // Pow4(1.0 - NoV);
    
    half fresnelTerm = Pow4(1.0 - NoV); // Pow4(1.0 - NoV);

    //half3 indirectSpecular = NPRMatcapReflection(brdfData.perceptualRoughness);
    half3 indirectDiffuse = bakedGI * occlusion;
    half3 indirectSpecular = GlossyEnvironmentReflection(reflectVector, brdfData.perceptualRoughness, 1);
    
    half3 color = ZZZEnvironmentBRDF(brdfData, indirectDiffuse, indirectSpecular, fresnelTerm);
    
    return color;
}


// 未优化的 BRDF 函数
// Distribution
float DistributionGGX(float3 NdotH, float roughness)
{
    float a = roughness * roughness;
    float a2 = a * a;
    float NdotH2 = NdotH * NdotH;

    float nom = a2;
    float denom = (NdotH2 * (a2 - 1.0) + 1.0);
    denom = PI * denom * denom;

    return nom / denom;
}
// GeometrySchlick
float GeometrySchlickGGX(float cosTheta, float k)
{
    float nom = cosTheta;
    float denom = cosTheta * (1.0 - k) + k;
    return nom / (denom + 1e-5f);
}
// GeometrySmith
float GeometrySmith(float NdotV,float NdotL ,float roughness)
{
    float r = (roughness + 1.0);
    float k = (r * r) / 8.0;
    float ggx2 = GeometrySchlickGGX(NdotV, k);
    float ggx1 = GeometrySchlickGGX(NdotL, k);
    return ggx1 * ggx2;
}
// Fresnel
float3 FresnelTerm(float3 F0, float cosA)
{
    half t = pow(1 - cosA,5.0); 
    return F0 + (1 - F0) * t;
}


// Direct Light Calculation
float3 DirectPBR(float NoL,float NoV,float NoH,float HoV,float3 albedo,float metalness,float roughness,float3 f0,float3 lightColor)
{
    float dTerm = DistributionGGX(NoH, roughness);
    float gTerm = GeometrySmith(NoL, NoV, roughness);
    float3 fTerm = FresnelTerm(f0, HoV);
    float3 specular = dTerm * gTerm * fTerm / (4.0 * max(NoV * NoL, 0.001));
    
    //我们按照能量守恒的关系，首先计算镜面反射部分，它的值等于入射光线被反射的能量所占的百分比。
    float3 kS = fTerm;
    //然后折射光部分就可以直接由镜面反射部分计算得出：
    float3 kD = (1.0 - kS) ;
    //金属是没有漫反射的,所以Kd需要乘上1-metalness
    kD *= 1.0 - metalness;
    
    //除π是为了能量守恒，但Unity也没有除以π，应该是觉得除以π后太暗，所以我们这里也先不除
    float3 diffuse = kD * albedo;// *INV_PI;
    float3 result = (diffuse + specular) * NoL * lightColor;
    
    return result;
}

