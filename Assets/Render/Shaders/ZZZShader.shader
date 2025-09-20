Shader "CelShaders/ZZZShader"
{
    Properties
    {
        // Domain
        [Title(Domain)]
        [Main(DomainGruop, _, off, off)] _DomainSettings ("Domain Settings", float) = 1
        [KWEnum(DomainGruop, Face, IS_FACE, Body, IS_BODY, Hair, IS_HAIR)]
        _Domain ("Domain", float) = 0
        
        // Debug Mode 
        [Title(Debug)]
        [Main(DebugGroup, DEBUG_MODE, off, on)] _DebugMode ("Use Debug Mode", float) = 1
        
        // Outline
        [Title(OutlineGruop, Outline Settings)]
        [Main(OutlineGruop, USE_OUTLINE, off, on)] _UseOutline ("Outline", float) = 1
        [Sub(OutlineGruop)] _OutlineColor("Outline Color", Color) = (0, 0, 0, 1)
        [Sub(OutlineGruop)] _OutlineWidth("Outline Width", Range(0, 2)) = 0.3
        [Sub(OutlineGruop)] _OutlineZOffset("Outline Z Offset", Range(0, 0.01)) = 0.00025
        
        
        // Albedo
        [Title(Albedo Settings)]
        [Main(AlbedoGroup, _, off, off)] _AlbedoSettings ("Albedo Settings", float) = 1
        [Tex(AlbedoGroup, Color)] _AlbedoMap("Albedo", 2D) = "white" {}
        [Sub(AlbedoGroup)] _MainTint("Tint", Color) = (1, 1, 1, 1)
        
        // Attenuation Mode
        [KWEnum(AlbedoGroup, Sigmoid Attenuation, USE_SIGMOID_ATTENUATION, Ramp Attenuation, USE_RAMP_ATTENUATION, Linear Partitioned Attenuation, USE_LINEAR_PARTITIONED_ATTENUATION)]
         _AttenuationMode("Attenuation Mode", Int) = 2

        [Title(Attenuation Modes(You Should Set The Mode in Albedo Settings))]
        
        // Sigmoid Attenuation
        [Main(SigmoidGroup, _, off, off)] _SigmoidSettings ("Sigmoid Settings", float) = 1
        [Sub(SigmoidGroup)] _SigmoidAttenuationColor        ("Sigmoid Color", Color)   = (0, 0, 0, 1)
        [Sub(SigmoidGroup)] _SigmoidAttenuationOffset       ("Sigmoid Offset", Range(0, 1)) = 0
        [Sub(SigmoidGroup)] _SigmoidAttenuationSmoothness   ("Sigmoid Smoothness", Range(1.5, 3.5)) = 1.0
        [Sub(SigmoidGroup)] _SigmoidAttenuationStrength     ("Sigmoid Strength", Range(0, 4)) = 1.0                                
                                        
        
        // Ramp Attenuation
        [Main(RampGroup, _, off, off)] _RampSettings ("Ramp Settings", float) = 1
        [Sub(RampGroup)] _RampTex                     ("Ramp Texture", 2D) = "white" {}
        [Sub(RampGroup)] _RampAttenuationOffset       ("Ramp Offset", Range(-0.75, 0.75)) = 0
        [Sub(RampGroup)] _RampAttenuationSmoothness   ("Ramp Smoothness", Range(0.5, 5)) = 1.0
        [Sub(RampGroup)] _RampAttenuationStrength     ("Ramp Strength", Range(0, 4)) = 1.0
        
                
        // Linear Partitioned Attenuation
        [Main(LinearGroup, _, off, off)] _LinearSettings ("Linear Settings", float) = 1
        [Sub(LinearGroup)] _DiffuseOffset("Diffuse Offset", Range(-1, 1)) = 0.0
        [Sub(LinearGroup)] _AlbedoSmoothness("Albedo Smoothness", Range(0, 0.65)) = 0.1
        
        // Albedo Tint
        [Sub(LinearGroup)] _ShadowColor1("Shadow Color1", Color) = (0, 0, 0, 1)
        [Sub(LinearGroup)] _ShadowColor2("Shadow Color2", Color) = (0, 0, 0, 1)
        [Sub(LinearGroup)] _ShadowColor3("Shadow Color3", Color) = (0, 0, 0, 1)
        [Sub(LinearGroup)] _ShadowColor4("Shadow Color4", Color) = (0, 0, 0, 1)
        [Sub(LinearGroup)] _ShadowColor5("Shadow Color5", Color) = (0, 0, 0, 1)
        
        [Sub(LinearGroup)] _ShallowColor1("Shallow Color1", Color) = (1, 1, 1, 1)
        [Sub(LinearGroup)] _ShallowColor2("Shallow Color2", Color) = (1, 1, 1, 1)
        [Sub(LinearGroup)] _ShallowColor3("Shallow Color3", Color) = (1, 1, 1, 1)
        [Sub(LinearGroup)] _ShallowColor4("Shallow Color4", Color) = (1, 1, 1, 1)
        [Sub(LinearGroup)] _ShallowColor5("Shallow Color5", Color) = (1, 1, 1, 1)
        
        [Sub(LinearGroup)] _PostShadowFadeTint   ("Post Shadow Fade Tint", Color) = (1, 1, 1, 1)
        [Sub(LinearGroup)] _PostShadowTint       ("Post Shadow Tint", Color) = (0.610496, 0.610496, 0.610496, 1)
        [Sub(LinearGroup)] _PostShallowFadeTint  ("Post Shallow Fade Tint", Color) = (0.791298, 0.791298, 0.791298, 1)
        [Sub(LinearGroup)] _PostShallowTint      ("Post Shallow Tint", Color) = (0.791298, 0.791298, 0.791298, 1)
        [Sub(LinearGroup)] _PostSSSTint          ("Post SSS Tint", Color) = (1, 0.879623, 0.799103, 1)
        [Sub(LinearGroup)] _PostFrontTint        ("Post Front Tint", Color) = (1, 1, 1, 1)
        
        // Normal Texture
        [Title(Normal Texture Settings)]
        [Main(NormalGroup, _, off, off)] _NormalTexSettings ("Normal Settings", float) = 1
        
        [Tex(NormalGroup, Color)] _NormalTex("Normal Map", 2D) = "Bump" {}
        [Sub(NormalGroup)] _BumpScale("Bump Scale", Range(0, 2.0)) = 1.0
        
        // M Texture
        [Title(M Texture Settings)]
        [Main(MTexGroup, _, off, off)] _MTexSettings ("M Texture Settings", float) = 1
        
        [Tex(MTexGroup, Color)] _MTex("M Texture", 2D) = "white" {}
        [Sub(MTexGroup)] _Metallic("Metallic", Range(0, 3)) = 1.0
        [Sub(MTexGroup)] _Smoothness("Smoothness", Range(0, 2)) = 1.0
        
        //////////////////////////////////////////////////////////
        [Title(Render State Settings)]
        [Main(PassGroup, _, off, off)] _PassSettings ("Render State Settings", float) = 1
        
        // Alpha Cut out
        [Sub(PassGroup)] _Cutoff("Alpha cut out", Range(0.0, 1.0)) = 0.5

        // BlendMode
        [Sub(PassGroup)] _Surface("__surface", Float) = 0.0
        [Sub(PassGroup)] _Blend("__mode", Float) = 0.0
        [Sub(PassGroup)] _Cull("__cull", Float) = 2.0
        [HideInInspector] [ToggleUI] _AlphaClip("__clip", Float) = 0.0
        [Sub(PassGroup)] _BlendOp("__blendop", Float) = 0.0
        [Sub(PassGroup)] _SrcBlend("__src", Float) = 1.0
        [Sub(PassGroup)] _DstBlend("__dst", Float) = 0.0
        [Sub(PassGroup)] _SrcBlendAlpha("__srcA", Float) = 1.0
        [Sub(PassGroup)] _DstBlendAlpha("__dstA", Float) = 0.0
        [Sub(PassGroup)] _ZWrite("__zw", Float) = 1.0
        [Sub(PassGroup)] _AlphaToMask("__alphaToMask", Float) = 0.0

        // Editmode props
        [HideInInspector] _QueueOffset("Queue offset", Float) = 0.0

        // ObsoleteProperties
        [HideInInspector] _MainTex("BaseMap", 2D) = "white" {}
        [HideInInspector] _Color("BaseColor", Color) = (0.5, 0.5, 0.5, 1)
        [HideInInspector] _SampleGI("SampleGI", float) = 0.0 // needed from bakedlit
    }

    SubShader
    {
        Tags
        {
            "RenderType" = "Opaque"
            "IgnoreProjector" = "True"
            "UniversalMaterialType" = "Lit"
            "RenderPipeline" = "UniversalPipeline"
        }
        LOD 100

        // Render State Commands
        Blend [_SrcBlend][_DstBlend], [_SrcBlendAlpha][_DstBlendAlpha]
        ZWrite [_ZWrite]
        Cull [_Cull]

        // 前向渲染
        Pass
        {
            Name "ForwardPass"
            Tags
            {
                "LightMode"="UniversalForward"
            }
            
            // -------------------------------------
            // Render State Commands
            AlphaToMask[_AlphaToMask]
            Cull Off

            HLSLPROGRAM
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
                    
            #pragma target 2.0

            // -------------- 宏开关 ---------------
            #pragma shader_feature DEBUG_MODE
            
            #pragma shader_feature IS_FACE
            #pragma shader_feature IS_BODY
            #pragma shader_feature IS_HAIR

            #pragma shader_feature USE_SIGMOID_ATTENUATION
            #pragma shader_feature USE_RAMP_ATTENUATION
            #pragma shader_feature USE_LINEAR_PARTITIONED_ATTENUATION

            // ----------- Shader Stages ----------
            #pragma vertex ZZZVert
            #pragma fragment ZZZFrag
            
            // -------------------------------------
            // Material Keywords
            #pragma shader_feature_local_fragment _SURFACE_TYPE_TRANSPARENT
            #pragma shader_feature_local_fragment _ALPHATEST_ON
            #pragma shader_feature_local_fragment _ALPHAMODULATE_ON

            // -------------------------------------
            // Unity defined keywords
            #pragma multi_compile_fog
            #pragma multi_compile_fragment _ _SCREEN_SPACE_OCCLUSION
            #pragma multi_compile_fragment _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3
            #pragma multi_compile _ DEBUG_DISPLAY
            #pragma multi_compile_fragment _ LOD_FADE_CROSSFADE
            #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/RenderingLayers.hlsl"

            // -------------- Base Functions --------------
            #include "Assets/Render/Shaders/ShaderLib/BaseNPRFunctions.hlsl"
            #include "Assets/Render/Shaders/ShaderLib/BasePBRFunctions.hlsl"
            
            //---------------- Structs ---------------------
            struct Attributes
            {
                float4 positionOS : POSITION;
                float2 uv : TEXCOORD0;
                float2 uv1 : TEXCOORD1;// for debug
                
                float3 normalOS : NORMAL;
                float4 tangentOS : TANGENT;
                
                float4 color : COLOR;// for debug
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float3 positionWS : TEXCOORD0;
                float2 uv : TEXCOORD1;
                float2 uv1 : TEXCOORD7;// for debug
                
                float3 normalWS : TEXCOORD2;
                float3 tangentWS : TEXCOORD3;
                float3 bitangentWS : TEXCOORD4;

                float4 color : TEXCOORD5;// for debug
            };

            // ---------------- Uniform Variable ---------------------
            #include "Assets/Render/Shaders/ShaderLib/UniformVarable.hlsl"

            // ---------------- Shader Stages ---------------------
            Varyings ZZZVert(Attributes input)
            {
                Varyings output;
                
                output.uv = input.uv;
                output.uv1 = input.uv1;// for debug
                
                VertexPositionInputs positionInputs = GetVertexPositionInputs(input.positionOS.xyz);
                output.positionCS = positionInputs.positionCS;
                output.positionWS = positionInputs.positionWS;
                
                VertexNormalInputs normalInputs = GetVertexNormalInputs(input.normalOS, input.tangentOS);
                output.normalWS = normalInputs.normalWS;
                output.tangentWS = normalInputs.tangentWS;
                output.bitangentWS = normalInputs.bitangentWS;

                output.color = input.color;// for debug
                
                return output;
            }

            float4 ZZZFrag(Varyings input) : SV_Target
            {
                // ------ Main Vector ------
                Light mainLight = GetMainLight();
                float3 lightDir = normalize(mainLight.direction);
                float3 viewDir = normalize(_WorldSpaceCameraPos - input.positionWS);
                
                // ------ Texture Data ------
                // Albedo Texture
                float4 albedo = DecodeAlbedoTexture(_AlbedoMap, sampler_AlbedoMap, input.uv);
#ifndef IS_FACE
                // Decode Normal Texture
                NormalTexData normalTexData = DecodeNormalTexture(_NormalTex, sampler_NormalTex, input.uv, input.tangentWS, input.bitangentWS, input.normalWS, _BumpScale);
        
                // Decode M Texture
                MTexData mTexData = DecodeMTexture(_MTex, sampler_MTex, input.uv);
#endif

#ifdef IS_FACE
                NormalTexData normalTexData;
                normalTexData.normalWS = input.normalWS;
                normalTexData.diffuseBias = 0;
        
                MTexData mTexData;
                mTexData.materialID = 0;
                mTexData.metallic = 0;
                mTexData.smoothness = 0;
                mTexData.specular = 0;
#endif

                // ------ Base Data ------
                float2 uv = input.uv;
                float2 uv1 = input.uv1;// for debug
                float3 lightColor = mainLight.color;

                float diffuseBias = normalTexData.diffuseBias;
                float3 normalWS = normalTexData.normalWS;
                
                float materialID = mTexData.materialID;
                float metallic = lerp(0, mTexData.metallic, _Metallic);
                float smoothness = lerp(0, mTexData.smoothness, _Smoothness);
                float specular  = mTexData.specular;
                
                float NoL = dot(normalWS, lightDir);
                float NoV = dot(normalWS, viewDir);


#ifdef DEBUG_MODE
                
                return half4(materialID.xxx / 4, 1);
                
#endif
                // ------ Cel Shading ------
                // Albedo
                float3 albedoColor = 0;
                
                
#if defined(USE_SIGMOID_ATTENUATION) || defined(USE_RAMP_ATTENUATION)

                float halfLambert = clamp(NoL * 0.5 + 0.5, 0, 1);
#endif

#ifdef USE_SIGMOID_ATTENUATION

                float shadowArea = sigmoid(1 - halfLambert, _SigmoidAttenuationOffset, _SigmoidAttenuationSmoothness * 10) * _SigmoidAttenuationStrength;
                float3 sigmoidShadow = lerp(1, _SigmoidAttenuationColor.rgb, shadowArea);
                albedoColor = albedo.rgb * sigmoidShadow;

                
#endif

                
#ifdef USE_RAMP_ATTENUATION
                
                halfLambert = clamp(pow(halfLambert, _RampAttenuationSmoothness) + _RampAttenuationOffset, 0.0001, 0.9999);
                float3 shadowRamp = SampleShadowRamp(_RampTex, sampler_RampTex, float2(halfLambert,materialID / 4)).rgb * _RampAttenuationStrength;
                albedoColor = albedo.rgb * shadowRamp;

#endif

#ifdef USE_LINEAR_PARTITIONED_ATTENUATION
                
                // attenuation
                AttenuationData attenuation = CalculateAttenuation(_AlbedoSmoothness, NoL, diffuseBias + _DiffuseOffset);

                // Select Color by MaterialID
                float4 selectedShadowColor = SelectByMaterialID(materialID, _ShadowColor1, _ShadowColor2, _ShadowColor3, _ShadowColor4, _ShadowColor5);
                float4 selectedShallowColor = SelectByMaterialID(materialID, _ShallowColor1, _ShallowColor2, _ShallowColor3, _ShallowColor4, _ShallowColor5);

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

                BRDFData brdfData;
                brdfData.albedo = albedo.rgb;
                brdfData.diffuse = albedo.rgb;
                brdfData.specular = specular;
                brdfData.reflectivity = specular;
                brdfData.perceptualRoughness = 1 - smoothness;
                brdfData.roughness = 1 - smoothness;
                brdfData.roughness2 = brdfData.roughness * brdfData.roughness;
                brdfData.grazingTerm;
                brdfData.normalizationTerm = brdfData.roughness * 4 + 2.0; // roughness * 4.0 + 2.0
                brdfData.roughness2MinusOne = brdfData.roughness * brdfData.roughness - 1.0; // roughness^2 - 1.0
                

                // half DirectBRDFSpecular = NPRDirectBRDFSpecular()

                return float4(albedoColor, 1.0);

                return float4(_AttenuationMode.xxx / 1.9, 1.0);
                
                // for debug
                float4 Id = SelectByMaterialID(materialID, float4(1,0,0,1), float4(0,1,0,1), float4(0,0,1,1), float4(1,1,0,1), float4(1,0,1,1));
                return Id;
            }
            
            ENDHLSL
        }

        // 描边
        Pass
        {
            Name "OutLine"
            Tags
            {
                "LightMode" = "SRPDefaultUnlit"
            }
            
            Cull Front
            
            HLSLINCLUDE
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.shadergraph/ShaderGraphLibrary/ShaderVariablesFunctions.hlsl"
            #pragma shader_feature _ENABLE_ALPHA_TEST_ON
            #pragma shader_feature _OLWVWD_ON

            float _OutlineWidth;
            float4 _OutlineColor;

            // -------------- Base Functions --------------
            float3 TransformTangentToWorldNormal(float3 normalTS, float3 tangentWS, float3 bitangentWS, float3 normalWS)
            {
                return normalize(TransformTangentToWorld(normalTS,real3x3(tangentWS, bitangentWS, normalWS)));
            }

            float3 DecodeSmoothNormal(float2 uv, float3 tangentWS, float3 bitangentWS, float3 normalWS)
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

            
            //---------------- Structs ---------------------
            struct VertexData
            {
                float4 positionOS : POSITION;
                float2 texcoord : TEXCOORD0;
                float2 smoothNormalTexcoord : TEXCOORD2;
                float4 normalOS : NORMAL;
                float4 tangentOS : TANGENT;
                float4 color : COLOR;
            };

            struct v2f
            {
                float4 positionCS : SV_POSITION;
                float2 uv : TEXCOORD0;
            };
            ENDHLSL

            
            HLSLPROGRAM
            
            #pragma shader_feature USE_OUTLINE
            
            #ifdef USE_OUTLINE
            #pragma vertex OutlineVert
            #pragma fragment OutlineFrag

            // ---------------- Uniform Variable ---------------------
            float _OutlineZOffset;
            TEXTURE2D(_AlbedoMap);       SAMPLER(sampler_AlbedoMap);
            

            // ---------------- Shader Stage ---------------------
            v2f OutlineVert(VertexData input)
            {
                v2f output;

                output.uv = input.texcoord;
                
                VertexPositionInputs vertexInput = GetVertexPositionInputs(input.positionOS.xyz);
                VertexNormalInputs normalInputs = GetVertexNormalInputs(input.normalOS.xyz, input.tangentOS);
                
                float3 normalWS = DecodeOctahedralSmoothNormalUV(input.smoothNormalTexcoord, normalInputs.tangentWS, normalInputs.bitangentWS, normalInputs.normalWS).rgb;
                
                // 求得 X 因屏幕比例缩放的倍数
                float4 scaledScreenParams = GetScaledScreenParams();
                float ScaleX = abs(scaledScreenParams.y / scaledScreenParams.x); 

                float3 normalCS = TransformWorldToHClipDir(normalWS); //法线转换到裁剪空间
                float3 extendDir = normalize(normalCS.xyz) * (_OutlineWidth * 0.01) * input.color.a; //根据法线和线宽计算偏移量
                extendDir.x *= ScaleX; //由于屏幕比例可能不是1:1，所以偏移量会被拉伸显示，根据屏幕比例把x进行修正
                
                float4 offsetPosCS = vertexInput.positionCS;
                offsetPosCS.z += -_OutlineZOffset;// Z 偏移
                output.positionCS = offsetPosCS;
                
                // 屏幕下描边宽度不变，则需要顶点偏移的距离在NDC坐标下为固定值
                // 因为后续会转换成NDC坐标，会除w进行缩放，所以先乘一个w，那么该偏移的距离就不会在NDC下有变换
                float ctrl = clamp(1 / output.positionCS.w,0,1);
                output.positionCS.xy += extendDir.xy * output.positionCS.w * ctrl;
                
                // output.positionCS.xy += extendDis * output.positionCS.w;
                
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

            
            
            ENDHLSL
        }

        // Fill GBuffer data to prevent "holes", just in case someone wants to reuse GBuffer for non-lighting effects.
        // Deferred lighting is stenciled out.
        Pass
        {
            Name "GBuffer"
            Tags
            {
                "LightMode" = "UniversalGBuffer"
            }

            HLSLPROGRAM
            #pragma target 4.5

            // Deferred Rendering Path does not support the OpenGL-based graphics API:
            // Desktop OpenGL, OpenGL ES 3.0, WebGL 2.0.
            #pragma exclude_renderers gles3 glcore

            // -------------------------------------
            // Shader Stages
            #pragma vertex UnlitPassVertex
            #pragma fragment UnlitPassFragment

            // -------------------------------------
            // Material Keywords
            #pragma shader_feature_local_fragment _ALPHATEST_ON
            #pragma shader_feature_local_fragment _ALPHAMODULATE_ON

            // -------------------------------------
            // Unity defined keywords
            #pragma multi_compile_fragment _ _SCREEN_SPACE_OCCLUSION
            #pragma multi_compile_fragment _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3
            #pragma multi_compile_fragment _ LOD_FADE_CROSSFADE
            #pragma multi_compile_fragment _ _GBUFFER_NORMALS_OCT
            #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/RenderingLayers.hlsl"

            //--------------------------------------
            // GPU Instancing
            #pragma multi_compile_instancing
            #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"

            // -------------------------------------
            // Includes
            #include "Packages/com.unity.render-pipelines.universal/Shaders/UnlitInput.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Shaders/UnlitGBufferPass.hlsl"
            ENDHLSL
        }

        Pass
        {
            Name "DepthOnly"
            Tags
            {
                "LightMode" = "DepthOnly"
            }

            // -------------------------------------
            // Render State Commands
            ZWrite On
            ColorMask R

            HLSLPROGRAM
            #pragma target 2.0

            // -------------------------------------
            // Shader Stages
            #pragma vertex DepthOnlyVertex
            #pragma fragment DepthOnlyFragment

            // -------------------------------------
            // Material Keywords
            #pragma shader_feature_local _ALPHATEST_ON

            // -------------------------------------
            // Unity defined keywords
            #pragma multi_compile_fragment _ LOD_FADE_CROSSFADE

            //--------------------------------------
            // GPU Instancing
            #pragma multi_compile_instancing
            #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"

            // -------------------------------------
            // Includes
            #include "Packages/com.unity.render-pipelines.universal/Shaders/UnlitInput.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Shaders/DepthOnlyPass.hlsl"
            ENDHLSL
        }

        Pass
        {
            Name "DepthNormalsOnly"
            Tags
            {
                "LightMode" = "DepthNormalsOnly"
            }

            // -------------------------------------
            // Render State Commands
            ZWrite On

            HLSLPROGRAM
            #pragma target 2.0

            // -------------------------------------
            // Shader Stages
            #pragma vertex DepthNormalsVertex
            #pragma fragment DepthNormalsFragment

            // -------------------------------------
            // Material Keywords
            #pragma shader_feature_local _ALPHATEST_ON

            // -------------------------------------
            // Universal Pipeline keywords
            #pragma multi_compile_fragment _ _GBUFFER_NORMALS_OCT // forward-only variant
            #pragma multi_compile_fragment _ LOD_FADE_CROSSFADE
            #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/RenderingLayers.hlsl"

            //--------------------------------------
            // GPU Instancing
            #pragma multi_compile_instancing
            #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"

            // -------------------------------------
            // Includes
            #include "Packages/com.unity.render-pipelines.universal/Shaders/UnlitInput.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Shaders/UnlitDepthNormalsPass.hlsl"
            ENDHLSL
        }

        // This pass it not used during regular rendering, only for lightmap baking.
        Pass
        {
            Name "Meta"
            Tags
            {
                "LightMode" = "Meta"
            }

            // -------------------------------------
            // Render State Commands
            Cull Off

            HLSLPROGRAM
            #pragma target 2.0

            // -------------------------------------
            // Shader Stages
            #pragma vertex UniversalVertexMeta
            #pragma fragment UniversalFragmentMetaUnlit

            // -------------------------------------
            // Unity defined keywords
            #pragma shader_feature EDITOR_VISUALIZATION

            // -------------------------------------
            // Includes
            #include "Packages/com.unity.render-pipelines.universal/Shaders/UnlitInput.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Shaders/UnlitMetaPass.hlsl"
            ENDHLSL
        }
    }

    FallBack "Hidden/Universal Render Pipeline/FallbackError"
    // CustomEditor "UnityEditor.Rendering.Universal.ShaderGUI.UnlitShader"
    CustomEditor "LWGUI.LWGUI"
}
