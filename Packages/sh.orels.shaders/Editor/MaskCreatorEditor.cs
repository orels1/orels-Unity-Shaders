using UnityEditor;
using UnityEditor.AssetImporters;

namespace ORL.Shaders.Tools
{
    // [CustomEditor(typeof(MaskCreator))]
    public class MaskCreatorEditor: ScriptedImporterEditor
    {
        private SerializedProperty _typeProp;
        private SerializedProperty _gridDataProp;
        private SerializedProperty _gridWidthProp;
        private SerializedProperty _gridHeightProp;
        private SerializedProperty _gridValuesProp;

        public override void OnEnable()
        {
            // serializedObject.Update();
            // _typeProp = serializedObject.FindProperty("maskType");
            // _gridDataProp = serializedObject.FindProperty("gridData");
            // _gridWidthProp = _gridDataProp.FindPropertyRelative("width");
            // _gridHeightProp = _gridDataProp.FindPropertyRelative("height");
            // _gridValuesProp = _gridDataProp.FindPropertyRelative("values");
        }

        public override void OnInspectorGUI()
        {
            // serializedObject.Update();
            // _typeProp = serializedObject.FindProperty("maskType");
            // _gridDataProp = serializedObject.FindProperty("gridData");
            // _gridWidthProp = _gridDataProp.FindPropertyRelative("width");
            // _gridHeightProp = _gridDataProp.FindPropertyRelative("height");
            // _gridValuesProp = _gridDataProp.FindPropertyRelative("values");
            // EditorGUILayout.PropertyField(_typeProp);
            // serializedObject.ApplyModifiedProperties();
            // ApplyRevertGUI();
            base.OnInspectorGUI();
        }
    }
}