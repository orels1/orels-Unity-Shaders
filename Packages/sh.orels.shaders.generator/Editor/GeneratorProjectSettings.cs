using System;
using System.Collections.Generic;
using System.IO;
using NUnit.Framework;
using UnityEditor;
using UnityEngine;
using UnityEngine.UIElements;

namespace ORL.ShaderGenerator.Settings
{
    [Serializable]
    public struct ModuleRemap
    {
        public string Source;
        public string Destination;
    }

    public class GeneratorProjectSettings : ScriptableObject
    {

        public List<string> alwaysIncludedBlocks = new() {
            "@/Structs/VertexData",
            "@/Structs/FragmentData",
            "@/Libraries/CoreRPShaderLibrary/BiRPtoURP",
            "@/Libraries/Utilities",
            "@/Libraries/SamplingLibrary"
        };

        public string defaultLightingModel = "@/LightingModels/PBR";

        public bool forceDebugBuilds = false;

        public List<ModuleRemap> userModuleRemaps = new();

        internal const string SETTINGS_FOLDER = "Assets/Settings";
        internal const string SETTINGS_PATH = "Assets/Settings/ORLShaderGeneratorSettings.asset";

        public static GeneratorProjectSettings GetOrCreateSettings()
        {
            var settings = AssetDatabase.LoadAssetAtPath<GeneratorProjectSettings>(SETTINGS_PATH);
            if (settings != null) return settings;

            settings = ScriptableObject.CreateInstance<GeneratorProjectSettings>();
            if (!Directory.Exists(SETTINGS_FOLDER))
            {
                Directory.CreateDirectory(SETTINGS_FOLDER);
            }
            AssetDatabase.CreateAsset(settings, SETTINGS_PATH);
            AssetDatabase.SaveAssets();

            return settings;
        }

        /// <summary>
        /// This version of Get Settings does not create a physical asset if none exists.
        /// This is needed for scripted importers, as creating an asset during import will cause a unity error
        /// </summary>
        /// <returns></returns>
        public static GeneratorProjectSettings GetSettings()
        {
            var settings = AssetDatabase.LoadAssetAtPath<GeneratorProjectSettings>(SETTINGS_PATH);
            if (settings != null) return settings;

            settings = ScriptableObject.CreateInstance<GeneratorProjectSettings>();
            return settings;
        }

        public static SerializedObject GetSerializedSettings()
        {
            return new SerializedObject(GetOrCreateSettings());
        }

        public static void ResetSettings()
        {
            if (!File.Exists(SETTINGS_PATH)) return;
            AssetDatabase.DeleteAsset(SETTINGS_PATH);
            GetOrCreateSettings();
        }
    }

    internal class GeneratorProjectSettingsProvider : SettingsProvider
    {
        public GeneratorProjectSettingsProvider(string path, SettingsScope scope = SettingsScope.Project) : base(path, scope) { }

        public static bool IsSettingsAvailable()
        {
            return File.Exists(GeneratorProjectSettings.SETTINGS_PATH);
        }

        private SerializedObject _settings;
        public override void OnActivate(string searchContext, VisualElement rootElement)
        {
            _settings = GeneratorProjectSettings.GetSerializedSettings();
        }

        public override void OnGUI(string searchContext)
        {
            _settings.Update();
            EditorGUILayout.LabelField("Always Included Blocks", EditorStyles.boldLabel);
            EditorGUILayout.HelpBox(new GUIContent("These blocks will always be included in every shader"));
            EditorGUILayout.PropertyField(_settings.FindProperty("alwaysIncludedBlocks"), new GUIContent("Blocks List"));


            EditorGUILayout.Space();

            EditorGUILayout.PropertyField(_settings.FindProperty("defaultLightingModel"));
            EditorGUILayout.HelpBox(new GUIContent("The default lighting model is used when no lighting model is specified in the shader definition"));

            EditorGUILayout.Space();

            EditorGUILayout.LabelField("User Module Remaps", EditorStyles.boldLabel);
            EditorGUILayout.HelpBox(new GUIContent("This list of remaps allows you to arbitrarily swap out modules by import path. E.g. you can replace all inclusions of a particular module with your custom one"));

            var remapsProp = _settings.FindProperty("userModuleRemaps");
            remapsProp.isExpanded = EditorGUILayout.Foldout(remapsProp.isExpanded, new GUIContent("Remaps List"));
            if (remapsProp.isExpanded)
            {
                using (new EditorGUILayout.VerticalScope(EditorStyles.helpBox))
                {
                    for (var i = 0; i < remapsProp.arraySize; i++)
                    {
                        using (new EditorGUILayout.HorizontalScope())
                        {
                            var sourceProp = remapsProp.GetArrayElementAtIndex(i).FindPropertyRelative("Source");
                            var destinationProp = remapsProp.GetArrayElementAtIndex(i).FindPropertyRelative("Destination");
                            EditorGUILayout.PropertyField(sourceProp, GUIContent.none);
                            EditorGUILayout.LabelField(" -> ", GUILayout.Width(30));
                            EditorGUILayout.PropertyField(destinationProp, GUIContent.none);
                            if (GUILayout.Button("Remove"))
                            {
                                remapsProp.DeleteArrayElementAtIndex(i);
                                break;
                            }
                        }
                    }
                    if (GUILayout.Button("Add New Remap"))
                    {
                        remapsProp.InsertArrayElementAtIndex(remapsProp.arraySize);
                    }
                }
            }

            if (GUILayout.Button("Regenerate All Shaders"))
            {
                AssetDatabase.StartAssetEditing();
                try
                {
                    foreach (var asset in AssetDatabase.FindAssets("t:shader", new string[] { "Assets", "Packages" }))
                    {
                        var path = AssetDatabase.GUIDToAssetPath(asset);
                        var importer = AssetImporter.GetAtPath(path) as ShaderDefinitionImporter;
                        if (importer != null)
                        {
                            AssetDatabase.ImportAsset(path, ImportAssetOptions.ForceUpdate);
                        }
                    }
                }
                finally
                {
                    AssetDatabase.StopAssetEditing();
                    AssetDatabase.Refresh();
                }
            }
            EditorGUILayout.HelpBox("This will regenerate all shaders in the project. This is useful if you have made changes to the remaps", MessageType.Info);

            EditorGUILayout.Space();

            EditorGUILayout.PropertyField(_settings.FindProperty("forceDebugBuilds"));

            _settings.ApplyModifiedPropertiesWithoutUndo();

            if (GUILayout.Button("Reset Settings"))
            {
                if (EditorUtility.DisplayDialog("Reset Settings", "Are you sure you want to reset the settings? This will delete all the remaps and any other settings you have changed", "Yes", "No"))
                {
                    GeneratorProjectSettings.ResetSettings();
                    _settings = GeneratorProjectSettings.GetSerializedSettings();
                    return;
                }
            }
        }

        [SettingsProvider]
        public static SettingsProvider CreateGeneratorProjectSettingsProvider()
        {
            if (IsSettingsAvailable())
            {
                var provider = new GeneratorProjectSettingsProvider("Project/orels1/Shader Generator", SettingsScope.Project);
                provider.keywords = GetSearchKeywordsFromSerializedObject(GeneratorProjectSettings.GetSerializedSettings());
                return provider;
            }
            else
            {
                GeneratorProjectSettings.GetOrCreateSettings();
            }

            return null;
        }


    }
}