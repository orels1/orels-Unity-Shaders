using System;
using System.Collections.Generic;
using UnityEngine;

namespace ORL.ShaderInspector
{
    public class LocalizationData : ScriptableObject
    {
        [Serializable]
        public struct LocalizedPropData
        {
            public string langauge;
            public string tooltip;

            public override string ToString()
            {
                return tooltip;
            }
        }

        public List<string> properties;
        public List<LocalizedPropData> data;
    }
}