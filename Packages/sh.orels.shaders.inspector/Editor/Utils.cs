using System;
using System.Collections.Generic;
using System.Linq;
using System.Reflection;
using System.Text.RegularExpressions;
using UnityEditor;
using UnityEngine;

namespace ORL.ShaderInspector
{
    public static class Utils
    {
        public static bool TryGetValueFromKeyword(string name, Material material, out bool value)
        {
            if (material.IsKeywordEnabled(name))
            {
                value = true;
                return true;
            }

            value = false;
            return true;
        }
        
        public static bool TryGetValueFromFloat(string name, Material material, out float value)
        {
            if (material.HasProperty(name))
            {
                value = material.GetFloat(name);
                return true;
            }

            value = 0;
            return false;
        }

        public static bool TryGetValueFromTexture(string name, Material material, out bool value)
        {
            try
            {
                if (material.HasProperty(name) && material.GetTexturePropertyNames().Contains(name))
                {
                    value = material.GetTexture(name) != null;
                    return true;
                }
                
                value = false;
                return false;
            }
            catch
            {
                value = false;
                return false;
            }
        }
        
        /// <summary>
        /// Strips all of the shader inspector internals from the property name for nice display
        /// </summary>
        /// <param name="originalName"></param>
        /// <returns>The cleaned up name</returns>
        public static string StripInternalSymbols(string originalName)
        {
            // This regex matches stuff like %ShowIf(stuff) and %SetKeyword(stuff)
            var pattern = @"(?<=[\w\!\(\)]+\s+)(?<fn>\%[\w\,\s\&\|\(\)\!\?\>\<\=\%\/\$\.\-\@]+]*)";
            var cleaned = originalName.Replace(">", "");
            cleaned = Regex.Replace(cleaned, pattern, "");
            return cleaned;
        }
    }
}
