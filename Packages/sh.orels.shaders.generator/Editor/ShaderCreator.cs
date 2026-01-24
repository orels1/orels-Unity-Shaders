using System;
using System.IO;
using System.Reflection;
using UnityEditor;
using UnityEditor.ProjectWindowCallback;
using UnityEngine;
using Object = UnityEngine.Object;

namespace ORL.ShaderGenerator
{
    public static class ShaderCreator
    {
        [MenuItem("Assets/Create/Shader/orels1/VFX", priority = 9)]
        private static void CreateVFXShader()
        {
            CreateShaderFromTemplate("VFX");
        }

        [MenuItem("Assets/Create/Shader/orels1/Transparent VFX", priority = 9)]
        private static void CreateTransparentVFXShader()
        {
            CreateShaderFromTemplate("TransparentVFX");
        }

        [MenuItem("Assets/Create/Shader/orels1/PBR", priority = 9)]
        private static void CreatePBRShader()
        {
            CreateShaderFromTemplate("PBR");
        }

        [MenuItem("Assets/Create/Shader/orels1/Empty PBR", priority = 9)]
        private static void CreateEmptyPBRShader()
        {
            CreateShaderFromTemplate("EmptyPBR");
        }

        [MenuItem("Assets/Create/Shader/orels1/Toon", priority = 9)]
        private static void CreateToonShader()
        {
            CreateShaderFromTemplate("Toon");
        }

        [MenuItem("Assets/Create/Shader/orels1/Toon Transparent", priority = 9)]
        private static void CreateToonTransparentShader()
        {
            CreateShaderFromTemplate("ToonTransparent");
        }

        [MenuItem("Assets/Create/Shader/orels1/Toon Transparent PrePass", priority = 9)]
        private static void CreateToonTransparentPrePassShader()
        {
            CreateShaderFromTemplate("ToonTransparentPrePass");
        }

        [MenuItem("Assets/Create/Shader/orels1/Empty Toon", priority = 9)]
        private static void CreateEmptyToonShader()
        {
            CreateShaderFromTemplate("EmptyToon");
        }

        [MenuItem("Assets/Create/Shader/orels1/UI", priority = 9)]
        private static void CreateUIShader()
        {
            CreateShaderFromTemplate("UI");
        }

        [MenuItem("Assets/Create/Shader/orels1/Configurable Shader", priority = 9)]
        private static void CreateConfigurableShader()
        {
            CreateShaderFromTemplate("Configurable", ".orlconfshader");
        }

        private static void CreateShaderFromTemplate(string templateId, string extension = ".orlshader")
        {
            var checkResource = Resources.Load<TextAsset>($"ShaderTemplates/{templateId}");
            if (checkResource == null) return;
            Type projectWindowUtilType = typeof(ProjectWindowUtil);
            MethodInfo getActiveFolderPath = projectWindowUtilType.GetMethod("GetActiveFolderPath", BindingFlags.Static | BindingFlags.NonPublic);
            if (getActiveFolderPath == null)
            {
                Debug.LogWarning("Failed to get active folder path");
                return;
            }
            object obj = getActiveFolderPath.Invoke(null, new object[0]);
            string pathToCurrentFolder = obj.ToString();
            string uniquePath = AssetDatabase.GenerateUniqueAssetPath($"{pathToCurrentFolder}/New Shader{extension}");

            ProjectWindowUtil.StartNameEditingIfProjectWindowExists(0, ScriptableObject.CreateInstance<ShaderCreateEndAction>(), uniquePath, null, templateId);
        }

        private class ShaderCreateEndAction : EndNameEditAction
        {
            public override void Action(int instanceId, string pathName, string resourceFile)
            {
                var template = Resources.Load<TextAsset>($"ShaderTemplates/{resourceFile}");
                // add modules with correct paths
                var shaderContent = template.text;

                var name = pathName.Substring(pathName.LastIndexOf("/", StringComparison.InvariantCulture) + 1).Replace(".orlshader", "");
                var sanitizedName = name.Replace("/", "_").Replace(" ", "_");
                shaderContent = shaderContent.Replace("SHADER_NAME", name);
                shaderContent = shaderContent.Replace("FRAGMENT_NAME", sanitizedName + "Fragment");
                shaderContent = shaderContent.Replace("LIGHTING_NAME", sanitizedName + "Lighting");
                shaderContent = shaderContent.Replace("VERTEX_NAME", sanitizedName + "Vertex");
                shaderContent = shaderContent.Replace("COLOR_NAME", sanitizedName + "Color");
                shaderContent = shaderContent.Replace("SECTION_NAME", sanitizedName);

                File.WriteAllText(pathName, shaderContent);
                AssetDatabase.Refresh();
                Object o = AssetDatabase.LoadAssetAtPath<Object>(pathName);
                Selection.activeObject = o;
            }
        }
    }
}
