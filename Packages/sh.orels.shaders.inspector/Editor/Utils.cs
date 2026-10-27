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
            var pattern = @"(?<=[\w\,\s\&\|\(\)\!\?\>\<\=\%\/\$\.\-\@]+\s+)(?<fn>\%[\w\,\s\&\|\(\)\!\?\>\<\=\%\/\$\.\-\@]+]*)";
            var cleaned = originalName.Replace(">", "");
            cleaned = Regex.Replace(cleaned, pattern, "");
            return cleaned;
        }

        /// <summary>
        /// Returns the actual property name instead of the display name when the user holds down the ALT key
        /// </summary>
        /// <param name="property">The property to show the name of</param>
        /// <param name="displayName">The display name to fall back to</param>
        /// <returns>Either the actual property name, or the passed display name</returns>
        public static string GetAltName(MaterialProperty property, string displayName)
        {
            return Event.current != null && Event.current.alt ? property.name : displayName;
        }

        /// <summary>
        /// Copies the actual property name to the clipboard when the user left-clicks the property while holding down the ALT key
        /// </summary>
        /// <param name="property">The property to copy the name of</param>
        /// <param name="rect">The rect of the property row to check clicks against</param>
        public static void CopyNameOnClick(MaterialProperty property, Rect rect)
        {
            var e = Event.current;
            if (e == null || !e.alt || e.type != EventType.MouseDown || e.button != 0 || !rect.Contains(e.mousePosition))
            {
                return;
            }

            GUIUtility.systemCopyBuffer = property.name;
            e.Use();
        }
    }
}
