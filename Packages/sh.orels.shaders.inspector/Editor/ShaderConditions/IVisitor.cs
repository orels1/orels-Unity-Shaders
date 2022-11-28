namespace ORL.ShaderConditions
{
    public interface IVisitor<T>{
        T VisitBinaryExpression(Binary expression);
        T VisitGroupingExpression(Grouping expression);
        T VisitLiteralExpression(Literal expression);
        T VisitLogicalExpression(Logical expression);
        T VisitUnaryExpression(Unary expression);
    }
}