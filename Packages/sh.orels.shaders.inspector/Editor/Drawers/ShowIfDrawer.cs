using System;
using System.Collections.Generic;
using System.Text.RegularExpressions;
using ORL.ShaderConditions;
using UnityEditor;
using UnityEngine;
using ORL.ShaderInspector;

namespace ORL.Drawers
{
    public class ShowIfDrawer: IDrawerFunc
    {
        public string FunctionName => "ShowIf";
        
        // Matches %ShowIf(Condition);
        private Regex _matcher = new Regex(@"(?<=[\w\s\>\s]+)\%ShowIf\((?<condition>[\w\,\s\&\|\(\)\!\<\>\=]+)\)");
        
        public string[] PersistentKeys => Array.Empty<string>();

        private Dictionary<string, Expression> _expressions = new Dictionary<string, Expression>();
        private Interpreter _interpreter;

        public bool OnGUI(MaterialEditor editor, MaterialProperty[] properties, MaterialProperty property, int index, ref Dictionary<string, object> uiState, Func<bool> next)
        {
            if (EditorGUI.indentLevel == -1 && !property.displayName.Trim().StartsWith("# ")) return true;
            
            if (_interpreter == null)
            {
                _interpreter = new Interpreter(editor.target as Material);
            }
            Compiler.HasError = false;
            var match = _matcher.Match(property.displayName);
            var condition = match.Groups["condition"].Value;

            if (!_expressions.ContainsKey(property.displayName))
            {
                var scanner = new Scanner(condition);
                var tokens = scanner.Tokenize();
                var parser = new Parser(tokens);
                var expr = parser.Parse();
                if (Compiler.HasError)
                {
                    Debug.LogError("Failed to parse condition: " + condition);
                    return true;
                }
                _expressions.Add(property.displayName, expr);
            }
            var result = Convert.ToBoolean(_interpreter.Interpret(_expressions[property.displayName]));
            if (!result) return true;
            return next();
        }
    }
}