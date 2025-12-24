using System;
using System.Collections.Generic;
using System.Text.RegularExpressions;
using UnityEditor;
using UnityEngine;

namespace ORL.Drawers
{
    public class EnablePassDrawer : IDrawerFunc
    {
        public string FunctionName => "EnablePass";

        // Matches %EnablePass(LightMode)
        private Regex _matcher = new Regex(@"%EnablePass\((?<lightMode>[\w]+)+\)");

        public string[] PersistentKeys => Array.Empty<string>();

        public bool OnGUI(MaterialEditor editor, MaterialProperty[] properties, MaterialProperty property, int index, ref Dictionary<string, object> uiState, Func<bool> next)
        {
            if (EditorGUI.indentLevel == -1) return true;

            var match = _matcher.Match(property.displayName);
            var lightMode = match.Groups["lightMode"].Value;
            var currentValue = property.floatValue > 0;

            foreach (Material material in editor.targets)
            {
                if (material.GetShaderPassEnabled(lightMode) == currentValue) continue;
                material.SetShaderPassEnabled(lightMode, currentValue);
            }

            return next();
        }
    }
}