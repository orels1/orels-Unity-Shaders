using System;
using System.Collections.Generic;
using UnityEngine;

namespace ORL.ModularShaderSystem
{
    [CreateAssetMenu(fileName = "ShaderModule", menuName = MSSConstants.CREATE_PATH + "/Shader Module", order = 0)]
    public class ShaderModule : ScriptableObject
    {
        public string Id;
        
        public string Name;
        
        public string Version;
        
        public string Author;
        
        public string Description;

        public List<EnableProperty> EnableProperties;
        
        public List<Property> Properties;
        
        public List<string> ModuleDependencies;
        
        public List<string> IncompatibleWith;
        
        public List<ModuleTemplate> Templates;
        
        public List<ShaderFunction> Functions;
        
        [HideInInspector] public string AdditionalSerializedData;
    }
}