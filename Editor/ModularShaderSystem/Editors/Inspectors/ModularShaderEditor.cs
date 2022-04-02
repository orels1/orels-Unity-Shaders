using System;
using System.IO;
using UnityEditor;
using UnityEngine;
using UnityEngine.UIElements;
using UnityEditor.UIElements;

namespace ORL.ModularShaderSystem.UI
{
    [CustomEditor(typeof(ModularShader))]
    public class ModularShaderEditor : Editor
    {
        private VisualElement _root;
        private ModularShader _shader;
        
        public override VisualElement CreateInspectorGUI()
        {
            _root = new VisualElement();
            _shader = (ModularShader)serializedObject.targetObject;
            var visualTree = Resources.Load<VisualTreeAsset>(MSSConstants.RESOURCES_FOLDER + "/MSSUIElements/ModularShaderEditor");
            VisualElement template = visualTree.CloneTree();

            _root.Add(template);
            
            var baseModulesField = _root.Q<ModuleInspectorList>("BaseModulesField");
            bool areModulesEditable = !_shader.LockBaseModules;
            bool checkForProperties = _shader.UseTemplatesForProperties;
            if(!areModulesEditable)
                baseModulesField.SetFoldingState(true);
            baseModulesField.SetEnabled(areModulesEditable);

            var templateField = _root.Q<ObjectField>("ShaderTemplateField");
            templateField.objectType = typeof(TemplateAsset);
            
            var propertiesTemplateField = _root.Q<ObjectField>("ShaderPropertiesTemplateField");
            propertiesTemplateField.objectType = typeof(TemplateAsset);
            propertiesTemplateField.style.display = checkForProperties ? DisplayStyle.Flex : DisplayStyle.None;
            
            var useTemplatesField = _root.Q<Toggle>("UseTemplatesForPropertiesField");
            useTemplatesField.RegisterValueChangedCallback(x =>
            {
                propertiesTemplateField.style.display = x.newValue ? DisplayStyle.Flex : DisplayStyle.None;
            });
            
            var generateButton = _root.Q<Button>("RegenerateShaderButton");

            generateButton.clicked += () =>
            {
                var _issues = ShaderGenerator.CheckShaderIssues(_shader);
                if (_issues.Count > 0)
                {
                    EditorUtility.DisplayDialog("Error", $"The modular shader has issues that must be resolved before generating the shader:\n  {string.Join("\n  ", _issues)}", "Ok");
                    return;
                }

                string path = "";
                if (_shader.LastGeneratedShaders != null &&_shader.LastGeneratedShaders.Count > 0 && _shader.LastGeneratedShaders[0] != null)
                {
                    path = Path.GetDirectoryName(AssetDatabase.GetAssetPath(_shader.LastGeneratedShaders[0]));
                }

                if (string.IsNullOrWhiteSpace(path))
                {

                    path = EditorUtility.OpenFolderPanel("Select folder", "Assets", "");
                    if (string.IsNullOrWhiteSpace(path))
                        return;

                }
                string localPath = Environment.CurrentDirectory;
                localPath = localPath.Replace('\\', '/');
                path = path.Replace(localPath + "/", "");
                ShaderGenerator.GenerateShader(path, _shader);
            };

            return _root;
        }
    }
}