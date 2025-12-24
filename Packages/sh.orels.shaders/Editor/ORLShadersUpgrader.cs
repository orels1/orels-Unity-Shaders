using UnityEngine;
using UnityEditor;
using ORL.Shaders.UpgradePlans;
using System.Collections.Generic;
using System;
using System.Linq;
using System.IO;

namespace ORL.Shaders
{
    public class ORLShadersUpgrader : EditorWindow
    {
        [MenuItem("Tools/orels1/Upgrade Materials")]
        private static void ShowWindow()
        {
            var window = GetWindow<ORLShadersUpgrader>(true);
            window.titleContent = new GUIContent("ORL Material Upgrader");
            window.Show();
        }

        private UpgradePlanBase _selectedUpgradePlan;
        private int _selectedUpgradePlanIndex;
        private List<UpgradePlanBase> _upgradePlans = new List<UpgradePlanBase>();
        private List<Shader> _shaders = new List<Shader>();
        private List<Material> _affectedMaterials = new List<Material>();
        private List<string> _includedFolders = new List<string>();
        private List<string> _excludedFolders = new List<string>();
        private bool _dryRun;

        private List<UpgradePlanBase> FindUpgradePlans()
        {
            var upgradePlans = new List<UpgradePlanBase>();
            foreach (var type in System.Reflection.Assembly.GetExecutingAssembly().GetTypes())
            {
                if (type.IsSubclassOf(typeof(UpgradePlanBase)))
                {
                    var upgradePlan = (UpgradePlanBase)Activator.CreateInstance(type);
                    upgradePlans.Add(upgradePlan);
                }
            }

            return upgradePlans;
        }

        private List<Shader> FindShaders()
        {
            var shaders = new List<Shader>();
            var results = AssetDatabase.FindAssets("t:Shader", new string[] { "Assets", "Packages" });
            foreach (var guid in results)
            {
                var path = AssetDatabase.GUIDToAssetPath(guid);
                if (path.EndsWith(".orlshader") || path.EndsWith(".orlconfshader"))
                {
                    var shader = AssetDatabase.LoadAssetAtPath<Shader>(path);
                    if (shader != null)
                    {
                        shaders.Add(shader);
                    }
                }
            }
            return shaders;
        }

        private List<Material> FindMaterials()
        {
            var affectedMaterials = new List<Material>();
            EditorUtility.DisplayProgressBar("Looking up Materials", "Please wait...", 0);
            var guids = new string[0];
            if (_includedFolders.Count > 0)
            {
                guids = AssetDatabase.FindAssets("t:Material", _includedFolders.ToArray());
            }
            else
            {
                guids = AssetDatabase.FindAssets("t:Material");
            }
            var i = 0f;
            foreach (var guid in guids)
            {
                var path = AssetDatabase.GUIDToAssetPath(guid);
                if (_excludedFolders.Any(p => path.StartsWith(p))) continue;
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

                if (_shaders.Contains(material.shader))
                {
                    affectedMaterials.Add(material);
                    i++;
                    continue;
                }
                i++;
            }
            EditorUtility.ClearProgressBar();
            Debug.Log("Found " + affectedMaterials.Count + " materials");

            return affectedMaterials;
        }

        private string PickPath(string startingPath = "")
        {
            var newPath = EditorUtility.OpenFolderPanel("Select Folder", startingPath, "");
            if (string.IsNullOrWhiteSpace(newPath)) return null;
            var projectRoot = Application.dataPath.Replace("\\", "/").Replace("Assets", "");
            return newPath.Replace(projectRoot, "");
        }

        private Vector2 _materialsScrollPos;
        private Vector2 _shadersScrollPos;
        private Vector2 _includedFoldersScrollPos;
        private Vector2 _excludedFoldersScrollPos;
        private bool _showSelectedShaders;
        private bool _showIncludedFolders;
        private bool _showExcludedFolders;

