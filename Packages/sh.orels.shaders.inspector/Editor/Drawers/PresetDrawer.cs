using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text.RegularExpressions;
using ORL.ShaderInspector;
using UnityEditor;
using UnityEditor.Presets;

namespace ORL.Drawers
{
    public class PresetDrawer: IDrawerFunc
    {
        public string FunctionName => "Preset";
        
        // Matches %Preset(presetsFolderPath);
        private Regex _matcher = new Regex(@"(?<=[\w\s\>\s]+)\%Preset\((?<presetsFolderPath>[\w\,\s\&\|\(\)\!\<\>\=\$\/\-\.\@]+)\)");
        
        public string[] PersistentKeys { get; }

        public bool OnGUI(MaterialEditor editor, MaterialProperty[] properties, MaterialProperty property, int index,
            ref Dictionary<string, object> uiState, Func<bool> next)
        {
            if (EditorGUI.indentLevel == -1) return true;
            
            var uiKey = $"{property.name}_presetsList";
            
            Dictionary<(string path, string name), Preset> presetsList;
            if (!uiState.TryGetValue(uiKey, out var savedList))
            {
                var newList = new Dictionary<(string path, string name), Preset>();
                
                var presetsFolderPath = _matcher.Match(property.displayName).Groups["presetsFolderPath"].Value;
                presetsFolderPath = presetsFolderPath.Replace("@/", "Packages/sh.orels.shaders/Runtime/");
                var allFiles = Directory.GetFiles(presetsFolderPath, "*.preset", SearchOption.AllDirectories);

                newList.Add((string.Empty, "Custom"), null);
                foreach (var preset in allFiles)
                {
                    var loaded = AssetDatabase.LoadAssetAtPath<Preset>(preset);
                    if (loaded != null)
                    {
                        var cleanPath = preset.Replace(presetsFolderPath, string.Empty)
                            .Substring(1)
                            .Replace(".preset", string.Empty)
                            .Replace('\\', '/');
                        newList.Add((preset, cleanPath), loaded);
                    }
                }

                uiState[uiKey] = newList;
                presetsList = newList;
            }
            else
            {
                presetsList = savedList as Dictionary<(string path, string name), Preset>;
            }

            using (var c = new EditorGUI.ChangeCheckScope())
            {
                var newPreset = EditorGUILayout.Popup(Utils.StripInternalSymbols(property.displayName), (int) property.floatValue, presetsList.Keys.Select(el => el.name).ToArray());
                var selectedPreset = presetsList.ElementAt(newPreset).Value;
                if (!c.changed) return true;
                
                if (newPreset < 1)
                {
                    property.floatValue = 0;
                    return true;
                }

                if (!selectedPreset.CanBeAppliedTo(editor.target)) return true;
                if (EditorUtility.DisplayDialog(
                        "Apply Preset?",
                        "Are you sure you want to apply this preset?\n" +
                        "This will replace all your currently configured values with the ones from a preset",
                        "Yes",
                        "No"
                    ))
                {
                    selectedPreset.ApplyTo(editor.target);
                    property.floatValue = newPreset;
                    return true;
                }
            }
            
            
            
            return true;
        }
    }
}