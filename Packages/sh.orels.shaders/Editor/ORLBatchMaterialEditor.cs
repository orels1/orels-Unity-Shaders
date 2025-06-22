using System.Collections.Generic;
using System.Linq;
using UnityEditor;
using UnityEngine;

namespace ORL.Shaders
{
    public class ORLBatchMaterialEditor : EditorWindow
    {
        private string shaderNameFilter = "";
        private List<Material> materials = new List<Material>();
        private Vector2 materialScrollPos;
        private bool showMaterials = true;

        private Dictionary<string, MaterialProperty> sharedProperties =
            new Dictionary<string, MaterialProperty>();

        private Vector2 propertiesScrollPos;

        private class MaterialProperty
        {
            public string name;
            public string displayName;
            public ShaderUtil.ShaderPropertyType type;
            public object value;
            public bool hasMixedValues;
            public Vector2 rangeMin = Vector2.zero;
            public Vector2 rangeMax = Vector2.one;
            public bool hasRange;
            public string[] attributes;
            public bool isToggle;
            public bool isEnum;
            public string[] enumNames;
            public string keyword;
        }

        [MenuItem("Tools/orels1/Batch Material Editor")]
        public static void ShowWindow()
        {
            GetWindow<ORLBatchMaterialEditor>("Batch Material Editor");
        }

        private void OnGUI()
        {
            EditorGUILayout.LabelField("Batch Material Editor", EditorStyles.boldLabel);
            EditorGUILayout.Space();

            // Shader filter section
            EditorGUILayout.LabelField("Shader Filter", EditorStyles.boldLabel);
            shaderNameFilter = EditorGUILayout.TextField("Shader Path Contains:",
                shaderNameFilter);

            using (new EditorGUILayout.HorizontalScope())
            {
                if (GUILayout.Button("Load Materials"))
                {
                    LoadMaterials();
                }

                if (GUILayout.Button("Refresh Properties"))
                {
                    FindSharedProperties();
                }
            }

            EditorGUILayout.Space();

            // Materials list
            showMaterials = EditorGUILayout.Foldout(showMaterials,
                $"Materials ({materials.Count})");

            if (showMaterials)
            {
                using (var scrollView = new EditorGUILayout.ScrollViewScope(
                           materialScrollPos, GUILayout.Height(150)))
                {
                    materialScrollPos = scrollView.scrollPosition;

                    for (int i = materials.Count - 1; i >= 0; i--)
                    {
                        using (new EditorGUILayout.HorizontalScope())
                        {
                            materials[i] = (Material)EditorGUILayout.ObjectField(
                                materials[i], typeof(Material), false);

                            if (GUILayout.Button("Remove", GUILayout.Width(60)))
                            {
                                materials.RemoveAt(i);
                                FindSharedProperties();
                            }
                        }
                    }

                    if (GUILayout.Button("Add Material"))
                    {
                        materials.Add(null);
                    }
                }
            }

            EditorGUILayout.Space();

            // Shared properties section
            if (sharedProperties.Count > 0)
            {
                EditorGUILayout.LabelField("Shared Properties", EditorStyles.boldLabel);

                using (var scrollView = new EditorGUILayout.ScrollViewScope(
                           propertiesScrollPos))
                {
                    propertiesScrollPos = scrollView.scrollPosition;

                    foreach (var kvp in sharedProperties.ToList())
                    {
                        var prop = kvp.Value;

                        using (new EditorGUILayout.HorizontalScope())
                        {
                            EditorGUILayout.LabelField(prop.displayName, GUILayout.Width(180));

                            using (var changeCheck = new EditorGUI.ChangeCheckScope())
                            {
                                object newValue = DrawPropertyField(prop);

                                if (changeCheck.changed)
                                {
                                    prop.value = newValue;
                                    prop.hasMixedValues = false;
                                    ApplyPropertyToMaterials(prop, newValue);
                                }
                            }
                        }
                    }
                }
            }
        }

        private void LoadMaterials()
        {
            materials.Clear();

            if (string.IsNullOrEmpty(shaderNameFilter))
                return;

            string[] materialGuids = AssetDatabase.FindAssets("t:Material");

            foreach (string guid in materialGuids)
            {
                string path = AssetDatabase.GUIDToAssetPath(guid);
                Material mat = AssetDatabase.LoadAssetAtPath<Material>(path);

                if (mat != null && mat.shader != null)
                {
                    string shaderPath = AssetDatabase.GetAssetPath(mat.shader);

                    if (!string.IsNullOrEmpty(shaderPath) &&
                        shaderPath.Contains(shaderNameFilter))
                    {
                        materials.Add(mat);
                    }
                }
            }

            FindSharedProperties();
        }

