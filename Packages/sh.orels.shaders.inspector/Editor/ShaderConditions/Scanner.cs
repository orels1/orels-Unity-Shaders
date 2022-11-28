using System.Collections.Generic;

namespace ORL.ShaderConditions
{
    public class Scanner
    {
        private readonly string _source;
        private List<Token> _tokens = new List<Token>();
        
        public Scanner(string source)
        {
            _source = source;
        }
        
        private int _start = 0;
        private int _current = 0;

        public List<Token> Tokenize()
        {
            _tokens = new List<Token>();
            while (!IsAtEnd())
            {
                _start = _current;
                ScanToken();
            }
            
            _tokens.Add(new Token(TokenType.EOL,"", null));
            return _tokens;
        }

        private void ScanToken()
        {
            var currChar = Advance();
            switch (currChar)
            {
                case '(': AddToken(TokenType.LEFT_PAREN); break;
                case ')': AddToken(TokenType.RIGHT_PAREN); break;
                case '!': AddToken(Match('=') ? TokenType.BANG_EQUAL : TokenType.BANG); break;
                case '=':
                    if (Match('='))
                    {
                        AddToken(TokenType.EQUAL_EQUAL);
                    }
                    break;
                case '<': AddToken(Match('=') ? TokenType.LESS_EQUAL : TokenType.LESS); break;
                case '>': AddToken(Match('=') ? TokenType.GREATER_EQUAL : TokenType.GREATER); break;
                case '-': AddToken(TokenType.MINUS); break;
                case '&':
                    if (Match('&'))
                    {
                        AddToken(TokenType.AND);
                    }

                    break;
                case '|':
                    if (Match('|'))
                    {
                        AddToken(TokenType.OR);
                    }

                    break;
                case ' ': break;
                case '\t': break;
                default:
                    if (IsDigit(currChar))
                    {
                        Number();
                        break;
                    }
                    if (IsAlpha(currChar))
                    {
                        Identifier();
                        break;
                    }
                    Compiler.Error($"Unexpected character {currChar}.");
                    break;
            }
        }
        
        private char Advance()
        {
            _current++;
            return _source[_current - 1];
        }

        private bool Match(char expected)
        {
            if (IsAtEnd()) return false;
            if (_source[_current] != expected) return false;

            _current++;
            return true;
        }

        private char Peek()
        {
            if (IsAtEnd()) return '\0';
            return _source[_current];
        }

        private bool IsDigit(char c)
        {
            return c >= '0' && c <= '9';
        }

        private bool IsAlpha(char c)
        {
            return (c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z') || c == '_';
        }

        private bool IsAlphaNumeric(char c)
        {
            return IsAlpha(c) || IsDigit(c);
        }

        private void Number()
        {
            while (IsDigit(Peek()))
            {
                Advance();
            }
            
            AddToken(TokenType.NUMBER, float.Parse(_source.Substring(_start, _current - _start)));
        }

        private void Identifier()
        {
            while (IsAlphaNumeric(Peek()))
            {
                Advance();
            }
            
            AddToken(TokenType.IDENTIFIER);
        }

        private void AddToken(TokenType type)
        {
            AddToken(type, null);
        }

        private void AddToken(TokenType type, object literal)
        {
            var text = _source.Substring(_start, _current - _start);
            _tokens.Add(new Token(type, text, literal));
        }

        private bool IsAtEnd()
        {
            return _current >= _source.Length;
        }
        
    }
}