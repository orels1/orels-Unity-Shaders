using System.Collections.Generic;
using System.IO;
using System.Text;
using NUnit.Framework;
using UnityEditor;
using UnityEditorInternal;
using UnityEditor.Experimental.AssetImporters;
using UnityEngine;

namespace ORL.ShaderGenerator
{
    [CustomEditor(typeof(ConfiguredShaderDefinitionImporter))]
    public class ConfiguredShaderDefinitionImporterEditor : ShaderDefinitionImporterEditor
    {
        private List<string> _builtInLMs = new List<string>();
        private List<string> _builtInShaders = new List<string>();
        private List<string> _builtInModules = new List<string>();
        private Dictionary<string, ReorderableListProperty> reorderableLists;

        public override void OnEnable()
        {
            reorderableLists = new Dictionary<string, ReorderableListProperty>(10);
            ScanForBuiltInAssets();
            base.OnEnable();
        }

        public override void OnInspectorGUI()
        {
            EditorGUILayout.PropertyField(serializedObject.FindProperty("shaderName"));
            
            EditorGUILayout.Space(2);
            
            var baseShaderValue = serializedObject.FindProperty("baseShader").stringValue.Replace("@/Shaders/", string.Empty);
            var hasBaseShader = !string.IsNullOrWhiteSpace(baseShaderValue) && baseShaderValue != "None";

            var lmValue = serializedObject.FindProperty("lightingModel").stringValue
                .Replace("@/LightingModels/", string.Empty);

            if (!hasBaseShader)
            {
                var currLMIndex = _builtInLMs.IndexOf(lmValue);
                if (currLMIndex == -1)
                {
                    currLMIndex = 0;
                }
                
                serializedObject.FindProperty("lightingModel").stringValue =
                    $"@/LightingModels/{_builtInLMs[EditorGUILayout.Popup("Lighting Model", currLMIndex, _builtInLMs.ToArray())]}";
            }

            var currShaderIndex = _builtInShaders.IndexOf(baseShaderValue);
            if (currShaderIndex == -1)
            {
                currShaderIndex = 0;
            }

            var newBaseShader =
                _builtInShaders[EditorGUILayout.Popup("Base Shader", currShaderIndex, _builtInShaders.ToArray())];
            if (newBaseShader.Equals("None"))
            {
                serializedObject.FindProperty("baseShader").stringValue = null;
            }
            else
            {
                serializedObject.FindProperty("baseShader").stringValue = $"@/Shaders/{newBaseShader}";
            }

            EditorGUILayout.Space(5);
            
            var modulesProp = serializedObject.FindProperty("modules");
            var modulesListData = GetReorderableList(modulesProp);
            modulesListData.modules = _builtInModules;
            modulesListData.List.DoLayoutList();

            serializedObject.ApplyModifiedProperties();

            if (GUILayout.Button("Modules/Features List"))
            {
                Application.OpenURL("https://shaders.orels.sh/docs/shaders-list");
            }

            var hasDupes = false;
            var allModules = new List<string>();
            var hasToon = false;
            for (int i = 0; i < modulesProp.arraySize; i++)
            {
                var module = modulesProp.GetArrayElementAtIndex(i).stringValue;
                if (allModules.Contains(module))
                {
                    hasDupes = true;
                }

                if (module.Contains("Toon"))
                {
                    hasToon = true;
                }
                allModules.Add(module);
            }

            if (hasBaseShader && allModules.Contains("@/Modules/BaseColor"))
            {
                EditorGUILayout.HelpBox("Usage of BaseColor module with any of the Base Shaders will often lead to compile issues, it is recommended to remove it", MessageType.Warning);
            }
            
            if (hasBaseShader && allModules.Contains("@/Modules/Toon/Main"))
            {
                EditorGUILayout.HelpBox("Usage of Toon/Main module with any of the Base Shaders will often lead to compile issues, it is recommended to remove it", MessageType.Warning);
            }

            if (hasDupes)
            {
                EditorGUILayout.HelpBox("There are duplicate modules in your modules list, make sure you do not have repeat modules", MessageType.Error);
            }

            if (hasToon && (lmValue != "Toon" || (hasBaseShader && !baseShaderValue.Contains("Toon"))))
            {
                EditorGUILayout.HelpBox("Toon modules on non-toon shaders might not work as expected. Use of a Toon module or Toon Lighting Model is recommended", MessageType.Warning);
            }

            if (modulesProp.arraySize > 0)
            {
                EditorGUILayout.HelpBox("Not every module is guaranteed to work with the rest. Try different combinations in different order and see what works!", MessageType.Info);
            }
            
            EditorGUILayout.Space(5);

            base.OnInspectorGUI();
        }

        private const string LMS_PATH = "Packages/sh.orels.shaders.generator/Runtime/Sources/LightingModels";
        private const string MODULES_PATH = "Packages/sh.orels.shaders.generator/Runtime/Sources/Modules";
        private const string SHADERS_PATH = "Packages/sh.orels.shaders/Runtime/Shaders";

