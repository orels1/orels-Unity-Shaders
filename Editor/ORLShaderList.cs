using System.Collections.Generic;
using ORL.OdinSerializer;
using UnityEditor;
using UnityEngine;

namespace ORL
{
    [CreateAssetMenu(fileName = "ORLShaderList", menuName = "Shader/Internal/ORL Shader List", order = 10)]
    public class ORLShaderList : SerializedScriptableObject
    {
        // source path : export path
        public Dictionary<string, string> shadersList = new Dictionary<string, string>();
    }

    [CustomEditor(typeof(ORLShaderList))]
    public class ORLShaderListEditor : Editor
    {
        public override void OnInspectorGUI()
        {
            base.OnInspectorGUI();
            var t = (ORLShaderList) target;
            EditorGUILayout.Space();
            if (GUILayout.Button("Clear the List"))
            {
                t.shadersList = new Dictionary<string, string>();
                EditorUtility.SetDirty(t);
                AssetDatabase.SaveAssets();
                AssetDatabase.Refresh();
                return;
            }
            EditorGUILayout.Space();
            EditorGUILayout.LabelField("Saved shaders for auto-refresh");
            if (t.shadersList == null)
            {
                t.shadersList = new Dictionary<string, string>();
                EditorUtility.SetDirty(t);
                AssetDatabase.SaveAssets();
                AssetDatabase.Refresh();
                return;
            }
            foreach (var shader in t.shadersList)
            {
                EditorGUILayout.BeginVertical(EditorStyles.helpBox);
                EditorGUILayout.LabelField(shader.Key, EditorStyles.largeLabel);
                EditorGUILayout.LabelField(shader.Value);
                EditorGUILayout.EndVertical();
            }
        }
    }
}