        private void FindSharedProperties()
        {
            sharedProperties.Clear();

            if (materials.Count == 0 || materials.Any(m => m == null))
                return;

            // Get properties from first material
            var firstMaterial = materials[0];
            var shader = firstMaterial.shader;

            for (int i = 0; i < ShaderUtil.GetPropertyCount(shader); i++)
            {
                string propName = ShaderUtil.GetPropertyName(shader, i);
                var propType = ShaderUtil.GetPropertyType(shader, i);

                // Check if all materials have this property
                bool allHaveProperty = materials.All(mat =>
                    mat.HasProperty(propName));

                if (allHaveProperty)
                {
                    var matProp = new MaterialProperty
                    {
                        name = propName,
                        displayName = ShaderUtil.GetPropertyDescription(shader, i),
                        type = propType,
                        attributes = shader.GetPropertyAttributes(i)
                    };

                    // Parse attributes
                    ParsePropertyAttributes(matProp, shader, i);

                    // Get range info for float properties
                    if (propType == ShaderUtil.ShaderPropertyType.Range)
                    {
                        matProp.hasRange = true;
                        matProp.rangeMin = new Vector2(
                            ShaderUtil.GetRangeLimits(shader, i, 1), 0);
                        matProp.rangeMax = new Vector2(
                            ShaderUtil.GetRangeLimits(shader, i, 2), 0);
                    }

                    // Check for mixed values and set initial value
                    CheckForMixedValues(matProp);

                    sharedProperties[propName] = matProp;
                }
            }
        }

        private void CheckForMixedValues(MaterialProperty prop)
        {
            var values = new List<object>();

            foreach (var mat in materials)
            {
                if (mat == null) continue;
                values.Add(GetPropertyValue(mat, prop.name, prop.type));
            }

            if (values.Count == 0) return;

            // Check if all values are the same
            var firstValue = values[0];
            bool allSame = true;

            for (int i = 1; i < values.Count; i++)
            {
                if (!ValuesEqual(firstValue, values[i]))
                {
                    allSame = false;
                    break;
                }
            }

            prop.hasMixedValues = !allSame;
            prop.value = firstValue; // Use first value as default
        }

        private bool ValuesEqual(object a, object b)
        {
            if (a == null && b == null) return true;
            if (a == null || b == null) return false;

            // Special handling for floats to account for floating point precision
            if (a is float fa && b is float fb)
                return Mathf.Approximately(fa, fb);

            return a.Equals(b);
        }

        private void ParsePropertyAttributes(MaterialProperty prop, Shader shader, int propIndex)
        {
            if (prop.attributes == null) return;

            foreach (string attr in prop.attributes)
            {
                if (attr.StartsWith("Toggle"))
                {
                    prop.isToggle = true;
                    // Extract keyword from Toggle attribute
                    if (attr.Contains("(") && attr.Contains(")"))
                    {
                        int start = attr.IndexOf("(") + 1;
                        int end = attr.IndexOf(")");
                        prop.keyword = attr.Substring(start, end - start).Trim();
                    }
                    else
                    {
                        // Default keyword is property name in uppercase
                        prop.keyword = prop.name.ToUpper();
                    }
                }
                else if (attr.StartsWith("Enum") || attr.StartsWith("KeywordEnum"))
                {
                    prop.isEnum = true;
                    ParseEnumAttribute(prop, attr);
                }
            }
        }

        private void ParseEnumAttribute(MaterialProperty prop, string attr)
        {
            // Parse enum values from attribute like "Enum(Off,0,On,1)" or "KeywordEnum(A,B,C)"
            if (attr.Contains("(") && attr.Contains(")"))
            {
                int start = attr.IndexOf("(") + 1;
                int end = attr.IndexOf(")");
                string enumContent = attr.Substring(start, end - start);

                if (attr.StartsWith("KeywordEnum"))
                {
                    // KeywordEnum just has names
                    prop.enumNames = enumContent.Split(',').Select(s => s.Trim()).ToArray();
                }
                else
                {
                    // Regular Enum has name,value pairs
                    string[] parts = enumContent.Split(',');
                    var names = new List<string>();
                    for (int i = 0; i < parts.Length; i += 2)
                    {
                        if (i < parts.Length)
                            names.Add(parts[i].Trim());
                    }

                    prop.enumNames = names.ToArray();
                }
            }
        }

        private object GetPropertyValue(Material mat, string propName,
            ShaderUtil.ShaderPropertyType type)
        {
            switch (type)
            {
                case ShaderUtil.ShaderPropertyType.Float:
                case ShaderUtil.ShaderPropertyType.Range:
                    return mat.GetFloat(propName);
                case ShaderUtil.ShaderPropertyType.Vector:
                    return mat.GetVector(propName);
                case ShaderUtil.ShaderPropertyType.Color:
                    return mat.GetColor(propName);
                case ShaderUtil.ShaderPropertyType.TexEnv:
                    return mat.GetTexture(propName);
                default:
                    return null;
            }
        }

