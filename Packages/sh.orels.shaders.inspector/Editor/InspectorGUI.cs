using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Reflection;
using System.Text.RegularExpressions;
using System.IO;
using ORL.Drawers;
using ORL.ShaderInspector.MaterialLibraries;
using UnityEditor;
using UnityEngine;
using UnityEngine.Rendering;
using Object = UnityEngine.Object;

namespace ORL.ShaderInspector
{
    public class InspectorGUI : ShaderGUI
    {
        // Drawers match arbitrary regexes, and thus it is impossible to order them
        // They are still useful for things like `# Some Header` and such
        // But they cannot rely on order of execution
        // The still are able to stop any further drawers from rendering as an optional feature
        private List<IDrawer> _drawers;

        // Functions are match in order of them being defined int he name
        // Which allows you to chain things in order of priority
        // As functions can choose to call or not call `next`
        private Dictionary<string, IDrawerFunc> _drawerFuncs;

        private Dictionary<string, object> _uiState;

        private bool _initialized;

        private List<string> _shaderFeatures;
        private List<string> _multiCompiles;
        
        #region State Management
        private string[] _persistedKeys = new[] { "debugShown" };

        private void Initialize(MaterialEditor materialEditor, MaterialProperty[] properties)
        {
            Styles.InitTextureStyles();

            // fill in our own stuff
            _drawers = Assembly
                .GetAssembly(typeof(IDrawer)).GetTypes()
                .Where(t =>
                {
                    return t.GetInterfaces().Contains(typeof(IDrawer)) &&
                           t.GetConstructor(Type.EmptyTypes) != null;
                })
                .Select(t => Activator.CreateInstance(t) as IDrawer).ToList();

            _drawerFuncs = new Dictionary<string, IDrawerFunc>();
            var drawerFuncInstances = Assembly
                .GetAssembly(typeof(IDrawerFunc)).GetTypes()
                .Where(t =>
                {
                    return t.GetInterfaces().Contains(typeof(IDrawerFunc)) &&
                           t.GetConstructor(Type.EmptyTypes) != null;
                })
                .Select(t => Activator.CreateInstance(t) as IDrawerFunc).ToList();
            foreach (var drawerFunc in drawerFuncInstances)
            {
                _drawerFuncs.Add(drawerFunc.FunctionName, drawerFunc);
            }

            // TODO: Allow loading custom types via assembly attribute

            var shaderSourcePath = AssetDatabase.GetAssetPath((materialEditor.target as Material).shader);
            string[] shaderSource;
            if (shaderSourcePath.EndsWith(".orlshader")) {
                shaderSource = AssetDatabase.LoadAllAssetsAtPath(shaderSourcePath).OfType<TextAsset>().First().text.Split('\n');
            } else {
                shaderSource = File.ReadAllLines(Application.dataPath.Replace("\\", "/").Replace("Assets", "") + shaderSourcePath);
            }

            var shaderFeatureLines = shaderSource.ToList().Where(line => line.Trim().StartsWith("#pragma shader_feature")).ToList();
            _shaderFeatures = new List<string>();
            foreach (var line in shaderFeatureLines)
            {
                var features = line.Trim().Replace("#pragma shader_feature_local", "").Replace("#pragma shader_feature", "").Split(' ');
                foreach (var feature in features)
                {
                    var featureName = feature.Trim();
                    if (string.IsNullOrWhiteSpace(featureName) || featureName == "_" || _shaderFeatures.Contains(featureName))
                    {
                        continue;
                    }
                    _shaderFeatures.Add(featureName);
                }
            }

            var multiCompileLines = shaderSource.ToList().Where(line => line.Trim().StartsWith("#pragma multi_compile")).ToList();
            _multiCompiles = new List<string>();
            foreach (var line in multiCompileLines)
            {
                var trimmed = line.Trim();
                // ignore the built-in multi_compiles (e.g. multi_compile_instancing)
                if (trimmed.StartsWith("#pragma multi_compile_") && !trimmed.StartsWith("#pragma multi_compile_local"))
                {
                    continue;
                }
                var multiCompiles = trimmed.Replace("#pragma multi_compile_local", "").Replace("#pragma multi_compile", "").Split(' ');
                foreach (var feature in multiCompiles)
                {
                    var multiCompileName = feature.Trim();
                    if (string.IsNullOrWhiteSpace(multiCompileName) || multiCompileName == "_" || _multiCompiles.Contains(multiCompileName))
                    {
                        continue;
                    }
                    _multiCompiles.Add(multiCompileName);
                }
            }

            _uiState = RestoreState(materialEditor.target as Material);
            if (!_uiState.ContainsKey("debugShown"))
            {
                _uiState.Add("debugShown", false);
            }

            foreach (var prop in properties)
            {
                if (prop.type == MaterialProperty.PropType.Texture && prop.textureDimension == TextureDimension.Tex2D && !_uiState.ContainsKey(prop.name + "_packer"))
                {
                    var packerKey = prop.name + "_packer";
                    _uiState.Add(packerKey, false);
                    _uiState.Add(packerKey + "_red_tex", prop.textureValue);
                    _uiState.Add(packerKey + "_blue_tex", prop.textureValue);
                    _uiState.Add(packerKey + "_green_tex", prop.textureValue);
                    _uiState.Add(packerKey + "_alpha_tex", prop.textureValue);
                    
                    _uiState.Add(packerKey + "_red_channel", 0);
                    _uiState.Add(packerKey + "_green_channel", 1);
                    _uiState.Add(packerKey + "_blue_channel", 2);
                    _uiState.Add(packerKey + "_alpha_channel", 3);
                    
                    _uiState.Add(packerKey + "_red_val", 1f);
                    _uiState.Add(packerKey + "_blue_val", 1f);
                    _uiState.Add(packerKey + "_green_val", 1f);
                    _uiState.Add(packerKey + "_alpha_val", 1f);
                    
                    _uiState.Add(packerKey + "_red_invert", false);
                    _uiState.Add(packerKey + "_blue_invert", false);
                    _uiState.Add(packerKey + "_green_invert", false);
                    _uiState.Add(packerKey + "_alpha_invert", false);
                    
                    _uiState.Add(packerKey + "_size", 2048);
                    _uiState.Add(packerKey + "_linear", false);
                    _uiState.Add(packerKey + "_name", materialEditor.target.name + "_" + Utils.StripInternalSymbols(prop.displayName).Trim() + "_packed");
                }
            }

            _initialized = true;
        }
        
