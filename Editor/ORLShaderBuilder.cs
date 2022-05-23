using System.Collections.Generic;
using System.IO;
using UnityEditor;
using UnityEngine;

namespace ORL
{
    [CreateAssetMenu(fileName = "ORLShadersBuilder", menuName = "Shader/Internal/ORL Builder", order = 10)]
    public class ORLShaderBuilder : ScriptableObject
    {
        public string exportPath;
        public List<string> included;
        public string packageName;
    }

    [CustomEditor(typeof(ORLShaderBuilder))]
    public class ORLShaderBuilderEditor : Editor
    {
        public override void OnInspectorGUI()
        {
            base.OnInspectorGUI();
            var t = (ORLShaderBuilder) target;
            if (GUILayout.Button("Export"))
            {
                if (string.IsNullOrEmpty(t.exportPath))
                {
                    Debug.LogWarning("Export path must be filled");
                    return;
                }
                var createPath = $"Assets/../{t.packageName}.unitypackage";
                var exportPath = t.exportPath + t.packageName + ".unitypackage";
                if (File.Exists(createPath)) {
                    File.Delete(createPath);
                }
                AssetDatabase.ExportPackage(t.included.ToArray(), t.packageName + ".unitypackage", ExportPackageOptions.Recurse);
                if (File.Exists(exportPath)) {
                    File.Delete(exportPath);
                }
                File.Move(createPath, exportPath);
                AssetDatabase.Refresh();
            }
        }
    }
}