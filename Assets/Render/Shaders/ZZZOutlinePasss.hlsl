// ----------- Build in Functions --------------
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Packages/com.unity.shadergraph/ShaderGraphLibrary/ShaderVariablesFunctions.hlsl"


// -------------- Base Functions --------------
float3 TransformTangentToWorldNormal(float3 normalTS, float3 tangentWS, float3 bitangentWS, float3 normalWS)
{
    return normalize(TransformTangentToWorld(normalTS,real3x3(tangentWS, bitangentWS, normalWS)));
}

float3 DecodeUVProjectionSmoothNormal(float2 uv, float3 tangentWS, float3 bitangentWS, float3 normalWS)
{
    // 从smoothNormalUV反推TBN空间的(x, y, z)分量
    float3 tbnNormal; // TBN空间中的法线向量

    // 反向实现unitVectorTo0ct函数逻辑
    float u = uv.x;
    float v = uv.y;
    float x, y, z;

    // 判断是正面（z>0）还是背面（z≤0）
    // 编码时z≤0的UV有特殊处理，可通过uv范围或计算特征判断
    bool isBackFace = (abs(u) + abs(v) > 1.001f); // 正面uv的|u|+|v|≤1，背面会略大于1

    if (!isBackFace)
    {
        // 正面：还原x = u*d, y = v*d，其中d = |x| + |y| + |z|
        // 推导：d = sqrt(1/(u² + v² + 1))（基于单位向量x²+y²+z²=1）
        float d = 1.0f / sqrt(u * u + v * v + 1.0f);
        x = u * d;
        y = v * d;
        z = d; // 正面z为正
    }
    else
    {
        // 背面：还原编码时的调整逻辑
        float signX = u >= 0 ? 1.0f : -1.0f;
        float signY = v >= 0 ? 1.0f : -1.0f;

        // 反推原始o.x和o.y（编码前的中间值）
        float ox = signX * (1.0f - abs(v));
        float oy = signY * (1.0f - abs(u));

        // 计算d和z（背面z为负）
        float d = 1.0f / sqrt(ox * ox + oy * oy + 1.0f);
        x = ox * d;
        y = oy * d;
        z = -d; // 背面z为负
    }

    // 得到TBN空间的法线向量
    float3 normalTS = float3(x, y, z);

    return TransformTangentToWorldNormal(normalTS, tangentWS, bitangentWS, normalWS);
}

float3 DecodeOctahedralSmoothNormalUV(float2 uv, float3 tangentWS, float3 bitangentWS, float3 normalWS)
{
    // 1. UV范围转换：[0,1] → [-1,1]（逆编码时的UV映射）
    float2 octCoord = uv * 2.0 - 1.0; // octCoord: 八面体坐标（x,y ∈ [-1,1]）

    // 2. 计算八面体坐标的L1范数（|x| + |y|），用于判断半球
    float absOctX = abs(octCoord.x);
    float absOctY = abs(octCoord.y);
    float l1Norm = absOctX + absOctY;

    // 3. 八面体解码：还原切线空间3D法线（tangentNormal ∈ 切线空间，单位向量）
    float3 normalTS;
    const float epsilon = 1e-6; // 避免浮点精度问题
    if (l1Norm <= 1.0 + epsilon)
    {
        // 正半球（n_z ≥ 0）：直接反推z分量
        normalTS.x = octCoord.x;
        normalTS.y = octCoord.y;
        normalTS.z = 1.0 - l1Norm; // z = 1 - (|x| + |y|)
    }
    else
    {
        // 负半球（n_z < 0）：逆折叠操作，先取符号再计算x/y
        float signX = octCoord.x > epsilon ? 1.0 : (octCoord.x < -epsilon ? -1.0 : 0.0);
        float signY = octCoord.y > epsilon ? 1.0 : (octCoord.y < -epsilon ? -1.0 : 0.0);

        normalTS.x = signX * (1.0 - absOctY);
        normalTS.y = signY * (1.0 - absOctX);
        normalTS.z = l1Norm - 1.0; // z = (|x| + |y|) - 1
    }
    // 归一化：确保切线空间法线是单位向量（抵消解码误差）
    normalTS = normalize(normalTS);

    return TransformTangentToWorldNormal(normalTS, tangentWS, bitangentWS, normalWS);
}

// 柏林噪声
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
struct VertexData
{
    float4 positionOS : POSITION;
    float2 texcoord : TEXCOORD0;

#if defined(UES_UV_PROJECTION_SMOOTH_NORMAL)

    float2 uvProjectionUV : TEXCOORD1;

#endif

#if defined(UES_OCTAHEDRAL_SMOOTH_NORMAL)

    float2 OctahedralsmoothNormalUV : TEXCOORD2; // for debug

#endif

    float4 normalOS : NORMAL;
    float4 tangentOS : TANGENT;
    float4 color : COLOR;
};

