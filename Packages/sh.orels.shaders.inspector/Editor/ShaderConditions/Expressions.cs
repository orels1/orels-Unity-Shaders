namespace ORL.ShaderConditions
{
    public abstract class Expression
    {
        public abstract T Accept<T>(IVisitor<T> visitor);
    }

    public class Binary : Expression
    {
        public readonly Expression Left;
        public readonly Expression Right;
        public readonly Token Operator;
        
        public Binary(Expression left, Token op, Expression right)
        {
            Left = left;
            Operator = op;
            Right = right;
        }
        
        public override T Accept<T>(IVisitor<T> visitor)
        {
            return visitor.VisitBinaryExpression(this);
        }
    }
    
    public class Grouping : Expression
    {
        public readonly Expression Expression;
        
        public Grouping(Expression expression)
        {
            Expression = expression;
        }
        
        public override T Accept<T>(IVisitor<T> visitor)
        {
            return visitor.VisitGroupingExpression(this);
        }
    }
    
    public class Literal : Expression
    {
        public readonly object Value;
        
        public Literal(object value)
        {
            Value = value;
        }
        
        public override T Accept<T>(IVisitor<T> visitor)
        {
            return visitor.VisitLiteralExpression(this);
        }
    }

    public class Logical : Expression
    {
        public readonly Expression Left;
        public readonly Expression Right;
        public readonly Token Operator;
        
        public Logical(Expression left, Token op, Expression right)
        {
            Left = left;
            Operator = op;
            Right = right;
        }
        
        public override T Accept<T>(IVisitor<T> visitor)
        {
            return visitor.VisitLogicalExpression(this);
        }
    }

    public class Unary : Expression
    {
        public readonly Expression Right;
        public readonly Token Operator;
        
        public Unary(Token op, Expression right)
        {
            Operator = op;
            Right = right;
        }
        
        public override T Accept<T>(IVisitor<T> visitor)
        {
            return visitor.VisitUnaryExpression(this);
        }
    }
}