        private object DrawPropertyField(MaterialProperty prop)
        {
            // Handle mixed values display
            bool showMixedValue = prop.hasMixedValues;
            EditorGUI.showMixedValue = showMixedValue;

            object result = prop.value;

            try
            {
                if (prop.isToggle && (prop.type == ShaderUtil.ShaderPropertyType.Float ||
                                      prop.type == ShaderUtil.ShaderPropertyType.Range))
                {
                    bool toggleValue = showMixedValue ? false : Mathf.Approximately((float)prop.value, 1.0f);
                    bool newToggle = EditorGUILayout.Toggle(toggleValue);
                    result = newToggle ? 1.0f : 0.0f;
                }
                else if (prop.isEnum && prop.enumNames != null &&
                         (prop.type == ShaderUtil.ShaderPropertyType.Float ||
                          prop.type == ShaderUtil.ShaderPropertyType.Range))
                {
                    int currentIndex = showMixedValue ? 0 : Mathf.RoundToInt((float)prop.value);
                    currentIndex = Mathf.Clamp(currentIndex, 0, prop.enumNames.Length - 1);
                    int newIndex = EditorGUILayout.Popup(currentIndex, prop.enumNames);
                    result = (float)newIndex;
                }
                else
                {
                    switch (prop.type)
                    {
                        case ShaderUtil.ShaderPropertyType.Float:
                            float floatVal = showMixedValue ? 0f : (float)prop.value;
                            result = EditorGUILayout.FloatField(floatVal);
                            break;

                        case ShaderUtil.ShaderPropertyType.Range:
                            float rangeVal = showMixedValue ? prop.rangeMin.x : (float)prop.value;
                            result = EditorGUILayout.Slider(rangeVal, prop.rangeMin.x, prop.rangeMax.x);
                            break;

                        case ShaderUtil.ShaderPropertyType.Vector:
                            Vector4 vecVal = showMixedValue ? Vector4.zero : (Vector4)prop.value;
                            result = EditorGUILayout.Vector4Field("", vecVal);
                            break;

                        case ShaderUtil.ShaderPropertyType.Color:
                            Color colorVal = showMixedValue ? Color.white : (Color)prop.value;
                            result = EditorGUILayout.ColorField(colorVal);
                            break;

                        case ShaderUtil.ShaderPropertyType.TexEnv:
                            Texture texVal = showMixedValue ? null : (Texture)prop.value;
                            result = EditorGUILayout.ObjectField(texVal, typeof(Texture), false);
                            break;

                        default:
                            EditorGUILayout.LabelField("Unsupported type");
                            break;
                    }
                }
            }
            finally
            {
                EditorGUI.showMixedValue = false;
            }

            return result;
        }

        private void ApplyPropertyToMaterials(MaterialProperty prop, object value)
        {
            Undo.SetCurrentGroupName($"Batch Edit {prop.displayName}");
            int undoGroup = Undo.GetCurrentGroup();

            foreach (var mat in materials)
            {
                if (mat == null) continue;

                Undo.RecordObject(mat, $"Batch Edit {prop.displayName}");

                // Set the property value
                switch (prop.type)
                {
                    case ShaderUtil.ShaderPropertyType.Float:
                    case ShaderUtil.ShaderPropertyType.Range:
                        mat.SetFloat(prop.name, (float)value);
                        break;
                    case ShaderUtil.ShaderPropertyType.Vector:
                        mat.SetVector(prop.name, (Vector4)value);
                        break;
                    case ShaderUtil.ShaderPropertyType.Color:
                        mat.SetColor(prop.name, (Color)value);
                        break;
                    case ShaderUtil.ShaderPropertyType.TexEnv:
                        mat.SetTexture(prop.name, (Texture)value);
                        break;
                }

                // Handle keywords for toggles and enums
                if (prop.isToggle && !string.IsNullOrEmpty(prop.keyword))
                {
                    bool isEnabled = Mathf.Approximately((float)value, 1.0f);
                    if (isEnabled)
                        mat.EnableKeyword(prop.keyword);
                    else
                        mat.DisableKeyword(prop.keyword);
                }
                else if (prop.isEnum && prop.enumNames != null)
                {
                    // For KeywordEnum, disable all keywords and enable the selected one
                    int selectedIndex = Mathf.RoundToInt((float)value);
                    for (int i = 0; i < prop.enumNames.Length; i++)
                    {
                        string keyword = $"{prop.name.ToUpper()}_{prop.enumNames[i].ToUpper()}";
                        if (i == selectedIndex)
                            mat.EnableKeyword(keyword);
                        else
                            mat.DisableKeyword(keyword);
                    }
                }

                EditorUtility.SetDirty(mat);
            }

            Undo.CollapseUndoOperations(undoGroup);
        }
    }
}