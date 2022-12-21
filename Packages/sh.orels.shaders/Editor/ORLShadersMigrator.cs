using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using UnityEditor;
using UnityEngine;
using YamlDotNet.Serialization;

namespace ORL.Shaders
{
    public class ORLShadersMigrator : EditorWindow
    {
        [MenuItem("Tools/orels1/Migrate Shaders")]
        public static void ShowWindow()
        {
            var locator = Resources.Load<TextAsset>("ORLShadersResourceLocator");
            var locatorPath = AssetDatabase.GetAssetPath(locator);
            var freshAsset = false;
            var settingsAsset = Resources.Load<ORLShadersSettings>("ORLShadersSettings");
            if (settingsAsset == null)
            {
                freshAsset = true;
                settingsAsset = CreateInstance<ORLShadersSettings>();
                AssetDatabase.CreateAsset(settingsAsset, locatorPath.Substring(0, locatorPath.LastIndexOf("/")) + "/ORLShadersSettings.asset");
                AssetDatabase.Refresh();
            }
            var settingsPath = AssetDatabase.GetAssetPath(settingsAsset);
            var packagePath = Application.dataPath.Replace("Assets", "") +
                              settingsPath.Substring(0, settingsPath.LastIndexOf("/"));
            packagePath = packagePath.Substring(0, packagePath.LastIndexOf("/"));
            packagePath = packagePath.Substring(0, packagePath.LastIndexOf("/"));
            packagePath += "/package.json";
            var jsonString =
                File.ReadAllLines(packagePath);
            var version = jsonString.Where(line => line.Contains("\"version\""))
                .Select(line => line.Trim()).First();
            version = version.Split(new [] { ": " }, StringSplitOptions.None)[1];
            version = version.Substring(1);
            version = version.Substring(0, version.Length - 1);
            version = version.Replace("\"", "");

            var currVersion = freshAsset ? version : settingsAsset.ShadersVersion;

            if (freshAsset)
            {
                settingsAsset.ShadersVersion = version;
                AssetDatabase.SaveAssets();
            }
            
            ShowWindow(currVersion, version);
        }

        private static string _oldVersion;
        private static string _newVersion;
        public static void ShowWindow(string oldVersion, string newVersion)
        {
            _oldVersion = oldVersion;
            _newVersion = newVersion;
            
            var window = GetWindow<ORLShadersMigrator>(true);
            window.titleContent = new GUIContent($"ORL Shaders Migrator ({_oldVersion} -> {_newVersion})");
            window.minSize = new Vector2(300, 500);
            window.Show();
        }
        
        private static HashSet<string> _migrateableShaders = new HashSet<string>
        {
            "02b44cf07259bda4592d27f11536b39d",
            "590a035cb264dbe428f749e03be09bf4",
            "915eaab166e9b964abd9a9486eef9dac",
            "2275fa1837feeec488ff498f874f1f4c",
            "d76ef0f150281d1498cc80a45d9c5358",
            "2190dbf828f1685419df234767c5e2c4",
            "9edf3bad854dd7f4f8a527bc600d6588",
            "894debc09c05bd643a49369e54629c0e",
            "59d2f25a89a34f34fa23f851d7c5d830",
            "f3c2bbeecfe6dd246ba0597b41c5d4c4",
            "f3ebe765fc449c345849abaeb6ab89f7",
            "d6893d669363e58488ed3c131379a0d2",
            "003f099eedad1cc489451a03850c2c12",
            "02b44cf07259bda4592d27f11536b39d",
            "1b03fffd06279344f92579165d1a821c",
            "0caac922b36d9e74e8435b8316baf498",
            "5f69cf125658cc046a729a5a5b4b9a11",
            "307b9906231b0784884d4b52416215a8",
            // "e67e822f851164b40b6b701128914625" // This is Tessellated Displacement, it is currently an old shader, so no migration is needed
        };

        private static string _fileId = "-8512187303908658807";

        private List<string> _affectedMaterials = new List<string>();
        private Vector2 _affectedMatsScrollPos = Vector2.zero;
        private bool _dryRun;

