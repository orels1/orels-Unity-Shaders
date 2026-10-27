using System;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Serialization;

namespace ORL.ShaderInspector
{
    public class LocalizationData : ScriptableObject
    {
        [Serializable]
        public struct LocalizedPropData
        {
            public string propName;
            public List<LocalizedLanguageData> data;
        }
        
        [Serializable]
        public struct LocalizedLanguageData
        {
            public string language;
            public string tooltip;
            public string name;

            public override string ToString()
            {
                return name + " : " + tooltip;
            }
        }

        // The module this file provides localization for
        // Defaults to the file name when not set explicitly in the file
        public string moduleName;

        public List<string> properties;
        public List<LocalizedPropData> data;
    }
}