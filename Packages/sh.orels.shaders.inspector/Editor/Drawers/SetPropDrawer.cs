using System;
using System.Collections.Generic;
using System.Text.RegularExpressions;
using ORL.ShaderConditions;
using UnityEditor;
using UnityEngine;

namespace ORL.Drawers
{
    public class SetPropDrawer: IDrawerFunc
    {
        public string FunctionName => "SetProp";
        
        // Matches %SetProp((Shader Condition), PropName, Value when True, Value when False)
        private Regex _matcher = new Regex(@"%SetProp\((?<condition>\([\w\,\s\&\|\(\)\!\<\>\=]+\))+\s*,\s*(?<propName>[\w]+)+\s*,\s*(?<trueValue>[\d\.]+)\s*,\s*(?<falseValue>[\d\.]+)\s*\)");
        
        private Dictionary<string, Expression> _expressions = new Dictionary<string, Expression>();
        private Interpreter _interpreter;
        
        public string[] PersistentKeys => Array.Empty<string>();

        public bool OnGUI(MaterialEditor editor, MaterialProperty[] properties, MaterialProperty property, int index, ref Dictionary<string, object> uiState, Func<bool> next)
        {
            if (EditorGUI.indentLevel == -1) return true;
            
            var match = _matcher.Match(property.displayName);
            
            if (_interpreter == null)
            {
                _interpreter = new Interpreter(editor.target as Material);
            }
            Compiler.HasError = false;
            var condition = match.Groups["condition"].Value;
            condition = condition.Substring(1, condition.Length - 2);
            var propName = match.Groups["propName"].Value;
            var trueValue = match.Groups["trueValue"].Value;
            var falseValue = match.Groups["falseValue"].Value;

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

            var value = result ? trueValue : falseValue;

            if (float.TryParse(value, out var parsedValue) && Mathf.Abs((editor.target as Material).GetFloat(propName) - parsedValue) > float.Epsilon)
            {
                (editor.target as Material)?.SetFloat(propName, float.Parse(value));
            }

            return next();
        }
    }
}