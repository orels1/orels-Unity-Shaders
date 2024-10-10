using System;
using System.Collections.Generic;
using System.Linq;
using System.Text.RegularExpressions;
using ORL.ShaderInspector;
using UnityEditor;
using UnityEngine;

namespace ORL.Drawers
{
    /// <summary>
    /// Overrides an editor with a dropdown to select a render type
    /// The desired render parameters are passed to specified properties
    /// </summary>
    public class RenderTypeDrawer : IDrawerFunc
    {
        public string FunctionName => "RenderType";

        private enum RenderType
        {
            Opaque,
            Cutout,
            Transparent,
            Fade,
            Custom,
        }

        private struct MaterialPropertyData
        {
            public string BlendOpProp;
            public string SrcBlendProp;
            public string DstBlendProp;
            public string BlendOpAlphaProp;
            public string SrcBlendAlphaProp;
            public string DstBlendAlphaProp;
            public string ZWriteProp;
        }

        // Matches %RenderType(BlendOp, SrcBlend, DstBlend, BlendOpAlpha, SrcBlendAlpha, DstBlendAlpha, ZWrite)
        private Regex _matcher = new Regex(@"%RenderType\((?<blendOp>\w+)\s*,\s*(?<srcBlend>\w+)\s*,\s*(?<dstBlend>\w+)\s*,\s*(?<blendOpAlpha>\w+)\s*,\s*(?<srcBlendAlpha>\w+)\s*,\s*(?<dstBlendAlpha>\w+)\s*,\s*(?<zwrite>\w+)\s*\)");

        public string[] PersistentKeys => Array.Empty<string>();

        public bool OnGUI(MaterialEditor editor, MaterialProperty[] properties, MaterialProperty property, int index,
            ref Dictionary<string, object> uiState, Func<bool> next)
        {
            if (EditorGUI.indentLevel == -1) return true;

            var match = _matcher.Match(property.displayName);

            if (!match.Success) return next();
            var targetMaterial = (Material)editor.target;

            var propertyData = new MaterialPropertyData
            {
                BlendOpProp = match.Groups["blendOp"].Value,
                SrcBlendProp = match.Groups["srcBlend"].Value,
                DstBlendProp = match.Groups["dstBlend"].Value,
                BlendOpAlphaProp = match.Groups["blendOpAlpha"].Value,
                SrcBlendAlphaProp = match.Groups["srcBlendAlpha"].Value,
                DstBlendAlphaProp = match.Groups["dstBlendAlpha"].Value,
                ZWriteProp = match.Groups["zwrite"].Value
            };

            var savedRenderType = (int)property.floatValue;

            var currentRenderType = savedRenderType == -1 ? RenderType.Opaque : (RenderType)savedRenderType;

            var presetTag = targetMaterial.GetTag("ORL_RenderType", false);
            var forcedType = !string.IsNullOrWhiteSpace(presetTag);

            switch (presetTag.ToLower())
            {
                case "opaque":
                    currentRenderType = RenderType.Opaque;
                    break;
                case "cutout":
                    currentRenderType = RenderType.Cutout;
                    break;
                case "transparent":
                    currentRenderType = RenderType.Transparent;
                    break;
                case "fade":
                    currentRenderType = RenderType.Fade;
                    break;
                case "custom":
                    currentRenderType = RenderType.Custom;
                    break;
            }

            RenderType newRenderType;

            using (new EditorGUI.DisabledScope(forcedType))
            {
                newRenderType = (RenderType)EditorGUILayout.Popup("RenderType", (int)currentRenderType, new[] {
                    "Opaque",
                    "Cutout",
                    "Transparent",
                    "Fade",
                    "Custom"
                });
            }

            if (forcedType)
            {
                EditorGUILayout.LabelField("Render Type is locked by the current shader", Styles.NoteTextStyle);
                property.floatValue = (float)currentRenderType;
                if (!IsMaterialSetUpForRenderType(targetMaterial, propertyData, newRenderType) || savedRenderType == -1 || (RenderType)savedRenderType != currentRenderType)
                {
                    SetRenderType(targetMaterial, currentRenderType, propertyData, property);
                }
                return true;
            }

            if (newRenderType != currentRenderType)
            {
                property.floatValue = (float)newRenderType;
            }

            if (!IsMaterialSetUpForRenderType(targetMaterial, propertyData, newRenderType) || newRenderType != currentRenderType)
            {
                SetRenderType(targetMaterial, newRenderType, propertyData, property);
            }

            return true;
        }

