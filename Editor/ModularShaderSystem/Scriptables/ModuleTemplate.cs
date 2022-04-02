using System;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Serialization;

namespace ORL.ModularShaderSystem
{
    [Serializable]
    public class ModuleTemplate 
    {
        public TemplateAsset Template;
        
        [FormerlySerializedAs("Keyword")] public List<string> Keywords;
        
        [FormerlySerializedAs("IsCGOnly")] public bool NeedsVariant;
        
        public int Queue = 100;
    }
}