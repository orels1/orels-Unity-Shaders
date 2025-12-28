
using UnityEditor;
using UnityEngine;
#if UNITY_2022_3_OR_NEWER
using UnityEditor.AssetImporters;
#else
using UnityEditor.Experimental.AssetImporters;
#endif

namespace ORL.ShaderInspector
{
    [CustomEditor(typeof(LocalizationImporter))]
    public class LocalizationImporterEditor: ScriptedImporterEditor
    {
        private Vector2 _scrollPos;
        
        public override void OnInspectorGUI()
        {
            serializedObject.Update();
            
            var t = (LocalizationImporter)target;
            
            var assets = AssetDatabase.LoadAllAssetsAtPath(t.assetPath);
            
            LocalizationData data = null;
            
            foreach (var asset in assets)
            {
                if (asset is LocalizationData dataAsset)
                {
                    data =  dataAsset;
                }
            }

            if (data != null)
            {
                using (var scroll = new EditorGUILayout.ScrollViewScope(_scrollPos))
                {
                    _scrollPos = scroll.scrollPosition;
                    
                    foreach (var entry in data.data)
                    {
                        using (new EditorGUILayout.VerticalScope())
                        {
                            EditorGUILayout.LabelField(entry.propName, EditorStyles.boldLabel);
                            using (new EditorGUILayout.HorizontalScope())
                            {
                                foreach (var lang in entry.data)
                                {
                                    EditorGUILayout.TextField(lang.name);
                                }
                            }
                            EditorGUILayout.LabelField("Tooltip", EditorStyles.miniLabel);
                            using (new EditorGUILayout.HorizontalScope())
                            {
                                foreach (var lang in entry.data)
                                {
                                    EditorGUILayout.TextField(lang.tooltip);
                                }
                            }
                            EditorGUILayout.Space();
                        }
                    }
                }
            }
            
            serializedObject.ApplyModifiedProperties();
            ApplyRevertGUI();
        }
    }
}