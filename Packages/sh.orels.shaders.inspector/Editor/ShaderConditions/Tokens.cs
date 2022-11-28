namespace ORL.ShaderConditions
{
    public enum TokenType
    {
        LEFT_PAREN, RIGHT_PAREN,
            
        BANG, BANG_EQUAL,
        EQUAL_EQUAL,
        GREATER, GREATER_EQUAL,
        LESS, LESS_EQUAL,
        
        MINUS,
            
        IDENTIFIER, NUMBER,
            
        AND, OR,
            
        EOL
    }

    public class Token
    {
        public readonly TokenType Type;
        public readonly string Lexeme;
        public readonly object Literal;
        
        public Token(TokenType type, string lexeme, object literal)
        {
            Type = type;
            Lexeme = lexeme;
            Literal = literal;
        }
        
        public override string ToString()
        {
            return $"{Type} {Lexeme} {Literal}";
        }
    }
}