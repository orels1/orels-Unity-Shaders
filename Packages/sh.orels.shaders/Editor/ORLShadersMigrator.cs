using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using UnityEditor;
using UnityEngine;

namespace ORL.Shaders
{
    public class ORLShadersMigrator : EditorWindow
    {
        [MenuItem("Tools/orels1/Migrate Shaders")]
        public static void ShowWindow()
        {
            var window = GetWindow<ORLShadersMigrator>(true);
            window.titleContent = new GUIContent($"ORL Shaders Migrator");
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

        // old GUID -> new GUID
        private static Dictionary<string, string> _migrationMap = new Dictionary<string, string>()
        {
            { "02b44cf07259bda4592d27f11536b39d", "bb1fc5fc14b648debb2f566068d58f43" },
            { "590a035cb264dbe428f749e03be09bf4", "3944d5378419d984583e5d7cfe7d611d" },
            { "915eaab166e9b964abd9a9486eef9dac", "81e10a4c59687964aaf903c7612ae9c1" },
            { "2275fa1837feeec488ff498f874f1f4c", "77a966990a60b6849bcc5ae9e684facc" },
            { "d76ef0f150281d1498cc80a45d9c5358", "1cd3eff6941570c46a0cca0ae963bd8c" },
            { "2190dbf828f1685419df234767c5e2c4", "d22b0ac99dbae7e4a9bdca0b613b2464" },
            { "9edf3bad854dd7f4f8a527bc600d6588", "e224c6e9d43e7c745b42078c6191393f" },
            { "894debc09c05bd643a49369e54629c0e", "13b2ccd4f6364f84ba5e8fa8fd1698cc" },
            { "59d2f25a89a34f34fa23f851d7c5d830", "e3221c2c550562449b5c42addb301b40" },
            { "f3c2bbeecfe6dd246ba0597b41c5d4c4", "b36109bcda611f9498611a60783d4d83" },
            { "f3ebe765fc449c345849abaeb6ab89f7", "fc636102982bd9548b08929996e8c67e" },
            { "d6893d669363e58488ed3c131379a0d2", "5664541c8a9b2bc489c9fa4f3d3e81f8" },
            { "003f099eedad1cc489451a03850c2c12", "029f9b562195c5a488f0744e956fca59" },
            { "1b03fffd06279344f92579165d1a821c", "f29b375ac6ad8e84f9a5095e5857e957" },
            { "0caac922b36d9e74e8435b8316baf498", "650f7b5fdb04efe42ac612d9fd0d03cb" },
            { "5f69cf125658cc046a729a5a5b4b9a11", "7de358116a341004b94136337d239d1b" },
            { "307b9906231b0784884d4b52416215a8", "10f0534e8e8748a409849338afe43251" },
        };

        // private static string _fileId = "-8512187303908658807";

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
                EditorGUIUtility.fieldWidth = 64;

                if (GUILayout.Button("Find Materials using ORL Shaders", GUILayout.Height(30)))
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
                                EditorGUILayout.ObjectField(AssetDatabase.LoadAssetAtPath<Material>(mat), typeof (Material), false);
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
                var shaderPath = AssetDatabase.GUIDToAssetPath(_migrationMap[shaderGuid]);
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