        private class SerializedState
        {
            public string[] keys;
            public string[] values;
            public string[] types;
        }

        private class SavedGradient
        {
            public Gradient value;
        }
        
        private Dictionary<string, object> RestoreState(Material target)
        {
            var importer = AssetImporter.GetAtPath(AssetDatabase.GetAssetPath(target));
            if (importer == null) return new Dictionary<string, object>();
            var userData = new SerializedState();
            if (!string.IsNullOrWhiteSpace(importer.userData))
            {
                EditorJsonUtility.FromJsonOverwrite(importer.userData, userData);
                var restored = new Dictionary<string, object>();
                for (int i = 0; i < userData.keys.Length; i++)
                {
                    switch (userData.types[i])
                    {
                        case "skip":
                            restored.Add(userData.keys[i], null);
                            break;
                        case "int":
                            restored.Add(userData.keys[i], int.Parse(userData.values[i]));
                            break;
                        case "float":
                            restored.Add(userData.keys[i], float.Parse(userData.values[i]));
                            break;
                        case "bool":
                            restored.Add(userData.keys[i], bool.Parse(userData.values[i]));
                            break;
                        case "string":
                            restored.Add(userData.keys[i], userData.values[i]);
                            break;
                        case "gradient":
                            var grad = new SavedGradient();
                            EditorJsonUtility.FromJsonOverwrite(userData.values[i], grad);
                            restored.Add(userData.keys[i], grad.value);
                            break;
                        default:
                            restored.Add(userData.keys[i], null);
                            break;
                    }
                }
            
                return restored;
            }
            
            return new Dictionary<string, object>();
        }

