#if UNITY_2021_3_OR_NEWER
using ORL.Layout;
using UnityEditor;
using UnityEngine;
using UnityEditor.UIElements;
using UnityEngine.UIElements;
using ORL.Layout.Extensions;
using System.Collections.Generic;
using System.Linq;

namespace ORL.Shaders
{
    public class ORLMassPropertySetter : EnhancedEditorWindow
    {

        [MenuItem("Tools/orels1/Adjust Materials Properties")]
        public static void ShowWindow()
        {
            var window = GetWindow<ORLMassPropertySetter>(true);
            window.titleContent = new GUIContent($"ORL Mass Property Setter");
            window.minSize = new Vector2(400, 600);
            window.Show();
        }

        private ReactiveProperty<List<Material>> _foundMaterialsProperty = new ReactiveProperty<List<Material>>(new List<Material>());
        private List<Material> _selectedMaterials = new List<Material>();

        private bool _colorCorrectionEnabled;
        private ReactiveProperty<float> _lift = new(1.0f);
        private ReactiveProperty<float> _gamma = new(1.1f);
        private ReactiveProperty<float> _gain = new(1.4f);

        protected override VisualElement Render()
        {
            return VStack(
                Button("Reload UI", () => ReloadGUI()),
                Label("This tool allows you to quickly change material properties across the project").Wrapped(),
                Button().Text("Find Materials").OnClick(() =>
                {
                    var found = AssetDatabase.FindAssets("t:Material").Select(guid => AssetDatabase.LoadAssetAtPath<Material>(AssetDatabase.GUIDToAssetPath(guid)))
                        .Where(mat => ORLShadersMigrator.RevertableShaders.Contains(AssetDatabase.GUIDFromAssetPath(AssetDatabase.GetAssetPath(mat.shader)).ToString())).ToList();

                    _foundMaterialsProperty.Set(found);
                }),
                ScrollView().Children(
                    ForEach<Material>(_foundMaterialsProperty.Value, mat => HStack(
                        Toggle().OnMount(field => field.value = _selectedMaterials.Contains(mat)).OnChange<Toggle, bool>(evt =>
                        {
                            if (evt.newValue)
                            {
                                _selectedMaterials.Add(mat);
                            }
                            else
                            {
                                _selectedMaterials.Remove(mat);
                            }
                        }),
                        ObjectField().OnMount(field => field.value = mat).Flex(1)
                    )).BoundToProp(_foundMaterialsProperty)
                ),
                HStack(
                    Button("Select All", () =>
                    {
                        _selectedMaterials = new List<Material>(_foundMaterialsProperty.Value);
                        _foundMaterialsProperty.Set(_foundMaterialsProperty.Value);
                    }).Flex(1),
                    Button("Deselect All", () =>
                    {
                        _selectedMaterials.Clear();
                        _foundMaterialsProperty.Set(_foundMaterialsProperty.Value);
                    }).Flex(1)
                ).Style(el => el.flexShrink = 0),
                Label("Properties to Adjust").Bold(),
                VStack(
                    Toggle("Color Correction").OnChange<Toggle, bool>(evt =>
                    {
                        _colorCorrectionEnabled = evt.newValue;
                    }),
                    HStack(
                        new Slider("Lift", 0, 2).BoundPropValue(_lift).Flex(1),
                        FloatField().BoundPropValue(_lift).Width(30)
                    ),
                    HStack(
                        new Slider("Gamma", 0, 2).BoundPropValue(_gamma).Flex(1),
                        FloatField().BoundPropValue(_gamma).Width(30)
                    ),
                    HStack(
                        new Slider("Gain", 0, 2).BoundPropValue(_gain).Flex(1),
                        FloatField().BoundPropValue(_gain).Width(30)
                    )
                ).Style(el => el.flexShrink = 0),
                Button("Update Mateirals", () =>
                {
                    var group = Undo.GetCurrentGroup();
                    foreach (var mat in _selectedMaterials)
                    {
                        Undo.RecordObject(mat, "Update Material Properties");
                        mat.SetInt("_ApplyColorCorrection", _colorCorrectionEnabled ? 1 : 0);
                        if (_colorCorrectionEnabled)
                        {
                            mat.EnableKeyword("APPLY_COLOR_CORRECTION");
                        }
                        else
                        {
                            mat.DisableKeyword("APPLY_COLOR_CORRECTION");
                        }
                        if (_colorCorrectionEnabled)
                        {
                            mat.SetFloat("_ColorCorrLift", _lift.Value);
                            mat.SetFloat("_ColorCorrGamma", _gamma.Value);
                            mat.SetFloat("_ColorCorrGain", _gain.Value);
                        }
                    }
                    Undo.CollapseUndoOperations(group);
                }).Bold().Color(Color.green)
            ).Padding(4);
        }
    }
}
#endif