struct v2f
{
    float4 positionCS : SV_POSITION;
    float2 uv : TEXCOORD0;
};


#if defined(USE_OUTLINE)

// ---------------- Uniform Variable ---------------------
TEXTURE2D(_AlbedoMap);
SAMPLER(sampler_AlbedoMap);

float _OutlineZOffset;
float _OutlineWidth;
float4 _OutlineColor;
float _ExtendClampFactor;

#if defined(USE_PERLIN_NOISE)

float4 _NoiseTillOffset;
float _NoiseAmplify;

#endif

// ---------------- Shader Stage ---------------------
v2f OutlineVert(VertexData input)
{
    v2f output;

    output.uv = input.texcoord;

    VertexPositionInputs vertexInput = GetVertexPositionInputs(input.positionOS.xyz);
    VertexNormalInputs normalInputs = GetVertexNormalInputs(input.normalOS.xyz, input.tangentOS);

    // Smooth Normal Mode
    float3 normalWS = 0;

    // 模型世界法线
#if defined(USE_MODEL_NORMAL)

     normalWS = TransformObjectToWorldNormal(input.normalOS);
                
#endif


    // uv Projection
#if defined(UES_UV_PROJECTION_SMOOTH_NORMAL)

    normalWS = DecodeUVProjectionSmoothNormal(input.uvProjectionUV, normalInputs.tangentWS, normalInputs.bitangentWS,
                                              normalInputs.normalWS).rgb;

#endif

    // 八面体投影
#if defined(UES_OCTAHEDRAL_SMOOTH_NORMAL)

    normalWS = DecodeOctahedralSmoothNormalUV(input.OctahedralsmoothNormalUV, normalInputs.tangentWS,
                                              normalInputs.bitangentWS, normalInputs.normalWS).rgb;

#endif

    // Adjust Outline Width
    float outlineWidth = 0;

#if defined(USE_PERLIN_NOISE)

    float2 noiseSampleUV = input.texcoord;
    noiseSampleUV = noiseSampleUV * _NoiseTillOffset.xy + _NoiseTillOffset.zw;
    float noiseWidth = perlin_noise(noiseSampleUV);
    noiseWidth = noiseWidth * 2 - 1; // ndc Space (-1, 1)   

    outlineWidth = _OutlineWidth * 0.025 * noiseWidth * _NoiseAmplify;
#else

    outlineWidth = _OutlineWidth * 0.025;
                
#endif

    // 求得 X 因屏幕比例缩放的倍数
    float4 scaledScreenParams = GetScaledScreenParams();
    float ScaleX = abs(scaledScreenParams.y / scaledScreenParams.x);

    float3 normalCS = TransformWorldToHClipDir(normalWS); //法线转换到裁剪空间
    float3 extendDir = normalize(normalCS.xyz) * outlineWidth * input.color.a; //根据法线和线宽计算偏移量
    extendDir.x *= ScaleX; //由于屏幕比例可能不是1:1，所以偏移量会被拉伸显示，根据屏幕比例把x进行修正

    // Z 偏移
    float4 offsetPosCS = vertexInput.positionCS;
    offsetPosCS.z += -_OutlineZOffset;
    output.positionCS = offsetPosCS;

    // 屏幕下描边宽度不变，则需要顶点偏移的距离在NDC坐标下为固定值
    // 因为后续会转换成NDC坐标，会除w进行缩放，所以先乘一个w，那么该偏移的距离就不会在NDC下有变换
    float clampW = _ExtendClampFactor * clamp(1 / output.positionCS.w, 0, 1);

    // for debug
    // output.positionCS.xy += extendDir.xy;
    // output.positionCS.xy += extendDir.xy * output.positionCS.w;
    
    
    output.positionCS.xy += extendDir.xy * output.positionCS.w * clampW;

    return output;
}

float4 OutlineFrag(v2f input) : SV_Target
{
    float2 uv = input.uv;

    float3 baseColor = SAMPLE_TEXTURE2D(_AlbedoMap, sampler_AlbedoMap, uv).rgb;
    half maxComponent = max(max(baseColor.r, baseColor.g), baseColor.b) - 0.004;
    half3 saturatedColor = step(maxComponent.rrr, baseColor) * baseColor;
    saturatedColor = lerp(baseColor.rgb, saturatedColor, 0.4);
    half3 outlineColor = 0.8 * saturatedColor * baseColor * _OutlineColor.xyz;

    return float4(outlineColor, 1.0);
}

#else

v2f OutlineVert(VertexData input)
{
    v2f output;
    float4 posCS = TransformObjectToHClip(input.positionOS);
    output.positionCS = posCS;
    output.uv = input.texcoord;

    return output;
}

float4 OutlineFrag(v2f input) : SV_Target
{
    return float4(0, 0, 0, 1.0);
}

#endif
