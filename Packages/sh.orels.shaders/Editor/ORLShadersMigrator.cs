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

        private int _tabIndex;

        [MenuItem("Tools/orels1/Migrate Materials")]
        public static void ShowWindow()
        {
            var window = GetWindow<ORLShadersMigrator>(true);
            window.titleContent = new GUIContent($"ORL Material Migrator");
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
            "e67e822f851164b40b6b701128914625"
        };

        private static HashSet<string> _revertableShaders = new HashSet<string>
        {
            "bb1fc5fc14b648debb2f566068d58f43",
            "3944d5378419d984583e5d7cfe7d611d",
            "81e10a4c59687964aaf903c7612ae9c1",
            "77a966990a60b6849bcc5ae9e684facc",
            "1cd3eff6941570c46a0cca0ae963bd8c",
            "d22b0ac99dbae7e4a9bdca0b613b2464",
            "e224c6e9d43e7c745b42078c6191393f",
            "13b2ccd4f6364f84ba5e8fa8fd1698cc",
            "e3221c2c550562449b5c42addb301b40",
            "b36109bcda611f9498611a60783d4d83",
            "fc636102982bd9548b08929996e8c67e",
            "5664541c8a9b2bc489c9fa4f3d3e81f8",
            "029f9b562195c5a488f0744e956fca59",
            "f29b375ac6ad8e84f9a5095e5857e957",
            "650f7b5fdb04efe42ac612d9fd0d03cb",
            "7de358116a341004b94136337d239d1b",
            "10f0534e8e8748a409849338afe43251",
            "2758518bdcab40a3abd3807018be68ca"
        };

        // old GUID -> new GUID
        private static Dictionary<string, string> _migrationMap = new Dictionary<string, string>
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
            { "e67e822f851164b40b6b701128914625", "2758518bdcab40a3abd3807018be68ca" }
        };
        
        // new GUID -> old GUID
        private static Dictionary<string, string> _revertMap = new Dictionary<string, string>
        {
            { "bb1fc5fc14b648debb2f566068d58f43", "02b44cf07259bda4592d27f11536b39d" },
            { "3944d5378419d984583e5d7cfe7d611d", "590a035cb264dbe428f749e03be09bf4" },
            { "81e10a4c59687964aaf903c7612ae9c1", "915eaab166e9b964abd9a9486eef9dac" },
            { "77a966990a60b6849bcc5ae9e684facc", "2275fa1837feeec488ff498f874f1f4c" },
            { "1cd3eff6941570c46a0cca0ae963bd8c", "d76ef0f150281d1498cc80a45d9c5358" },
            { "d22b0ac99dbae7e4a9bdca0b613b2464", "2190dbf828f1685419df234767c5e2c4" },
            { "e224c6e9d43e7c745b42078c6191393f", "9edf3bad854dd7f4f8a527bc600d6588" },
            { "13b2ccd4f6364f84ba5e8fa8fd1698cc", "894debc09c05bd643a49369e54629c0e" },
            { "e3221c2c550562449b5c42addb301b40", "59d2f25a89a34f34fa23f851d7c5d830" },
            { "b36109bcda611f9498611a60783d4d83", "f3c2bbeecfe6dd246ba0597b41c5d4c4" },
            { "fc636102982bd9548b08929996e8c67e", "f3ebe765fc449c345849abaeb6ab89f7" },
            { "5664541c8a9b2bc489c9fa4f3d3e81f8", "d6893d669363e58488ed3c131379a0d2" },
            { "029f9b562195c5a488f0744e956fca59", "003f099eedad1cc489451a03850c2c12" },
            { "f29b375ac6ad8e84f9a5095e5857e957", "1b03fffd06279344f92579165d1a821c" },
            { "650f7b5fdb04efe42ac612d9fd0d03cb", "0caac922b36d9e74e8435b8316baf498" },
            { "7de358116a341004b94136337d239d1b", "5f69cf125658cc046a729a5a5b4b9a11" },
            { "10f0534e8e8748a409849338afe43251", "307b9906231b0784884d4b52416215a8" },
            { "2758518bdcab40a3abd3807018be68ca", "e67e822f851164b40b6b701128914625" }
        };
        
        // name -> old GUID
        private static Dictionary<string, string> _nameMap = new Dictionary<string, string>
        {
            { "orels1/Standard", "02b44cf07259bda4592d27f11536b39d" },
            { "orels1/Standard AudioLink", "590a035cb264dbe428f749e03be09bf4" },
            { "orels1/Standard Color Randomisation", "915eaab166e9b964abd9a9486eef9dac" },
            { "orels1/Standard Cutout", "2275fa1837feeec488ff498f874f1f4c" },
            { "orels1/Standard Glass", "d76ef0f150281d1498cc80a45d9c5358" },
            { "orels1/Standard Layered Material Triplanar Effects", "2190dbf828f1685419df234767c5e2c4" },
            { "orels1/Standard Layered Material", "9edf3bad854dd7f4f8a527bc600d6588" },
            { "orels1/Standard Layered Parallax", "894debc09c05bd643a49369e54629c0e" },
            { "orels1/Standard LTCGI", "59d2f25a89a34f34fa23f851d7c5d830" },
            { "orels1/Standard Neon Light", "f3c2bbeecfe6dd246ba0597b41c5d4c4" },
            { "orels1/Standard Triplanar Effects", "f3ebe765fc449c345849abaeb6ab89f7" },
            { "orels1/Standard Vertex Animation", "d6893d669363e58488ed3c131379a0d2" },
            { "orels1/Standard Vertical Fog", "003f099eedad1cc489451a03850c2c12" },
            { "orels1/Toon/Main", "1b03fffd06279344f92579165d1a821c" },
            { "orels1/VFX/Block Fader", "0caac922b36d9e74e8435b8316baf498" },
            { "orels1/VFX/Clouds", "5f69cf125658cc046a729a5a5b4b9a11" },
            { "orels1/VFX/Cubemap Screen", "307b9906231b0784884d4b52416215a8" },
            { "orels1/Standard Tesselated Displacement", "e67e822f851164b40b6b701128914625" }
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
                using (new GUILayout.HorizontalScope())
                {
                    if (_tabIndex == 0)
                    {
                        GUI.backgroundColor = new Color(0.8f, 0.8f, 0.8f);
                    }
                    if (GUILayout.Button("Migrate to Latest", EditorStyles.miniButtonLeft))
                    {
                        if (_tabIndex != 0)
                        {
                            _affectedMaterials = new List<string>();
                            _affectedMatsScrollPos = Vector2.zero;
                        }
                        _tabIndex = 0;
                    }
                    GUI.backgroundColor = Color.white;
                    if (_tabIndex == 1)
                    {
                        GUI.backgroundColor = new Color(0.8f, 0.8f, 0.8f);
                    }
                    if (GUILayout.Button("Revert", EditorStyles.miniButtonRight))
                    {
                        if (_tabIndex != 1)
                        {
                            _affectedMaterials = new List<string>();
                            _affectedMatsScrollPos = Vector2.zero;
                        }
                        _tabIndex = 1;
                    }
                    GUI.backgroundColor = Color.white;
                }
                EditorGUILayout.Space(5);
                switch (_tabIndex) {
                    case 0:
                        MigrateTab();
                        break;
                    case 1:
                        RevertTab();
                        break;
                }
            }
        }

        private void MigrateTab()
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
        
        private List<string> FindAffectedMaterials(bool revert = false)
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
                
                if (_nameMap.ContainsKey(material.shader.name))
                {
                    affectedMaterials.Add(path);
                    i++;
                    continue;
                }
                var matYamlSource = File.ReadAllLines(Application.dataPath.Replace("\\", "/").Replace("Assets", "") + path);
                var shaderLines = matYamlSource.Where(line => line.Trim().StartsWith("m_Shader:")).ToList();
                if (shaderLines.Count == 0)
                {
                    i++;
                    continue;
                }
                var guidLine = shaderLines.First();
                if (!guidLine.Contains("guid: "))
                {
                    i++;
                    continue;
                }
                var shaderGuid = guidLine.Substring(guidLine.IndexOf("guid: ", StringComparison.InvariantCulture) + 6);
                if (!shaderGuid.Contains(","))
                {
                    i++;
                    continue;
                }
                shaderGuid = shaderGuid.Substring(0, shaderGuid.IndexOf(",", StringComparison.InvariantCulture));

                if (!(revert ? _revertableShaders : _migrateableShaders).Contains(shaderGuid))
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

        private void Migrate(bool revert = false)
        {
            EditorUtility.DisplayProgressBar(revert ? "Reverting Materials..." : "Migrating Materials", "Please wait...", 0);
            var group = Undo.GetCurrentGroup();
            var i = 0f;
            var dfgTex = AssetDatabase.LoadAssetAtPath<Texture2D>("Packages/sh.orels.shaders.generator/Runtime/Assets/dfg-multiscatter.exr");
            if (revert)
            {
                // try to load v4 dfg texture
                dfgTex = AssetDatabase.LoadAssetAtPath<Texture2D>("Assets/Shaders/orels1/ORL/dfg-multiscatter.exr");
                // attempt to load v5 dfg
                if (dfgTex == null)
                {
                    dfgTex = AssetDatabase.LoadAssetAtPath<Texture2D>("Assets/Shaders/orels1/Sources/Assets/Textures/dfg-multiscatter.exr");
                }
            }

            var migratedCount = 0;
            var missedCount = 0;
            var invalidCount = 0;
            try
            {
                foreach (var path in _affectedMaterials)
                {
                    var mat = AssetDatabase.LoadAssetAtPath<Material>(path);
                    var matYamlSource =
                        File.ReadAllLines(Application.dataPath.Replace("\\", "/").Replace("Assets", "") + path);
                    var shaderLines = matYamlSource.Where(line => line.Trim().StartsWith("m_Shader")).ToList();
                    if (shaderLines.Count == 0)
                    {
                        EditorUtility.DisplayProgressBar("Migrating Materials", $"Skipping {path}..",
                            i / _affectedMaterials.Count);
                        i++;
                        invalidCount++;
                        continue;
                    }

                    EditorUtility.DisplayProgressBar("Migrating Materials", $"Migrating {path}...",
                        i / _affectedMaterials.Count);
                    var shaderGuid = "";
                    if (_nameMap.ContainsKey(mat.shader.name))
                    {
                        if (revert)
                        {
                            shaderGuid = _migrationMap[_nameMap[mat.shader.name]];
                        }
                        else
                        {
                            shaderGuid = _nameMap[mat.shader.name];
                        }
                    }
                    else
                    {
                        var guidLine = shaderLines.First();
                        if (!guidLine.Contains("guid: "))
                        {
                            EditorUtility.DisplayProgressBar("Migrating Materials", $"Skipping {path}..",
                                i / _affectedMaterials.Count);
                            i++;
                            invalidCount++;
                            continue;
                        }
                        shaderGuid = guidLine.Substring(guidLine.IndexOf("guid: ", StringComparison.InvariantCulture) + 6);
                        if (!shaderGuid.Contains(","))
                        {
                            EditorUtility.DisplayProgressBar("Migrating Materials", $"Skipping {path}..",
                                i / _affectedMaterials.Count);
                            i++;
                            invalidCount++;
                            continue;
                        }
                        shaderGuid = shaderGuid.Substring(0, shaderGuid.IndexOf(",", StringComparison.InvariantCulture));
                    }
                    var newGuid = revert ? _revertMap[shaderGuid] : _migrationMap[shaderGuid];
                    var shaderPath = AssetDatabase.GUIDToAssetPath(newGuid);
                    var shader = AssetDatabase.LoadAssetAtPath<Shader>(shaderPath);
                    if (shader == null)
                    {
                        Debug.LogWarning($"Could not find a revert shader for {shaderGuid}. Was attempting to find {newGuid}");
                        i++;
                        missedCount++;
                        continue;
                    }
                    if (!_dryRun)
                    {
                        Undo.RecordObject(mat, "Migrated Material");
                        mat.shader = shader;
                        if (mat.GetTexturePropertyNames().Contains("_DFG") && dfgTex != null)
                        {
                            mat.SetTexture("_DFG", dfgTex);
                        }
                    }
                    else
                    {
                        Debug.Log("DRY RUN. Would have migrated " + path + " from " + shaderGuid + " to " +
                                  shader.name);
                    }

                    migratedCount++;
                    i++;
                }
            }
            finally
            {
                Undo.CollapseUndoOperations(group);
                EditorUtility.ClearProgressBar();
                if (_dryRun)
                {
                    Debug.Log($"DRY RUN. Migration finished. Would have migrated {migratedCount} / {_affectedMaterials.Count} materials. Could not find shaders for {missedCount} / {_affectedMaterials.Count} materials. Invalid materials {invalidCount} / {_affectedMaterials.Count}.");
                }
                else
                {
                    Debug.Log($"Migration finished. Migrated {migratedCount} / {_affectedMaterials.Count} materials. Could not find shaders for {missedCount} / {_affectedMaterials.Count} materials. Invalid materials {invalidCount} / {_affectedMaterials.Count}.");
                }
            }
        }

        private void RevertTab()
        {
            EditorGUIUtility.fieldWidth = 64;

            if (GUILayout.Button("Find Materials using ORL Shaders", GUILayout.Height(30)))
            {
                _affectedMaterials = FindAffectedMaterials(true);
            }
            EditorGUILayout.HelpBox(new GUIContent("Clicking this button will look through your assets to find materials that can be reverted"));

            if (_affectedMaterials.Count > 0)
            {
                EditorGUILayout.Space(10);
                EditorGUILayout.LabelField("The following materials will be reverted to the old shaders", EditorStyles.boldLabel);
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

                GUI.backgroundColor = new Color(234.0f / 255.0f, 231.0f / 255.0f, 32.0f / 255.0f);
                if (GUILayout.Button("Revert Now", GUILayout.Height(30)))
                {
                    Migrate(true);
                }
                GUI.backgroundColor = Color.white;

                _dryRun = EditorGUILayout.Toggle("Dry run", _dryRun);
                EditorGUILayout.HelpBox(new GUIContent("Dry run will not save any changes to your assets, it will print what the migration would do into the log instead"));
            }
        }
    }
}