        private void OnGUI()
        {
            if (_upgradePlans.Count == 0)
            {
                _upgradePlans = FindUpgradePlans();
                if (_upgradePlans.Count > 0)
                {
                    _selectedUpgradePlan = _upgradePlans[0];
                    _selectedUpgradePlanIndex = 0;
                }
            }

            if (_shaders.Count == 0)
            {
                _shaders = FindShaders();
                Debug.Log("Found " + _shaders.Count + " shaders");
            }

            using (var c = new EditorGUI.ChangeCheckScope())
            {
                _selectedUpgradePlanIndex = EditorGUILayout.Popup("Upgrade Plan", _selectedUpgradePlanIndex, _upgradePlans.Select(p => p.OldVersion + " -> " + p.NewVersion).ToArray());
                if (c.changed)
                {
                    _selectedUpgradePlan = _upgradePlans[_selectedUpgradePlanIndex];
                }
            }

            if (_shaders.Count > 0)
            {
                _showSelectedShaders = EditorGUILayout.Foldout(_showSelectedShaders, "Selected Shaders");
                if (_showSelectedShaders)
                {
                    using (new GUILayout.VerticalScope(EditorStyles.helpBox))
                    {
                        using (var scroller = new GUILayout.ScrollViewScope(_shadersScrollPos))
                        {
                            _shadersScrollPos = scroller.scrollPosition;
                            var index = 0;
                            foreach (var shader in _shaders)
                            {
                                using (new GUILayout.HorizontalScope())
                                {
                                    EditorGUILayout.ObjectField(shader, typeof(Shader), false);
                                    if (GUILayout.Button("-", GUILayout.Width(20)))
                                    {
                                        _shaders.Remove(shader);
                                        break;
                                    }
                                }
                                index++;
                            }
                        }
                    }
                    if (GUILayout.Button("Add Shader"))
                    {
                        _shaders.Add(Shader.Find("orels1/Standard"));
                    }
                }
            }

            if (GUILayout.Button("Find Materials using ORL Shaders", GUILayout.Height(30)))
            {
                _affectedMaterials = FindMaterials();
            }

            _showIncludedFolders = EditorGUILayout.Foldout(_showIncludedFolders, "Only Search These Folders");
            if (_showIncludedFolders)
            {
                using (new GUILayout.VerticalScope(EditorStyles.helpBox))
                {
                    using (var scroller = new GUILayout.ScrollViewScope(_includedFoldersScrollPos))
                    {
                        _includedFoldersScrollPos = scroller.scrollPosition;
                        var index = 0;
                        foreach (var folder in _includedFolders)
                        {
                            using (new GUILayout.HorizontalScope())
                            {
                                EditorGUILayout.TextField(folder);
                                if (GUILayout.Button("P", GUILayout.Width(20)))
                                {
                                    var newPath = PickPath(_includedFolders?[index] ?? "");
                                    if (newPath != null)
                                    {
                                        _includedFolders[index] = newPath;
                                    }
                                    break;
                                }
                                if (GUILayout.Button("-", GUILayout.Width(20)))
                                {
                                    _includedFolders.Remove(folder);
                                    break;
                                }
                            }
                            index++;
                        }
                    }
                    if (GUILayout.Button("Add Folder", GUILayout.Height(30)))
                    {
                        var newPath = PickPath();
                        if (newPath != null)
                        {
                            _includedFolders.Add(newPath);
                        }
                    }
                }
            }

            _showExcludedFolders = EditorGUILayout.Foldout(_showExcludedFolders, "Excluded Folders");
            if (_showExcludedFolders)
            {
                using (new GUILayout.VerticalScope(EditorStyles.helpBox))
                {
                    using (var scroller = new GUILayout.ScrollViewScope(_excludedFoldersScrollPos))
                    {
                        _excludedFoldersScrollPos = scroller.scrollPosition;
                        var index = 0;
                        foreach (var folder in _excludedFolders)
                        {
                            using (new GUILayout.HorizontalScope())
                            {
                                EditorGUILayout.TextField(folder);
                                if (GUILayout.Button("-", GUILayout.Width(20)))
                                {
                                    _excludedFolders.Remove(folder);
                                    break;
                                }
                            }
                            index++;
                        }

                        if (GUILayout.Button("Add Folder", GUILayout.Height(30)))
                        {
                            var newPath = PickPath();
                            if (newPath != null)
                            {
                                _excludedFolders.Add(newPath);
                            }
                        }
                    }
                }
            }

            if (_affectedMaterials.Count > 0)
            {
                using (new GUILayout.VerticalScope(EditorStyles.helpBox))
                {
                    using (var scroller = new GUILayout.ScrollViewScope(_materialsScrollPos))
                    {
                        _materialsScrollPos = scroller.scrollPosition;
                        var index = 0;
                        foreach (var mat in _affectedMaterials)
                        {
                            using (new GUILayout.HorizontalScope())
                            {
                                EditorGUILayout.ObjectField(mat, typeof(Material), false);
                                if (GUILayout.Button("-", GUILayout.Width(20)))
                                {
                                    _affectedMaterials.Remove(mat);
                                    break;
                                }
                            }
                            index++;
                        }
                    }
                }
            }

            GUILayout.FlexibleSpace();

            if (_affectedMaterials.Count > 0 && GUILayout.Button("Upgrade Now", GUILayout.Height(30)))
            {
                if (_selectedUpgradePlan == null) return;
                var success = _selectedUpgradePlan.Upgrade(_affectedMaterials, _dryRun);
                if (success && !_dryRun)
                {
                    Debug.Log($"Upgraded materials to {_selectedUpgradePlan.NewVersion}:\n{string.Join("\n", _affectedMaterials.Select(m => " - " + m.name + " (" + AssetDatabase.GetAssetPath(m) + ")"))}");
                    if (!EditorUtility.DisplayDialog("Upgrade Successful", "Upgraded " + _affectedMaterials.Count + " materials to " + _selectedUpgradePlan.NewVersion + "\nCheck logs for a full list of materials.\n\nPress Undo to revert\n\nYou can always undo later by pressing Ctrl+Z", "Ok", "Undo"))
                    {
                        Undo.RevertAllInCurrentGroup();
                        Debug.Log("Reverted all changes");
                    }
                }
                if (!success)
                {
                    EditorUtility.DisplayDialog("Upgrade Failed", "Failed to upgrade " + _affectedMaterials.Count + " materials to " + _selectedUpgradePlan.NewVersion, "Ok");
                }
            }
            _dryRun = EditorGUILayout.Toggle("Dry run", _dryRun);
        }
    }
}