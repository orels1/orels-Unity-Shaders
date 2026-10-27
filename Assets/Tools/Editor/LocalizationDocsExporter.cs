using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using UnityEditor;
using UnityEngine;
using ORL.ShaderInspector;

namespace ORL.Tools
{
    /// <summary>
    /// Exports all available localization data into per-module markdown files,
    /// in the "<display name>: <tooltip>" format, ready for ingestion into the docs site
    /// </summary>
    public class LocalizationDocsExporter : EditorWindow
    {
        private const string DefaultOutputFolder = "Assets/Localization Docs";
        private const string OutputFolderPref = "ORL.Tools.LocalizationDocs.OutputFolder";
        private const string LanguagePref = "ORL.Tools.LocalizationDocs.Language";

        [MenuItem("Tools/orels1/Export Localization Docs")]
        public static void ShowWindow()
        {
            var window = GetWindow<LocalizationDocsExporter>(true);
            window.titleContent = new GUIContent("ORL Localization Docs Exporter");
            window.minSize = new Vector2(350, 200);
            window.Show();
        }

        private string _outputFolder;
        private Vector2 _scrollPos;

        private void OnEnable()
        {
            _outputFolder = EditorPrefs.GetString(OutputFolderPref, DefaultOutputFolder);
        }

        private void OnGUI()
        {
            EditorGUILayout.HelpBox(
                "Exports every available localization file into a markdown document per module\n" +
                "Each property is listed as \"<display name>: <tooltip>\", using the selected language",
                MessageType.Info);

            using var folderCheck = new EditorGUI.ChangeCheckScope();
            _outputFolder = EditorGUILayout.TextField("Output Folder", _outputFolder);
            if (folderCheck.changed)
            {
                EditorPrefs.SetString(OutputFolderPref, _outputFolder);
            }

            var languages = LocalizationCache.GetAvailableLanguages();
            if (languages.Count == 0)
            {
                EditorGUILayout.HelpBox("No localization files (.orlloc) found in the project.", MessageType.Warning);
                return;
            }

            var saved = EditorPrefs.GetString(LanguagePref, "EN");
            var languageIndex = languages.FindIndex(l => string.Equals(l, saved, StringComparison.OrdinalIgnoreCase));
            if (languageIndex < 0)
            {
                languageIndex = 0;
            }

            var displayNames = languages.Select(LocalizationCache.GetLanguageDisplayName).ToArray();
            languageIndex = EditorGUILayout.Popup("Language", languageIndex, displayNames);
            EditorPrefs.SetString(LanguagePref, languages[languageIndex]);

            var modules = LocalizationCache.GetAllModules();
            EditorGUILayout.LabelField($"Will export {modules.Count} module(s):", EditorStyles.miniLabel);

            using (var scroll = new EditorGUILayout.ScrollViewScope(_scrollPos, GUILayout.Height(120)))
            {
                _scrollPos = scroll.scrollPosition;
                foreach (var module in modules)
                {
                    var source = LocalizationCache.GetModuleSourcePath(module);
                    EditorGUILayout.LabelField(
                        module,
                        source ?? "no source file found", EditorStyles.miniLabel);
                }
            }

            EditorGUILayout.Space();
            using (new EditorGUI.DisabledScope(string.IsNullOrWhiteSpace(_outputFolder)))
            {
                if (GUILayout.Button("Export"))
                {
                    Export(languages[languageIndex], modules);
                }
            }
        }

        private void Export(string language, List<string> modules)
        {
            try
            {
                Directory.CreateDirectory(_outputFolder);
            }
            catch (Exception ex)
            {
                EditorUtility.DisplayDialog("ORL Localization Docs Exporter",
                    $"Failed to create the output folder:\n{ex.Message}", "OK");
                return;
            }

            var exported = new List<string>();
            foreach (var module in modules)
            {
                var asset = LocalizationCache.GetModuleLocalization(module);
                if (asset == null) continue;

                var displayNames = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);
                foreach (var pair in LocalizationCache.GetModuleProperties(module))
                {
                    displayNames[pair.Key] = pair.Value;
                }

                var sb = new StringBuilder();
                sb.AppendLine($"# {module}");
                sb.AppendLine();
                foreach (var entry in asset.data)
                {
                    var langData = FindLocalized(entry, language);
                    var name = !string.IsNullOrWhiteSpace(langData.name)
                        ? langData.name.Trim()
                        : displayNames.TryGetValue(entry.propName, out var displayName) && !string.IsNullOrWhiteSpace(displayName)
                            ? displayName
                            : entry.propName;
                    var tooltip = langData.tooltip == null ? null : langData.tooltip.Trim();
                    sb.AppendLine(string.IsNullOrWhiteSpace(tooltip) ? $"- {name}" : $"- {name}: {tooltip}");
                }

                var fileName = SanitizeFileName(module) + ".md";
                File.WriteAllText(Path.Combine(_outputFolder, fileName), sb.ToString());
                exported.Add(module);
            }

            if (_outputFolder.StartsWith("Assets", StringComparison.OrdinalIgnoreCase))
            {
                AssetDatabase.Refresh();
            }
            EditorUtility.DisplayDialog("ORL Localization Docs Exporter",
                $"Exported {exported.Count} module doc(s) to {_outputFolder}", "OK");
        }

        private static LocalizationData.LocalizedLanguageData FindLocalized(LocalizationData.LocalizedPropData entry, string language)
        {
            var match = entry.data.Find(d => LocalizationCache.NormalizeLanguage(d.language) == language);
            if (!string.IsNullOrWhiteSpace(match.language)) return match;
            // fall back to english tooltips by default
            return entry.data.Find(d => LocalizationCache.NormalizeLanguage(d.language) == "EN");
        }

        private static string SanitizeFileName(string name)
        {
            var invalid = Path.GetInvalidFileNameChars();
            var sb = new StringBuilder();
            foreach (var c in name)
            {
                sb.Append(invalid.Contains(c) ? '_' : c);
            }
            return sb.ToString();
        }
    }
}
