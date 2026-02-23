using System.Collections.Generic;

namespace ORL.ShaderGenerator.Tools.SurfaceShaders
{
    public class SurfaceShaderMappings
    {
        // Standard metallic PBR mappings are just one-to-one so we don't need to remap
        public static readonly Dictionary<string, string> SurfaceOutputStandardMappings = null;

        // Standard specular PBR mappings aren't fully mapped yet
        // This would need a separate specular conversion module
        public static readonly Dictionary<string, string> SurfaceOutputMappings = new()
        {
            { "Albedo", "Albedo" },
            { "Specular", "Smoothness" },
            { "Gloss", "Metallic" },
            { "Alpha", "Alpha" },
            { "Normal", "Normal" }
        };
        
        public static readonly Dictionary<string, Dictionary<string, string>> OutputMappings = new()
        {
            { "SurfaceOutputStandard", SurfaceOutputStandardMappings },
            { "SurfaceOutput", SurfaceOutputMappings }
        };

        public static readonly Dictionary<string, string> LightingModelMappings = new()
        {
            { "Standard", "@/LightingModels/PBR" },
            { "BlinnPhong", "@/LightingModels/PBR" }
        };

        public static readonly Dictionary<string, string> SurfaceInputMappings = new()
        {
            { "worldPos", "worldSpacePosition" },
            { "worldNormal", "worldNormal" },
            { "viewDir", "tangentSpaceViewDir" },
            { "uv_texcoord", "uv0.xy" }, // Amplify uses this for uv0
            { "uv2_texcoord", "uv1.xy"} // Amplify uses this for uv1
        };

        public static readonly Dictionary<string, string> VertexInputMappings = new()
        {
            { "POSITION", "vertex"},
            {"NORMAL", "normal"},
            {"TANGENT", "tangent"},
            {"COLOR", "color"},
            { "TEXCOORD0", "uv0" },
            { "TEXCOORD1", "uv1" },
            { "TEXCOORD2", "uv2" },
            { "TEXCOORD3", "uv3" },
            { "TEXCOORD4", "uv4" },
            { "TEXCOORD5", "uv5" },
            { "TEXCOORD6", "uv6" },
            { "TEXCOORD7", "uv7" }
        };
    }
}