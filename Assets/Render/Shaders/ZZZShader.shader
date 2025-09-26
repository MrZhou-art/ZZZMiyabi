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
        [Sub(OutlineGruop)] _ExtendClampFactor("Outline Extend Clamp Factor", Range(0, 1)) = 1
        
        [KWEnum(OutlineGruop, ModelNormal, USE_MODEL_NORMAL, UV Projection Smooth Normal, UES_UV_PROJECTION_SMOOTH_NORMAL, Octahedral Smooth Normal, UES_OCTAHEDRAL_SMOOTH_NORMAL)]
        _SmoothNormalMode ("Smooth Normal Mode", float) = 2
        
        [KWEnum(OutlineGruop, On, USE_PERLIN_NOISE, Off, _)]
        _PerlinNoise ("Use Perlin Noise", float) = 1
        [Sub(OutlineGruop)] _NoiseTillOffset("Noise Till Offset", Vector) = (100, 100, 0, 0)
        [Sub(OutlineGruop)] _NoiseAmplify("Noise Amplify", Float) = -1
        
        
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
        
        // LightMap
        [Title(LightMap Settings)]
        [Main(LightMapGruop, _, off, off)] LightMapSettings ("LightMap Settings", float) = 1
        [KWEnum(LightMapGruop, Dynamic, DYNAMICLIGHTMAP_ON, Static, _)]
         _LightMapMode("LightMap Mode", Int) = 0
        
//////////////////////////// Render State Settings //////////////////////////////

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
            
            // ----- Render State Commands -------
            AlphaToMask[_AlphaToMask]
            Cull Off

            HLSLPROGRAM
            #pragma target 2.0

            // -------------- 宏开关 ---------------
            #pragma shader_feature DEBUG_MODE

            // TODO: PBR 工作流
            #pragma shader_feature _SPECULAR_SETUP
            #pragma shader_feature DYNAMICLIGHTMAP_ON
            
            #pragma shader_feature IS_FACE
            #pragma shader_feature IS_BODY
            #pragma shader_feature IS_HAIR

            #pragma shader_feature USE_SIGMOID_ATTENUATION
            #pragma shader_feature USE_RAMP_ATTENUATION
            #pragma shader_feature USE_LINEAR_PARTITIONED_ATTENUATION

            
            
            // -------- Shader ----------
            #pragma vertex ZZZVert
            #pragma fragment ZZZFrag
            
            // ------ Material Keywords ---------
            #pragma shader_feature_local_fragment _SURFACE_TYPE_TRANSPARENT
            #pragma shader_feature_local_fragment _ALPHATEST_ON
            #pragma shader_feature_local_fragment _ALPHAMODULATE_ON

            // ---- Unity defined keywords ------
            #pragma multi_compile_fog
            #pragma multi_compile_fragment _ _SCREEN_SPACE_OCCLUSION
            #pragma multi_compile_fragment _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3
            #pragma multi_compile _ DEBUG_DISPLAY
            #pragma multi_compile_fragment _ LOD_FADE_CROSSFADE

            // --------- Shader Stages -----------
            #include "Assets/Render/Shaders/ZZZForwardPass.hlsl"
            
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
            
            HLSLPROGRAM

            
            // -------------- 宏开关 ---------------
            #pragma shader_feature USE_OUTLINE

            // Perlin Noise
            #pragma shader_feature USE_PERLIN_NOISE

            // Smooth Normal Mode
            #pragma shader_feature USE_MODEL_NORMAL
            #pragma shader_feature UES_UV_PROJECTION_SMOOTH_NORMAL
            #pragma shader_feature UES_OCTAHEDRAL_SMOOTH_NORMAL
            
            #pragma shader_feature _ENABLE_ALPHA_TEST_ON
            #pragma shader_feature _OLWVWD_ON



            // -------- Shader ----------
            #pragma vertex OutlineVert
            #pragma fragment OutlineFrag


            
            // --------- Shader Stages -----------
            #include "Assets/Render/Shaders/ZZZOutlinePasss.hlsl"


                
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

            // ------- Render State Commands --------
            ZWrite On

            HLSLPROGRAM
            #pragma target 2.0

            // ---------- Shader Stages--------------
            #pragma vertex DepthNormalsVertex
            #pragma fragment DepthNormalsFragment

            // --------- Material Keywords------------
            #pragma shader_feature_local _ALPHATEST_ON

            // ---- Universal Pipeline keywords -------
            // 
            #pragma multi_compile_fragment _ _GBUFFER_NORMALS_OCT // forward-only variant
            #pragma multi_compile_fragment _ LOD_FADE_CROSSFADE
            #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/RenderingLayers.hlsl"

            //----------- GPU Instancing --------------
            // 
            #pragma multi_compile_instancing
            #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"

            // --------------- Includes --------------
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
