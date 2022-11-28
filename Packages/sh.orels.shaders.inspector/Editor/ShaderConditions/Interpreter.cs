using System;
using System.Collections.Generic;
using UnityEngine;
using Object = System.Object;

namespace ORL.ShaderConditions
{
    public class Interpreter : IVisitor<Object>
    {
        
        private Material _material;
        private Dictionary<string, object> _variables = new Dictionary<string, object>();

        public Interpreter(Material material)
        {
            _material = material;
        }

        public object VisitBinaryExpression(Binary expression)
        {
            var left = Evaluate(expression.Left);
            var right = Evaluate(expression.Right);

            switch (expression.Operator.Type)
            {
                case TokenType.GREATER:
                    return (float) left > (float) right;
                case TokenType.GREATER_EQUAL:
                    return (float) left >= (float) right;
                case TokenType.LESS:
                    return (float) left < (float) right;
                case TokenType.LESS_EQUAL:
                    return (float) left <= (float) right;
                case TokenType.BANG_EQUAL:
                    return !Equals(left, right);
                case TokenType.EQUAL_EQUAL:
                    return Equals(left, right);
            }

            return null;
        }

        public object VisitGroupingExpression(Grouping expression)
        {
            return Evaluate(expression.Expression);
        }

        public object VisitLiteralExpression(Literal expression)
        {
            if (expression.Value is float)
            {
                return expression.Value;
            }

            return GetVariableValue((string) expression.Value);
        }

        public object VisitLogicalExpression(Logical expression)
        {
            var left = Evaluate(expression.Left);

            if (expression.Operator.Type == TokenType.OR)
            {
                if (IsTruthy(left)) return left;
            }
            else
            {
                if (!IsTruthy(left)) return left;
            }

            return Evaluate(expression.Right);
        }

        public object VisitUnaryExpression(Unary expression)
        {
            var right = Evaluate(expression.Right);

            switch (expression.Operator.Type)
            {
                case TokenType.BANG:
                    return !IsTruthy(right);
                case TokenType.MINUS:
                    return -(float) right;
            }

            return null;
        }
        
        private bool IsTruthy(Object value) {
            if (value == null) return false;
            if (value is bool b) return b;
            if (value is float f) return f > 0; 
            return true;
        }
        
        private object GetVariableValue(string name)
        {
            {
                if (ShaderInspector.Utils.TryGetValueFromTexture(name, _material, out var value))
                {
                    // _variables.Add(name, value);
                    return value;
                }
            }
            
            {
                if (ShaderInspector.Utils.TryGetValueFromFloat(name, _material, out var value))
                {
                    // _variables.Add(name, value);
                    return value;
                }
            }
            
            {
                if (ShaderInspector.Utils.TryGetValueFromKeyword(name, _material, out var value))
                {
                    // _variables.Add(name, value);
                    return value;
                }
            }
            
            Compiler.Error($"Could not get vaue for {name}");
            return null;
        }

        private Object Evaluate(Expression expression)
        {
            return expression.Accept(this);
        }

        public object Interpret(Expression expression)
        {
            try
            {
                return Evaluate(expression);
            }
            catch (Exception e)
            {
                Compiler.Error(e.ToString());
            }

            return null;
        }
    }
}