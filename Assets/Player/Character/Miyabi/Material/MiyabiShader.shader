Shader "CelShaders/MiyabiShader"
{
    Properties
    {
        [Toggle] _IsFace("IsFace", Int) = 0
        [Toggle] _IsBody("IsBody", Int) = 0
        [Toggle] _IsHair("IsHair", Int) = 0
        
        [MainTexture] _AlbedoMap("Albedo", 2D) = "white" {}
        [MainColor] _MainTint("Tint", Color) = (1, 1, 1, 1)
        _DiffuseOffset("DiffuseOffset", Range(-1, 1)) = 0.0
        _AlbedoSmoothness("AlbedoSmoothness", Range(0, 0.65)) = 0.1
        
        // Albedo Tint
        _ShadowColor1("ShadowColor1", Color) = (0, 0, 0, 1)
        _ShadowColor2("ShadowColor2", Color) = (0, 0, 0, 1)
        _ShadowColor3("ShadowColor3", Color) = (0, 0, 0, 1)
        _ShadowColor4("ShadowColor4", Color) = (0, 0, 0, 1)
        _ShadowColor5("ShadowColor5", Color) = (0, 0, 0, 1)
        
        _ShallowColor1("ShallowColor1", Color) = (1, 1, 1, 1)
        _ShallowColor2("ShallowColor2", Color) = (1, 1, 1, 1)
        _ShallowColor3("ShallowColor3", Color) = (1, 1, 1, 1)
        _ShallowColor4("ShallowColor4", Color) = (1, 1, 1, 1)
        _ShallowColor5("ShallowColor5", Color) = (1, 1, 1, 1)
        
        _PostShadowFadeTint   ("PostShadowFadeTint", Color) = (1, 1, 1, 1)
        _PostShadowTint       ("PostShadowTint", Color) = (0.610496, 0.610496, 0.610496, 1)
        _PostShallowFadeTint  ("PostShallowFadeTint", Color) = (0.791298, 0.791298, 0.791298, 1)
        _PostShallowTint      ("PostShallowTint", Color) = (0.791298, 0.791298, 0.791298, 1)
        _PostSSSTint          ("PostSSSTint", Color) = (1, 0.879623, 0.799103, 1)
        _PostFrontTint        ("PostFrontTint", Color) = (1, 1, 1, 1)
        
        // Normal Texture
        [Normal] _NormalTex("NormalMap", 2D) = "Bump" {}
        _BumpScale("BumpScale", Range(0, 5.0)) = 1.0
        
        // M Texture
        _MTex("MTexture", 2D) = "white" {}
        
        // Alpha Cut out
        [HideInInspector] _Cutoff("AlphaCutout", Range(0.0, 1.0)) = 0.5

        // BlendMode
        [HideInInspector] _Surface("__surface", Float) = 0.0
        [HideInInspector] _Blend("__mode", Float) = 0.0
        [HideInInspector] _Cull("__cull", Float) = 2.0
        [HideInInspector] [ToggleUI] _AlphaClip("__clip", Float) = 0.0
        [HideInInspector] _BlendOp("__blendop", Float) = 0.0
        [HideInInspector] _SrcBlend("__src", Float) = 1.0
        [HideInInspector] _DstBlend("__dst", Float) = 0.0
        [HideInInspector] _SrcBlendAlpha("__srcA", Float) = 1.0
        [HideInInspector] _DstBlendAlpha("__dstA", Float) = 0.0
        [HideInInspector] _ZWrite("__zw", Float) = 1.0
        [HideInInspector] _AlphaToMask("__alphaToMask", Float) = 0.0

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

        // -------------------------------------
        // Render State Commands
        Blend [_SrcBlend][_DstBlend], [_SrcBlendAlpha][_DstBlendAlpha]
        ZWrite [_ZWrite]
        Cull [_Cull]

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

            HLSLPROGRAM
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
                    
            #pragma target 2.0

            // -------------------------------------
            // Shader Stages
            #pragma vertex Vert
            #pragma fragment Frag

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
            #include "Assets/Player/Character/Miyabi/Shaders/ShaderLib/BaseFunctions.hlsl"
            
            //---------------- Structs ---------------------
            struct Attributes
            {
                float4 positionOS : POSITION;
                float2 uv : TEXCOORD0;
                float2 uvSmoothNormal : TEXCOORD1;
                float3 normalOS : NORMAL;
                float4 tangentOS : TANGENT;
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float3 positionWS : TEXCOORD0;
                float2 uv : TEXCOORD1;
                float3 normalWS : TEXCOORD2;
                float3 tangentWS : TEXCOORD3;
                float3 bitangentWS : TEXCOORD4;
            };

            // ---------------- Uniform Variable ---------------------
            #include "Assets/Player/Character/Miyabi/Shaders/ShaderLib/UniformVarable.hlsl"

            // ---------------- Shader Stages ---------------------
            Varyings Vert(Attributes input)
            {
                Varyings output;
                
                output.uv = input.uv;
                
                VertexPositionInputs positionInputs = GetVertexPositionInputs(input.positionOS.xyz);
                output.positionCS = positionInputs.positionCS;
                output.positionWS = positionInputs.positionWS;
                
                VertexNormalInputs normalInputs = GetVertexNormalInputs(input.normalOS, input.tangentOS);
                output.normalWS = normalInputs.normalWS;
                output.tangentWS = normalInputs.tangentWS;
                output.bitangentWS = normalInputs.bitangentWS;
                
                return output;
            }

            float4 Frag(Varyings input) : SV_Target
            {
                // ------ Main Vector ------
                Light mainLight = GetMainLight();
                float3 lightDir = normalize(mainLight.direction);
                float3 viewDir = normalize(_WorldSpaceCameraPos - input.positionWS);
                
                // ------ Texture Data ------
                // Albedo Texture
                float4 albedo = DecodeAlbedoTexture(_AlbedoMap, sampler_AlbedoMap, input.uv);
                // Decode Normal Texture
                NormalTexData normalTexData = DecodeNormalTexture(_NormalTex, sampler_NormalTex, input.uv, input.tangentWS, input.bitangentWS, input.normalWS, _BumpScale);
                // Decode M Texture
                MTexData mTexData = DecodeMTexture(_MTex, sampler_MTex, input.uv);

                // ------ Base Data ------
                float3 lightColor = mainLight.color;

                float diffuseBias = normalTexData.diffuseBias;
                float3 normalWS = _IsFace ? input.normalWS : normalTexData.normalWS;
                    
                float materialID = mTexData.materialID;
                float metallic   = mTexData.metallic;
                float smoothness = mTexData.smoothness;
                float metalMask  = mTexData.metalMask;
                
                float NoL = dot(normalWS, lightDir);


                // ------ Cel Shading ------
                AttenuationData attenuation = CalculateAttenuation(_AlbedoSmoothness, NoL, diffuseBias + _DiffuseOffset);

                // Select Color by MaterialID
                float4 selectedShadowColor = SelectByMaterialID(materialID, _ShadowColor1, _ShadowColor2, _ShadowColor3, _ShadowColor4, _ShadowColor5);
                float4 selectedShallowColor = SelectByMaterialID(materialID, _ShallowColor1, _ShallowColor2, _ShallowColor3, _ShallowColor4, _ShallowColor5);

                // Tinting
                float3 albedoColor = CalculateAlbedo(
                    selectedShadowColor,
                    selectedShallowColor,
                    _PostShadowFadeTint.rgb,
                    _PostShadowTint.rgb,
                    _PostShallowFadeTint.rgb,
                    _PostShallowTint.rgb,
                    _PostSSSTint.rgb,
                    _PostFrontTint.rgb,
                    attenuation,
                    lightColor);

                return float4(albedoColor, 1.0);

                // for debug
                float4 Id = SelectByMaterialID(materialID, float4(1,0,0,1), float4(0,1,0,1), float4(0,0,1,1), float4(1,1,0,1), float4(1,0,1,1));
                return Id;
            }
            
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
}