        private void SaveState(Material target)
        {
            // currently the setting persistence is disabled
            return;
#pragma warning disable CS0162
            var importer = AssetImporter.GetAtPath(AssetDatabase.GetAssetPath(target));
            var filtered = new Dictionary<string, object>();
            var toPersist = _drawers.Select(d => d.PersistentKeys).SelectMany(k => k).ToList();
            toPersist.AddRange(_drawerFuncs.Values.Select(d => d.PersistentKeys).SelectMany(k => k));
            toPersist.AddRange(_persistedKeys);
            foreach (var el in _uiState)
            {
                var shouldPersist = toPersist.Any(k => el.Key.ToLowerInvariant().Trim().StartsWith(k.ToLowerInvariant().Trim()));
                if (shouldPersist)
                {
                    filtered.Add(el.Key, el.Value);
                }
            }
            var userData = new SerializedState();
            userData.keys = filtered.Keys.ToArray();
            var values = filtered.Values.ToArray();
            userData.values = new string[values.Length];
            userData.types = new string[values.Length];
            for (int i = 0; i < values.Length; i++)
            {
                if (values[i] == null)
                {
                    userData.types[i] = "skip";
                    userData.values[i] = null;
                    continue;
                }
                var type = values[i].GetType();
                switch (values[i])
                {
                    case int val:
                        userData.types[i] = "int";
                        userData.values[i] = val.ToString();
                        break;
                    case float val:
                        userData.types[i] = "float";
                        userData.values[i] = val.ToString(CultureInfo.InvariantCulture);
                        break;
                    case bool val:
                        userData.types[i] = "bool";
                        userData.values[i] = val.ToString();
                        break;
                    case string val:
                        userData.types[i] = "string";
                        userData.values[i] = val;
                        break;
                    case Gradient val:
                        userData.types[i] = "gradient";
                        userData.values[i] = EditorJsonUtility.ToJson(new SavedGradient { value = val });
                        break;
                    default:
                        userData.types[i] = "skip";
                        userData.values[i] = null;
                        break;
                }
            }
            importer.userData = EditorJsonUtility.ToJson(userData);
            importer.SaveAndReimport();
#pragma warning restore CS0162
        }
        
        private bool StateHasChanged(Dictionary<string, object> oldState, Dictionary<string, object> newState)
        {
            if (oldState.Count != newState.Count)
            {
                return true;
            }

            foreach (var el in oldState)
            {
                if (!newState.ContainsKey(el.Key))
                {
                    return true;
                }

                if (el.Value == null && newState[el.Key] != null)
                {
                    return true;
                }

                if (el.Value != null && newState[el.Key] == null)
                {
                    return true;
                }

                if (el.Value != null && newState[el.Key] != null && !el.Value.Equals(newState[el.Key]))
                {
                    return true;
                }
            }

            return false;
        }
        
        #endregion

        private Shader _initialShader;
        private int _oldPropCount;
        private bool _libraryOpen;

        public override void OnGUI(MaterialEditor materialEditor, MaterialProperty[] properties)
        {
            var material = materialEditor.target as Material;
            if (material == null) return;
            if (_initialShader == null)
            {
                _initialShader = material.shader;
            }
            else if (_initialShader != material.shader)
            {
                _initialized = false;
                _initialShader = material.shader;
            }
            if (_oldPropCount == 0) {
                _oldPropCount = properties.Length;
            } else  if (_oldPropCount != properties.Length) {
                _initialized = false;
                _oldPropCount = properties.Length;
            }
            if (!_initialized)
            {
                Initialize(materialEditor, properties);
            }
            
            // Draw the Preset management
            // This is disabled for now as this functionality isn't ready
            #if false
            if (GUILayout.Button("Open AmbientCG Browser"))
            {
                if (!_libraryOpen)
                {
                    _libraryOpen = true;
                    PopupWindow.Show(GUILayoutUtility.GetLastRect(), new AmbientCGBrowser(() =>
                    {
                        _libraryOpen = false;
                    }, material));
                }
            }
            #endif

            EditorGUILayout.Space();

            EditorGUIUtility.fieldWidth = 64f;
            var propIndex = 0;
            var oldState = new Dictionary<string, object>(_uiState);
            foreach (var property in properties)
            {
                if ((property.flags & MaterialProperty.PropFlags.HideInInspector) != 0)
                {
                    propIndex++;
                    continue;
                }

                var propDrawn = DrawUIProp(materialEditor, properties, property, propIndex);

                if (EditorGUI.indentLevel == -1)
                {
                    propIndex++;
                    continue;
                }

                if (propDrawn)
                {
                    propIndex++;
                    continue;
                }
                DrawRegularProp(materialEditor, properties, property, propIndex);
                propIndex++;
            }

            DrawFooter(materialEditor);
            DrawDebug(materialEditor, materialEditor.target as Material);
            if (!oldState.SequenceEqual(_uiState))
            {
                SaveState(materialEditor.target as Material);
            }
        }

        #region Drawing
        private bool MatchDrawerStack(List<IDrawer> drawers, MaterialEditor editor, MaterialProperty[] properties, MaterialProperty property, int index)
        {
            if (drawers.Count == 0)
            {
                return false;
            }

            var currDrawer = drawers[0];
            if (currDrawer.MatchDrawer(property))
            {
                drawers.RemoveAt(0);
                return currDrawer.OnGUI(editor, properties, property, index, ref _uiState, () => MatchDrawerStack(drawers, editor, properties, property, index));
            }

            drawers.RemoveAt(0);
            return MatchDrawerStack(drawers, editor, properties,property, index);
        }