        private void SetRenderType(Material targetMaterial, RenderType renderType, MaterialPropertyData propData, MaterialProperty property)
        {
            Undo.RecordObject(targetMaterial, "Adjusted RenderType");
            switch (renderType)
            {
                case RenderType.Opaque:
                    targetMaterial.SetOverrideTag("RenderType", "Opaque");
                    targetMaterial.SetInt(propData.SrcBlendProp, (int)UnityEngine.Rendering.BlendMode.One);
                    targetMaterial.SetInt(propData.DstBlendProp, (int)UnityEngine.Rendering.BlendMode.Zero);
                    targetMaterial.SetInt(propData.BlendOpProp, (int)UnityEngine.Rendering.BlendOp.Add);
                    targetMaterial.SetInt(propData.SrcBlendAlphaProp, (int)UnityEngine.Rendering.BlendMode.One);
                    targetMaterial.SetInt(propData.DstBlendAlphaProp, (int)UnityEngine.Rendering.BlendMode.Zero);
                    targetMaterial.SetInt(propData.BlendOpAlphaProp, (int)UnityEngine.Rendering.BlendOp.Add);
                    targetMaterial.renderQueue = (int)UnityEngine.Rendering.RenderQueue.Geometry;
                    targetMaterial.SetInt(propData.ZWriteProp, 1);
                    break;
                case RenderType.Cutout:
                    targetMaterial.SetOverrideTag("RenderType", "TransparentCutout");
                    targetMaterial.SetInt(propData.SrcBlendProp, (int)UnityEngine.Rendering.BlendMode.One);
                    targetMaterial.SetInt(propData.DstBlendProp, (int)UnityEngine.Rendering.BlendMode.Zero);
                    targetMaterial.SetInt(propData.BlendOpProp, (int)UnityEngine.Rendering.BlendOp.Add);
                    targetMaterial.SetInt(propData.SrcBlendAlphaProp, (int)UnityEngine.Rendering.BlendMode.One);
                    targetMaterial.SetInt(propData.DstBlendAlphaProp, (int)UnityEngine.Rendering.BlendMode.Zero);
                    targetMaterial.SetInt(propData.BlendOpAlphaProp, (int)UnityEngine.Rendering.BlendOp.Add);
                    targetMaterial.renderQueue = (int)UnityEngine.Rendering.RenderQueue.AlphaTest;
                    targetMaterial.SetInt(propData.ZWriteProp, 1);
                    break;
                case RenderType.Transparent:
                    targetMaterial.SetOverrideTag("RenderType", "Transparent");
                    targetMaterial.SetInt(propData.SrcBlendProp, (int)UnityEngine.Rendering.BlendMode.One);
                    targetMaterial.SetInt(propData.DstBlendProp, (int)UnityEngine.Rendering.BlendMode.OneMinusSrcAlpha);
                    targetMaterial.SetInt(propData.BlendOpProp, (int)UnityEngine.Rendering.BlendOp.Add);
                    targetMaterial.SetInt(propData.SrcBlendAlphaProp, (int)UnityEngine.Rendering.BlendMode.One);
                    targetMaterial.SetInt(propData.DstBlendAlphaProp, (int)UnityEngine.Rendering.BlendMode.OneMinusSrcAlpha);
                    targetMaterial.SetInt(propData.BlendOpAlphaProp, (int)UnityEngine.Rendering.BlendOp.Add);
                    targetMaterial.renderQueue = (int)UnityEngine.Rendering.RenderQueue.Transparent;
                    targetMaterial.SetInt(propData.ZWriteProp, 0);
                    break;
                case RenderType.Fade:
                    targetMaterial.SetOverrideTag("RenderType", "Transparent");
                    targetMaterial.SetInt(propData.SrcBlendProp, (int)UnityEngine.Rendering.BlendMode.SrcAlpha);
                    targetMaterial.SetInt(propData.DstBlendProp, (int)UnityEngine.Rendering.BlendMode.OneMinusSrcAlpha);
                    targetMaterial.SetInt(propData.BlendOpProp, (int)UnityEngine.Rendering.BlendOp.Add);
                    targetMaterial.SetInt(propData.SrcBlendAlphaProp, (int)UnityEngine.Rendering.BlendMode.One);
                    targetMaterial.SetInt(propData.DstBlendAlphaProp, (int)UnityEngine.Rendering.BlendMode.One);
                    targetMaterial.SetInt(propData.BlendOpAlphaProp, (int)UnityEngine.Rendering.BlendOp.Max);
                    targetMaterial.renderQueue = (int)UnityEngine.Rendering.RenderQueue.Transparent;
                    targetMaterial.SetInt(propData.ZWriteProp, 0);
                    break;
                case RenderType.Custom:
                    break;
            }
        }

