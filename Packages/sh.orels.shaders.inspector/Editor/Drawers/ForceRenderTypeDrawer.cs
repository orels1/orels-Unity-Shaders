using System;
using System.Collections.Generic;
using System.Text.RegularExpressions;
using UnityEditor;
using UnityEngine;
using UnityEngine.Rendering;

namespace ORL.Drawers
{
    public class ForceRenderTypeDrawer : IDrawerFunc
    {
        public string FunctionName => "ForceRenderType";

        // Matches %ForceRenderType(Type,Queue,CompatibleType1,CompatibleType2,CompatibleType3)
        private Regex _matcher = new Regex(@"%ForceRenderType\((?<type>[\w]+)+,?\s*(?<queue>[\w]+)?,?\s*(?<compatibleType1>[\w]+)?,?\s*(?<compatibleType2>[\w]+)?,?\s*(?<compatibleType3>[\w]+)?\)");

        public string[] PersistentKeys => Array.Empty<string>();

        public bool OnGUI(MaterialEditor editor, MaterialProperty[] properties, MaterialProperty property, int index, ref Dictionary<string, object> uiState, Func<bool> next)
        {
            if (EditorGUI.indentLevel == -1) return true;

            var match = _matcher.Match(property.displayName);
            var type = match.Groups["type"].Value;
            if (string.IsNullOrWhiteSpace(type)) return next();

            type = type.Trim().ToLower();

            var queue = match.Groups["queue"].Value;
            var compatibleType1 = match.Groups["compatibleType1"].Value;
            var compatibleType2 = match.Groups["compatibleType2"].Value;
            var compatibleType3 = match.Groups["compatibleType3"].Value;
            queue = queue.Trim();
            compatibleType1 = compatibleType1.Trim().ToLower();
            compatibleType2 = compatibleType2.Trim().ToLower();
            compatibleType3 = compatibleType3.Trim().ToLower();

            var cType1 = RenderTypeDrawer.GetRenderType(compatibleType1);
            var cType2 = RenderTypeDrawer.GetRenderType(compatibleType2);
            var cType3 = RenderTypeDrawer.GetRenderType(compatibleType3);
            foreach (Material material in editor.targets)
            {
                // unforce type if unchecked
                if (property.floatValue < 1)
                {
                    var builtInOverride = material.shader.FindPassTagValue(0, new ShaderTagId("ORL_RenderType"));
                    if (builtInOverride != null && !string.IsNullOrWhiteSpace(builtInOverride.name))
                    {
                        material.SetOverrideTag("ORL_RenderType", builtInOverride.name);
                        continue;
                    }
                    material.SetOverrideTag("ORL_RenderType", null);
                    continue;
                    // if (material.HasProperty("_RenderType"))
                    // {
                    //     material.SetInt("_RenderType", -1);
                    //     material.renderQueue = -1;
                    // }
                    // continue;
                }
                var currType = material.GetTag("ORL_RenderType", false);
                if (string.IsNullOrWhiteSpace(currType) && material.HasProperty("_RenderType"))
                {
                    var savedType = (RenderTypeDrawer.RenderType)material.GetInt("_RenderType");
                    if (savedType == RenderTypeDrawer.GetRenderType(type)) continue;
                    if ((savedType == cType1 && compatibleType1 != string.Empty) ||
                        (savedType == cType2 && compatibleType2 != string.Empty) ||
                        (savedType == cType3 && compatibleType3 != string.Empty)) continue;
                }
                if (!string.IsNullOrWhiteSpace(currType))
                {
                    currType = currType.ToLower();
                    if (currType == type) continue;
                    if (currType == compatibleType1 || currType == compatibleType2 || currType == compatibleType3) continue;
                }
                material.SetOverrideTag("ORL_RenderType", type.Substring(0, 1).ToUpper() + type.Substring(1));
                if (!string.IsNullOrWhiteSpace(queue) && int.TryParse(queue, out var queueValue))
                {
                    material.renderQueue = queueValue;
                }
            }

            return next();
        }
    }
}