        private void OnGUI()
        {
            using (new GUILayout.VerticalScope(new GUIStyle
                   {
                       margin = new RectOffset(10, 10, 10, 10)
                   }))
            {
                if (_oldVersion == _newVersion)
                {
                    EditorGUILayout.LabelField("You have the latest version, migration should not be required!");
                }
                else
                {
                    EditorGUILayout.LabelField("Shader Migration might be required", EditorStyles.boldLabel);
                }
                EditorGUIUtility.fieldWidth = 64;
                EditorGUILayout.Space(10);
                using (new EditorGUILayout.HorizontalScope())
                {
                    EditorGUILayout.TextField(_oldVersion);
                    EditorGUILayout.Space(10);
                    EditorGUILayout.LabelField("->", GUILayout.Width(20));
                    EditorGUILayout.Space(10);
                    EditorGUILayout.TextField(_newVersion);
                }
                EditorGUILayout.Space(10);

                if (GUILayout.Button("Find Affected Materials", GUILayout.Height(30)))
                {
                    _affectedMaterials = FindAffectedMaterials();
                }
                EditorGUILayout.HelpBox(new GUIContent("Clicking this button will look through your assets to find materials that might need migration"));

                if (_affectedMaterials.Count > 0)
                {
                    EditorGUILayout.Space(10);
                    EditorGUILayout.LabelField("The following materials will be migrated to new shaders", EditorStyles.boldLabel);
                    using (new GUILayout.VerticalScope(EditorStyles.helpBox))
                    {
                        using (var scroller = new GUILayout.ScrollViewScope(_affectedMatsScrollPos))
                        {
                            _affectedMatsScrollPos = scroller.scrollPosition;
                            foreach (var mat in _affectedMaterials)
                            {
                                EditorGUILayout.ObjectField(AssetDatabase.LoadAssetAtPath<Material>(mat), typeof (Material));
                            }
                        }
                    }

                    GUI.backgroundColor = new Color(95.0f / 255.0f, 237.0f / 255.0f, 47.0f / 255.0f);
                    if (GUILayout.Button("Migrate Now", GUILayout.Height(30)))
                    {
                        Migrate();
                    }
                    GUI.backgroundColor = Color.white;

                    _dryRun = EditorGUILayout.Toggle("Dry run", _dryRun);
                    EditorGUILayout.HelpBox(new GUIContent("Dry run will not save any changes to your assets, it will print what the migration would do into the log instead"));
                }
            }
        }
        
        private List<string> FindAffectedMaterials()
        {
            var affectedMaterials = new List<string>();
            EditorUtility.DisplayProgressBar("Looking up Materials", "Please wait...", 0);
            var guids = AssetDatabase.FindAssets("t:Material");
            var i = 0f;
            foreach (var guid in guids)
            {
                var path = AssetDatabase.GUIDToAssetPath(guid);
                EditorUtility.DisplayProgressBar("Looking up Materials", $"Checking {path}", i / guids.Length);
                var material = AssetDatabase.LoadAssetAtPath<Material>(path);
                if (material == null)
                {
                    i++;
                    continue;
                }
                if (material.shader == null)
                {
                    i++;
                    continue;
                }
                var matYamlSource = File.ReadAllLines(Application.dataPath.Replace("\\", "/").Replace("Assets", "") + path);
                var shaderLines = matYamlSource.Where(line => line.Trim().StartsWith("m_Shader")).ToList();
                if (shaderLines.Count == 0)
                {
                    i++;
                    continue;
                }
                var guidLine = shaderLines.First();
                var shaderGuid = guidLine.Substring(guidLine.IndexOf("guid: ") + 6);
                shaderGuid = shaderGuid.Substring(0, shaderGuid.IndexOf(","));
                if (!_migrateableShaders.Contains(shaderGuid))
                {
                    i++;
                    continue;
                }
                affectedMaterials.Add(path);
                i++;
            }
            EditorUtility.ClearProgressBar();

            return affectedMaterials;
        }

        private void Migrate()
        {
            EditorUtility.DisplayProgressBar("Migrating Materials", "Please wait...", 0);
            var group = Undo.GetCurrentGroup();
            var i = 0f;
            foreach (var path in _affectedMaterials)
            {
                var mat = AssetDatabase.LoadAssetAtPath<Material>(path);
                var matYamlSource = File.ReadAllLines(Application.dataPath.Replace("\\", "/").Replace("Assets", "") + path);
                var shaderLines = matYamlSource.Where(line => line.Trim().StartsWith("m_Shader")).ToList();
                if (shaderLines.Count == 0)
                {
                    EditorUtility.DisplayProgressBar("Migrating Materials", $"Skipping {path}..", i / _affectedMaterials.Count);
                    i++;
                    continue;
                }
                EditorUtility.DisplayProgressBar("Migrating Materials", $"Migrating {path}...", i / _affectedMaterials.Count);
                var guidLine = shaderLines.First();
                var shaderGuid = guidLine.Substring(guidLine.IndexOf("guid: ") + 6);
                shaderGuid = shaderGuid.Substring(0, shaderGuid.IndexOf(","));
                var shaderPath = AssetDatabase.GUIDToAssetPath(shaderGuid);
                var shader = AssetDatabase.LoadAssetAtPath<Shader>(shaderPath);
                if (!_dryRun)
                {
                    Undo.RecordObject(mat, "Migrated Material");
                    mat.shader = shader;
                }
                else
                {
                    Debug.Log("DRY RUN. Would have migrated " + path + " from " + shaderGuid + " to " + shader.name);
                }
                i++;
            }
            Undo.CollapseUndoOperations(group);
            EditorUtility.ClearProgressBar();
        }
    }
}