        private bool IsMaterialSetUpForRenderType(Material targetMaterial, MaterialPropertyData propData, RenderType renderType)
        {
            switch (renderType)
            {
                case RenderType.Opaque:
                    return targetMaterial.GetInt(propData.SrcBlendProp) == (int)UnityEngine.Rendering.BlendMode.One &&
                           targetMaterial.GetInt(propData.DstBlendProp) == (int)UnityEngine.Rendering.BlendMode.Zero &&
                           targetMaterial.GetInt(propData.BlendOpProp) == (int)UnityEngine.Rendering.BlendOp.Add &&
                           targetMaterial.GetInt(propData.SrcBlendAlphaProp) == (int)UnityEngine.Rendering.BlendMode.One &&
                           targetMaterial.GetInt(propData.DstBlendAlphaProp) == (int)UnityEngine.Rendering.BlendMode.Zero &&
                           targetMaterial.GetInt(propData.BlendOpAlphaProp) == (int)UnityEngine.Rendering.BlendOp.Add &&
                           targetMaterial.renderQueue > -1 && targetMaterial.renderQueue <= ((int)UnityEngine.Rendering.RenderQueue.AlphaTest) - 1;
                //    targetMaterial.GetInt(propData.ZWriteProp) == 1;
                case RenderType.Cutout:
                    return targetMaterial.GetInt(propData.SrcBlendProp) == (int)UnityEngine.Rendering.BlendMode.One &&
                           targetMaterial.GetInt(propData.DstBlendProp) == (int)UnityEngine.Rendering.BlendMode.Zero &&
                           targetMaterial.GetInt(propData.BlendOpProp) == (int)UnityEngine.Rendering.BlendOp.Add &&
                           targetMaterial.GetInt(propData.SrcBlendAlphaProp) == (int)UnityEngine.Rendering.BlendMode.One &&
                           targetMaterial.GetInt(propData.DstBlendAlphaProp) == (int)UnityEngine.Rendering.BlendMode.Zero &&
                           targetMaterial.GetInt(propData.BlendOpAlphaProp) == (int)UnityEngine.Rendering.BlendOp.Add &&
                           targetMaterial.renderQueue >= (int)UnityEngine.Rendering.RenderQueue.AlphaTest && targetMaterial.renderQueue <= ((int)UnityEngine.Rendering.RenderQueue.GeometryLast);
                //    targetMaterial.GetInt(propData.ZWriteProp) == 1;
                case RenderType.Transparent:
                    return targetMaterial.GetInt(propData.SrcBlendProp) == (int)UnityEngine.Rendering.BlendMode.One &&
                           targetMaterial.GetInt(propData.DstBlendProp) == (int)UnityEngine.Rendering.BlendMode.OneMinusSrcAlpha &&
                           targetMaterial.GetInt(propData.BlendOpProp) == (int)UnityEngine.Rendering.BlendOp.Add &&
                           targetMaterial.GetInt(propData.SrcBlendAlphaProp) == (int)UnityEngine.Rendering.BlendMode.One &&
                           targetMaterial.GetInt(propData.DstBlendAlphaProp) == (int)UnityEngine.Rendering.BlendMode.OneMinusSrcAlpha &&
                           targetMaterial.GetInt(propData.BlendOpAlphaProp) == (int)UnityEngine.Rendering.BlendOp.Add &&
                           targetMaterial.renderQueue > ((int)UnityEngine.Rendering.RenderQueue.GeometryLast) + 1 && targetMaterial.renderQueue <= ((int)UnityEngine.Rendering.RenderQueue.Overlay) - 1;
                //    targetMaterial.GetInt(propData.ZWriteProp) == 0;
                case RenderType.Fade:
                    return targetMaterial.GetInt(propData.SrcBlendProp) == (int)UnityEngine.Rendering.BlendMode.SrcAlpha &&
                           targetMaterial.GetInt(propData.DstBlendProp) == (int)UnityEngine.Rendering.BlendMode.OneMinusSrcAlpha &&
                           targetMaterial.GetInt(propData.BlendOpProp) == (int)UnityEngine.Rendering.BlendOp.Add &&
                           targetMaterial.GetInt(propData.SrcBlendAlphaProp) == (int)UnityEngine.Rendering.BlendMode.One &&
                           targetMaterial.GetInt(propData.DstBlendAlphaProp) == (int)UnityEngine.Rendering.BlendMode.One &&
                           targetMaterial.GetInt(propData.BlendOpAlphaProp) == (int)UnityEngine.Rendering.BlendOp.Max &&
                           targetMaterial.renderQueue > ((int)UnityEngine.Rendering.RenderQueue.GeometryLast) + 1 && targetMaterial.renderQueue <= ((int)UnityEngine.Rendering.RenderQueue.Overlay) - 1;
                //    targetMaterial.GetInt(propData.ZWriteProp) == 0;
                case RenderType.Custom:
                    return true;
            }

            return false;
        }

    }
}