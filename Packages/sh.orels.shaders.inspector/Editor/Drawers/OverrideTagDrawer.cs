using System;
using System.Collections.Generic;
using System.Linq;
using System.Text.RegularExpressions;
using UnityEditor;
using UnityEngine;

namespace ORL.Drawers
{
    /// <summary>
    /// Overrides the editor with a dropdown menu to select a tag,
    /// Values list is taken from [Enum] material property drawer
    /// </summary>
    public class OverrideTagDrawer: IDrawerFunc
    {
        public string FunctionName => "OverrideTag";
        
        // Matches %OverrideTag(TagName)
        private Regex _matcher = new Regex(@"%OverrideTag\((?<tagName>[\w\,\s\&\|\(\)\!\<\>\=]+)\s*\)");

        private Regex _enumMatcher = new Regex(@"Enum\((\s?\w+\s?\,\s?\d+\s?\,?)+\)");
        
        public string[] PersistentKeys => Array.Empty<string>();
        
        public bool OnGUI(MaterialEditor editor, MaterialProperty[] properties, MaterialProperty property, int index,
            ref Dictionary<string, object> uiState, Func<bool> next)
        {
            if (EditorGUI.indentLevel == -1) return true;
            
            var match = _matcher.Match(property.displayName);

            if (!match.Success) return next();
            var targetMaterial = (Material) editor.target;
            
            var tagName = match.Groups["tagName"].Value;
            var attributes = targetMaterial.shader.GetPropertyAttributes(index);
            var enumString = Array.Find(attributes, s => s.StartsWith("Enum"));
            if (attributes.Length == 0 || string.IsNullOrEmpty(enumString)) return next();

            var parsedEnum = _enumMatcher.Match(enumString);
            var enumParams = parsedEnum.Groups[1].Captures;
            var enumDictionary = new Dictionary<int, string>();
            foreach (var enumParam in enumParams)
            {
                var parsed = enumParam.ToString().Split(',').Select(s => s.Trim()).ToArray();
                enumDictionary.Add(int.Parse(parsed[1]), parsed[0]);
            }

            var currTag = enumDictionary[(int) property.floatValue];

            if (targetMaterial.GetTag(tagName, false) != currTag)
            {
                Undo.RecordObject(editor.target, "Adjusted Tag");
                targetMaterial.SetOverrideTag(tagName, currTag);
            }
            
            return next();
        }
        
    }
}