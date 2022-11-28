using System;
using System.Collections.Generic;
using System.Linq;
using System.Reflection;
using System.Text.RegularExpressions;
using ORL.Drawers;
using UnityEditor;
using UnityEngine;

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

        private void Initialize()
        {
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
            
            _initialized = true;
        }
        
        public override void OnGUI(MaterialEditor materialEditor, MaterialProperty[] properties)
        {
            if (!_initialized)
            {
                Initialize();    
            }
            materialEditor.SetDefaultGUIWidths();
            var propIndex = 0;
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
                return currDrawer.OnGUI(editor, properties, property, index, _uiState, () => MatchDrawerStack(drawers, editor, properties, property, index));
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
                return _drawerFuncs[currDrawerFunc].OnGUI(editor, properties, property, index, _uiState, () => MatchDrawerFuncStack(funcs, editor, properties, property, index));
            }

            funcs.RemoveAt(0);
            return MatchDrawerFuncStack(funcs, editor, properties,property, index);
        }

        private Regex _drawerFuncMatcher = new Regex(@"(?:%)([a-zA-Z]+)(?=\(.*\))");
        
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
                        .ForEach(g =>
                        {
                            groups.Add(g.Value);
                        });
                }
                drawn = MatchDrawerFuncStack(groups, editor, properties, property, index);
            }

            if (!drawn)
            {
                drawn = MatchDrawerStack(drawerStack, editor, properties, property, index);
            }
            return drawn;
        }

        private static Regex _singleLineRegex = new Regex(@"(?<=\w+\s+)(\>)(?=\s*%?)");

        public static void DrawRegularProp(MaterialEditor editor, MaterialProperty[] properties, MaterialProperty property, int index)
        {
            var strippedName = Utils.StripInternalSymbols(property.displayName);
            var isSingleLine = property.type == MaterialProperty.PropType.Texture && _singleLineRegex.IsMatch(property.displayName);
            if (isSingleLine)
            {
                var labelSize = EditorStyles.label.CalcSize(new GUIContent(strippedName)) * EditorGUIUtility.pixelsPerPoint;
                var buttonRect = editor.TexturePropertySingleLine(new GUIContent(strippedName), property);
                var maxSizeButtonSize = buttonRect.width * 0.6f;
                buttonRect.xMin += labelSize.x + 34f * EditorGUIUtility.pixelsPerPoint;
                if (buttonRect.width > maxSizeButtonSize)
                {
                    var diff = buttonRect.width - maxSizeButtonSize;
                    buttonRect.width = maxSizeButtonSize;
                    buttonRect.x += diff;
                }
                buttonRect.height = labelSize.y;
                GUI.Button(buttonRect, "Repack Texture");
                return;
            }
            
            var controlRect = EditorGUILayout.GetControlRect(true,
                editor.GetPropertyHeight(property, strippedName), EditorStyles.layerMaskField);
            
            if (property.type == MaterialProperty.PropType.Texture)
            {
                var buttonRect = controlRect;
                var labelSize = EditorStyles.label.CalcSize(new GUIContent(strippedName)) * EditorGUIUtility.pixelsPerPoint;
                buttonRect.xMin += labelSize.x + 34f * EditorGUIUtility.pixelsPerPoint;
                buttonRect.height = labelSize.y;
                buttonRect.width -= 52 * EditorGUIUtility.pixelsPerPoint;
                GUI.Button(buttonRect, "Repack Texture");
                editor.TextureProperty(controlRect, property, strippedName);
                return;
            }
            editor.ShaderProperty(controlRect, property, strippedName);
        }
        #endregion

        private void DrawFooter(MaterialEditor editor)
        {
            editor.EnableInstancingField();
            editor.LightmapEmissionFlagsProperty(EditorGUI.indentLevel - 1, true);
            editor.DoubleSidedGIField();
        }
    }
}