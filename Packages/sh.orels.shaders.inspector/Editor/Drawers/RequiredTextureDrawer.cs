﻿using System;
using System.Collections.Generic;
using System.Text.RegularExpressions;
using ORL.ShaderConditions;
using UnityEditor;
using UnityEngine;

namespace ORL.Drawers
{
    public class RequiredTextureDrawer: IDrawerFunc
    {
        public string FunctionName => "RequiredTexture";
        
        // Matches %RequiredTexture(TexPath);
        private Regex _matcher = new Regex(@"(?<=[\w\s\>\s]+)\%RequiredTexture\((?<texPath>[\w\,\s\&\|\(\)\!\<\>\=\$\/\-\.\@]+)\)");

        private string _savedPath;
        private Texture2D _savedTex;

        public bool OnGUI(MaterialEditor editor, MaterialProperty[] properties, MaterialProperty property, int index, Dictionary<string, object> uiState, Func<bool> next)
        {
            if (EditorGUI.indentLevel == -1) return true;
            var match = _matcher.Match(property.displayName);
            if (!match.Success) return next();
            var texPath = match.Groups["texPath"].Value;
            // we only want to replace with default if the texture ref is not set or a new texture is referenced
            if (_savedPath == texPath && property.textureValue != null) return next();
            var fetched = FetchTex(texPath);
            if (fetched == null) return next();
            _savedTex = fetched;
            _savedPath = texPath;
            property.textureValue = fetched;

            return next();
        }
        
        private Texture2D FetchTex(string texPath)
        {
            var cleaned = texPath.Replace("@/", "Packages/sh.orels.shaders.generator/Runtime/Assets/");
            var tex = AssetDatabase.LoadAssetAtPath<Texture2D>(cleaned);
            if (tex == null)
            {
                Debug.LogError($"Could not find texture at path {cleaned}");
            }

            return tex;
        }
    }
}