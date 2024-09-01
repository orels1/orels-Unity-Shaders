﻿using System;
using System.Collections.Generic;
using System.IO;
using System.Text;
using UnityEditor;
using UnityEngine;

#if UNITY_2022_3_OR_NEWER
using UnityEditor.AssetImporters;
#else
using UnityEditor.Experimental.AssetImporters;
#endif

namespace ORL.ShaderGenerator
{
    [ScriptedImporter(1, "orlconfshader")]
    public class ConfiguredShaderDefinitionImporter : ShaderDefinitionImporter
    {
        public string shaderName = "Configurable/NewShader";
        public string lightingModel;
        public string baseShader;
        public List<string> modules = new List<string>
        {
            "@/Modules/BaseColor"
        };

        public List<bool> customModuleFlags = new List<bool>
        {
            false
        };

        public string lastGeneratedContent;
        public long lastGeneratedTime;
        public bool skipGeneration;

        public override void OnImportAsset(AssetImportContext ctx)
        {
            var finalCode = GetGeneratedContents(this);

            var currentFileContent = File.ReadAllText(ctx.assetPath);

            // Shader wasn't generated by us, flag it as modified
            var lastUpdated = File.GetLastWriteTime(ctx.assetPath);
            // check if explicitly skipping or if the shader was modified with more than 1 second difference
            Debug.Log($"Skip Generation? {skipGeneration}, Last Updated: {lastUpdated.Ticks}, Last Generated: {lastGeneratedTime}. Time Diff {(lastUpdated.Ticks - lastGeneratedTime)}");
            if (skipGeneration || ((lastUpdated.Ticks - lastGeneratedTime) > TimeSpan.FromSeconds(1).Ticks))
            {
                base.OnImportAsset(ctx);
                return;
            }

            // Otherwise - overwrite the file if it was modified
            if (!finalCode.Equals(currentFileContent, StringComparison.InvariantCulture))
            {
                File.WriteAllText(ctx.assetPath, finalCode);
            }

            base.OnImportAsset(ctx);
        }

        public static string GetGeneratedContents(ConfiguredShaderDefinitionImporter importer)
        {
            var generated = new StringBuilder();
            generated.AppendLine(@"// This file is automatically generated from the configuration defined in the UI");
            generated.AppendLine(@"// It is not recommended to edit this file manually");
            generated.AppendLine(@"// If a manual edit is detected - it will no longer be adjustable via the UI");
            generated.AppendLine(@"// You can use a force reset button in the UI to reset the file to the original state");
            generated.AppendLine($@"%ShaderName(""{importer.shaderName}"")");
            if (!string.IsNullOrWhiteSpace(importer.lightingModel) && string.IsNullOrWhiteSpace(importer.baseShader))
            {
                generated.AppendLine($@"%LightingModel(""{importer.lightingModel}"")");
            }
            generated.AppendLine(@"%CustomEditor(""ORL.ShaderInspector.InspectorGUI"")");
            generated.AppendLine();
            generated.AppendLine("%Includes()");
            generated.AppendLine("{");
            if (!string.IsNullOrWhiteSpace(importer.baseShader))
            {
                generated.AppendLine($@"    ""{importer.baseShader}"",");
            }

            foreach (var module in importer.modules)
            {
                generated.AppendLine($@"    ""{module}"",");
            }

            generated.AppendLine(@"    ""self""");
            generated.AppendLine("}");

            return generated.ToString();
        }
    }
}