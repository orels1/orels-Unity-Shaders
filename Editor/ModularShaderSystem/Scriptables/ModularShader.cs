using System.Collections.Generic;
using UnityEngine;

namespace ORL.ModularShaderSystem
{
    [CreateAssetMenu(fileName = "ModularShader", menuName = MSSConstants.CREATE_PATH + "/Modular Shader", order = 0)]
    public class ModularShader : ScriptableObject
    {
        public string Id;
        
        public string Name;
        
        public string Version;
        
        public string Author;
        
        public string Description;
        
        public bool UseTemplatesForProperties;
        
        public TemplateAsset ShaderPropertiesTemplate;
        
        public string ShaderPath;
        
        public TemplateAsset ShaderTemplate;
        
        public string CustomEditor;
        
        public List<Property> Properties;
        
        public List<ShaderModule> BaseModules;
        
        [HideInInspector] public List<ShaderModule> AdditionalModules;
        
        public bool LockBaseModules;
        
        public List<Shader> LastGeneratedShaders;
        
        [HideInInspector] public string AdditionalSerializedData;
    }
}