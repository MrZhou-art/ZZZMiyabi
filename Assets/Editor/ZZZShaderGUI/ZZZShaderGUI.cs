using UnityEditor;
using UnityEngine;

namespace Editor.ZZZShaderGUI
{
    static class Domains
    {
        public const string FaceName = "IS_FACE";
        public const string BodyName = "IS_BODY";
        public const string HairName = "IS_HAIR";
        
        public const int FaceID = 0;
        public const int BodyID = 1;
        public const int HairID = 2;
    }

    static class AttenuationModes
    {
        public const string SigmoidAttenuationName           = "USE_SIGMOID_ATTENUATION";
        public const string RampAttenuationName              = "USE_RAMP_ATTENUATION";
        public const string LinearPartitionedAttenuationName = "USE_LINEAR_PARTITIONED_ATTENUATION";
        
        public const int SigmoidAttenuationID           = 0;
        public const int RampAttenuationID              = 1;
        public const int LinearPartitionedAttenuationID = 2;
    }
            
    public class ZZZShaderGUI : ShaderGUI 
    {
        public override void OnGUI(MaterialEditor materialEditor, MaterialProperty[] properties) {
            // Default GUI 
            base.OnGUI(materialEditor, properties);

            Material material = materialEditor.target as Material;
            if (material == null) return;

            SetKeyword("_DebugMode", "DEBUG_MODE", material, properties);
            SetKeyword("_UseOutline", "USE_OUTLINE", material, properties);
            
            // Face:0    Body:1    Hair:2
            SetDomainKeyword(material, properties);
            
            // Attenuation Mode
            SetAttenuationModeKeyword(material, properties);
        }

        void SetKeyword(in string propertyName,in string keywordName, in Material material, in MaterialProperty[] properties)
        {
            MaterialProperty property = FindProperty(propertyName, properties);
            
            if (property.floatValue > 0) {
                material.EnableKeyword(keywordName); // 启用宏
            } else {
                material.DisableKeyword(keywordName); // 禁用宏
            }
        }

        void SetDomainKeyword(in Material material, in MaterialProperty[] properties)
        {
            MaterialProperty property = FindProperty("_Domain", properties);
            
            switch (property.floatValue)
            {
                case Domains.FaceID: 
                    material.EnableKeyword (Domains.FaceName); 
                    material.DisableKeyword(Domains.BodyName); 
                    material.DisableKeyword(Domains.HairName); 
                    break;
                case Domains.BodyID: 
                    material.DisableKeyword(Domains.FaceName); 
                    material.EnableKeyword (Domains.BodyName); 
                    material.DisableKeyword(Domains.HairName); 
                    break;
                case Domains.HairID: 
                    material.DisableKeyword(Domains.FaceName); 
                    material.DisableKeyword(Domains.BodyName); 
                    material.EnableKeyword (Domains.HairName);
                    break;    
            }
        }

        void SetAttenuationModeKeyword(in Material material, in MaterialProperty[] properties)
        {
            MaterialProperty property = FindProperty("_AttenuationMode", properties);
            
            switch (property.floatValue)
            {
                case AttenuationModes.SigmoidAttenuationID: 
                    material.EnableKeyword (AttenuationModes.SigmoidAttenuationName); 
                    material.DisableKeyword(AttenuationModes.RampAttenuationName); 
                    material.DisableKeyword(AttenuationModes.LinearPartitionedAttenuationName); 
                    break;
                case AttenuationModes.RampAttenuationID: 
                    material.DisableKeyword(AttenuationModes.SigmoidAttenuationName); 
                    material.EnableKeyword (AttenuationModes.RampAttenuationName); 
                    material.DisableKeyword(AttenuationModes.LinearPartitionedAttenuationName); 
                    break;
                case AttenuationModes.LinearPartitionedAttenuationID: 
                    material.DisableKeyword(AttenuationModes.SigmoidAttenuationName);  
                    material.DisableKeyword(AttenuationModes.RampAttenuationName);  
                    material.EnableKeyword (AttenuationModes.LinearPartitionedAttenuationName); 
                    break;    
            }
        }
        
        // TODO: 加入 lit Shader 中的默认属性
    }
    
    
    // material changed check
    /*public override void ValidateMaterial(Material material)
    {
        SetMaterialKeywords(material);
    }*/

    /*public override void AssignNewShaderToMaterial(Material material, Shader oldShader, Shader newShader)
    {
        if (material == null)
            throw new ArgumentNullException("material");

        // _Emission property is lost after assigning Standard shader to the material
        // thus transfer it before assigning the new shader
        if (material.HasProperty("_Emission"))
        {
            material.SetColor("_EmissionColor", material.GetColor("_Emission"));
        }

        base.AssignNewShaderToMaterial(material, oldShader, newShader);

        if (oldShader == null || !oldShader.name.Contains("Legacy Shaders/"))
        {
            SetupMaterialBlendMode(material);
            return;
        }

        SurfaceType surfaceType = SurfaceType.Opaque;
        BlendMode blendMode = BlendMode.Alpha;
        if (oldShader.name.Contains("/Transparent/Cutout/"))
        {
            surfaceType = SurfaceType.Opaque;
            material.SetFloat("_AlphaClip", 1);
        }
        else if (oldShader.name.Contains("/Transparent/"))
        {
            // NOTE: legacy shaders did not provide physically based transparency
            // therefore Fade mode
            surfaceType = SurfaceType.Transparent;
            blendMode = BlendMode.Alpha;
        }
        material.SetFloat("_Blend", (float)blendMode);

        material.SetFloat("_Surface", (float)surfaceType);
        if (surfaceType == SurfaceType.Opaque)
        {
            material.DisableKeyword("_SURFACE_TYPE_TRANSPARENT");
        }
        else
        {
            material.EnableKeyword("_SURFACE_TYPE_TRANSPARENT");
        }
    }
*/
}