        private void ScanForBuiltInAssets()
        {
            _builtInLMs.Clear();
            var allLMs = Directory.GetFiles(LMS_PATH, "*.orlsource", SearchOption.AllDirectories);
            foreach (var file in allLMs)
            {
                if (file.EndsWith(".meta")) continue;
                _builtInLMs.Add(file.Replace(LMS_PATH, string.Empty).Substring(1)
                    .Replace(".orlsource", string.Empty).Replace('\\', '/'));
            }

            _builtInModules.Clear();
            var allModules = Directory.GetFiles(MODULES_PATH, "*.orlsource", SearchOption.AllDirectories);
            foreach (var module in allModules)
            {
                if (module.EndsWith(".meta")) continue;
                _builtInModules.Add(module.Replace(MODULES_PATH, string.Empty).Substring(1)
                    .Replace(".orlsource", string.Empty).Replace('\\', '/'));
            }

            _builtInShaders.Clear();
            _builtInShaders.Add("None");
            var allShaders = Directory.GetFiles(SHADERS_PATH, "*.orlshader", SearchOption.AllDirectories);
            foreach (var shader in allShaders)
            {
                if (shader.EndsWith(".meta")) continue;
                _builtInShaders.Add(shader.Replace(SHADERS_PATH, string.Empty).Substring(1)
                    .Replace(".orlshader", string.Empty).Replace('\\', '/'));
            }
        }

        private ReorderableListProperty GetReorderableList(SerializedProperty prop)
        {
            ReorderableListProperty ret = null;
            if (reorderableLists.TryGetValue(prop.name, out ret))
            {
                ret.Property = prop;
                return ret;
            }

            ret = new ReorderableListProperty(prop);
            reorderableLists.Add(prop.name, ret);
            return ret;
        }

        private ReorderableListProperty GetReorderableList(SerializedProperty prop, SerializedProperty otherProp)
        {
            ReorderableListProperty ret = null;
            if (reorderableLists.TryGetValue(prop.name, out ret))
            {
                ret.Property = prop;
                return ret;
            }

            ret = new ReorderableListProperty(prop, otherProp);
            reorderableLists.Add(prop.name, ret);
            return ret;
        }

        private class ReorderableListProperty
        {
            public bool IsExpanded { get; set; }
            public ReorderableList List { get; private set; }
            public List<string> modules;

            private SerializedProperty prop;
            private SerializedProperty otherProp;
            private bool doubleList;

            public SerializedProperty Property
            {
                get => prop;
                set
                {
                    prop = value;
                    List.serializedProperty = prop;
                }
            }

            public ReorderableListProperty(SerializedProperty property)
            {
                IsExpanded = property.isExpanded;
                prop = property;
                CreateList();
            }

            public ReorderableListProperty()
            {
                prop = null;
                List = null;
            }

            public ReorderableListProperty(SerializedProperty property, SerializedProperty otherProperty)
            {
                IsExpanded = property.isExpanded;
                prop = property;
                otherProp = otherProperty;
                doubleList = true;
                CreateList();
            }

            private void CreateList()
            {
                List = new ReorderableList(Property.serializedObject, Property, true, true, true, true);
                List.drawHeaderCallback += rect => EditorGUI.LabelField(rect, prop.displayName);
                List.onCanRemoveCallback += list => List.count > 0;
                List.drawElementCallback += DrawElement;
                List.elementHeightCallback += idx => Mathf.Max(EditorGUIUtility.singleLineHeight,
                    EditorGUI.GetPropertyHeight(prop.GetArrayElementAtIndex(idx),
                        GUIContent.none, true)) + 4f;
            }

            private void DrawElement(Rect rect, int index, bool active, bool focused)
            {
                if (prop.GetArrayElementAtIndex(index).propertyType == SerializedPropertyType.Generic)
                {
                    EditorGUI.LabelField(rect, prop.GetArrayElementAtIndex(index).displayName);
                }

                rect.height = EditorGUI.GetPropertyHeight(prop.GetArrayElementAtIndex(index), GUIContent.none, true);
                rect.y += 1;
                if (!doubleList)
                {
                    var currIndex = modules.IndexOf(prop.GetArrayElementAtIndex(index).stringValue
                        .Replace("@/Modules/", string.Empty));
                    if (currIndex == -1)
                    {
                        currIndex = 0;
                    }

                    prop.GetArrayElementAtIndex(index).stringValue =
                        $"@/Modules/{modules[EditorGUI.Popup(rect, currIndex, modules.ToArray())]}";
                    // EditorGUI.PropertyField(rect, prop.GetArrayElementAtIndex(index), GUIContent.none, true);
                }
                else
                {
                    var secondRect = EditorGUI.IndentedRect(rect);
                    secondRect.xMin = rect.xMax / 2f + 2f;
                    rect.xMax = rect.xMax / 2f - 2f;
                    EditorGUI.PropertyField(rect, prop.GetArrayElementAtIndex(index), GUIContent.none, true);
                    EditorGUI.PropertyField(secondRect, otherProp.GetArrayElementAtIndex(index), GUIContent.none, true);
                }

                List.elementHeight = rect.height + 4f;
            }
        }
    }
}