        private bool MatchDrawerFuncStack(List<string> funcs, MaterialEditor editor, MaterialProperty[] properties, MaterialProperty property, int index)
        {
            if (funcs.Count == 0)
            {
                return false;
            }

            var currDrawerFunc = funcs.First();
            if (_drawerFuncs.ContainsKey(currDrawerFunc))
            {
                funcs.RemoveAt(0);
                return _drawerFuncs[currDrawerFunc].OnGUI(editor, properties, property, index, ref _uiState, () => MatchDrawerFuncStack(funcs, editor, properties, property, index));
            }

            funcs.RemoveAt(0);
            return MatchDrawerFuncStack(funcs, editor, properties,property, index);
        }

        private readonly static Regex _drawerFuncMatcher = new Regex(@"(?:%)([a-zA-Z]+)(?=\(.*\))");

        private bool DrawUIProp(MaterialEditor editor, MaterialProperty[] properties, MaterialProperty property, int index)
        {
            var drawerStack = new List<IDrawer>(_drawers);
            var drawn = false;
            if (_drawerFuncMatcher.IsMatch(property.displayName))
            {
                var groups = new List<string>();
                foreach (Match match in _drawerFuncMatcher.Matches(property.displayName))
                {
                    match.Groups.Cast<Group>()
                        .Where(g => !g.Value.StartsWith("%"))
                        .ToList()
                        .ForEach(g => groups.Add(g.Value));
                }
                #if UNITY_2022_1_OR_NEWER
                var oldIndentLevel = EditorGUI.indentLevel;
                var shouldRestore = oldIndentLevel != -1;
                EditorGUI.indentLevel = oldIndentLevel != -1 ? Mathf.Max(0, EditorGUI.indentLevel - 1) : oldIndentLevel;
                #endif
                drawn = MatchDrawerFuncStack(groups, editor, properties, property, index);
                #if UNITY_2022_1_OR_NEWER
                if (shouldRestore && EditorGUI.indentLevel != -1)
                {
                    EditorGUI.indentLevel = oldIndentLevel;
                }
                #endif
            }

            if (!drawn)
            {
                #if UNITY_2022_1_OR_NEWER
                var oldIndentLevel = EditorGUI.indentLevel;
                var shouldRestore = oldIndentLevel != -1;
                EditorGUI.indentLevel = oldIndentLevel != -1 ? Mathf.Max(0, EditorGUI.indentLevel - 1) : oldIndentLevel;
                #endif
                drawn = MatchDrawerStack(drawerStack, editor, properties, property, index);
                #if UNITY_2022_1_OR_NEWER
                if (shouldRestore && EditorGUI.indentLevel != -1)
                {
                    EditorGUI.indentLevel = oldIndentLevel;
                }
                #endif
            }
            return drawn;
        }

        private readonly static Regex _singleLineRegex = new Regex(@"(?<=^[\w\s]+)(\>)");

