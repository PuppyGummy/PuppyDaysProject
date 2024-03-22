Shader "Custom/BillboardGen"
{
    Properties
    {
        [NoScaleOffset]_MainTex("MainTex", 2D) = "white" {}
        _ColorTint("ColorTint", Color) = (1, 1, 1, 1)
        [HideInInspector]_QueueOffset("_QueueOffset", Float) = 0
        [HideInInspector]_QueueControl("_QueueControl", Float) = -1
        [HideInInspector][NoScaleOffset]unity_Lightmaps("unity_Lightmaps", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset]unity_LightmapsInd("unity_LightmapsInd", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset]unity_ShadowMasks("unity_ShadowMasks", 2DArray) = "" {}
    }
    SubShader
    {
        Tags
        {
            "RenderPipeline"="UniversalPipeline"
            "RenderType"="Transparent"
            "UniversalMaterialType" = "Unlit"
            "Queue"="Transparent"
            "DisableBatching"="true"
            "ShaderGraphShader"="true"
            "ShaderGraphTargetId"="UniversalUnlitSubTarget"
        }
        Pass
        {
            Name "Universal Forward"
            Tags
            {
                // LightMode: <None>
            }
        
        // Render State
        Cull Back
        Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
        ZTest LEqual
        ZWrite Off
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 2.0
        #pragma multi_compile_instancing
        #pragma multi_compile_fog
        #pragma instancing_options renderinglayer
        #pragma vertex vert
        #pragma fragment frag
        
        // Keywords
        #pragma multi_compile _ LIGHTMAP_ON
        #pragma multi_compile _ DIRLIGHTMAP_COMBINED
        #pragma shader_feature _ _SAMPLE_GI
        #pragma multi_compile_fragment _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3
        #pragma multi_compile_fragment _ DEBUG_DISPLAY
        #pragma multi_compile_fragment _ _SCREEN_SPACE_OCCLUSION
        // GraphKeywords: <None>
        
        // Defines
        
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define VARYINGS_NEED_POSITION_WS
        #define VARYINGS_NEED_NORMAL_WS
        #define VARYINGS_NEED_TEXCOORD0
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_UNLIT
        #define _FOG_FRAGMENT 1
        #define _SURFACE_TYPE_TRANSPARENT 1
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/RenderingLayers.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DBuffer.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv0 : TEXCOORD0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS;
             float3 normalWS;
             float4 texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float4 uv0;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float4 texCoord0 : INTERP0;
             float3 positionWS : INTERP1;
             float3 normalWS : INTERP2;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.texCoord0.xyzw = input.texCoord0;
            output.positionWS.xyz = input.positionWS;
            output.normalWS.xyz = input.normalWS;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.texCoord0 = input.texCoord0.xyzw;
            output.positionWS = input.positionWS.xyz;
            output.normalWS = input.normalWS.xyz;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _MainTex_TexelSize;
        float4 _ColorTint;
        CBUFFER_END
        
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_MainTex);
        SAMPLER(sampler_MainTex);
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A * B;
        }
        
        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }
        
        void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            float3 _Vector3_33d2c331174240f183a3f4a02ddae7bc_Out_0_Vector3 = float3(1, 0, 0);
            float _Split_8ea0ecbd03c445409fb4c60fb9b5ba10_R_1_Float = IN.ObjectSpacePosition[0];
            float _Split_8ea0ecbd03c445409fb4c60fb9b5ba10_G_2_Float = IN.ObjectSpacePosition[1];
            float _Split_8ea0ecbd03c445409fb4c60fb9b5ba10_B_3_Float = IN.ObjectSpacePosition[2];
            float _Split_8ea0ecbd03c445409fb4c60fb9b5ba10_A_4_Float = 0;
            float3 _Multiply_aeb53a435e314cae94058263749dfa7f_Out_2_Vector3;
            Unity_Multiply_float3_float3(_Vector3_33d2c331174240f183a3f4a02ddae7bc_Out_0_Vector3, (_Split_8ea0ecbd03c445409fb4c60fb9b5ba10_R_1_Float.xxx), _Multiply_aeb53a435e314cae94058263749dfa7f_Out_2_Vector3);
            float3 _Vector3_702beec8c4db4ae49ca2d2478661fb0b_Out_0_Vector3 = float3(0, 0.7071068, 0.7071068);
            float3 _Multiply_bce4a6411e514e87a0b2b92695dfad67_Out_2_Vector3;
            Unity_Multiply_float3_float3((_Split_8ea0ecbd03c445409fb4c60fb9b5ba10_G_2_Float.xxx), _Vector3_702beec8c4db4ae49ca2d2478661fb0b_Out_0_Vector3, _Multiply_bce4a6411e514e87a0b2b92695dfad67_Out_2_Vector3);
            float3 _Add_678b38c020fd495b9757d16172c4371b_Out_2_Vector3;
            Unity_Add_float3(_Multiply_aeb53a435e314cae94058263749dfa7f_Out_2_Vector3, _Multiply_bce4a6411e514e87a0b2b92695dfad67_Out_2_Vector3, _Add_678b38c020fd495b9757d16172c4371b_Out_2_Vector3);
            float3 _Vector3_5494654f26e94b2cbb0491bbccc6783a_Out_0_Vector3 = float3(0, 0.7071068, -0.7071068);
            float3 _Multiply_c948b0e7effa4e7594458520aec1f26d_Out_2_Vector3;
            Unity_Multiply_float3_float3((_Split_8ea0ecbd03c445409fb4c60fb9b5ba10_B_3_Float.xxx), _Vector3_5494654f26e94b2cbb0491bbccc6783a_Out_0_Vector3, _Multiply_c948b0e7effa4e7594458520aec1f26d_Out_2_Vector3);
            float3 _Add_aaeb70621f474a03896bbf39a1b54726_Out_2_Vector3;
            Unity_Add_float3(_Add_678b38c020fd495b9757d16172c4371b_Out_2_Vector3, _Multiply_c948b0e7effa4e7594458520aec1f26d_Out_2_Vector3, _Add_aaeb70621f474a03896bbf39a1b54726_Out_2_Vector3);
            description.Position = _Add_aaeb70621f474a03896bbf39a1b54726_Out_2_Vector3;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float3 BaseColor;
            float Alpha;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float4 _Property_34d8e5a242f742b29ae7608eaddc08d2_Out_0_Vector4 = _ColorTint;
            UnityTexture2D _Property_44cf21bb858540a0a2e62f58cd8e8a91_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_MainTex);
            float4 _SampleTexture2D_3c64c0fdf6e549f582c16e19208b632f_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_44cf21bb858540a0a2e62f58cd8e8a91_Out_0_Texture2D.tex, _Property_44cf21bb858540a0a2e62f58cd8e8a91_Out_0_Texture2D.samplerstate, _Property_44cf21bb858540a0a2e62f58cd8e8a91_Out_0_Texture2D.GetTransformedUV(IN.uv0.xy) );
            float _SampleTexture2D_3c64c0fdf6e549f582c16e19208b632f_R_4_Float = _SampleTexture2D_3c64c0fdf6e549f582c16e19208b632f_RGBA_0_Vector4.r;
            float _SampleTexture2D_3c64c0fdf6e549f582c16e19208b632f_G_5_Float = _SampleTexture2D_3c64c0fdf6e549f582c16e19208b632f_RGBA_0_Vector4.g;
            float _SampleTexture2D_3c64c0fdf6e549f582c16e19208b632f_B_6_Float = _SampleTexture2D_3c64c0fdf6e549f582c16e19208b632f_RGBA_0_Vector4.b;
            float _SampleTexture2D_3c64c0fdf6e549f582c16e19208b632f_A_7_Float = _SampleTexture2D_3c64c0fdf6e549f582c16e19208b632f_RGBA_0_Vector4.a;
            float4 _Multiply_722b821a6cdf408cac5f8691e43e03c1_Out_2_Vector4;
            Unity_Multiply_float4_float4(_Property_34d8e5a242f742b29ae7608eaddc08d2_Out_0_Vector4, _SampleTexture2D_3c64c0fdf6e549f582c16e19208b632f_RGBA_0_Vector4, _Multiply_722b821a6cdf408cac5f8691e43e03c1_Out_2_Vector4);
            float _Split_cea6bc0fd68a4855b1521db985502486_R_1_Float = _Multiply_722b821a6cdf408cac5f8691e43e03c1_Out_2_Vector4[0];
            float _Split_cea6bc0fd68a4855b1521db985502486_G_2_Float = _Multiply_722b821a6cdf408cac5f8691e43e03c1_Out_2_Vector4[1];
            float _Split_cea6bc0fd68a4855b1521db985502486_B_3_Float = _Multiply_722b821a6cdf408cac5f8691e43e03c1_Out_2_Vector4[2];
            float _Split_cea6bc0fd68a4855b1521db985502486_A_4_Float = _Multiply_722b821a6cdf408cac5f8691e43e03c1_Out_2_Vector4[3];
            surface.BaseColor = (_Multiply_722b821a6cdf408cac5f8691e43e03c1_Out_2_Vector4.xyz);
            surface.Alpha = _Split_cea6bc0fd68a4855b1521db985502486_A_4_Float;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
        #if VFX_USE_GRAPH_VALUES
            uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
            /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
        #endif
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
        
        
        
            #if UNITY_UV_STARTS_AT_TOP
            #else
            #endif
        
        
            output.uv0 = input.texCoord0;
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/UnlitPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "DepthNormalsOnly"
            Tags
            {
                "LightMode" = "DepthNormalsOnly"
            }
        
        // Render State
        Cull Back
        ZTest LEqual
        ZWrite On
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 2.0
        #pragma multi_compile_instancing
        #pragma vertex vert
        #pragma fragment frag
        
        // Keywords
        #pragma multi_compile_fragment _ _GBUFFER_NORMALS_OCT
        // GraphKeywords: <None>
        
        // Defines
        
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define VARYINGS_NEED_NORMAL_WS
        #define VARYINGS_NEED_TEXCOORD0
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_DEPTHNORMALSONLY
        #define _SURFACE_TYPE_TRANSPARENT 1
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/RenderingLayers.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv0 : TEXCOORD0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 normalWS;
             float4 texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float4 uv0;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float4 texCoord0 : INTERP0;
             float3 normalWS : INTERP1;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.texCoord0.xyzw = input.texCoord0;
            output.normalWS.xyz = input.normalWS;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.texCoord0 = input.texCoord0.xyzw;
            output.normalWS = input.normalWS.xyz;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _MainTex_TexelSize;
        float4 _ColorTint;
        CBUFFER_END
        
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_MainTex);
        SAMPLER(sampler_MainTex);
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A * B;
        }
        
        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }
        
        void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            float3 _Vector3_33d2c331174240f183a3f4a02ddae7bc_Out_0_Vector3 = float3(1, 0, 0);
            float _Split_8ea0ecbd03c445409fb4c60fb9b5ba10_R_1_Float = IN.ObjectSpacePosition[0];
            float _Split_8ea0ecbd03c445409fb4c60fb9b5ba10_G_2_Float = IN.ObjectSpacePosition[1];
            float _Split_8ea0ecbd03c445409fb4c60fb9b5ba10_B_3_Float = IN.ObjectSpacePosition[2];
            float _Split_8ea0ecbd03c445409fb4c60fb9b5ba10_A_4_Float = 0;
            float3 _Multiply_aeb53a435e314cae94058263749dfa7f_Out_2_Vector3;
            Unity_Multiply_float3_float3(_Vector3_33d2c331174240f183a3f4a02ddae7bc_Out_0_Vector3, (_Split_8ea0ecbd03c445409fb4c60fb9b5ba10_R_1_Float.xxx), _Multiply_aeb53a435e314cae94058263749dfa7f_Out_2_Vector3);
            float3 _Vector3_702beec8c4db4ae49ca2d2478661fb0b_Out_0_Vector3 = float3(0, 0.7071068, 0.7071068);
            float3 _Multiply_bce4a6411e514e87a0b2b92695dfad67_Out_2_Vector3;
            Unity_Multiply_float3_float3((_Split_8ea0ecbd03c445409fb4c60fb9b5ba10_G_2_Float.xxx), _Vector3_702beec8c4db4ae49ca2d2478661fb0b_Out_0_Vector3, _Multiply_bce4a6411e514e87a0b2b92695dfad67_Out_2_Vector3);
            float3 _Add_678b38c020fd495b9757d16172c4371b_Out_2_Vector3;
            Unity_Add_float3(_Multiply_aeb53a435e314cae94058263749dfa7f_Out_2_Vector3, _Multiply_bce4a6411e514e87a0b2b92695dfad67_Out_2_Vector3, _Add_678b38c020fd495b9757d16172c4371b_Out_2_Vector3);
            float3 _Vector3_5494654f26e94b2cbb0491bbccc6783a_Out_0_Vector3 = float3(0, 0.7071068, -0.7071068);
            float3 _Multiply_c948b0e7effa4e7594458520aec1f26d_Out_2_Vector3;
            Unity_Multiply_float3_float3((_Split_8ea0ecbd03c445409fb4c60fb9b5ba10_B_3_Float.xxx), _Vector3_5494654f26e94b2cbb0491bbccc6783a_Out_0_Vector3, _Multiply_c948b0e7effa4e7594458520aec1f26d_Out_2_Vector3);
            float3 _Add_aaeb70621f474a03896bbf39a1b54726_Out_2_Vector3;
            Unity_Add_float3(_Add_678b38c020fd495b9757d16172c4371b_Out_2_Vector3, _Multiply_c948b0e7effa4e7594458520aec1f26d_Out_2_Vector3, _Add_aaeb70621f474a03896bbf39a1b54726_Out_2_Vector3);
            description.Position = _Add_aaeb70621f474a03896bbf39a1b54726_Out_2_Vector3;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float Alpha;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float4 _Property_34d8e5a242f742b29ae7608eaddc08d2_Out_0_Vector4 = _ColorTint;
            UnityTexture2D _Property_44cf21bb858540a0a2e62f58cd8e8a91_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_MainTex);
            float4 _SampleTexture2D_3c64c0fdf6e549f582c16e19208b632f_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_44cf21bb858540a0a2e62f58cd8e8a91_Out_0_Texture2D.tex, _Property_44cf21bb858540a0a2e62f58cd8e8a91_Out_0_Texture2D.samplerstate, _Property_44cf21bb858540a0a2e62f58cd8e8a91_Out_0_Texture2D.GetTransformedUV(IN.uv0.xy) );
            float _SampleTexture2D_3c64c0fdf6e549f582c16e19208b632f_R_4_Float = _SampleTexture2D_3c64c0fdf6e549f582c16e19208b632f_RGBA_0_Vector4.r;
            float _SampleTexture2D_3c64c0fdf6e549f582c16e19208b632f_G_5_Float = _SampleTexture2D_3c64c0fdf6e549f582c16e19208b632f_RGBA_0_Vector4.g;
            float _SampleTexture2D_3c64c0fdf6e549f582c16e19208b632f_B_6_Float = _SampleTexture2D_3c64c0fdf6e549f582c16e19208b632f_RGBA_0_Vector4.b;
            float _SampleTexture2D_3c64c0fdf6e549f582c16e19208b632f_A_7_Float = _SampleTexture2D_3c64c0fdf6e549f582c16e19208b632f_RGBA_0_Vector4.a;
            float4 _Multiply_722b821a6cdf408cac5f8691e43e03c1_Out_2_Vector4;
            Unity_Multiply_float4_float4(_Property_34d8e5a242f742b29ae7608eaddc08d2_Out_0_Vector4, _SampleTexture2D_3c64c0fdf6e549f582c16e19208b632f_RGBA_0_Vector4, _Multiply_722b821a6cdf408cac5f8691e43e03c1_Out_2_Vector4);
            float _Split_cea6bc0fd68a4855b1521db985502486_R_1_Float = _Multiply_722b821a6cdf408cac5f8691e43e03c1_Out_2_Vector4[0];
            float _Split_cea6bc0fd68a4855b1521db985502486_G_2_Float = _Multiply_722b821a6cdf408cac5f8691e43e03c1_Out_2_Vector4[1];
            float _Split_cea6bc0fd68a4855b1521db985502486_B_3_Float = _Multiply_722b821a6cdf408cac5f8691e43e03c1_Out_2_Vector4[2];
            float _Split_cea6bc0fd68a4855b1521db985502486_A_4_Float = _Multiply_722b821a6cdf408cac5f8691e43e03c1_Out_2_Vector4[3];
            surface.Alpha = _Split_cea6bc0fd68a4855b1521db985502486_A_4_Float;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
        #if VFX_USE_GRAPH_VALUES
            uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
            /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
        #endif
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
        
        
        
            #if UNITY_UV_STARTS_AT_TOP
            #else
            #endif
        
        
            output.uv0 = input.texCoord0;
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DepthNormalsOnlyPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "ShadowCaster"
            Tags
            {
                "LightMode" = "ShadowCaster"
            }
        
        // Render State
        Cull Back
        ZTest LEqual
        ZWrite On
        ColorMask 0
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 2.0
        #pragma multi_compile_instancing
        #pragma vertex vert
        #pragma fragment frag
        
        // Keywords
        #pragma multi_compile_vertex _ _CASTING_PUNCTUAL_LIGHT_SHADOW
        // GraphKeywords: <None>
        
        // Defines
        
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define VARYINGS_NEED_NORMAL_WS
        #define VARYINGS_NEED_TEXCOORD0
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_SHADOWCASTER
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv0 : TEXCOORD0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 normalWS;
             float4 texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float4 uv0;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float4 texCoord0 : INTERP0;
             float3 normalWS : INTERP1;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.texCoord0.xyzw = input.texCoord0;
            output.normalWS.xyz = input.normalWS;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.texCoord0 = input.texCoord0.xyzw;
            output.normalWS = input.normalWS.xyz;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _MainTex_TexelSize;
        float4 _ColorTint;
        CBUFFER_END
        
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_MainTex);
        SAMPLER(sampler_MainTex);
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A * B;
        }
        
        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }
        
        void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            float3 _Vector3_33d2c331174240f183a3f4a02ddae7bc_Out_0_Vector3 = float3(1, 0, 0);
            float _Split_8ea0ecbd03c445409fb4c60fb9b5ba10_R_1_Float = IN.ObjectSpacePosition[0];
            float _Split_8ea0ecbd03c445409fb4c60fb9b5ba10_G_2_Float = IN.ObjectSpacePosition[1];
            float _Split_8ea0ecbd03c445409fb4c60fb9b5ba10_B_3_Float = IN.ObjectSpacePosition[2];
            float _Split_8ea0ecbd03c445409fb4c60fb9b5ba10_A_4_Float = 0;
            float3 _Multiply_aeb53a435e314cae94058263749dfa7f_Out_2_Vector3;
            Unity_Multiply_float3_float3(_Vector3_33d2c331174240f183a3f4a02ddae7bc_Out_0_Vector3, (_Split_8ea0ecbd03c445409fb4c60fb9b5ba10_R_1_Float.xxx), _Multiply_aeb53a435e314cae94058263749dfa7f_Out_2_Vector3);
            float3 _Vector3_702beec8c4db4ae49ca2d2478661fb0b_Out_0_Vector3 = float3(0, 0.7071068, 0.7071068);
            float3 _Multiply_bce4a6411e514e87a0b2b92695dfad67_Out_2_Vector3;
            Unity_Multiply_float3_float3((_Split_8ea0ecbd03c445409fb4c60fb9b5ba10_G_2_Float.xxx), _Vector3_702beec8c4db4ae49ca2d2478661fb0b_Out_0_Vector3, _Multiply_bce4a6411e514e87a0b2b92695dfad67_Out_2_Vector3);
            float3 _Add_678b38c020fd495b9757d16172c4371b_Out_2_Vector3;
            Unity_Add_float3(_Multiply_aeb53a435e314cae94058263749dfa7f_Out_2_Vector3, _Multiply_bce4a6411e514e87a0b2b92695dfad67_Out_2_Vector3, _Add_678b38c020fd495b9757d16172c4371b_Out_2_Vector3);
            float3 _Vector3_5494654f26e94b2cbb0491bbccc6783a_Out_0_Vector3 = float3(0, 0.7071068, -0.7071068);
            float3 _Multiply_c948b0e7effa4e7594458520aec1f26d_Out_2_Vector3;
            Unity_Multiply_float3_float3((_Split_8ea0ecbd03c445409fb4c60fb9b5ba10_B_3_Float.xxx), _Vector3_5494654f26e94b2cbb0491bbccc6783a_Out_0_Vector3, _Multiply_c948b0e7effa4e7594458520aec1f26d_Out_2_Vector3);
            float3 _Add_aaeb70621f474a03896bbf39a1b54726_Out_2_Vector3;
            Unity_Add_float3(_Add_678b38c020fd495b9757d16172c4371b_Out_2_Vector3, _Multiply_c948b0e7effa4e7594458520aec1f26d_Out_2_Vector3, _Add_aaeb70621f474a03896bbf39a1b54726_Out_2_Vector3);
            description.Position = _Add_aaeb70621f474a03896bbf39a1b54726_Out_2_Vector3;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float Alpha;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float4 _Property_34d8e5a242f742b29ae7608eaddc08d2_Out_0_Vector4 = _ColorTint;
            UnityTexture2D _Property_44cf21bb858540a0a2e62f58cd8e8a91_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_MainTex);
            float4 _SampleTexture2D_3c64c0fdf6e549f582c16e19208b632f_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_44cf21bb858540a0a2e62f58cd8e8a91_Out_0_Texture2D.tex, _Property_44cf21bb858540a0a2e62f58cd8e8a91_Out_0_Texture2D.samplerstate, _Property_44cf21bb858540a0a2e62f58cd8e8a91_Out_0_Texture2D.GetTransformedUV(IN.uv0.xy) );
            float _SampleTexture2D_3c64c0fdf6e549f582c16e19208b632f_R_4_Float = _SampleTexture2D_3c64c0fdf6e549f582c16e19208b632f_RGBA_0_Vector4.r;
            float _SampleTexture2D_3c64c0fdf6e549f582c16e19208b632f_G_5_Float = _SampleTexture2D_3c64c0fdf6e549f582c16e19208b632f_RGBA_0_Vector4.g;
            float _SampleTexture2D_3c64c0fdf6e549f582c16e19208b632f_B_6_Float = _SampleTexture2D_3c64c0fdf6e549f582c16e19208b632f_RGBA_0_Vector4.b;
            float _SampleTexture2D_3c64c0fdf6e549f582c16e19208b632f_A_7_Float = _SampleTexture2D_3c64c0fdf6e549f582c16e19208b632f_RGBA_0_Vector4.a;
            float4 _Multiply_722b821a6cdf408cac5f8691e43e03c1_Out_2_Vector4;
            Unity_Multiply_float4_float4(_Property_34d8e5a242f742b29ae7608eaddc08d2_Out_0_Vector4, _SampleTexture2D_3c64c0fdf6e549f582c16e19208b632f_RGBA_0_Vector4, _Multiply_722b821a6cdf408cac5f8691e43e03c1_Out_2_Vector4);
            float _Split_cea6bc0fd68a4855b1521db985502486_R_1_Float = _Multiply_722b821a6cdf408cac5f8691e43e03c1_Out_2_Vector4[0];
            float _Split_cea6bc0fd68a4855b1521db985502486_G_2_Float = _Multiply_722b821a6cdf408cac5f8691e43e03c1_Out_2_Vector4[1];
            float _Split_cea6bc0fd68a4855b1521db985502486_B_3_Float = _Multiply_722b821a6cdf408cac5f8691e43e03c1_Out_2_Vector4[2];
            float _Split_cea6bc0fd68a4855b1521db985502486_A_4_Float = _Multiply_722b821a6cdf408cac5f8691e43e03c1_Out_2_Vector4[3];
            surface.Alpha = _Split_cea6bc0fd68a4855b1521db985502486_A_4_Float;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
        #if VFX_USE_GRAPH_VALUES
            uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
            /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
        #endif
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
        
        
        
            #if UNITY_UV_STARTS_AT_TOP
            #else
            #endif
        
        
            output.uv0 = input.texCoord0;
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShadowCasterPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "GBuffer"
            Tags
            {
                "LightMode" = "UniversalGBuffer"
            }
        
        // Render State
        Cull Back
        Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
        ZTest LEqual
        ZWrite Off
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 4.5
        #pragma exclude_renderers gles gles3 glcore
        #pragma multi_compile_instancing
        #pragma multi_compile_fog
        #pragma instancing_options renderinglayer
        #pragma vertex vert
        #pragma fragment frag
        
        // Keywords
        #pragma multi_compile_fragment _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3
        #pragma multi_compile _ LOD_FADE_CROSSFADE
        #pragma multi_compile_fragment _ _SCREEN_SPACE_OCCLUSION
        // GraphKeywords: <None>
        
        // Defines
        
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define VARYINGS_NEED_POSITION_WS
        #define VARYINGS_NEED_NORMAL_WS
        #define VARYINGS_NEED_TEXCOORD0
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_GBUFFER
        #define _SURFACE_TYPE_TRANSPARENT 1
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DBuffer.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv0 : TEXCOORD0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS;
             float3 normalWS;
             float4 texCoord0;
            #if !defined(LIGHTMAP_ON)
             float3 sh;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float4 uv0;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
            #if !defined(LIGHTMAP_ON)
             float3 sh : INTERP0;
            #endif
             float4 texCoord0 : INTERP1;
             float3 positionWS : INTERP2;
             float3 normalWS : INTERP3;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            #if !defined(LIGHTMAP_ON)
            output.sh = input.sh;
            #endif
            output.texCoord0.xyzw = input.texCoord0;
            output.positionWS.xyz = input.positionWS;
            output.normalWS.xyz = input.normalWS;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            #if !defined(LIGHTMAP_ON)
            output.sh = input.sh;
            #endif
            output.texCoord0 = input.texCoord0.xyzw;
            output.positionWS = input.positionWS.xyz;
            output.normalWS = input.normalWS.xyz;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _MainTex_TexelSize;
        float4 _ColorTint;
        CBUFFER_END
        
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_MainTex);
        SAMPLER(sampler_MainTex);
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A * B;
        }
        
        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }
        
        void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            float3 _Vector3_33d2c331174240f183a3f4a02ddae7bc_Out_0_Vector3 = float3(1, 0, 0);
            float _Split_8ea0ecbd03c445409fb4c60fb9b5ba10_R_1_Float = IN.ObjectSpacePosition[0];
            float _Split_8ea0ecbd03c445409fb4c60fb9b5ba10_G_2_Float = IN.ObjectSpacePosition[1];
            float _Split_8ea0ecbd03c445409fb4c60fb9b5ba10_B_3_Float = IN.ObjectSpacePosition[2];
            float _Split_8ea0ecbd03c445409fb4c60fb9b5ba10_A_4_Float = 0;
            float3 _Multiply_aeb53a435e314cae94058263749dfa7f_Out_2_Vector3;
            Unity_Multiply_float3_float3(_Vector3_33d2c331174240f183a3f4a02ddae7bc_Out_0_Vector3, (_Split_8ea0ecbd03c445409fb4c60fb9b5ba10_R_1_Float.xxx), _Multiply_aeb53a435e314cae94058263749dfa7f_Out_2_Vector3);
            float3 _Vector3_702beec8c4db4ae49ca2d2478661fb0b_Out_0_Vector3 = float3(0, 0.7071068, 0.7071068);
            float3 _Multiply_bce4a6411e514e87a0b2b92695dfad67_Out_2_Vector3;
            Unity_Multiply_float3_float3((_Split_8ea0ecbd03c445409fb4c60fb9b5ba10_G_2_Float.xxx), _Vector3_702beec8c4db4ae49ca2d2478661fb0b_Out_0_Vector3, _Multiply_bce4a6411e514e87a0b2b92695dfad67_Out_2_Vector3);
            float3 _Add_678b38c020fd495b9757d16172c4371b_Out_2_Vector3;
            Unity_Add_float3(_Multiply_aeb53a435e314cae94058263749dfa7f_Out_2_Vector3, _Multiply_bce4a6411e514e87a0b2b92695dfad67_Out_2_Vector3, _Add_678b38c020fd495b9757d16172c4371b_Out_2_Vector3);
            float3 _Vector3_5494654f26e94b2cbb0491bbccc6783a_Out_0_Vector3 = float3(0, 0.7071068, -0.7071068);
            float3 _Multiply_c948b0e7effa4e7594458520aec1f26d_Out_2_Vector3;
            Unity_Multiply_float3_float3((_Split_8ea0ecbd03c445409fb4c60fb9b5ba10_B_3_Float.xxx), _Vector3_5494654f26e94b2cbb0491bbccc6783a_Out_0_Vector3, _Multiply_c948b0e7effa4e7594458520aec1f26d_Out_2_Vector3);
            float3 _Add_aaeb70621f474a03896bbf39a1b54726_Out_2_Vector3;
            Unity_Add_float3(_Add_678b38c020fd495b9757d16172c4371b_Out_2_Vector3, _Multiply_c948b0e7effa4e7594458520aec1f26d_Out_2_Vector3, _Add_aaeb70621f474a03896bbf39a1b54726_Out_2_Vector3);
            description.Position = _Add_aaeb70621f474a03896bbf39a1b54726_Out_2_Vector3;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float3 BaseColor;
            float Alpha;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float4 _Property_34d8e5a242f742b29ae7608eaddc08d2_Out_0_Vector4 = _ColorTint;
            UnityTexture2D _Property_44cf21bb858540a0a2e62f58cd8e8a91_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_MainTex);
            float4 _SampleTexture2D_3c64c0fdf6e549f582c16e19208b632f_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_44cf21bb858540a0a2e62f58cd8e8a91_Out_0_Texture2D.tex, _Property_44cf21bb858540a0a2e62f58cd8e8a91_Out_0_Texture2D.samplerstate, _Property_44cf21bb858540a0a2e62f58cd8e8a91_Out_0_Texture2D.GetTransformedUV(IN.uv0.xy) );
            float _SampleTexture2D_3c64c0fdf6e549f582c16e19208b632f_R_4_Float = _SampleTexture2D_3c64c0fdf6e549f582c16e19208b632f_RGBA_0_Vector4.r;
            float _SampleTexture2D_3c64c0fdf6e549f582c16e19208b632f_G_5_Float = _SampleTexture2D_3c64c0fdf6e549f582c16e19208b632f_RGBA_0_Vector4.g;
            float _SampleTexture2D_3c64c0fdf6e549f582c16e19208b632f_B_6_Float = _SampleTexture2D_3c64c0fdf6e549f582c16e19208b632f_RGBA_0_Vector4.b;
            float _SampleTexture2D_3c64c0fdf6e549f582c16e19208b632f_A_7_Float = _SampleTexture2D_3c64c0fdf6e549f582c16e19208b632f_RGBA_0_Vector4.a;
            float4 _Multiply_722b821a6cdf408cac5f8691e43e03c1_Out_2_Vector4;
            Unity_Multiply_float4_float4(_Property_34d8e5a242f742b29ae7608eaddc08d2_Out_0_Vector4, _SampleTexture2D_3c64c0fdf6e549f582c16e19208b632f_RGBA_0_Vector4, _Multiply_722b821a6cdf408cac5f8691e43e03c1_Out_2_Vector4);
            float _Split_cea6bc0fd68a4855b1521db985502486_R_1_Float = _Multiply_722b821a6cdf408cac5f8691e43e03c1_Out_2_Vector4[0];
            float _Split_cea6bc0fd68a4855b1521db985502486_G_2_Float = _Multiply_722b821a6cdf408cac5f8691e43e03c1_Out_2_Vector4[1];
            float _Split_cea6bc0fd68a4855b1521db985502486_B_3_Float = _Multiply_722b821a6cdf408cac5f8691e43e03c1_Out_2_Vector4[2];
            float _Split_cea6bc0fd68a4855b1521db985502486_A_4_Float = _Multiply_722b821a6cdf408cac5f8691e43e03c1_Out_2_Vector4[3];
            surface.BaseColor = (_Multiply_722b821a6cdf408cac5f8691e43e03c1_Out_2_Vector4.xyz);
            surface.Alpha = _Split_cea6bc0fd68a4855b1521db985502486_A_4_Float;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
        #if VFX_USE_GRAPH_VALUES
            uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
            /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
        #endif
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
        
        
        
            #if UNITY_UV_STARTS_AT_TOP
            #else
            #endif
        
        
            output.uv0 = input.texCoord0;
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/UnlitGBufferPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "SceneSelectionPass"
            Tags
            {
                "LightMode" = "SceneSelectionPass"
            }
        
        // Render State
        Cull Off
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 2.0
        #pragma vertex vert
        #pragma fragment frag
        
        // Keywords
        // PassKeywords: <None>
        // GraphKeywords: <None>
        
        // Defines
        
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define VARYINGS_NEED_TEXCOORD0
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_DEPTHONLY
        #define SCENESELECTIONPASS 1
        #define ALPHA_CLIP_THRESHOLD 1
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv0 : TEXCOORD0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float4 texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float4 uv0;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float4 texCoord0 : INTERP0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.texCoord0.xyzw = input.texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.texCoord0 = input.texCoord0.xyzw;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _MainTex_TexelSize;
        float4 _ColorTint;
        CBUFFER_END
        
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_MainTex);
        SAMPLER(sampler_MainTex);
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A * B;
        }
        
        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }
        
        void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            float3 _Vector3_33d2c331174240f183a3f4a02ddae7bc_Out_0_Vector3 = float3(1, 0, 0);
            float _Split_8ea0ecbd03c445409fb4c60fb9b5ba10_R_1_Float = IN.ObjectSpacePosition[0];
            float _Split_8ea0ecbd03c445409fb4c60fb9b5ba10_G_2_Float = IN.ObjectSpacePosition[1];
            float _Split_8ea0ecbd03c445409fb4c60fb9b5ba10_B_3_Float = IN.ObjectSpacePosition[2];
            float _Split_8ea0ecbd03c445409fb4c60fb9b5ba10_A_4_Float = 0;
            float3 _Multiply_aeb53a435e314cae94058263749dfa7f_Out_2_Vector3;
            Unity_Multiply_float3_float3(_Vector3_33d2c331174240f183a3f4a02ddae7bc_Out_0_Vector3, (_Split_8ea0ecbd03c445409fb4c60fb9b5ba10_R_1_Float.xxx), _Multiply_aeb53a435e314cae94058263749dfa7f_Out_2_Vector3);
            float3 _Vector3_702beec8c4db4ae49ca2d2478661fb0b_Out_0_Vector3 = float3(0, 0.7071068, 0.7071068);
            float3 _Multiply_bce4a6411e514e87a0b2b92695dfad67_Out_2_Vector3;
            Unity_Multiply_float3_float3((_Split_8ea0ecbd03c445409fb4c60fb9b5ba10_G_2_Float.xxx), _Vector3_702beec8c4db4ae49ca2d2478661fb0b_Out_0_Vector3, _Multiply_bce4a6411e514e87a0b2b92695dfad67_Out_2_Vector3);
            float3 _Add_678b38c020fd495b9757d16172c4371b_Out_2_Vector3;
            Unity_Add_float3(_Multiply_aeb53a435e314cae94058263749dfa7f_Out_2_Vector3, _Multiply_bce4a6411e514e87a0b2b92695dfad67_Out_2_Vector3, _Add_678b38c020fd495b9757d16172c4371b_Out_2_Vector3);
            float3 _Vector3_5494654f26e94b2cbb0491bbccc6783a_Out_0_Vector3 = float3(0, 0.7071068, -0.7071068);
            float3 _Multiply_c948b0e7effa4e7594458520aec1f26d_Out_2_Vector3;
            Unity_Multiply_float3_float3((_Split_8ea0ecbd03c445409fb4c60fb9b5ba10_B_3_Float.xxx), _Vector3_5494654f26e94b2cbb0491bbccc6783a_Out_0_Vector3, _Multiply_c948b0e7effa4e7594458520aec1f26d_Out_2_Vector3);
            float3 _Add_aaeb70621f474a03896bbf39a1b54726_Out_2_Vector3;
            Unity_Add_float3(_Add_678b38c020fd495b9757d16172c4371b_Out_2_Vector3, _Multiply_c948b0e7effa4e7594458520aec1f26d_Out_2_Vector3, _Add_aaeb70621f474a03896bbf39a1b54726_Out_2_Vector3);
            description.Position = _Add_aaeb70621f474a03896bbf39a1b54726_Out_2_Vector3;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float Alpha;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float4 _Property_34d8e5a242f742b29ae7608eaddc08d2_Out_0_Vector4 = _ColorTint;
            UnityTexture2D _Property_44cf21bb858540a0a2e62f58cd8e8a91_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_MainTex);
            float4 _SampleTexture2D_3c64c0fdf6e549f582c16e19208b632f_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_44cf21bb858540a0a2e62f58cd8e8a91_Out_0_Texture2D.tex, _Property_44cf21bb858540a0a2e62f58cd8e8a91_Out_0_Texture2D.samplerstate, _Property_44cf21bb858540a0a2e62f58cd8e8a91_Out_0_Texture2D.GetTransformedUV(IN.uv0.xy) );
            float _SampleTexture2D_3c64c0fdf6e549f582c16e19208b632f_R_4_Float = _SampleTexture2D_3c64c0fdf6e549f582c16e19208b632f_RGBA_0_Vector4.r;
            float _SampleTexture2D_3c64c0fdf6e549f582c16e19208b632f_G_5_Float = _SampleTexture2D_3c64c0fdf6e549f582c16e19208b632f_RGBA_0_Vector4.g;
            float _SampleTexture2D_3c64c0fdf6e549f582c16e19208b632f_B_6_Float = _SampleTexture2D_3c64c0fdf6e549f582c16e19208b632f_RGBA_0_Vector4.b;
            float _SampleTexture2D_3c64c0fdf6e549f582c16e19208b632f_A_7_Float = _SampleTexture2D_3c64c0fdf6e549f582c16e19208b632f_RGBA_0_Vector4.a;
            float4 _Multiply_722b821a6cdf408cac5f8691e43e03c1_Out_2_Vector4;
            Unity_Multiply_float4_float4(_Property_34d8e5a242f742b29ae7608eaddc08d2_Out_0_Vector4, _SampleTexture2D_3c64c0fdf6e549f582c16e19208b632f_RGBA_0_Vector4, _Multiply_722b821a6cdf408cac5f8691e43e03c1_Out_2_Vector4);
            float _Split_cea6bc0fd68a4855b1521db985502486_R_1_Float = _Multiply_722b821a6cdf408cac5f8691e43e03c1_Out_2_Vector4[0];
            float _Split_cea6bc0fd68a4855b1521db985502486_G_2_Float = _Multiply_722b821a6cdf408cac5f8691e43e03c1_Out_2_Vector4[1];
            float _Split_cea6bc0fd68a4855b1521db985502486_B_3_Float = _Multiply_722b821a6cdf408cac5f8691e43e03c1_Out_2_Vector4[2];
            float _Split_cea6bc0fd68a4855b1521db985502486_A_4_Float = _Multiply_722b821a6cdf408cac5f8691e43e03c1_Out_2_Vector4[3];
            surface.Alpha = _Split_cea6bc0fd68a4855b1521db985502486_A_4_Float;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
        #if VFX_USE_GRAPH_VALUES
            uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
            /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
        #endif
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
        
        
        
            #if UNITY_UV_STARTS_AT_TOP
            #else
            #endif
        
        
            output.uv0 = input.texCoord0;
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/SelectionPickingPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "ScenePickingPass"
            Tags
            {
                "LightMode" = "Picking"
            }
        
        // Render State
        Cull Back
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 2.0
        #pragma vertex vert
        #pragma fragment frag
        
        // Keywords
        // PassKeywords: <None>
        // GraphKeywords: <None>
        
        // Defines
        
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define VARYINGS_NEED_TEXCOORD0
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_DEPTHONLY
        #define SCENEPICKINGPASS 1
        #define ALPHA_CLIP_THRESHOLD 1
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv0 : TEXCOORD0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float4 texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float4 uv0;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float4 texCoord0 : INTERP0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.texCoord0.xyzw = input.texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.texCoord0 = input.texCoord0.xyzw;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _MainTex_TexelSize;
        float4 _ColorTint;
        CBUFFER_END
        
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_MainTex);
        SAMPLER(sampler_MainTex);
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A * B;
        }
        
        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }
        
        void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            float3 _Vector3_33d2c331174240f183a3f4a02ddae7bc_Out_0_Vector3 = float3(1, 0, 0);
            float _Split_8ea0ecbd03c445409fb4c60fb9b5ba10_R_1_Float = IN.ObjectSpacePosition[0];
            float _Split_8ea0ecbd03c445409fb4c60fb9b5ba10_G_2_Float = IN.ObjectSpacePosition[1];
            float _Split_8ea0ecbd03c445409fb4c60fb9b5ba10_B_3_Float = IN.ObjectSpacePosition[2];
            float _Split_8ea0ecbd03c445409fb4c60fb9b5ba10_A_4_Float = 0;
            float3 _Multiply_aeb53a435e314cae94058263749dfa7f_Out_2_Vector3;
            Unity_Multiply_float3_float3(_Vector3_33d2c331174240f183a3f4a02ddae7bc_Out_0_Vector3, (_Split_8ea0ecbd03c445409fb4c60fb9b5ba10_R_1_Float.xxx), _Multiply_aeb53a435e314cae94058263749dfa7f_Out_2_Vector3);
            float3 _Vector3_702beec8c4db4ae49ca2d2478661fb0b_Out_0_Vector3 = float3(0, 0.7071068, 0.7071068);
            float3 _Multiply_bce4a6411e514e87a0b2b92695dfad67_Out_2_Vector3;
            Unity_Multiply_float3_float3((_Split_8ea0ecbd03c445409fb4c60fb9b5ba10_G_2_Float.xxx), _Vector3_702beec8c4db4ae49ca2d2478661fb0b_Out_0_Vector3, _Multiply_bce4a6411e514e87a0b2b92695dfad67_Out_2_Vector3);
            float3 _Add_678b38c020fd495b9757d16172c4371b_Out_2_Vector3;
            Unity_Add_float3(_Multiply_aeb53a435e314cae94058263749dfa7f_Out_2_Vector3, _Multiply_bce4a6411e514e87a0b2b92695dfad67_Out_2_Vector3, _Add_678b38c020fd495b9757d16172c4371b_Out_2_Vector3);
            float3 _Vector3_5494654f26e94b2cbb0491bbccc6783a_Out_0_Vector3 = float3(0, 0.7071068, -0.7071068);
            float3 _Multiply_c948b0e7effa4e7594458520aec1f26d_Out_2_Vector3;
            Unity_Multiply_float3_float3((_Split_8ea0ecbd03c445409fb4c60fb9b5ba10_B_3_Float.xxx), _Vector3_5494654f26e94b2cbb0491bbccc6783a_Out_0_Vector3, _Multiply_c948b0e7effa4e7594458520aec1f26d_Out_2_Vector3);
            float3 _Add_aaeb70621f474a03896bbf39a1b54726_Out_2_Vector3;
            Unity_Add_float3(_Add_678b38c020fd495b9757d16172c4371b_Out_2_Vector3, _Multiply_c948b0e7effa4e7594458520aec1f26d_Out_2_Vector3, _Add_aaeb70621f474a03896bbf39a1b54726_Out_2_Vector3);
            description.Position = _Add_aaeb70621f474a03896bbf39a1b54726_Out_2_Vector3;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float Alpha;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float4 _Property_34d8e5a242f742b29ae7608eaddc08d2_Out_0_Vector4 = _ColorTint;
            UnityTexture2D _Property_44cf21bb858540a0a2e62f58cd8e8a91_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_MainTex);
            float4 _SampleTexture2D_3c64c0fdf6e549f582c16e19208b632f_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_44cf21bb858540a0a2e62f58cd8e8a91_Out_0_Texture2D.tex, _Property_44cf21bb858540a0a2e62f58cd8e8a91_Out_0_Texture2D.samplerstate, _Property_44cf21bb858540a0a2e62f58cd8e8a91_Out_0_Texture2D.GetTransformedUV(IN.uv0.xy) );
            float _SampleTexture2D_3c64c0fdf6e549f582c16e19208b632f_R_4_Float = _SampleTexture2D_3c64c0fdf6e549f582c16e19208b632f_RGBA_0_Vector4.r;
            float _SampleTexture2D_3c64c0fdf6e549f582c16e19208b632f_G_5_Float = _SampleTexture2D_3c64c0fdf6e549f582c16e19208b632f_RGBA_0_Vector4.g;
            float _SampleTexture2D_3c64c0fdf6e549f582c16e19208b632f_B_6_Float = _SampleTexture2D_3c64c0fdf6e549f582c16e19208b632f_RGBA_0_Vector4.b;
            float _SampleTexture2D_3c64c0fdf6e549f582c16e19208b632f_A_7_Float = _SampleTexture2D_3c64c0fdf6e549f582c16e19208b632f_RGBA_0_Vector4.a;
            float4 _Multiply_722b821a6cdf408cac5f8691e43e03c1_Out_2_Vector4;
            Unity_Multiply_float4_float4(_Property_34d8e5a242f742b29ae7608eaddc08d2_Out_0_Vector4, _SampleTexture2D_3c64c0fdf6e549f582c16e19208b632f_RGBA_0_Vector4, _Multiply_722b821a6cdf408cac5f8691e43e03c1_Out_2_Vector4);
            float _Split_cea6bc0fd68a4855b1521db985502486_R_1_Float = _Multiply_722b821a6cdf408cac5f8691e43e03c1_Out_2_Vector4[0];
            float _Split_cea6bc0fd68a4855b1521db985502486_G_2_Float = _Multiply_722b821a6cdf408cac5f8691e43e03c1_Out_2_Vector4[1];
            float _Split_cea6bc0fd68a4855b1521db985502486_B_3_Float = _Multiply_722b821a6cdf408cac5f8691e43e03c1_Out_2_Vector4[2];
            float _Split_cea6bc0fd68a4855b1521db985502486_A_4_Float = _Multiply_722b821a6cdf408cac5f8691e43e03c1_Out_2_Vector4[3];
            surface.Alpha = _Split_cea6bc0fd68a4855b1521db985502486_A_4_Float;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
        #if VFX_USE_GRAPH_VALUES
            uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
            /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
        #endif
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
        
        
        
            #if UNITY_UV_STARTS_AT_TOP
            #else
            #endif
        
        
            output.uv0 = input.texCoord0;
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/SelectionPickingPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
    }
    CustomEditor "UnityEditor.ShaderGraph.GenericShaderGraphMaterialGUI"
    CustomEditorForRenderPipeline "UnityEditor.ShaderGraphUnlitGUI" "UnityEngine.Rendering.Universal.UniversalRenderPipelineAsset"
    FallBack "Hidden/Shader Graph/FallbackError"
}