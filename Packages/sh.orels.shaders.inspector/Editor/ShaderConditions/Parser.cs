using System;
using System.Collections.Generic;
using UnityEngine;

namespace ORL.ShaderConditions
{
    public class Parser
    {
        private readonly List<Token> _tokens;
        private int _current = 0;

        public Parser(List<Token> tokens)
        {
            _tokens = tokens;
        }

        public Expression Parse()
        {
            try
            {
                return Expression();
            }
            catch (ParserException)
            {
                return null;
            }
        }

        private Expression Expression()
        {
            return Or();
        }

        private Expression Or()
        {
            var expr = And();

            while (Match(TokenType.OR))
            {
                var op = Previous();
                var right = And();
                expr = new Logical(expr, op, right);
            }

            return expr;
        }

        private Expression And()
        {
            var expr = Equality();

            while (Match(TokenType.AND))
            {
                var op = Previous();
                var right = Equality();
                expr = new Logical(expr, op, right);
            }

            return expr;
        }

        private Expression Equality()
        {
            var expr = Comparison();

            while (Match(TokenType.BANG_EQUAL, TokenType.EQUAL_EQUAL))
            {
                var op = Previous();
                var right = Comparison();
                expr = new Binary(expr, op, right);
            }

            return expr;
        }

        private Expression Comparison()
        {
            var expr = Unary();

            while (Match(TokenType.GREATER, TokenType.GREATER_EQUAL, TokenType.LESS, TokenType.LESS_EQUAL))
            {
                var op = Previous();
                var right = Unary();
                expr = new Binary(expr, op, right);
            }

            return expr;
        }

        private Expression Unary()
        {
            if (Match(TokenType.BANG, TokenType.MINUS))
            {
                var op = Previous();
                var right = Unary();
                return new Unary(op, right);
            }

            return Primary();
        }

        private Expression Primary()
        {
            if (Match(TokenType.NUMBER))
            {
                return new Literal(Previous().Literal);
            }

            if (Match(TokenType.IDENTIFIER))
            {
                return new Literal(Previous().Lexeme);
            }

            if (Match(TokenType.LEFT_PAREN))
            {
                var expr = Expression();
                Consume(TokenType.RIGHT_PAREN, "Expected ')' after expression.");
                return new Grouping(expr);
            }

            throw Error(Peek(), "Expected expression.");
        }

        private Token Consume(TokenType tokenType, string errorMessage)
        {
            if (Check(tokenType))
            {
                return Advance();
            }

            throw Error(Peek(), errorMessage);
        }

        private Exception Error(Token token, string errorMessage)
        {
            Compiler.Error(errorMessage);
            return new ParserException();
        }

        private void Synchronize()
        {
            Advance();

            while (!IsAtEnd())
            {
                Advance();
            }
        }

        private bool Match(params TokenType[] tokens)
        {
            foreach (var token in tokens)
            {
                if (Check(token))
                {
                    Advance();
                    return true;
                }
            }

            return false;
        }

        private bool Check(TokenType token)
        {
            if (IsAtEnd()) return false;
            return Peek().Type == token;
        }

        private Token Advance()
        {
            if (!IsAtEnd()) _current++;
            return Previous();
        }

        private bool IsAtEnd()
        {
            return Peek().Type == TokenType.EOL;
        }

        private Token Peek()
        {
            return _tokens[_current];
        }

        private Token Previous()
        {
            return _tokens[_current - 1];
        }
    }

    public class ParserException : Exception
    {
        public ParserException() : base()
        {
        }

        public ParserException(string message) : base(message)
        {
        }

        public ParserException(string message, Exception innerException) : base(message, innerException)
        {
        }
    }
}