        public void DrawRegularProp(MaterialEditor editor, MaterialProperty[] properties, MaterialProperty property, int index)
        {
            #if UNITY_2022_1_OR_NEWER
            var oldIndentLevel = EditorGUI.indentLevel;
            var shouldRestore = oldIndentLevel != -1;
            EditorGUI.indentLevel = oldIndentLevel != -1 ? Mathf.Max(0, EditorGUI.indentLevel - 1) : oldIndentLevel;
            #endif
            
            var strippedName = Utils.StripInternalSymbols(property.displayName);
            var isSingleLine = property.type == MaterialProperty.PropType.Texture && _singleLineRegex.IsMatch(property.displayName);
            var defaultProps =
                (editor.target as Material).shader.GetPropertyAttributes(Array.IndexOf(properties, property));
            var tooltip = Array.Find(defaultProps, attr => attr.StartsWith("Tooltip("));
            var space = Array.Find(defaultProps, attr => attr.StartsWith("Space("));
            if (!string.IsNullOrWhiteSpace(space)) {
                space = space.Substring(space.IndexOf("(") + 1);
                space = space.Substring(0, space.LastIndexOf(")"));
                EditorGUILayout.Space(float.Parse(space));
            }
            if (!string.IsNullOrWhiteSpace(tooltip))
            {
                tooltip = tooltip.Substring(tooltip.IndexOf("(") + 1);
                tooltip = tooltip.Substring(0, tooltip.LastIndexOf(")"));
            }
            
            if (isSingleLine)
            {
                var buttonRect = editor.TexturePropertySingleLine(new GUIContent(strippedName, tooltip), property);
                buttonRect.x = EditorGUIUtility.labelWidth + 20.0f;
                buttonRect.width = EditorGUIUtility.currentViewWidth - EditorGUIUtility.labelWidth - 38f;
                // We can only repack 2D textures
                if (property.textureDimension != TextureDimension.Tex2D) return;
                var packerKey = property.name + "_packer";
                _uiState[packerKey] = TexturePacker.DrawPacker(buttonRect, (bool) _uiState[packerKey], ref _uiState, packerKey, editor.target as Material, property, editor);
                #if UNITY_2022_1_OR_NEWER
                if (shouldRestore)
                {
                    EditorGUI.indentLevel = oldIndentLevel;
                }
                #endif
                return;
            }

            var propHeight = editor.GetPropertyHeight(property, strippedName);
            if (property.type == MaterialProperty.PropType.Vector && EditorGUIUtility.currentViewWidth > 340) {
                propHeight /= 2.0f;
            }
            var controlRect = EditorGUILayout.GetControlRect(true, propHeight, EditorStyles.layerMaskField);

            if (property.type == MaterialProperty.PropType.Texture)
            {
                var buttonRect = controlRect;
                var labelSize = EditorStyles.label.CalcSize(new GUIContent(strippedName)) * EditorGUIUtility.pixelsPerPoint;
                buttonRect.height = labelSize.y;
                buttonRect.xMin = EditorGUIUtility.labelWidth;
                buttonRect.xMax -= EditorGUIUtility.fieldWidth;
                editor.TextureProperty(controlRect, property, strippedName, tooltip, (property.flags & MaterialProperty.PropFlags.NoScaleOffset) == 0);
                // We can only repack 2D textures
                if (property.textureDimension != TextureDimension.Tex2D) return;
                var packerKey = property.name + "_packer";
                _uiState[packerKey] = TexturePacker.DrawPacker(buttonRect, (bool) _uiState[packerKey], ref _uiState, packerKey, editor.target as Material, property, editor);
                #if UNITY_2022_1_OR_NEWER
                if (shouldRestore && EditorGUI.indentLevel != -1)
                {
                    EditorGUI.indentLevel = oldIndentLevel;
                }
                #endif
                return;
            }
            editor.ShaderProperty(controlRect, property, new GUIContent(strippedName, tooltip));
            #if UNITY_2022_1_OR_NEWER
            if (shouldRestore)
            {
                EditorGUI.indentLevel = oldIndentLevel;
            }
            #endif
        }
        #endregion

        private void DrawFooter(MaterialEditor editor)
        {
            Styles.DrawStaticHeader("Extras");
            EditorGUI.indentLevel = 1;
            #if UNITY_2022_1_OR_NEWER
            EditorGUI.indentLevel = 0;
            #endif
            editor.RenderQueueField();
            editor.EnableInstancingField();
            editor.LightmapEmissionFlagsProperty(0, true, true);
            editor.DoubleSidedGIField();
        }

        private void DrawDebug(MaterialEditor editor, Material material)
        {
            var currValue = (bool) _uiState["debugShown"];
            var newValue = Styles.DrawFoldoutHeader("Debug", currValue);

            if (currValue != newValue)
            {
                _uiState["debugShown"] = newValue;
                editor.Repaint();
            }

            if (!newValue) return;
            
            #if UNITY_2022_1_OR_NEWER
            // Unity 2022 is 1 more level nested
            EditorGUI.indentLevel = 0;
            #endif

            EditorGUILayout.LabelField("Active Keywords", EditorStyles.boldLabel);
            using (new EditorGUI.DisabledGroupScope(true)) {
                EditorGUILayout.TextArea(string.Join("\n", material.shaderKeywords));
            }

            if (_shaderFeatures.Count > 0) {
                EditorGUILayout.LabelField("Defined Shader Features", EditorStyles.boldLabel);
                using (new EditorGUI.DisabledGroupScope(true)) {
                    EditorGUILayout.TextArea(string.Join("\n", _shaderFeatures));
                }
            }

            if (_multiCompiles.Count > 0) {
                EditorGUILayout.LabelField("Defined Multi-Compiles", EditorStyles.boldLabel);
                using (new EditorGUI.DisabledGroupScope(true)) {
                    EditorGUILayout.TextArea(string.Join("\n", _multiCompiles));
                }
            }
        }
    }
}