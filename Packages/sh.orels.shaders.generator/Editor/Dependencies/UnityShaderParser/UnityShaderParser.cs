/*
BSD 3-Clause License

Copyright (c) 2024, Pema Malling

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

1. Redistributions of source code must retain the above copyright notice, this
   list of conditions and the following disclaimer.

2. Redistributions in binary form must reproduce the above copyright notice,
   this list of conditions and the following disclaimer in the documentation
   and/or other materials provided with the distribution.

3. Neither the name of the copyright holder nor the names of its
   contributors may be used to endorse or promote products derived from
   this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Globalization;
using System.IO;
using System.Linq;
using System.Reflection;
using System.Text;
using System.Threading.Tasks;
using UnityShaderParser.Common;
using UnityShaderParser.HLSL;
using UnityShaderParser.HLSL.PreProcessor;
using UnityShaderParser.ShaderLab;



// HLSL/HLSLEditor.cs
namespace UnityShaderParser.HLSL
{
    public abstract class HLSLEditor : HLSLSyntaxVisitor
    {
        public string Source { get; private set; }
        public List<Token<TokenKind>> Tokens { get; private set; }

        public HLSLEditor(string source, List<Token<TokenKind>> tokens)
        {
            Source = source;
            Tokens = tokens;
        }

        protected HashSet<(SourceSpan span, string newText)> Edits = new HashSet<(SourceSpan, string)>();

        protected void Edit(SourceSpan span, string newText) => Edits.Add((span, newText));
        protected void Edit(Token<TokenKind> token, string newText) => Edit(token.Span, newText);
        protected void Edit(HLSLSyntaxNode node, string newText) => Edit(node.Span, newText);
        protected void AddBefore(SourceSpan span, string newText) => Edit(new SourceSpan(span.BasePath, span.FileName, span.Start, span.Start), newText);
        protected void AddBefore(Token<TokenKind> token, string newText) => Edit(new SourceSpan(token.Span.BasePath, token.Span.FileName, token.Span.Start, token.Span.Start), newText);
        protected void AddBefore(HLSLSyntaxNode node, string newText) => Edit(new SourceSpan(node.Span.BasePath, node.Span.FileName, node.Span.Start, node.Span.Start), newText);
        protected void AddAfter(SourceSpan span, string newText) => Edit(new SourceSpan(span.BasePath, span.FileName, span.End, span.End), newText);
        protected void AddAfter(Token<TokenKind> token, string newText) => Edit(new SourceSpan(token.Span.BasePath, token.Span.FileName, token.Span.End, token.Span.End), newText);
        protected void AddAfter(HLSLSyntaxNode node, string newText) => Edit(new SourceSpan(node.Span.BasePath, node.Span.FileName, node.Span.End, node.Span.End), newText);

        public string ApplyCurrentEdits() => PrintingUtil.ApplyEditsToSourceText(Edits, Source);

        public string ApplyEdits(HLSLSyntaxNode node)
        {
            Visit(node);
            return ApplyCurrentEdits();
        }

        public string ApplyEdits(IEnumerable<HLSLSyntaxNode> nodes)
        {
            VisitMany(nodes);
            return ApplyCurrentEdits();
        }

        public static string RunEditor<T>(string source, HLSLSyntaxNode node)
            where T : HLSLEditor
        {
            var editor = (HLSLEditor)Activator.CreateInstance(typeof(T), source, node.Tokens);
            return editor.ApplyEdits(node);
        }

        public static string RunEditor<T>(string source, IEnumerable<HLSLSyntaxNode> node)
            where T : HLSLEditor
        {
            var editor = (HLSLEditor)Activator.CreateInstance(typeof(T), source, node.SelectMany(x => x.Tokens).ToList());
            return editor.ApplyEdits(node);
        }
    }
}


// HLSL/HLSLLexer.cs
namespace UnityShaderParser.HLSL
{
    using HLSLToken = Token<TokenKind>;

    public class HLSLLexer : BaseLexer<TokenKind>
    {
        protected override ParserStage Stage => ParserStage.HLSLLexing;

        public HLSLLexer(string source, string basePath, string fileName, bool throwExceptionOnError, SourceLocation offset)
            : base(source, basePath, fileName, throwExceptionOnError, offset) { }

        public static List<HLSLToken> Lex(string source, string basePath, string fileName, bool throwExceptionOnError, out List<Diagnostic> diagnostics)
        {
            return Lex(source, basePath, fileName, throwExceptionOnError, new SourceLocation(1, 1, 0), out diagnostics);
        }

        public static List<HLSLToken> Lex(string source, string basePath, string fileName, bool throwExceptionOnError, SourceLocation offset, out List<Diagnostic> diagnostics)
        {
            HLSLLexer lexer = new HLSLLexer(source, basePath, fileName, throwExceptionOnError, offset);

            lexer.Lex();

            diagnostics = lexer.diagnostics;
            return lexer.tokens;
        }

        protected override void ProcessChar(char nextChar)
        {
            switch (nextChar)
            {
                case char c when char.IsLetter(c) || c == '_':
                    LexIdentifier();
                    break;

                case '0' when LookAhead('x'):
                    Advance(1);
                    string hexNum = EatIdentifier().Substring(1);
                    string origHexNum = hexNum;
                    if (hexNum.EndsWith("u") || hexNum.EndsWith("U"))
                        hexNum = hexNum.Substring(0, hexNum.Length - 1);
                    if (!uint.TryParse(hexNum, System.Globalization.NumberStyles.HexNumber, System.Globalization.CultureInfo.InvariantCulture, out uint hexVal))
                        Error(DiagnosticFlags.SyntaxError, $"Invalid hex literal 0x{hexNum}");
                    Add($"0x{origHexNum}", TokenKind.IntegerLiteralToken);
                    break;

                case char c when char.IsDigit(c) || (c == '.' && char.IsDigit(LookAhead())):
                    string num = EatNumber(out bool isFloat);
                    TokenKind kind = isFloat ? TokenKind.FloatLiteralToken : TokenKind.IntegerLiteralToken;
                    Add(num, kind);
                    break;

                case '\'':
                    Add(EatStringLiteral('\'', '\''), TokenKind.CharacterLiteralToken);
                    break;

                case '"':
                    Add(EatStringLiteral('"', '"'), TokenKind.StringLiteralToken);
                    break;

                case ' ':
                case '\t':
                case '\r':
                case '\n':
                case '\\':
                    Advance(); // Only consume 1 (preprocessor might care about the newlines)
                    break;

                case '/' when LookAhead('/'):
                    Advance(2);
                    while (!Match('\n'))
                    {
                        Advance();
                        if (IsAtEnd())
                            break;
                    }
                    break;

                case '/' when LookAhead('*'):
                    Advance(2);
                    while (!(Match('*') && LookAhead('/')))
                    {
                        Advance();
                        if (IsAtEnd())
                        {
                            Error(DiagnosticFlags.SyntaxError, $"Unterminated comment.");
                            break;
                        }
                    }
                    Advance(2);
                    break;

                case '(': Advance(); Add(TokenKind.OpenParenToken); break;
                case ')': Advance(); Add(TokenKind.CloseParenToken); break;
                case '[': Advance(); Add(TokenKind.OpenBracketToken); break;
                case ']': Advance(); Add(TokenKind.CloseBracketToken); break;
                case '{': Advance(); Add(TokenKind.OpenBraceToken); break;
                case '}': Advance(); Add(TokenKind.CloseBraceToken); break;
                case ';': Advance(); Add(TokenKind.SemiToken); break;
                case ',': Advance(); Add(TokenKind.CommaToken); break;
                case '.': Advance(); Add(TokenKind.DotToken); break;
                case '~': Advance(); Add(TokenKind.TildeToken); break;
                case '?': Advance(); Add(TokenKind.QuestionToken); break;

                case '<' when LookAhead('='): Advance(2); Add(TokenKind.LessThanEqualsToken); break;
                case '<' when LookAhead('<') && LookAhead('=', 2): Advance(3); Add(TokenKind.LessThanLessThanEqualsToken); break;
                case '<' when LookAhead('<'): Advance(2); Add(TokenKind.LessThanLessThanToken); break;
                case '<': Advance(); Add(TokenKind.LessThanToken); break;

                case '>' when LookAhead('='): Advance(2); Add(TokenKind.GreaterThanEqualsToken); break;
                case '>' when LookAhead('>') && LookAhead('=', 2): Advance(3); Add(TokenKind.GreaterThanGreaterThanEqualsToken); break;
                case '>' when LookAhead('>'): Advance(2); Add(TokenKind.GreaterThanGreaterThanToken); break;
                case '>': Advance(); Add(TokenKind.GreaterThanToken); break;

                case '+' when LookAhead('+'): Advance(2); Add(TokenKind.PlusPlusToken); break;
                case '+' when LookAhead('='): Advance(2); Add(TokenKind.PlusEqualsToken); break;
                case '+': Advance(); Add(TokenKind.PlusToken); break;

                case '-' when LookAhead('-'): Advance(2); Add(TokenKind.MinusMinusToken); break;
                case '-' when LookAhead('='): Advance(2); Add(TokenKind.MinusEqualsToken); break;
                case '-': Advance(); Add(TokenKind.MinusToken); break;

                case '*' when LookAhead('='): Advance(2); Add(TokenKind.AsteriskEqualsToken); break;
                case '*': Advance(); Add(TokenKind.AsteriskToken); break;

                case '/' when LookAhead('='): Advance(2); Add(TokenKind.SlashEqualsToken); break;
                case '/': Advance(); Add(TokenKind.SlashToken); break;

                case '%' when LookAhead('='): Advance(2); Add(TokenKind.PercentEqualsToken); break;
                case '%': Advance(); Add(TokenKind.PercentToken); break;

                case '&' when LookAhead('&'): Advance(2); Add(TokenKind.AmpersandAmpersandToken); break;
                case '&' when LookAhead('='): Advance(2); Add(TokenKind.AmpersandEqualsToken); break;
                case '&': Advance(); Add(TokenKind.AmpersandToken); break;

                case '|' when LookAhead('|'): Advance(2); Add(TokenKind.BarBarToken); break;
                case '|' when LookAhead('='): Advance(2); Add(TokenKind.BarEqualsToken); break;
                case '|': Advance(); Add(TokenKind.BarToken); break;

                case '^' when LookAhead('='): Advance(2); Add(TokenKind.CaretEqualsToken); break;
                case '^': Advance(); Add(TokenKind.CaretToken); break;

                case ':' when LookAhead(':'): Advance(2); Add(TokenKind.ColonColonToken); break;
                case ':': Advance(); Add(TokenKind.ColonToken); break;

                case '=' when LookAhead('='): Advance(2); Add(TokenKind.EqualsEqualsToken); break;
                case '=': Advance(); Add(TokenKind.EqualsToken); break;

                case '!' when LookAhead('='): Advance(2); Add(TokenKind.ExclamationEqualsToken); break;
                case '!': Advance(); Add(TokenKind.NotToken); break;

                case '#' when LookAhead('#'): Advance(2); Add(TokenKind.HashHashToken); break;

                case '#':
                    LexPreProcessorDirective();
                    break;

                case char c:
                    Advance();
                    Error(DiagnosticFlags.SyntaxError, $"Unexpected token '{c}'.");
                    break;
            }
        }

        private void LexIdentifier()
        {
            string identifier = EatIdentifier();
            if (HLSLSyntaxFacts.TryParseHLSLKeyword(identifier, out TokenKind token))
            {
                Add(token);
            }
            else
            {
                Add(identifier, TokenKind.IdentifierToken);
            }
        }

        private void LexPreProcessorDirective()
        {
            Eat('#');
            SkipWhitespace();
            string keyword = EatIdentifier();
            switch (keyword)
            {
                case "define":
                    Add(TokenKind.DefineDirectiveKeyword);
                    SkipWhitespace();
                    Add(EatIdentifier(), TokenKind.IdentifierToken);
                    if (Match('(')) // No whitespace
                    {
                        // In order to distinguish function like macros and regular macros, one must inspect whitespace
                        Advance();
                        Add(TokenKind.OpenFunctionLikeMacroParenToken);
                    }
                    break;

                case "line": Add(TokenKind.LineDirectiveKeyword); break;
                case "undef": Add(TokenKind.UndefDirectiveKeyword); break;
                case "error": Add(TokenKind.ErrorDirectiveKeyword); break;
                case "pragma": Add(TokenKind.PragmaDirectiveKeyword); break;
                case "include": case "include_with_pragmas": Add(TokenKind.IncludeDirectiveKeyword);
                    SkipWhitespace();
                    // Handle system includes
                    if (Match('<'))
                    {
                        Eat('<');
                        var sb = new StringBuilder();
                        while (!IsAtEnd() && !Match('>'))
                        {
                            sb.Append(Advance());
                        }
                        Eat('>');
                        Add(sb.ToString(), TokenKind.SystemIncludeLiteralToken);
                    }
                    break;

                case "if": Add(TokenKind.IfDirectiveKeyword); break;
                case "ifdef": Add(TokenKind.IfdefDirectiveKeyword); break;
                case "ifndef": Add(TokenKind.IfndefDirectiveKeyword); break;
                case "elif": Add(TokenKind.ElifDirectiveKeyword); break;
                case "else": Add(TokenKind.ElseDirectiveKeyword); break;
                case "endif": Add(TokenKind.EndifDirectiveKeyword); break;

                default:
                    Add(TokenKind.HashToken);
                    Add(keyword, TokenKind.IdentifierToken);
                    break;
            }

            // Go to end of line
            while (!IsAtEnd() && !Match('\n'))
            {
                // Skip multiline macro line breaks
                if (Match('\\'))
                {
                    Advance();
                    SkipWhitespace();
                    if (Match('\n'))
                    {
                        Advance();
                    }
                }

                // Process char
                StartCurrentSpan();
                ProcessChar(Peek());
            }
            Add(TokenKind.EndDirectiveToken);
        }
    }
}


// HLSL/HLSLParser.cs
namespace UnityShaderParser.HLSL
{
    using HLSLToken = Token<TokenKind>;

    public class HLSLParserConfig
    {
        public PreProcessorMode PreProcessorMode { get; set; }
        public string BasePath { get; set; }
        public string FileName { get; set; }
        public IPreProcessorIncludeResolver IncludeResolver { get; set; }
        public Dictionary<string, string> Defines { get; set; }
        public bool ThrowExceptionOnError { get; set; }
        public DiagnosticFlags DiagnosticFilter { get; set; }

        public HLSLParserConfig()
        {
            PreProcessorMode = PreProcessorMode.ExpandAll;
            BasePath = Directory.GetCurrentDirectory();
            FileName = null;
            IncludeResolver = new DefaultPreProcessorIncludeResolver();
            Defines = new Dictionary<string, string>();
            ThrowExceptionOnError = false;
            DiagnosticFilter = DiagnosticFlags.All;
        }

        public HLSLParserConfig(HLSLParserConfig config)
        {
            PreProcessorMode = config.PreProcessorMode;
            BasePath = config.BasePath;
            FileName = config.FileName;
            IncludeResolver = config.IncludeResolver;
            Defines = config.Defines;
            ThrowExceptionOnError = config.ThrowExceptionOnError;
            DiagnosticFilter = config.DiagnosticFilter;
        }
    }

    public class HLSLParser : BaseParser<TokenKind>
    {
        public HLSLParser(List<HLSLToken> tokens, bool throwExceptionOnError, DiagnosticFlags diagnosticFilter)
            : base(tokens, throwExceptionOnError, diagnosticFilter)
        {
            InitOperatorGroups();
        }

        protected override TokenKind StringLiteralTokenKind => TokenKind.StringLiteralToken;
        protected override TokenKind IntegerLiteralTokenKind => TokenKind.IntegerLiteralToken;
        protected override TokenKind FloatLiteralTokenKind => TokenKind.FloatLiteralToken;
        protected override TokenKind IdentifierTokenKind => TokenKind.IdentifierToken;
        protected override TokenKind InvalidTokenKind => TokenKind.InvalidToken;
        protected override ParserStage Stage => ParserStage.HLSLParsing;

        public static List<HLSLSyntaxNode> ParseTopLevelDeclarations(List<HLSLToken> tokens, HLSLParserConfig config, out List<Diagnostic> diagnostics, out List<string> pragmas)
        {
            HLSLParser parser = new HLSLParser(tokens, config.ThrowExceptionOnError, config.DiagnosticFilter);
            parser.RunPreProcessor(config, out pragmas);
            var result = parser.ParseTopLevelDeclarations();
            foreach (var decl in result)
            {
                decl.ComputeParents();
            }
            diagnostics = parser.diagnostics;
            return result;
        }

        public static HLSLSyntaxNode ParseTopLevelDeclaration(List<HLSLToken> tokens, HLSLParserConfig config, out List<Diagnostic> diagnostics, out List<string> pragmas)
        {
            HLSLParser parser = new HLSLParser(tokens, config.ThrowExceptionOnError, config.DiagnosticFilter);
            parser.RunPreProcessor(config, out pragmas);
            var result = parser.ParseTopLevelDeclaration();
            result.ComputeParents();
            diagnostics = parser.diagnostics;
            return result;
        }

        public static List<StatementNode> ParseStatements(List<HLSLToken> tokens, HLSLParserConfig config, out List<Diagnostic> diagnostics, out List<string> pragmas)
        {
            HLSLParser parser = new HLSLParser(tokens, config.ThrowExceptionOnError, config.DiagnosticFilter);
            parser.RunPreProcessor(config, out pragmas);
            var result = parser.ParseMany0(() => !parser.LoopShouldContinue(), () => parser.ParseStatement());
            foreach (var stmt in result)
            {
                stmt.ComputeParents();
            }
            diagnostics = parser.diagnostics;
            return result;
        }

        public static StatementNode ParseStatement(List<HLSLToken> tokens, HLSLParserConfig config, out List<Diagnostic> diagnostics, out List<string> pragmas)
        {
            HLSLParser parser = new HLSLParser(tokens, config.ThrowExceptionOnError, config.DiagnosticFilter);
            parser.RunPreProcessor(config, out pragmas);
            var result = parser.ParseStatement();
            result.ComputeParents();
            diagnostics = parser.diagnostics;
            return result;
        }

        public static ExpressionNode ParseExpression(List<HLSLToken> tokens, HLSLParserConfig config, out List<Diagnostic> diagnostics, out List<string> pragmas)
        {
            HLSLParser parser = new HLSLParser(tokens, config.ThrowExceptionOnError, config.DiagnosticFilter);
            parser.RunPreProcessor(config, out pragmas);
            var result = parser.ParseExpression();
            result.ComputeParents();
            diagnostics = parser.diagnostics;
            return result;
        }

        public void RunPreProcessor(HLSLParserConfig config, out List<string> pragmas)
        {
            if (config.PreProcessorMode == PreProcessorMode.DoNothing)
            {
                pragmas = new List<string>();
                return;
            }

            tokens = HLSLPreProcessor.PreProcess(
                tokens,
                config.ThrowExceptionOnError,
                config.DiagnosticFilter,
                config.PreProcessorMode,
                config.BasePath,
                config.IncludeResolver,
                config.Defines,
                out pragmas,
                out var ppDiags);
            diagnostics.AddRange(ppDiags);
        }

        public List<HLSLSyntaxNode> ParseTopLevelDeclarations()
        {
            List<HLSLSyntaxNode> result = new List<HLSLSyntaxNode>();

            while (LoopShouldContinue())
            {
                result.Add(ParseTopLevelDeclaration());
            }

            return result;
        }

        public HLSLSyntaxNode ParseTopLevelDeclaration()
        {
            switch (Peek().Kind)
            {
                case TokenKind.NamespaceKeyword:
                    return ParseNamespace();

                case TokenKind.CBufferKeyword:
                case TokenKind.TBufferKeyword:
                    return ParseConstantBuffer();

                case TokenKind.StructKeyword:
                case TokenKind.ClassKeyword:
                    return ParseStructDefinitionOrDeclaration(new List<AttributeNode>());

                case TokenKind.InterfaceKeyword:
                  return ParseInterfaceDefinition(new List<AttributeNode>());

                case TokenKind.TypedefKeyword:
                    return ParseTypedef(new List<AttributeNode>());

                case TokenKind.Technique10Keyword:
                case TokenKind.Technique11Keyword:
                case TokenKind.TechniqueKeyword:
                    return ParseTechnique();

                case TokenKind.SemiToken:
                    var semiTok = Advance();
                    return new EmptyStatementNode(Range(semiTok, semiTok)) { Attributes = new List<AttributeNode>() };

                default:
                    if (IsNextPreProcessorDirective())
                    {
                        return ParsePreProcessorDirective(ParseTopLevelDeclaration);
                    }
                    else if (IsNextPossiblyFunctionDeclaration())
                    {
                        return ParseFunction();
                    }
                    else
                    {
                        return ParseVariableDeclarationStatement(new List<AttributeNode>());
                    }
            }
        }

        private bool IsNextCast()
        {
            int offset = 0;

            // Must have initial paren
            if (LookAhead(offset).Kind != TokenKind.OpenParenToken)
                return false;
            offset++;

            // If we mention a builtin or user defined type - it might be a cast
            if (HLSLSyntaxFacts.IsBuiltinType(LookAhead(offset).Kind) ||
                LookAhead(offset).Kind == TokenKind.ClassKeyword ||
                LookAhead(offset).Kind == TokenKind.StructKeyword ||
                LookAhead(offset).Kind == TokenKind.InterfaceKeyword)
            {
                offset++;
            }
            // If there is an identifier
            else if (LookAhead(offset).Kind == TokenKind.IdentifierToken)
            {
                // Take as many qualifier sections as possible
                offset++;
                while (LookAhead(offset).Kind == TokenKind.ColonColonToken)
                {
                    offset++;
                    if (LookAhead(offset).Kind != TokenKind.IdentifierToken)
                    {
                        return false;
                    }
                    offset++;
                }
            }
            // If none of the above are true, can't be a cast
            else
            {
                return false;
            }

            // It could be a generic type
            if (LookAhead(offset).Kind == TokenKind.LessThanToken)
            {
                offset++;
                while (LookAhead(offset).Kind != TokenKind.GreaterThanToken)
                {
                    if (LookAhead(offset).Kind == TokenKind.InvalidToken)
                        return false;

                    offset++;
                }
                offset++;
            }

            // If we had an identifier, check if it is followed by an array type
            while (LookAhead(offset).Kind == TokenKind.OpenBracketToken)
            {
                // All arguments must be constants or identifiers
                offset++;
                if (LookAhead(offset).Kind != TokenKind.IntegerLiteralToken && LookAhead(offset).Kind != TokenKind.IdentifierToken)
                {
                    return false;
                }
                offset++;
                if (LookAhead(offset).Kind != TokenKind.CloseBracketToken)
                {
                    return false;
                }
                offset++;
            }

            // If we've reached this point, make sure the cast is closed
            if (LookAhead(offset).Kind != TokenKind.CloseParenToken)
                return false;

            // It might still be ambiguous, so check if the next token is allowed to follow a cast
            offset++;
            return HLSLSyntaxFacts.CanTokenComeAfterCast(LookAhead(offset).Kind);
        }

        private bool IsNextPossiblyFunctionDeclaration()
        {
            return Speculate(() =>
            {
                ParseMany0(TokenKind.OpenBracketToken, ParseAttribute);
                ParseDeclarationModifiers();
                ParseType(true);
                ParseUserDefinedNamedType();
                return Match(TokenKind.OpenParenToken);
            });
        }

        private new IdentifierNode ParseIdentifier()
        {
            string identifier = base.ParseIdentifier();
            return new IdentifierNode(new List<HLSLToken> { Previous() })
            {
                Identifier = identifier,
            };
        }

        public StatePropertyNode ParseStateProperty()
        {
            var firstTok = Peek();

            UserDefinedNamedTypeNode name;
            if (Match(TokenKind.TextureKeyword))
            {
                var nameTok = Advance();
                name = new NamedTypeNode(new List<HLSLToken> { nameTok }) 
                {
                    Name = new IdentifierNode(new List<HLSLToken> { nameTok })
                    { 
                        Identifier = "texture" 
                    } 
                };
            }
            else
            {
                name = ParseUserDefinedNamedType();
            }
            ArrayRankNode rank = null;
            if (Match(TokenKind.OpenBracketToken))
            {
                rank = ParseArrayRank();
            }

            ExpressionNode expr;
            Eat(TokenKind.EqualsToken);
            bool isReference = Match(TokenKind.LessThanToken);
            if (isReference)
            {
                Eat(TokenKind.LessThanToken);
                expr = ParseNamedExpression();
                if (Match(TokenKind.OpenBracketToken))
                {
                    Eat(TokenKind.OpenBracketToken);
                    var indexExpr = ParseExpression();
                    Eat(TokenKind.CloseBracketToken);
                    expr = new ElementAccessExpressionNode(Range(firstTok, Previous()))
                    {
                        Target = expr,
                        Index = indexExpr
                    };
                }
                Eat(TokenKind.GreaterThanToken);
            }
            else
            {
                expr = ParseExpression();
            }
            Eat(TokenKind.SemiToken);

            return new StatePropertyNode(Range(firstTok, Previous()))
            {
                Name = name,
                ArrayRank = rank,
                Value = expr,
                IsReference = isReference,
            };
        }

        public SamplerStateLiteralExpressionNode ParseSamplerStateLiteral()
        {
            var keywordTok = Eat(TokenKind.SamplerStateLegacyKeyword);
            Eat(TokenKind.OpenBraceToken);

            List<StatePropertyNode> states = new List<StatePropertyNode>();
            while (Match(TokenKind.IdentifierToken, TokenKind.TextureKeyword))
            {
                states.Add(ParseStateProperty());
            }

            Eat(TokenKind.CloseBraceToken);

            return new SamplerStateLiteralExpressionNode(Range(keywordTok, Previous()))
            {
                States = states
            };
        }

        public CompileExpressionNode ParseCompileExpression()
        {
            var keywordTok = Eat(TokenKind.CompileKeyword);
            var target = ParseIdentifier();

            var name = ParseNamedExpression();
            var param = ParseParameterList();
            var expr = new FunctionCallExpressionNode(Range(keywordTok, Previous())) { Name = name, Arguments = param };

            return new CompileExpressionNode(Range(keywordTok, Previous()))
            {
                Target = target,
                Invocation = expr
            };
        }

        internal ExpressionNode ParseExpression(int level = 0)
        {
            if (Match(TokenKind.SamplerStateLegacyKeyword))
            {
                return ParseSamplerStateLiteral();
            }

            return ParseBinaryExpression(level);
        }

        // https://en.cppreference.com/w/c/language/operator_precedence
        private List<(
            HashSet<TokenKind> operators,
            bool rightAssociative,
            Func<ExpressionNode, OperatorKind, ExpressionNode, ExpressionNode> ctor
        )> operatorGroups;

        private void InitOperatorGroups()
        {
            operatorGroups = new List<(HashSet<TokenKind> operators, bool rightAssociative, Func<ExpressionNode, OperatorKind, ExpressionNode, ExpressionNode> ctor)>
            {
                // Compound expression
                (new HashSet<TokenKind>() { TokenKind.CommaToken },
                false,
                (l, op, r) => new CompoundExpressionNode(Range(l.Tokens.FirstOrDefault(), r.Tokens.LastOrDefault())) { Left = l, Right = r }),

                // Assignment
                (new HashSet<TokenKind>() {
                    TokenKind.EqualsToken, TokenKind.PlusEqualsToken, TokenKind.MinusEqualsToken,
                    TokenKind.AsteriskEqualsToken, TokenKind.SlashEqualsToken, TokenKind.PercentEqualsToken,
                    TokenKind.LessThanLessThanEqualsToken, TokenKind.GreaterThanGreaterThanEqualsToken,
                    TokenKind.AmpersandEqualsToken, TokenKind.CaretEqualsToken, TokenKind.BarEqualsToken },
                true,
                (l, op, r) => new AssignmentExpressionNode(Range(l.Tokens.FirstOrDefault(), r.Tokens.LastOrDefault())) { Left = l, Operator = op, Right = r }),

                // Ternary
                (new HashSet<TokenKind>() { TokenKind.QuestionToken },
                true,
                (l, op, r) => throw new Exception("This should never happen. Please file a bug report.")),

                // LogicalOr
                (new HashSet<TokenKind>() { TokenKind.BarBarToken },
                false,
                (l, op, r) => new BinaryExpressionNode(Range(l.Tokens.FirstOrDefault(), r.Tokens.LastOrDefault())) { Left = l, Operator = op, Right = r }),

                // LogicalAnd
                (new HashSet<TokenKind>() { TokenKind.AmpersandAmpersandToken },
                false,
                (l, op, r) => new BinaryExpressionNode(Range(l.Tokens.FirstOrDefault(), r.Tokens.LastOrDefault())) { Left = l, Operator = op, Right = r }),

                // BitwiseOr
                (new HashSet<TokenKind>() { TokenKind.BarToken },
                false,
                (l, op, r) => new BinaryExpressionNode(Range(l.Tokens.FirstOrDefault(), r.Tokens.LastOrDefault())) { Left = l, Operator = op, Right = r }),

                // BitwiseXor
                (new HashSet<TokenKind>() { TokenKind.CaretToken },
                false,
                (l, op, r) => new BinaryExpressionNode(Range(l.Tokens.FirstOrDefault(), r.Tokens.LastOrDefault())) { Left = l, Operator = op, Right = r }),

                // BitwiseAnd
                (new HashSet<TokenKind>() { TokenKind.AmpersandToken },
                false,
                (l, op, r) => new BinaryExpressionNode(Range(l.Tokens.FirstOrDefault(), r.Tokens.LastOrDefault())) { Left = l, Operator = op, Right = r }),

                // Equality
                (new HashSet<TokenKind>() { TokenKind.EqualsEqualsToken, TokenKind.ExclamationEqualsToken },
                false,
                (l, op, r) => new BinaryExpressionNode(Range(l.Tokens.First(), r.Tokens.Last())) { Left = l, Operator = op, Right = r }),

                // Comparison
                (new HashSet<TokenKind>() { TokenKind.LessThanToken, TokenKind.LessThanEqualsToken, TokenKind.GreaterThanToken, TokenKind.GreaterThanEqualsToken },
                false,
                (l, op, r) => new BinaryExpressionNode(Range(l.Tokens.FirstOrDefault(), r.Tokens.LastOrDefault())) { Left = l, Operator = op, Right = r }),

                // BitShift
                (new HashSet<TokenKind>() { TokenKind.LessThanLessThanToken, TokenKind.GreaterThanGreaterThanToken },
                false,
                (l, op, r) => new BinaryExpressionNode(Range(l.Tokens.FirstOrDefault(), r.Tokens.LastOrDefault())) { Left = l, Operator = op, Right = r }),

                // AddSub
                (new HashSet<TokenKind>() { TokenKind.PlusToken, TokenKind.MinusToken },
                false,
                (l, op, r) => new BinaryExpressionNode(Range(l.Tokens.FirstOrDefault(), r.Tokens.LastOrDefault())) { Left = l, Operator = op, Right = r }),

                // MulDivMod
                (new HashSet<TokenKind>() { TokenKind.AsteriskToken, TokenKind.SlashToken, TokenKind.PercentToken },
                false,
                (l, op, r) => new BinaryExpressionNode(Range(l.Tokens.FirstOrDefault(), r.Tokens.LastOrDefault())) { Left = l, Operator = op, Right = r }),

                // Binds most tightly
            };
        }
        
        public ExpressionNode ParseBinaryExpression(int level = 0)
        {
            if (level >= operatorGroups.Count)
            {
                return ParsePrefixOrPostFixExpression();
            }

            ExpressionNode higher = ParseBinaryExpression(level + 1);

            // Ternary is a special case
            if (level == (int)OperatorPrecedence.Ternary)
            {
                if (Match(TokenKind.QuestionToken))
                {
                    Eat(TokenKind.QuestionToken);
                    var left = ParseExpression();
                    Eat(TokenKind.ColonToken);
                    var right = ParseExpression();
                    return new TernaryExpressionNode(Range(higher.Tokens.First(), right.Tokens.Last())) { Condition = higher, TrueCase = left, FalseCase = right };
                }
            }

            var group = operatorGroups[level];
            while (Match(tok => group.operators.Contains(tok.Kind)))
            {
                HLSLToken next = Advance();
                if (!HLSLSyntaxFacts.TryConvertToOperator(next.Kind, out OperatorKind op))
                {
                    Error("a valid operator", next);
                }

                higher = group.ctor(
                    higher,
                    op,
                    ParseBinaryExpression(group.rightAssociative ? level : level + 1));

                if (IsAtEnd())
                {
                    return higher;
                }
            }

            return higher;
        }

        public ExpressionNode ParsePrefixOrPostFixExpression()
        {
            var firstTok = Peek();
            ExpressionNode higher;
            switch (firstTok.Kind)
            {
                case TokenKind.PlusPlusToken:
                case TokenKind.MinusMinusToken:
                case TokenKind.PlusToken:
                case TokenKind.MinusToken:
                case TokenKind.NotToken:
                case TokenKind.TildeToken:
                    TokenKind opKind = Eat(HLSLSyntaxFacts.IsPrefixUnaryToken).Kind;
                    HLSLSyntaxFacts.TryConvertToOperator(opKind, out var op);
                    var unExpr = ParsePrefixOrPostFixExpression();
                    higher = new PrefixUnaryExpressionNode(Range(firstTok, Previous())) { Operator = op, Expression = unExpr };
                    break;

                case TokenKind.OpenParenToken when IsNextCast():
                    Eat(TokenKind.OpenParenToken);
                    var type = ParseType();
                    List<ArrayRankNode> arrayRanks = new List<ArrayRankNode>();
                    while (Match(TokenKind.OpenBracketToken))
                    {
                        arrayRanks.Add(ParseArrayRank());
                    }
                    Eat(TokenKind.CloseParenToken);
                    var castExpr = ParsePrefixOrPostFixExpression();
                    higher = new CastExpressionNode(Range(firstTok, Previous())) { Kind = type, Expression = castExpr, ArrayRanks = arrayRanks, IsFunctionLike = false };
                    break;

                case TokenKind.OpenParenToken:
                    Eat(TokenKind.OpenParenToken);
                    higher = ParseExpression();
                    Eat(TokenKind.CloseParenToken);
                    break;

                default:
                    // Special case for constructors of built-in types. Their target is not an expression, but a keyword.
                    if (Match(HLSLSyntaxFacts.IsMultiArityNumericConstructor))
                    {
                        var kind = ParseNumericType();
                        var ctorArgs = ParseParameterList();
                        higher = new NumericConstructorCallExpressionNode(Range(firstTok, Previous())) { Kind = kind, Arguments = ctorArgs };
                    }
                    // Special case for function style C-casts
                    else if (Match(HLSLSyntaxFacts.IsSingleArityNumericConstructor))
                    {
                        var kind = ParseNumericType();
                        Eat(TokenKind.OpenParenToken);
                        var castFrom = ParseExpression();
                        Eat(TokenKind.CloseParenToken);
                        higher = new CastExpressionNode(Range(firstTok, Previous())) { Kind = kind, Expression = castFrom, ArrayRanks = new List<ArrayRankNode>(), IsFunctionLike = true };
                    }
                    else
                    {
                        higher = ParseTerminalExpression();
                    }
                    break;
            }

            while (LoopShouldContinue())
            {
                switch (Peek().Kind)
                {
                    case TokenKind.PlusPlusToken:
                    case TokenKind.MinusMinusToken:
                        HLSLSyntaxFacts.TryConvertToOperator(Advance().Kind, out var incrOp);
                        higher = new PostfixUnaryExpressionNode(Range(firstTok, Previous())) { Expression = higher, Operator = incrOp };
                        break;

                    case TokenKind.OpenParenToken when higher is NamedExpressionNode target:
                        var funcArgs = ParseParameterList();
                        higher = new FunctionCallExpressionNode(Range(firstTok, Previous())) { Name = target, Arguments = funcArgs };
                        break;

                    case TokenKind.OpenBracketToken:
                        Eat(TokenKind.OpenBracketToken);
                        var indexArg = ParseExpression();
                        Eat(TokenKind.CloseBracketToken);
                        higher = new ElementAccessExpressionNode(Range(firstTok, Previous())) { Target = higher, Index = indexArg };
                        break;

                    case TokenKind.DotToken:
                        Eat(TokenKind.DotToken);
                        var identifier = ParseIdentifier();

                        if (Match(TokenKind.OpenParenToken))
                        {
                            var methodArgs = ParseParameterList();
                            higher = new MethodCallExpressionNode(Range(firstTok, Previous())) { Target = higher, Name = identifier, Arguments = methodArgs };
                        }
                        else
                        {
                            higher = new FieldAccessExpressionNode(Range(firstTok, Previous())) { Target = higher, Name = identifier };
                        }
                        break;

                    default:
                        return higher;
                }
            }

            return higher;
        }

        public NamedExpressionNode ParseNamedExpression()
        {
            var firstTok = Peek();
            var identifier = ParseIdentifier();
            
            var name = new IdentifierExpressionNode(Range(firstTok, firstTok)) { Name = identifier };

            if (Match(TokenKind.ColonColonToken))
            {
                Eat(TokenKind.ColonColonToken);

                var nextNameExpr = ParseNamedExpression();
                return new QualifiedIdentifierExpressionNode(Range(firstTok, Previous())) { Left = name, Right = nextNameExpr };
            }
            else
            {
                return name;
            }
        }

        public ArrayInitializerExpressionNode ParseArrayInitializer()
        {
            var openTok = Eat(TokenKind.OpenBraceToken);
            var exprs = ParseSeparatedList0(
                TokenKind.CloseBraceToken,
                TokenKind.CommaToken,
                () => ParseExpression((int)OperatorPrecedence.Compound + 1),
                true);
            var closeTok = Eat(TokenKind.CloseBraceToken);
            return new ArrayInitializerExpressionNode(Range(openTok, closeTok)) { Elements = exprs };
        }

        public LiteralExpressionNode ParseLiteralExpression()
        {
            HLSLToken next = Peek();
            string lexeme = HLSLSyntaxFacts.IdentifierOrKeywordToString(next);

            if (!HLSLSyntaxFacts.TryConvertLiteralKind(next.Kind, out var literalKind))
            {
                Error("a valid literal expression", next);
            }
            Advance();

            return new LiteralExpressionNode(Range(next, next)) { Lexeme = lexeme, Kind = literalKind };
        }

        public ExpressionNode ParseTerminalExpression()
        {
            if (Match(TokenKind.IdentifierToken))
            {
                return ParseNamedExpression();
            }

            else if (Match(TokenKind.CompileKeyword))
            {
                return ParseCompileExpression();
            }

            else if (Match(TokenKind.OpenBraceToken))
            {
                return ParseArrayInitializer();
            }

            return ParseLiteralExpression();
        }

        public List<ExpressionNode> ParseParameterList()
        {
            Eat(TokenKind.OpenParenToken);
            List<ExpressionNode> exprs = ParseSeparatedList0(
                TokenKind.CloseParenToken,
                TokenKind.CommaToken,
                () => ParseExpression((int)OperatorPrecedence.Compound + 1));
            Eat(TokenKind.CloseParenToken);
            return exprs;
        }

        public AttributeNode ParseAttribute()
        {
            var openTok = Eat(TokenKind.OpenBracketToken);

            var identifier = ParseIdentifier();

            List<LiteralExpressionNode> args = new List<LiteralExpressionNode>();
            if (Match(TokenKind.OpenParenToken))
            {
                Eat(TokenKind.OpenParenToken);

                args = ParseSeparatedList1(TokenKind.CommaToken, ParseLiteralExpression);

                Eat(TokenKind.CloseParenToken);
            }

            var closeTok = Eat(TokenKind.CloseBracketToken);

            return new AttributeNode(Range(openTok, closeTok))
            {
                Name = identifier,
                Arguments = args
            };
        }

        public FunctionNode ParseFunction()
        {
            var firstTok = Peek();
            List<AttributeNode> attributes = ParseMany0(TokenKind.OpenBracketToken, ParseAttribute);

            var modifiers = ParseDeclarationModifiers();
            TypeNode returnType = ParseType(true);

            UserDefinedNamedTypeNode name = ParseUserDefinedNamedType();

            Eat(TokenKind.OpenParenToken);
            List<FormalParameterNode> parameters = ParseSeparatedList0(TokenKind.CloseParenToken, TokenKind.CommaToken, ParseFormalParameter);
            Eat(TokenKind.CloseParenToken);

            SemanticNode semantic = ParseOptional(TokenKind.ColonToken, ParseSemantic);

            // Function prototype
            if (Match(TokenKind.SemiToken))
            {
                var semiTok = Eat(TokenKind.SemiToken);
                return new FunctionDeclarationNode(Range(firstTok, semiTok))
                {
                    Attributes = attributes,
                    Modifiers = modifiers,
                    ReturnType = returnType,
                    Name = name,
                    Parameters = parameters,
                    Semantic = semantic
                };
            }
            RecoverTo(TokenKind.SemiToken, TokenKind.CloseBraceToken);

            // Otherwise, full function
            BlockNode body = ParseBlock(new List<AttributeNode>());
            return new FunctionDefinitionNode(Range(firstTok, Previous()))
            {
                Attributes = attributes,
                Modifiers = modifiers,
                ReturnType = returnType,
                Name = name,
                Parameters = parameters,
                Semantic = semantic,
                Body = body
            };
        }

        public StatementNode ParseStructDefinitionOrDeclaration(List<AttributeNode> attributes)
        {
            var firstTok = attributes.FirstOrDefault()?.Tokens.FirstOrDefault() ?? Peek();
            var modifiers = ParseDeclarationModifiers();
            StructTypeNode structType = ParseStructType();

            // This is a definition - no instance
            if (Match(TokenKind.SemiToken))
            {
                if (modifiers.Count > 0)
                {
                    Error(DiagnosticFlags.SyntaxError, $"Struct definitions cannot have modifiers, found '{string.Join(", ", modifiers)}'.");
                }

                var semiTok = Eat(TokenKind.SemiToken);
                RecoverTo(TokenKind.SemiToken);
                return new StructDefinitionNode(Range(firstTok, semiTok))
                {
                    Attributes = attributes,
                    StructType = structType,
                };
            }
            // This is a declaration - making a type and an instance
            else
            {
                List<VariableDeclaratorNode> variables = ParseSeparatedList1(TokenKind.CommaToken, () => ParseVariableDeclarator());
                var semiTok = Eat(TokenKind.SemiToken);
                RecoverTo(TokenKind.SemiToken);
                return new VariableDeclarationStatementNode(Range(firstTok, semiTok))
                {
                    Modifiers = modifiers,
                    Kind = structType,
                    Declarators = variables,
                    Attributes = attributes,
                };
            }
        }

        public InterfaceDefinitionNode ParseInterfaceDefinition(List<AttributeNode> attributes)
        {
            var keywordTok = Eat(TokenKind.InterfaceKeyword);
            var firstTok = attributes.FirstOrDefault()?.Tokens.FirstOrDefault() ?? keywordTok;
            var name = ParseUserDefinedNamedType();

            Eat(TokenKind.OpenBraceToken);

            List<FunctionNode> funs = ParseMany0(
                () => !Match(TokenKind.CloseBraceToken),
                ParseFunction);

            List<FunctionDeclarationNode> decls = new List<FunctionDeclarationNode>();
            foreach (var function in funs)
            {
                if (function is FunctionDeclarationNode decl)
                {
                    decls.Add(decl);
                }
                else
                {
                    Error(DiagnosticFlags.SemanticError, "Expected only function declarations/prototypes in interface type, but found a function body.");
                }
            }

            Eat(TokenKind.CloseBraceToken);
            var semiTok = Eat(TokenKind.SemiToken);
            RecoverTo(TokenKind.SemiToken);

            return new InterfaceDefinitionNode(Range(keywordTok, semiTok))
            {
                Attributes = attributes,
                Name = name,
                Functions = decls,
            };
        }

        public NamespaceNode ParseNamespace()
        {
            var keywordTok = Eat(TokenKind.NamespaceKeyword);
            var name = ParseUserDefinedNamedType();
            Eat(TokenKind.OpenBraceToken);
            var decls = ParseMany0(() => !Match(TokenKind.CloseBraceToken), ParseTopLevelDeclaration);
            var closeTok = Eat(TokenKind.CloseBraceToken);
            RecoverTo(TokenKind.CloseBraceToken);

            return new NamespaceNode(Range(keywordTok, closeTok))
            {
                Name = name,
                Declarations = decls,
            };
        }

        public ConstantBufferNode ParseConstantBuffer()
        {
            var buffer = Eat(TokenKind.CBufferKeyword, TokenKind.TBufferKeyword);
            var name = ParseUserDefinedNamedType();

            RegisterLocationNode reg = null;
            if (Match(TokenKind.ColonToken))
            {
                reg = ParseRegisterLocation();
            }

            Eat(TokenKind.OpenBraceToken);

            List<VariableDeclarationStatementNode> decls = ParseMany0(
                () => !Match(TokenKind.CloseBraceToken),
                () => ParseVariableDeclarationStatement(new List<AttributeNode>()));

            Eat(TokenKind.CloseBraceToken);
            if (Match(TokenKind.SemiToken))
            {
                Eat(TokenKind.SemiToken);
            }
            RecoverTo(TokenKind.SemiToken, TokenKind.CloseBraceToken);

            return new ConstantBufferNode(Range(buffer, Previous()))
            {
                Name = name,
                RegisterLocation = reg,
                Declarations = decls,
                IsTextureBuffer = buffer.Kind == TokenKind.TBufferKeyword
            };
        }

        public TypedefNode ParseTypedef(List<AttributeNode> attributes)
        {
            var keywordTok = Eat(TokenKind.TypedefKeyword);
            var firstTok = attributes.FirstOrDefault()?.Tokens.FirstOrDefault() ?? keywordTok;

            bool isConst = false;
            if (Match(TokenKind.ConstKeyword))
            {
                Eat(TokenKind.ConstKeyword);
                isConst = true;
            }

            var type = ParseType();

            var names = ParseSeparatedList1(TokenKind.CommaToken, ParseUserDefinedNamedType);

            var semiTok = Eat(TokenKind.SemiToken);
            RecoverTo(TokenKind.SemiToken);

            return new TypedefNode(Range(firstTok, semiTok))
            {
                Attributes = attributes,
                FromType = type,
                ToNames = names,
                IsConst = isConst,
            };
        }

        public TypeNode ParseType(bool allowVoid = false)
        {
            if (HLSLSyntaxFacts.TryConvertToPredefinedObjectType(Peek(), out PredefinedObjectType predefinedType))
            {
                var firstTok = Advance();

                List<TypeNode> args = new List<TypeNode>();
                if (Match(TokenKind.LessThanToken))
                {
                    Eat(TokenKind.LessThanToken);
                    args = ParseSeparatedList0(
                        TokenKind.GreaterThanToken,
                        TokenKind.CommaToken,
                        ParseTemplateArgumentType);
                    Eat(TokenKind.GreaterThanToken);
                }

                return new PredefinedObjectTypeNode(Range(firstTok, Previous()))
                {
                    Kind = predefinedType,
                    TemplateArguments = args,
                };
            }

            if (Match(TokenKind.IdentifierToken))
            {
                return ParseUserDefinedNamedType();
            }

            if (Match(TokenKind.StructKeyword, TokenKind.ClassKeyword))
            {
                return ParseStructType();
            }

            return ParseNumericType(allowVoid);
        }

        public StructTypeNode ParseStructType()
        {
            var keywordTok = Eat(TokenKind.StructKeyword, TokenKind.ClassKeyword);
            bool isClass = keywordTok.Kind == TokenKind.ClassKeyword;
            var name = ParseOptional(TokenKind.IdentifierToken, ParseUserDefinedNamedType);

            // base list
            List<UserDefinedNamedTypeNode> baseList = new List<UserDefinedNamedTypeNode>();
            if (Match(TokenKind.ColonToken))
            {
                Eat(TokenKind.ColonToken);

                baseList = ParseSeparatedList1(TokenKind.CommaToken, ParseUserDefinedNamedType);
            }

            Eat(TokenKind.OpenBraceToken);

            List<VariableDeclarationStatementNode> decls = new List<VariableDeclarationStatementNode>();
            List<FunctionNode> methods = new List<FunctionNode>();
            while (LoopShouldContinue() && !Match(TokenKind.CloseBraceToken))
            {
                if (IsNextPossiblyFunctionDeclaration())
                {
                    methods.Add(ParseFunction());
                }
                else
                {
                    decls.Add(ParseVariableDeclarationStatement(new List<AttributeNode>()));
                }
            }

            var closeTok = Eat(TokenKind.CloseBraceToken);

            return new StructTypeNode(Range(keywordTok, closeTok))
            {
                Name = name,
                Inherits = baseList,
                Fields = decls,
                Methods = methods,
                IsClass = isClass,
            };
        }

        public NumericTypeNode ParseNumericType(bool allowVoid = false)
        {
            HLSLToken typeToken = Advance();
            if (HLSLSyntaxFacts.TryConvertToScalarType(typeToken.Kind, out ScalarType scalarType))
            {
                if (scalarType == ScalarType.Void && !allowVoid)
                    Error("a type that isn't 'void'", typeToken);
                return new ScalarTypeNode(Range(typeToken, typeToken)) { Kind = scalarType };
            }

            if (HLSLSyntaxFacts.TryConvertToMonomorphicVectorType(typeToken.Kind, out ScalarType vectorType, out int dimension))
            {
                if (typeToken.Kind == TokenKind.VectorKeyword && Match(TokenKind.LessThanToken))
                {
                    Eat(TokenKind.LessThanToken);
                    var genVectorType = ParseNumericType().Kind;
                    Eat(TokenKind.CommaToken);
                    var genDim = ParseExpression((int)OperatorPrecedence.Comparison + 1);
                    var closeTok = Eat(TokenKind.GreaterThanToken);
                    return new GenericVectorTypeNode(Range(typeToken, closeTok)) { Kind = genVectorType, Dimension = genDim };
                }

                return new VectorTypeNode(Range(typeToken, typeToken)) { Kind = vectorType, Dimension = dimension };
            }

            if (HLSLSyntaxFacts.TryConvertToMonomorphicMatrixType(typeToken.Kind, out ScalarType matrixType, out int dimX, out int dimY))
            {
                if (typeToken.Kind == TokenKind.MatrixKeyword && Match(TokenKind.LessThanToken))
                {
                    Eat(TokenKind.LessThanToken);
                    var genMatrixType = ParseNumericType().Kind;
                    Eat(TokenKind.CommaToken);
                    var genDimX = ParseExpression((int)OperatorPrecedence.Comparison + 1);
                    Eat(TokenKind.CommaToken);
                    var genDimY = ParseExpression((int)OperatorPrecedence.Comparison + 1);
                    var closeTok = Eat(TokenKind.GreaterThanToken);
                    return new GenericMatrixTypeNode(Range(typeToken, closeTok)) { Kind = genMatrixType, FirstDimension = genDimX, SecondDimension = genDimY };
                }

                return new MatrixTypeNode(Range(typeToken, typeToken)) { Kind = matrixType, FirstDimension = dimX, SecondDimension = dimY };
            }

            if (typeToken.Kind == TokenKind.UnsignedKeyword)
            {
                var type = ParseNumericType();
                type.Kind = HLSLSyntaxFacts.MakeUnsigned(type.Kind);
                return type;
            }

            if (typeToken.Kind == TokenKind.UNormKeyword || typeToken.Kind == TokenKind.SNormKeyword)
            {
                var type = ParseNumericType();
                type.Kind = HLSLSyntaxFacts.MakeNormed(type.Kind, typeToken.Kind);
                return type;
            }

            Error("a valid type", typeToken);
            return new ScalarTypeNode(Range(typeToken, typeToken)) { Kind = ScalarType.Void };
        }

        public UserDefinedNamedTypeNode ParseUserDefinedNamedType()
        {
            var firstTok = Peek();
            var identifier = ParseIdentifier();
            var name = new NamedTypeNode(Range(firstTok, firstTok)) { Name = identifier };

            if (Match(TokenKind.ColonColonToken))
            {
                Eat(TokenKind.ColonColonToken);
                var right = ParseUserDefinedNamedType();
                return new QualifiedNamedTypeNode(Range(firstTok, Previous())) { Left = name, Right = right };
            }
            else
            {
                return name;
            }
        }

        public TypeNode ParseTemplateArgumentType()
        {
            if (Match(TokenKind.CharacterLiteralToken, TokenKind.FloatLiteralToken, TokenKind.IntegerLiteralToken, TokenKind.StringLiteralToken))
            {
                var expression = ParseLiteralExpression();
                return new LiteralTemplateArgumentType(Range(Previous(), Previous())) { Literal = expression };
            }

            return ParseType();
        }

        public FormalParameterNode ParseFormalParameter()
        {
            var firstTok = Peek();
            List<AttributeNode> attributes = ParseMany0(TokenKind.OpenBracketToken, ParseAttribute);
            var modifiers = ParseParameterModifiers();
            TypeNode type = ParseType();
            VariableDeclaratorNode declarator = ParseVariableDeclarator(false);

            return new FormalParameterNode(Range(firstTok, Previous()))
            {
                Attributes = attributes,
                Modifiers = modifiers,
                ParamType = type,
                Declarator = declarator
            };
        }

        public ArrayRankNode ParseArrayRank()
        {
            var openTok = Eat(TokenKind.OpenBracketToken);
            ExpressionNode expr = null;
            if (!Match(TokenKind.CloseBracketToken))
            {
                expr = ParseExpression();
            }
            var closeTok = Eat(TokenKind.CloseBracketToken);
            return new ArrayRankNode(Range(openTok, closeTok)) { Dimension = expr };
        }

        public VariableDeclaratorNode ParseVariableDeclarator(bool allowCompoundInitializer = true)
        {
            var firstTok = Peek();
            var identifier = ParseIdentifier();

            List<ArrayRankNode> arrayRanks = new List<ArrayRankNode>();
            while (Match(TokenKind.OpenBracketToken))
            {
                arrayRanks.Add(ParseArrayRank());
            }

            List<VariableDeclaratorQualifierNode> qualifiers = ParseMany0(TokenKind.ColonToken, ParseVariableDeclaratorQualifierNode);

            List<VariableDeclarationStatementNode> annotations = new List<VariableDeclarationStatementNode>();
            if (Match(TokenKind.LessThanToken))
            {
                Eat(TokenKind.LessThanToken);
                annotations = ParseMany0(() => !Match(TokenKind.GreaterThanToken), () => ParseVariableDeclarationStatement(new List<AttributeNode>()));
                Eat(TokenKind.GreaterThanToken);
            }

            InitializerNode initializer = null;
            if (Match(TokenKind.EqualsToken))
            {
                initializer = ParseValueInitializer(allowCompoundInitializer);
            }
            else if (Match(TokenKind.OpenBraceToken))
            {
                initializer = ParseStateInitializerOrArray();
            }

            return new VariableDeclaratorNode(Range(firstTok, Previous()))
            {
                Name = identifier,
                ArrayRanks = arrayRanks,
                Qualifiers = qualifiers,
                Annotations = annotations,
                Initializer = initializer,
            };
        }

        public ValueInitializerNode ParseValueInitializer(bool allowCompoundInitializer = true)
        {
            var eqTok = Eat(TokenKind.EqualsToken);
            var expr = ParseExpression(allowCompoundInitializer ? 0 : (int)OperatorPrecedence.Compound + 1);
            return new ValueInitializerNode(Range(eqTok, Previous())) { Expression = expr };
        }

        public StateInitializerNode ParseStateInitializer()
        {
            var openTok = Eat(TokenKind.OpenBraceToken);
            List<StatePropertyNode> states = new List<StatePropertyNode>();
            while (Match(TokenKind.IdentifierToken))
            {
                states.Add(ParseStateProperty());
            }
            var closeTok = Eat(TokenKind.CloseBraceToken);
            return new StateInitializerNode(Range(openTok, closeTok)) { States = states };
        }

        public InitializerNode ParseStateInitializerOrArray()
        {
            if (LookAhead().Kind == TokenKind.OpenBraceToken)
            {
                var openTok = Eat(TokenKind.OpenBraceToken);
                List<StateInitializerNode> initializers = ParseSeparatedList0(TokenKind.CloseBraceToken, TokenKind.CommaToken, ParseStateInitializer);
                var closeTok = Eat(TokenKind.CloseBraceToken);
                return new StateArrayInitializerNode(Range(openTok, closeTok)) { Initializers = initializers };
            }
            else
            {
                return ParseStateInitializer();
            }
        }

        public VariableDeclaratorQualifierNode ParseVariableDeclaratorQualifierNode()
        {
            switch (LookAhead().Kind)
            {
                case TokenKind.IdentifierToken: return ParseSemantic();
                case TokenKind.RegisterKeyword: return ParseRegisterLocation();
                case TokenKind.PackoffsetKeyword: return ParsePackoffsetNode();
                default: return ParseSemantic();
            }
        }

        public SemanticNode ParseSemantic()
        {
            var colTok = Eat(TokenKind.ColonToken);
            var identifier = ParseIdentifier();
            return new SemanticNode(Range(colTok, Previous())) { Name = identifier };
        }

        public RegisterLocationNode ParseRegisterLocation()
        {
            var colTok = Eat(TokenKind.ColonToken);
            Eat(TokenKind.RegisterKeyword);
            Eat(TokenKind.OpenParenToken);

            string location = base.ParseIdentifier();
            RegisterKind kind = default;
            int index = 0;
            switch (location.ToLower().FirstOrDefault())
            {
                case 't': kind = RegisterKind.Texture; break;
                case 'b': kind = RegisterKind.Buffer; break;
                case 'u': kind = RegisterKind.UAV; break;
                case 's': kind = RegisterKind.Sampler; break;
                default: break;
            }
            string indexLexeme = string.Concat(location.SkipWhile(x => !char.IsNumber(x)));
            if (!int.TryParse(indexLexeme, out index))
            {
                Error(DiagnosticFlags.SemanticError, $"Expected a valid register location, but got '{location}'.");
            }

            int? spaceIndex = null;
            if (Match(TokenKind.CommaToken))
            {
                Eat(TokenKind.CommaToken);

                string space = base.ParseIdentifier();
                string spaceLexeme = string.Concat(space.SkipWhile(x => !char.IsNumber(x)));
                if (int.TryParse(spaceLexeme, out int parsedIndex))
                {
                    spaceIndex = parsedIndex;
                }
                else
                {
                    Error(DiagnosticFlags.SemanticError, $"Expected a valid space, but got '{location}'.");
                }
            }

            var closeTok = Eat(TokenKind.CloseParenToken);

            return new RegisterLocationNode(Range(colTok, closeTok))
            {
                Kind = kind,
                Location = index,
                Space = spaceIndex,
            };
        }

        public PackoffsetNode ParsePackoffsetNode()
        {
            var colTok = Eat(TokenKind.ColonToken);
            Eat(TokenKind.PackoffsetKeyword);
            Eat(TokenKind.OpenParenToken);

            string location = base.ParseIdentifier();
            int index = 0;
            string indexLexeme = string.Concat(location.SkipWhile(x => !char.IsNumber(x)));
            if (!int.TryParse(indexLexeme, out index))
            {
                Error(DiagnosticFlags.SemanticError, $"Expected a valid packoffset location, but got '{location}'.");
            }

            string swizzle = null;
            if (Match(TokenKind.DotToken))
            {
                Eat(TokenKind.DotToken);
                swizzle = base.ParseIdentifier();
            }

            var closeTok = Eat(TokenKind.CloseParenToken);

            return new PackoffsetNode(Range(colTok, closeTok))
            {
                Location = index,
                Swizzle = swizzle,
            };
        }

        public BlockNode ParseBlock(List<AttributeNode> attributes)
        {
            var openTok = Eat(TokenKind.OpenBraceToken);
            var firstTok = attributes.FirstOrDefault()?.Tokens.FirstOrDefault() ?? openTok;
            List<StatementNode> statements = ParseMany0(() => !Match(TokenKind.CloseBraceToken), ParseStatement);
            var closeTok = Eat(TokenKind.CloseBraceToken);
            RecoverTo(TokenKind.CloseBraceToken);

            return new BlockNode(Range(firstTok, closeTok))
            {
                Attributes = attributes,
                Statements = statements,
            };
        }

        private bool IsVariableDeclarationStatement(TokenKind nextKind)
        {
            if (HLSLSyntaxFacts.IsModifier(nextKind))
                return true;
            if ((HLSLSyntaxFacts.IsBuiltinType(nextKind) || nextKind == TokenKind.IdentifierToken))
            {
                return Speculate(() =>
                {
                    ParseType();
                    return Match(TokenKind.IdentifierToken);
                });
            }
            return false;
        }

        public StatementNode ParseStatement()
        {
            var firstTok = Peek();
            List<AttributeNode> attributes = ParseMany0(TokenKind.OpenBracketToken, ParseAttribute);

            HLSLToken next = Peek();
            switch (next.Kind)
            {
                case TokenKind.SemiToken:
                    var emptySemiTok = Advance();
                    return new EmptyStatementNode(Range(firstTok, emptySemiTok)) { Attributes = attributes };

                case TokenKind.OpenBraceToken:
                    return ParseBlock(attributes);

                case TokenKind.ReturnKeyword:
                    Advance();
                    ExpressionNode returnExpr = null;
                    if (!Match(TokenKind.SemiToken))
                    {
                        returnExpr = ParseExpression();
                    }
                    var returnSemiTok = Eat(TokenKind.SemiToken);
                    RecoverTo(TokenKind.SemiToken);
                    return new ReturnStatementNode(Range(firstTok, returnSemiTok)) { Attributes = attributes, Expression = returnExpr };

                case TokenKind.ForKeyword:
                    return ParseForStatement(attributes);

                case TokenKind.WhileKeyword:
                    return ParseWhileStatement(attributes);

                case TokenKind.DoKeyword:
                    return ParseDoWhileStatement(attributes);

                case TokenKind.IfKeyword:
                    return ParseIfStatement(attributes);

                case TokenKind.SwitchKeyword:
                    return ParseSwitchStatement(attributes);

                case TokenKind.TypedefKeyword:
                    return ParseTypedef(attributes);

                case TokenKind.BreakKeyword:
                    Advance();
                    var breakTok = Eat(TokenKind.SemiToken);
                    RecoverTo(TokenKind.SemiToken);
                    return new BreakStatementNode(Range(firstTok, breakTok)) { Attributes = attributes };

                case TokenKind.ContinueKeyword:
                    Advance();
                    var continueTok = Eat(TokenKind.SemiToken);
                    RecoverTo(TokenKind.SemiToken);
                    return new ContinueStatementNode(Range(firstTok, continueTok)) { Attributes = attributes };

                case TokenKind.DiscardKeyword:
                    Advance();
                    var discardTok = Eat(TokenKind.SemiToken);
                    RecoverTo(TokenKind.SemiToken);
                    return new DiscardStatementNode(Range(firstTok, discardTok)) { Attributes = attributes };

                case TokenKind.InterfaceKeyword:
                    return ParseInterfaceDefinition(attributes);

                case TokenKind.StructKeyword:
                case TokenKind.ClassKeyword:
                    return ParseStructDefinitionOrDeclaration(attributes);

                case TokenKind kind when IsVariableDeclarationStatement(kind):
                    return ParseVariableDeclarationStatement(attributes);

                case var _ when IsNextPreProcessorDirective():
                    return ParsePreProcessorDirective(ParseStatement);

                default:
                    ExpressionNode expr = ParseExpression();
                    var exprSemiTok = Eat(TokenKind.SemiToken);
                    RecoverTo(TokenKind.SemiToken);
                    return new ExpressionStatementNode(Range(firstTok, exprSemiTok)) { Attributes = attributes, Expression = expr };
            }
        }

        public List<BindingModifier> ParseParameterModifiers()
        {
            List<BindingModifier> modifiers = new List<BindingModifier>();
            while (HLSLSyntaxFacts.TryConvertToParameterModifier(Peek(), out var modifier))
            {
                Advance();
                modifiers.Add(modifier);
            }
            return modifiers;
        }

        public List<BindingModifier> ParseDeclarationModifiers()
        {
            List<BindingModifier> modifiers = new List<BindingModifier>();
            while (HLSLSyntaxFacts.TryConvertToDeclarationModifier(Peek(), out var modifier))
            {
                Advance();
                modifiers.Add(modifier);
            }
            return modifiers;
        }

        public VariableDeclarationStatementNode ParseVariableDeclarationStatement(List<AttributeNode> attributes)
        {
            var firstTok = attributes.FirstOrDefault()?.Tokens.FirstOrDefault() ?? Peek();
            var modifiers = ParseDeclarationModifiers();
            TypeNode kind = ParseType();
            List<VariableDeclaratorNode> variables = ParseSeparatedList1(TokenKind.CommaToken, () => ParseVariableDeclarator());
            var semiTok = Eat(TokenKind.SemiToken);
            RecoverTo(TokenKind.SemiToken);

            return new VariableDeclarationStatementNode(Range(firstTok, semiTok))
            {
                Modifiers = modifiers,
                Kind = kind,
                Declarators = variables,
                Attributes = attributes,
            };
        }

        public ForStatementNode ParseForStatement(List<AttributeNode> attributes)
        {
            var keywordTok = Eat(TokenKind.ForKeyword);
            var firstTok = attributes.FirstOrDefault()?.Tokens.FirstOrDefault() ?? keywordTok;
            Eat(TokenKind.OpenParenToken);

            VariableDeclarationStatementNode decl = null;
            ExpressionNode initializer = null;
            if (!Match(TokenKind.SemiToken))
            {
                if (!TryParse(() => ParseVariableDeclarationStatement(new List<AttributeNode>()), out decl))
                {
                    if (TryParse(() => ParseExpression(), out initializer))
                    {
                        Eat(TokenKind.SemiToken);
                    }
                    else
                    {
                        Error("an expression or declaration in first section of for loop", Peek());
                    }
                }
            }
            else
            {
                Eat(TokenKind.SemiToken);
            }

            ExpressionNode cond = null;
            if (!Match(TokenKind.SemiToken))
            {
                cond = ParseExpression();
            }
            Eat(TokenKind.SemiToken);

            ExpressionNode incrementor = null;
            if (!Match(TokenKind.SemiToken))
            {
                incrementor = ParseExpression();
            }
            Eat(TokenKind.CloseParenToken);

            var body = ParseStatement();
            RecoverTo(TokenKind.SemiToken, TokenKind.CloseBraceToken);

            return new ForStatementNode(Range(firstTok, Previous()))
            {
                Declaration = decl,
                Condition = cond,
                Increment = incrementor,
                Body = body,
                Attributes = attributes,
            };
        }

        public WhileStatementNode ParseWhileStatement(List<AttributeNode> attributes)
        {
            var keywordTok = Eat(TokenKind.WhileKeyword);
            var firstTok = attributes.FirstOrDefault()?.Tokens.FirstOrDefault() ?? keywordTok;
            Eat(TokenKind.OpenParenToken);

            var cond = ParseExpression();

            Eat(TokenKind.CloseParenToken);

            var body = ParseStatement();
            RecoverTo(TokenKind.SemiToken, TokenKind.CloseBraceToken);

            return new WhileStatementNode(Range(firstTok, Previous()))
            {
                Attributes = attributes,
                Condition = cond,
                Body = body,
            };
        }

        public DoWhileStatementNode ParseDoWhileStatement(List<AttributeNode> attributes)
        {
            var keywordTok = Eat(TokenKind.DoKeyword);
            var firstTok = attributes.FirstOrDefault()?.Tokens.FirstOrDefault() ?? keywordTok;
            var body = ParseStatement();

            Eat(TokenKind.WhileKeyword);
            Eat(TokenKind.OpenParenToken);

            var cond = ParseExpression();

            Eat(TokenKind.CloseParenToken);
            var semiTok = Eat(TokenKind.SemiToken);
            RecoverTo(TokenKind.SemiToken);

            return new DoWhileStatementNode(Range(firstTok, semiTok))
            {
                Attributes = attributes,
                Body = body,
                Condition = cond,
            };
        }

        public IfStatementNode ParseIfStatement(List<AttributeNode> attributes)
        {
            var keywordTok = Eat(TokenKind.IfKeyword);
            var firstTok = attributes.FirstOrDefault()?.Tokens.FirstOrDefault() ?? keywordTok;
            Eat(TokenKind.OpenParenToken);

            var cond = ParseExpression();

            Eat(TokenKind.CloseParenToken);

            var body = ParseStatement();

            StatementNode elseClause = null;
            if (Match(TokenKind.ElseKeyword))
            {
                Eat(TokenKind.ElseKeyword);
                elseClause = ParseStatement();
            }
            RecoverTo(TokenKind.SemiToken, TokenKind.CloseBraceToken);

            return new IfStatementNode(Range(firstTok, Previous()))
            {
                Attributes = attributes,
                Condition = cond,
                Body = body,
                ElseClause = elseClause,
            };
        }

        public SwitchStatementNode ParseSwitchStatement(List<AttributeNode> attributes)
        {
            var keywordTok = Eat(TokenKind.SwitchKeyword);
            var firstTok = attributes.FirstOrDefault()?.Tokens.FirstOrDefault() ?? keywordTok;
            Eat(TokenKind.OpenParenToken);
            var expr = ParseExpression();
            Eat(TokenKind.CloseParenToken);
            Eat(TokenKind.OpenBraceToken);

            List<SwitchClauseNode> switchClauses = new List<SwitchClauseNode>();
            while (Match(TokenKind.CaseKeyword, TokenKind.DefaultKeyword))
            {
                var clauseStartTok = Peek();
                List<SwitchLabelNode> switchLabels = new List<SwitchLabelNode>();
                while (Match(TokenKind.CaseKeyword, TokenKind.DefaultKeyword))
                {
                    if (Match(TokenKind.CaseKeyword))
                    {
                        var caseTok = Eat(TokenKind.CaseKeyword);
                        var caseExpr = ParseExpression();
                        Eat(TokenKind.ColonToken);
                        switchLabels.Add(new SwitchCaseLabelNode(Range(caseTok, Previous())) { Value = caseExpr });
                    }
                    else
                    {
                        var defaultTok = Eat(TokenKind.DefaultKeyword);
                        Eat(TokenKind.ColonToken);
                        switchLabels.Add(new SwitchDefaultLabelNode(Range(defaultTok, Previous())) { });
                    }
                }

                List<StatementNode> statements = ParseMany0(
                    () => !Match(TokenKind.CloseBraceToken, TokenKind.CaseKeyword, TokenKind.DefaultKeyword),
                    ParseStatement);
                switchClauses.Add(new SwitchClauseNode(Range(clauseStartTok, Previous())) { Labels = switchLabels, Statements = statements });
            }

            var closeTok = Eat(TokenKind.CloseBraceToken);
            RecoverTo(TokenKind.CloseBraceToken);

            return new SwitchStatementNode(Range(firstTok, closeTok))
            {
                Attributes = attributes,
                Expression = expr,
                Clauses = switchClauses,
            };
        }

        public TechniqueNode ParseTechnique()
        {
            var keywordTok = Eat(TokenKind.TechniqueKeyword, TokenKind.Technique10Keyword, TokenKind.Technique11Keyword);
            int version = keywordTok.Kind == TokenKind.Technique10Keyword ? 10 : 11;

            UserDefinedNamedTypeNode name = null;
            if (Match(TokenKind.IdentifierToken))
            {
                name = ParseUserDefinedNamedType();
            }

            List<VariableDeclarationStatementNode> annotations = new List<VariableDeclarationStatementNode>();
            if (Match(TokenKind.LessThanToken))
            {
                Eat(TokenKind.LessThanToken);
                annotations = ParseMany0(() => !Match(TokenKind.GreaterThanToken), () => ParseVariableDeclarationStatement(new List<AttributeNode>()));
                Eat(TokenKind.GreaterThanToken);
            }

            Eat(TokenKind.OpenBraceToken);
            var passes = ParseMany0(TokenKind.PassKeyword, ParsePass);
            Eat(TokenKind.CloseBraceToken);

            if (Match(TokenKind.SemiToken))
            {
                Eat(TokenKind.SemiToken);
            }
            RecoverTo(TokenKind.SemiToken, TokenKind.CloseBraceToken);

            return new TechniqueNode(Range(keywordTok, Previous()))
            {
                Name = name,
                Annotations = annotations,
                Version = version,
                Passes = passes
            };
        }

        public PassNode ParsePass()
        {
            var keywordTok = Eat(TokenKind.PassKeyword);
            UserDefinedNamedTypeNode name = null;
            if (Match(TokenKind.IdentifierToken))
            {
                name = ParseUserDefinedNamedType();
            }

            List<VariableDeclarationStatementNode> annotations = new List<VariableDeclarationStatementNode>();
            if (Match(TokenKind.LessThanToken))
            {
                Eat(TokenKind.LessThanToken);
                annotations = ParseMany0(() => !Match(TokenKind.GreaterThanToken), () => ParseVariableDeclarationStatement(new List<AttributeNode>()));
                Eat(TokenKind.GreaterThanToken);
            }

            Eat(TokenKind.OpenBraceToken);
            var statements = ParseMany0(() => !Match(TokenKind.CloseBraceToken), () =>
            {
                if (TryParse(ParseStatement, out var stmt))
                {
                    return stmt;
                }
                // Assume state property
                else
                {
                    return ParseStateProperty();
                }
            });
            var closeTok = Eat(TokenKind.CloseBraceToken);
            RecoverTo(TokenKind.CloseBraceToken);

            return new PassNode(Range(keywordTok, closeTok))
            {
                Name = name,
                Annotations = annotations,
                Statements = statements
            };
        }

        private bool IsNextPreProcessorDirective()
        {
            switch (Peek().Kind)
            {
                case TokenKind.DefineDirectiveKeyword:
                case TokenKind.IncludeDirectiveKeyword:
                case TokenKind.LineDirectiveKeyword:
                case TokenKind.UndefDirectiveKeyword:
                case TokenKind.ErrorDirectiveKeyword:
                case TokenKind.PragmaDirectiveKeyword:
                case TokenKind.IfDirectiveKeyword:
                case TokenKind.IfdefDirectiveKeyword:
                case TokenKind.IfndefDirectiveKeyword:
                    return true;
                default:
                    return false;
            }
        }

        public PreProcessorDirectiveNode ParsePreProcessorDirective(Func<HLSLSyntaxNode> recurse)
        {
            var next = Peek();
            switch (next.Kind)
            {
                case TokenKind.DefineDirectiveKeyword:
                    return ParseDefineDirective();
                case TokenKind.IncludeDirectiveKeyword:
                    return ParseIncludeDirective();
                case TokenKind.LineDirectiveKeyword:
                    return ParseLineDirective();
                case TokenKind.UndefDirectiveKeyword:
                    return ParseUndefDirective();
                case TokenKind.ErrorDirectiveKeyword:
                    return ParseErrorDirective();
                case TokenKind.PragmaDirectiveKeyword:
                    return ParsePragmaDirective();
                case TokenKind.IfDirectiveKeyword:
                    return ParseIfDirective(recurse, false);
                case TokenKind.IfdefDirectiveKeyword:
                    return ParseIfDefDirective(recurse);
                case TokenKind.IfndefDirectiveKeyword:
                    return ParseIfNotDefDirective(recurse);
                default:
                    Error("a valid preprocessor directive", next);
                    return null;
            }
        }

        public PreProcessorDirectiveNode ParseDefineDirective()
        {
            var keywordTok = Eat(TokenKind.DefineDirectiveKeyword);
            string ident = base.ParseIdentifier();
            
            // Function like
            if (Match(TokenKind.OpenFunctionLikeMacroParenToken))
            {
                Eat(TokenKind.OpenFunctionLikeMacroParenToken);
                var args = ParseSeparatedList0(TokenKind.CloseParenToken, TokenKind.CommaToken, base.ParseIdentifier);
                Eat(TokenKind.CloseParenToken);
                var tokens = ParseMany0(() => !Match(TokenKind.EndDirectiveToken), () => Advance());
                var endTok = Eat(TokenKind.EndDirectiveToken);
                RecoverTo(TokenKind.EndDirectiveToken);
                return new FunctionLikeMacroNode(Range(keywordTok, endTok))
                {
                    Name = ident,
                    Arguments = args,
                    Value = tokens,
                };
            }
            else
            {
                var tokens = ParseMany0(() => !Match(TokenKind.EndDirectiveToken), () => Advance());
                var endTok = Eat(TokenKind.EndDirectiveToken);
                RecoverTo(TokenKind.EndDirectiveToken);
                return new ObjectLikeMacroNode(Range(keywordTok, endTok))
                {
                    Name = ident,
                    Value = tokens,
                };
            }
        }

        public IncludeDirectiveNode ParseIncludeDirective()
        {
            var keywordTok = Eat(TokenKind.IncludeDirectiveKeyword);
            string ident = Eat(TokenKind.StringLiteralToken, TokenKind.SystemIncludeLiteralToken).Identifier;
            var endTok = Eat(TokenKind.EndDirectiveToken);
            RecoverTo(TokenKind.EndDirectiveToken);
            return new IncludeDirectiveNode(Range(keywordTok, endTok)) { Path = ident };
        }

        public LineDirectiveNode ParseLineDirective()
        {
            var keywordTok = Eat(TokenKind.LineDirectiveKeyword);
            int line = ParseIntegerLiteral();
            var endTok = Eat(TokenKind.EndDirectiveToken);
            RecoverTo(TokenKind.EndDirectiveToken);
            return new LineDirectiveNode(Range(keywordTok, endTok)) { Line = line };
        }

        public UndefDirectiveNode ParseUndefDirective()
        {
            var keywordTok = Eat(TokenKind.UndefDirectiveKeyword);
            string ident = base.ParseIdentifier();
            var endTok = Eat(TokenKind.EndDirectiveToken);
            RecoverTo(TokenKind.EndDirectiveToken);
            return new UndefDirectiveNode(Range(keywordTok, endTok)) { Name = ident };
        }

        public ErrorDirectiveNode ParseErrorDirective()
        {
            var keywordTok = Eat(TokenKind.ErrorDirectiveKeyword);
            var tokens = ParseMany0(() => !Match(TokenKind.EndDirectiveToken), () => Advance());
            var endTok = Eat(TokenKind.EndDirectiveToken);
            RecoverTo(TokenKind.EndDirectiveToken);
            return new ErrorDirectiveNode(Range(keywordTok, endTok)) { Value = tokens };
        }

        public PragmaDirectiveNode ParsePragmaDirective()
        {
            var keywordTok = Eat(TokenKind.PragmaDirectiveKeyword);
            var tokens = ParseMany0(() => !Match(TokenKind.EndDirectiveToken), () => Advance());
            var endTok = Eat(TokenKind.EndDirectiveToken);
            RecoverTo(TokenKind.EndDirectiveToken);
            return new PragmaDirectiveNode(Range(keywordTok, endTok)) { Value = tokens };
        }

        public IfDirectiveNode ParseIfDirective(Func<HLSLSyntaxNode> recurse, bool elif)
        {
            var keywordTok = elif ? Eat(TokenKind.ElifDirectiveKeyword) : Eat(TokenKind.IfDirectiveKeyword);
            var expr = ParseExpression();
            var endTok = Eat(TokenKind.EndDirectiveToken);
            RecoverTo(TokenKind.EndDirectiveToken);
            var body = ParseMany0(() => !Match(TokenKind.ElseDirectiveKeyword, TokenKind.ElifDirectiveKeyword, TokenKind.EndifDirectiveKeyword), recurse);
            var elseClause = ParseDirectiveConditionalRemainder(recurse);
            return new IfDirectiveNode(Range(keywordTok, Previous()))
            {
                Condition = expr,
                Body = body,
                ElseClause = elseClause,
            };
        }

        public IfDefDirectiveNode ParseIfDefDirective(Func<HLSLSyntaxNode> recurse)
        {
            var keywordTok = Eat(TokenKind.IfdefDirectiveKeyword);
            string ident = base.ParseIdentifier();
            var endTok = Eat(TokenKind.EndDirectiveToken);
            RecoverTo(TokenKind.EndDirectiveToken);
            var body = ParseMany0(() => !Match(TokenKind.ElseDirectiveKeyword, TokenKind.ElifDirectiveKeyword, TokenKind.EndifDirectiveKeyword), recurse);
            var elseClause = ParseDirectiveConditionalRemainder(recurse);
            return new IfDefDirectiveNode(Range(keywordTok, Previous()))
            {
                Condition = ident,
                Body = body,
                ElseClause = elseClause,
            };
        }

        public IfNotDefDirectiveNode ParseIfNotDefDirective(Func<HLSLSyntaxNode> recurse)
        {
            var keywordTok = Eat(TokenKind.IfndefDirectiveKeyword);
            string ident = base.ParseIdentifier();
            var endTok = Eat(TokenKind.EndDirectiveToken);
            RecoverTo(TokenKind.EndDirectiveToken);
            var body = ParseMany0(() => !Match(TokenKind.ElseDirectiveKeyword, TokenKind.ElifDirectiveKeyword, TokenKind.EndifDirectiveKeyword), recurse);
            var elseClause = ParseDirectiveConditionalRemainder(recurse);
            return new IfNotDefDirectiveNode(Range(keywordTok, Previous()))
            {
                Condition = ident,
                Body = body,
                ElseClause = elseClause,
            };
        }

        public PreProcessorDirectiveNode ParseDirectiveConditionalRemainder(Func<HLSLSyntaxNode> recurse)
        {
            PreProcessorDirectiveNode elseClause = null;
            var next = Peek();
            switch (next.Kind)
            {
                case TokenKind.ElseDirectiveKeyword:
                    var keywordTok = Eat(TokenKind.ElseDirectiveKeyword);
                    Eat(TokenKind.EndDirectiveToken);
                    RecoverTo(TokenKind.EndDirectiveToken);
                    var body = ParseMany0(() => !Match(TokenKind.EndifDirectiveKeyword), recurse);
                    Eat(TokenKind.EndifDirectiveKeyword);
                    var endTokElse = Eat(TokenKind.EndDirectiveToken);
                    RecoverTo(TokenKind.EndDirectiveToken);
                    elseClause = new ElseDirectiveNode(Range(keywordTok, endTokElse)) { Body = body };
                    break;
                case TokenKind.ElifDirectiveKeyword:
                    elseClause = ParseIfDirective(recurse, true);
                    break;
                case TokenKind.EndifDirectiveKeyword:
                    Eat(TokenKind.EndifDirectiveKeyword);
                    var endTok = Eat(TokenKind.EndDirectiveToken);
                    RecoverTo(TokenKind.EndDirectiveToken);
                    break;
                default:
                    Error("a valid preprocessor directive", next);
                    break;
            }
            return elseClause;
        }
    }
}


// HLSL/HLSLPrinter.cs
namespace UnityShaderParser.HLSL
{
    public class HLSLPrinter : HLSLSyntaxVisitor
    {
        // Settings
        public int MaxParametersUntilLineBreak { get; set; } = 4;
        public bool IndentBlockLikeSwitchClauses { get; set; } = false;

        // State and helpers
        protected StringBuilder sb = new StringBuilder();
        public string Text => sb.ToString();

        protected int indentLevel = 0;
        protected void PushIndent() => indentLevel++;
        protected void PopIndent() => indentLevel--;
        protected string Indent() => new string(' ', indentLevel * 4);

        protected void Emit(string text) => sb.Append(text);
        protected void EmitLine(string text = "") => sb.AppendLine(text);
        protected void EmitIndented(string text = "")
        {
            sb.Append(Indent());
            sb.Append(text);
        }
        protected void EmitIndentedLine(string text)
        {
            sb.Append(Indent());
            sb.AppendLine(text);
        }

        protected Stack<int> expressionPrecedences = new Stack<int>();

        protected void VisitManySeparated<T>(IList<T> nodes, string separator, bool trailing = false, bool leading = false)
            where T : HLSLSyntaxNode
        {
            if (leading && nodes.Count > 0)
            {
                Emit(separator);
            }
            VisitMany(nodes, () => Emit(separator));
            if (trailing && nodes.Count > 0)
            {
                Emit(separator);
            }
        }

        protected void EmitExpression(OperatorPrecedence prec, Action expressionEmitter)
        {
            int precedence = (int)prec;
            bool needsParen = false;
            if (expressionPrecedences.Count > 0 && expressionPrecedences.Peek() >= precedence)
            {
                needsParen = true;
            }

            expressionPrecedences.Push(precedence);
            if (needsParen) Emit("(");
            expressionEmitter();
            if (needsParen) Emit(")");
            expressionPrecedences.Pop();
        }

        // Visitor implementation
        public override void VisitIdentifierNode(IdentifierNode node)
        {
            Emit(node.Identifier);
        }
        public override void VisitFormalParameterNode(FormalParameterNode node)
        {
            VisitManySeparated(node.Attributes, " ", true);
            string modifiers = string.Join("", node.Modifiers.Select(PrintingUtil.GetEnumName).Select(x => x + " "));
            Emit(modifiers);
            Visit(node.ParamType);
            Emit(" ");
            Visit(node.Declarator);
        }
        public override void VisitVariableDeclaratorNode(VariableDeclaratorNode node)
        {
            Emit(node.Name.Identifier);
            VisitMany(node.ArrayRanks);
            VisitMany(node.Qualifiers);
            if (node.Annotations?.Count > 0)
            {
                EmitLine();
                EmitIndentedLine("<");
                PushIndent();
                VisitMany(node.Annotations);
                PopIndent();
                EmitIndented(">");
            }
            Visit(node.Initializer);
        }
        public override void VisitArrayRankNode(ArrayRankNode node)
        {
            Emit("[");
            Visit(node.Dimension);
            Emit("]");
        }    
        public override void VisitValueInitializerNode(ValueInitializerNode node)
        {
            Emit(" = ");
            Visit(node.Expression);
        }
        public override void VisitStateInitializerNode(StateInitializerNode node)
        {
            EmitLine();
            EmitIndentedLine("{");
            PushIndent();
            VisitMany(node.States);
            PopIndent();
            EmitIndented("}");
        }
        public override void VisitStateArrayInitializerNode(StateArrayInitializerNode node)
        {
            EmitLine();
            EmitIndentedLine("{");
            PushIndent();
            VisitManySeparated(node.Initializers, ",");
            PopIndent();
            EmitLine();
            EmitIndented("}");
        }
        private void VisitFunctionNode(FunctionNode node)
        {
            EmitIndented();
            string modifiers = string.Join("", node.Modifiers.Select(PrintingUtil.GetEnumName).Select(x => x + " "));
            Emit(modifiers);
            VisitManySeparated(node.Attributes, "\n", true);
            if (node.Attributes.Count > 0) EmitLine();
            Visit(node.ReturnType);
            Emit(" ");
            Visit(node.Name);
            Emit("(");
            if (node.Parameters?.Count > MaxParametersUntilLineBreak)
            {
                EmitLine();
                PushIndent();
                for (int i = 0; i < node.Parameters.Count; i++)
                {
                    EmitIndented();
                    Visit(node.Parameters[i]);
                    if (i < node.Parameters.Count - 1)
                        EmitLine(",");
                }
                PopIndent();
            }
            else
            {
                VisitManySeparated(node.Parameters, ", ");
            }
            Emit(")");
            Visit(node.Semantic);
        }
        public override void VisitFunctionDeclarationNode(FunctionDeclarationNode node)
        {
            VisitFunctionNode(node);
            EmitLine(";");
        }
        public override void VisitFunctionDefinitionNode(FunctionDefinitionNode node)
        {
            VisitFunctionNode(node);
            EmitLine();
            if (node.BodyIsSingleStatement)
            {
                EmitIndented();
            }
            Visit(node.Body);
        }
        public override void VisitStructDefinitionNode(StructDefinitionNode node)
        {
            EmitIndented();
            VisitManySeparated(node.Attributes, " ", true);
            Visit(node.StructType);
            EmitLine(";");
        }
        public override void VisitInterfaceDefinitionNode(InterfaceDefinitionNode node)
        {
            EmitIndented();
            VisitManySeparated(node.Attributes, " ", true);
            Emit("interface ");
            Visit(node.Name);
            EmitLine();
            EmitIndentedLine("{");
            PushIndent();
            VisitMany(node.Functions);
            PopIndent();
            EmitIndentedLine("};");
        }
        public override void VisitConstantBufferNode(ConstantBufferNode node)
        {
            if (node.IsTextureBuffer)
            {
                Emit("tbuffer ");
            }
            else
            {
                Emit("cbuffer ");
            }
            Visit(node.Name);
            Visit(node.RegisterLocation);
            EmitLine();
            EmitIndentedLine("{");
            PushIndent();
            VisitMany(node.Declarations);
            PopIndent();
            EmitIndentedLine("}");
        }
        public override void VisitNamespaceNode(NamespaceNode node)
        {
            EmitIndented("namespace ");
            Visit(node.Name);
            EmitLine();
            EmitIndentedLine("{");
            PushIndent();
            VisitMany(node.Declarations);
            PopIndent();
            EmitIndentedLine("}");
        }
        public override void VisitTypedefNode(TypedefNode node)
        {
            EmitIndented();
            VisitManySeparated(node.Attributes, " ", true);
            Emit("typedef ");
            if (node.IsConst)
            {
                Emit("const ");
            }
            Visit(node.FromType);
            Emit(" ");
            VisitManySeparated(node.ToNames, ", ");
            EmitLine(";");
        }
        public override void VisitSemanticNode(SemanticNode node)
        {
            Emit($" : {node.Name}");
        }
        public override void VisitRegisterLocationNode(RegisterLocationNode node)
        {
            Emit($" : register({PrintingUtil.GetEnumName(node.Kind)}{node.Location}");
            if (node.Space != null)
            {
                Emit($", space{node.Space})");
            }
            else
            {
                Emit(")");
            }
        }
        public override void VisitPackoffsetNode(PackoffsetNode node)
        {
            Emit($" : packoffset(c{node.Location}");
            if (string.IsNullOrEmpty(node.Swizzle))
            {
                Emit(")");
            }
            else
            {
                Emit($".{node.Swizzle})");
            }
        }
        public override void VisitBlockNode(BlockNode node)
        {
            EmitIndented();
            VisitManySeparated(node.Attributes, " ", true);
            EmitLine("{");
            PushIndent();
            VisitMany(node.Statements);
            PopIndent();
            EmitIndentedLine("}");
        }
        public override void VisitVariableDeclarationStatementNode(VariableDeclarationStatementNode node)
        {
            bool partOfFor = node.Parent is ForStatementNode forStatement && forStatement.Declaration == node;

            if (!partOfFor) EmitIndented();
            VisitManySeparated(node.Attributes, " ", true);
            string modifiers = string.Join("", node.Modifiers.Select(PrintingUtil.GetEnumName).Select(x => x + " "));
            Emit(modifiers);
            Visit(node.Kind);
            Emit(" ");
            VisitManySeparated(node.Declarators, ", ");
            Emit(";");
            if (!partOfFor) EmitLine();
        }
        public override void VisitReturnStatementNode(ReturnStatementNode node)
        {
            if (node.Expression != null)
            {
                EmitIndented("return ");
                Visit(node.Expression);
                EmitLine(";");
            }
            else
            {
                EmitIndentedLine("return;");
            }
        }

        public override void VisitBreakStatementNode(BreakStatementNode node)
        {
            EmitIndentedLine("break;");
        }
        public override void VisitContinueStatementNode(ContinueStatementNode node)
        {
            EmitIndentedLine("continue;");
        }
        public override void VisitDiscardStatementNode(DiscardStatementNode node)
        {
            EmitIndentedLine("discard;");
        }
        public override void VisitEmptyStatementNode(EmptyStatementNode node)
        {
            EmitIndentedLine(";");
        }
        public override void VisitForStatementNode(ForStatementNode node)
        {
            EmitIndented();
            VisitManySeparated(node.Attributes, " ", true);
            Emit("for (");
            if (node.FirstIsDeclaration)
            {
                Visit(node.Declaration);
                Emit(" ");
            }
            else
            {
                Visit(node.Initializer);
                Emit("; ");
            }

            Visit(node.Condition);
            Emit("; ");

            Visit(node.Increment);
            EmitLine(")");
            if (node.BodyIsSingleStatement)
            {
                EmitIndented();
            }
            Visit(node.Body);
        }
        public override void VisitWhileStatementNode(WhileStatementNode node)
        {
            EmitIndented();
            VisitManySeparated(node.Attributes, " ", true);
            Emit("while (");
            Visit(node.Condition);
            EmitLine(")");
            if (node.BodyIsSingleStatement)
            {
                EmitIndented();
            }
            Visit(node.Body);
        }
        public override void VisitDoWhileStatementNode(DoWhileStatementNode node)
        {
            EmitIndented();
            VisitManySeparated(node.Attributes, " ", true);
            EmitLine("do");
            if (node.BodyIsSingleStatement)
            {
                EmitIndented();
            }
            Visit(node.Body);
            EmitIndented("while (");
            Visit(node.Condition);
            EmitLine(");");
        }
        public override void VisitIfStatementNode(IfStatementNode node)
        {
            if (!node.BodyIsElseIfClause)
            {
                EmitIndented();
            }
            VisitManySeparated(node.Attributes, " ", true);
            Emit("if (");
            Visit(node.Condition);
            EmitLine(")");
            if (node.BodyIsSingleStatement)
            {
                EmitIndented();
            }
            Visit(node.Body);
            if (node.ElseClause != null)
            {
                EmitIndented("else ");
                if (node.ElseClauseIsSingleStatement && !node.ElseClauseIsElseIfClause)
                {
                    EmitLine();
                    EmitIndented();
                }
                else if (!node.ElseClauseIsElseIfClause)
                {
                    EmitLine();
                }

                Visit(node.ElseClause);
            }
        }
        public override void VisitSwitchStatementNode(SwitchStatementNode node)
        {
            EmitIndented();
            VisitManySeparated(node.Attributes, " ", true);
            Emit("switch (");
            Visit(node.Expression);
            EmitLine(")");
            EmitIndentedLine("{");
            PushIndent();
            VisitMany(node.Clauses);
            PopIndent();
            EmitIndentedLine("}");
        }
        public override void VisitSwitchClauseNode(SwitchClauseNode node)
        {
            VisitMany(node.Labels);
            bool isSingleBlock = node.Statements.Count == 1 && node.Statements[0] is BlockNode;
            if (!isSingleBlock && !IndentBlockLikeSwitchClauses) PushIndent();
            VisitMany(node.Statements);
            if (!isSingleBlock && !IndentBlockLikeSwitchClauses) PopIndent();
        }
        public override void VisitSwitchCaseLabelNode(SwitchCaseLabelNode node)
        {
            EmitIndented("case ");
            Visit(node.Value);
            EmitLine(":");
        }
        public override void VisitSwitchDefaultLabelNode(SwitchDefaultLabelNode node)
        {
            EmitIndentedLine("default:");
        }
        public override void VisitExpressionStatementNode(ExpressionStatementNode node)
        {
            EmitIndented();
            Visit(node.Expression);
            EmitLine(";");
        }
        public override void VisitAttributeNode(AttributeNode node)
        {
            Emit("[");
            Emit(node.Name.Identifier);
            if (node.Arguments?.Count > 0)
            {
                Emit("(");
                VisitManySeparated(node.Arguments, ", ");
                Emit(")");
            }
            Emit("]");
        }
        public override void VisitQualifiedIdentifierExpressionNode(QualifiedIdentifierExpressionNode node)
        {
            Emit(node.GetName());
        }
        public override void VisitIdentifierExpressionNode(IdentifierExpressionNode node)
        {
            Emit(node.GetName());
        }
        public override void VisitLiteralExpressionNode(LiteralExpressionNode node)
        {
            if (node.Kind == LiteralKind.String)
            {
                Emit($"\"{node.Lexeme}\"");
            }
            else if (node.Kind == LiteralKind.Character)
            {
                Emit($"'{node.Lexeme}'");
            }
            else
            {
                Emit(node.Lexeme);
            }
        }
        public override void VisitAssignmentExpressionNode(AssignmentExpressionNode node)
        {
            EmitExpression(OperatorPrecedence.Assignment, () =>
            {
                Visit(node.Left);
                Emit($" {PrintingUtil.GetEnumName(node.Operator)} ");
                Visit(node.Right);
            });
        }
        public override void VisitBinaryExpressionNode(BinaryExpressionNode node)
        {
            EmitExpression(HLSLSyntaxFacts.GetPrecedence(node.Operator, OperatorFixity.Infix), () =>
            {
                Visit(node.Left);
                Emit($" {PrintingUtil.GetEnumName(node.Operator)} ");
                Visit(node.Right);
            });
        }
        public override void VisitCompoundExpressionNode(CompoundExpressionNode node)
        {
            EmitExpression(OperatorPrecedence.Compound, () =>
            {
                Visit(node.Left);
                Emit(", ");
                Visit(node.Right);
            });
        }
        public override void VisitPrefixUnaryExpressionNode(PrefixUnaryExpressionNode node)
        {
            EmitExpression(OperatorPrecedence.PrefixUnary, () =>
            {
                Emit($"{PrintingUtil.GetEnumName(node.Operator)}");
                Visit(node.Expression);
            });
        }
        public override void VisitPostfixUnaryExpressionNode(PostfixUnaryExpressionNode node)
        {
            EmitExpression(OperatorPrecedence.PostFixUnary, () =>
            {
                Visit(node.Expression);
                Emit($"{PrintingUtil.GetEnumName(node.Operator)}");
            });
        }
        public override void VisitFieldAccessExpressionNode(FieldAccessExpressionNode node)
        {
            EmitExpression(OperatorPrecedence.PostFixUnary, () =>
            {
                bool needsExtraParen = node.Target is LiteralExpressionNode; // Can't directly swizzle a literal
                if (needsExtraParen) Emit("(");
                Visit(node.Target);
                if (needsExtraParen) Emit(")");
                Emit($".{node.Name}");
            });
        }
        public override void VisitMethodCallExpressionNode(MethodCallExpressionNode node)
        {
            EmitExpression(OperatorPrecedence.PostFixUnary, () =>
            {
                Visit(node.Target);
                Emit($".{node.Name}(");
                VisitManySeparated(node.Arguments, ", ");
                Emit(")");
            });
        }
        public override void VisitFunctionCallExpressionNode(FunctionCallExpressionNode node)
        {
            EmitExpression(OperatorPrecedence.PostFixUnary, () =>
            {
                Visit(node.Name);
                Emit("(");
                VisitManySeparated(node.Arguments, ", ");
                Emit(")");
            });
        }
        public override void VisitNumericConstructorCallExpressionNode(NumericConstructorCallExpressionNode node)
        {
            EmitExpression(OperatorPrecedence.PostFixUnary, () =>
            {
                Visit(node.Kind);
                Emit("(");
                VisitManySeparated(node.Arguments, ", ");
                Emit(")");
            });
        }
        public override void VisitElementAccessExpressionNode(ElementAccessExpressionNode node)
        {
            EmitExpression(OperatorPrecedence.PostFixUnary, () =>
            {
                Visit(node.Target);
                Emit("[");
                Visit(node.Index);
                Emit("]");
            });
        }
        public override void VisitCastExpressionNode(CastExpressionNode node)
        {
            if (node.IsFunctionLike)
            {
                EmitExpression(OperatorPrecedence.PostFixUnary, () =>
                {
                    Visit(node.Kind);
                    Emit("(");
                    Visit(node.Expression);
                    Emit(")");
                });
            }
            else
            {
                EmitExpression(OperatorPrecedence.PrefixUnary, () =>
                {
                    Emit("(");
                    Visit(node.Kind);
                    VisitMany(node.ArrayRanks);
                    Emit(")");
                    Visit(node.Expression);
                });
            }
        }
        public override void VisitArrayInitializerExpressionNode(ArrayInitializerExpressionNode node)
        {
            EmitLine();
            EmitIndentedLine("{");
            PushIndent();
            foreach (var element in node.Elements)
            {
                EmitIndented();
                Visit(element);
                EmitLine(",");
            }
            PopIndent();
            EmitIndented("}");
        }
        public override void VisitTernaryExpressionNode(TernaryExpressionNode node)
        {
            EmitExpression(OperatorPrecedence.Ternary, () =>
            {
                Visit(node.Condition);
                Emit(" ? ");
                Visit(node.TrueCase);
                Emit(" : ");
                Visit(node.FalseCase);
            });
        }
        public override void VisitSamplerStateLiteralExpressionNode(SamplerStateLiteralExpressionNode node)
        {
            EmitLine("sampler_state");
            EmitIndentedLine("{");
            PushIndent();
            VisitMany(node.States);
            PopIndent();
            EmitIndented("}");
        }
        public override void VisitCompileExpressionNode(CompileExpressionNode node)
        {
            Emit($"compile {node.Target} ");
            Visit(node.Invocation);
        }
        public override void VisitQualifiedNamedTypeNode(QualifiedNamedTypeNode node)
        {
            Emit(node.GetName());
        }
        public override void VisitNamedTypeNode(NamedTypeNode node)
        {
            Emit(node.GetName());
        }
        public override void VisitPredefinedObjectTypeNode(PredefinedObjectTypeNode node)
        {
            Emit(PrintingUtil.GetEnumName(node.Kind));
            if (node.TemplateArguments?.Count > 0)
            {
                Emit("<");
                VisitManySeparated(node.TemplateArguments, ", ");
                Emit(">");
            }
        }
        public override void VisitStructTypeNode(StructTypeNode node)
        {
            if (node.IsClass)
            {
                Emit("class ");
            }
            else
            {
                Emit("struct ");
            }

            Visit(node.Name);
            if (node.Inherits.Count > 0)
            {
                Emit(" : ");
                VisitManySeparated(node.Inherits, ", ");
            }
            EmitLine();
            EmitIndentedLine("{");
            PushIndent();
            VisitMany(node.Fields);
            VisitMany(node.Methods);
            PopIndent();
            EmitIndented("}");
        }
        public override void VisitScalarTypeNode(ScalarTypeNode node)
        {
            Emit(PrintingUtil.GetEnumName(node.Kind));
        }
        public override void VisitMatrixTypeNode(MatrixTypeNode node)
        {
            Emit($"{PrintingUtil.GetEnumName(node.Kind)}{node.FirstDimension}x{node.SecondDimension}");
        }
        public override void VisitGenericMatrixTypeNode(GenericMatrixTypeNode node)
        {
            Emit($"matrix<{PrintingUtil.GetEnumName(node.Kind)}, ");
            Visit(node.FirstDimension);
            Emit(", ");
            Visit(node.SecondDimension);
            Emit(">");
        }
        public override void VisitVectorTypeNode(VectorTypeNode node)
        {
            Emit($"{PrintingUtil.GetEnumName(node.Kind)}{node.Dimension}");
        }
        public override void VisitGenericVectorTypeNode(GenericVectorTypeNode node)
        {
            Emit($"vector<{PrintingUtil.GetEnumName(node.Kind)}, ");
            Visit(node.Dimension);
            Emit(">");
        }
        public override void VisitTechniqueNode(TechniqueNode node)
        {
            Emit(node.Version == 11 ? "technique " : $"technique{node.Version} ");
            Visit(node.Name);
            EmitLine();
            if (node.Annotations?.Count > 0)
            {
                EmitIndentedLine("<");
                PushIndent();
                VisitMany(node.Annotations);
                PopIndent();
                EmitIndentedLine(">");
            }
            EmitIndentedLine("{");
            PushIndent();
            VisitMany(node.Passes);
            PopIndent();
            EmitIndentedLine("}");
        }
        public override void VisitStatePropertyNode(StatePropertyNode node)
        {
            EmitIndented();
            Visit(node.Name);
            Visit(node.ArrayRank);
            Emit(" = ");
            if (node.IsReference) Emit("<");
            Visit(node.Value);
            if (node.IsReference) Emit(">");
            EmitLine(";");
        }
        public override void VisitPassNode(PassNode node)
        {
            EmitIndented("pass ");
            Visit(node.Name);
            EmitLine();
            if (node.Annotations?.Count > 0)
            {
                EmitIndentedLine("<");
                PushIndent();
                VisitMany(node.Annotations);
                PopIndent();
                EmitIndentedLine(">");
            }
            EmitIndentedLine("{");
            PushIndent();
            VisitMany(node.Statements);
            PopIndent();
            EmitIndentedLine("}");
        }

        private string TokensToString(IEnumerable<Token<HLSL.TokenKind>> tokens)
        {
            return string.Join(" ", tokens.Select(x => HLSLSyntaxFacts.TokenToString(x)));
        }

        public override void VisitObjectLikeMacroNode(ObjectLikeMacroNode node)
        {
            EmitIndentedLine($"#define {node.Name} {TokensToString(node.Value)}");
        }

        public override void VisitFunctionLikeMacroNode(FunctionLikeMacroNode node)
        {
            EmitIndentedLine($"#define {node.Name}({string.Join(", ", node.Arguments)}) {TokensToString(node.Value)}");
        }

        public override void VisitErrorDirectiveNode(ErrorDirectiveNode node)
        {
            EmitIndentedLine($"#error {TokensToString(node.Value)}");
        }

        public override void VisitIncludeDirectiveNode(IncludeDirectiveNode node)
        {
            EmitIndentedLine($"#include \"{node.Path}\"");
        }

        public override void VisitLineDirectiveNode(LineDirectiveNode node)
        {
            EmitIndentedLine($"#line {node.Line}");
        }

        public override void VisitPragmaDirectiveNode(PragmaDirectiveNode node)
        {
            EmitIndentedLine($"#pragma {TokensToString(node.Value)}");
        }

        public override void VisitUndefDirectiveNode(UndefDirectiveNode node)
        {
            EmitIndentedLine($"#undef {node.Name}");
        }

        public override void VisitIfDirectiveNode(IfDirectiveNode node)
        {
            if (node.IsElif)
            {
                EmitIndented($"#elif ");
            }
            else
            {
                EmitIndented($"#if ");
            }
            Visit(node.Condition);
            EmitLine();
            VisitMany(node.Body);
            if (node.ElseClause == null)
            {
                EmitIndentedLine("#endif");
            }
            else
            {
                Visit(node.ElseClause);
            }
        }

        public override void VisitIfDefDirectiveNode(IfDefDirectiveNode node)
        {
            EmitIndentedLine($"#ifdef {node.Condition}");
            VisitMany(node.Body);
            if (node.ElseClause == null)
            {
                EmitIndentedLine("#endif");
            }
            else
            {
                Visit(node.ElseClause);
            }
        }

        public override void VisitIfNotDefDirectiveNode(IfNotDefDirectiveNode node)
        {
            EmitIndentedLine($"#ifndef {node.Condition}");
            VisitMany(node.Body);
            if (node.ElseClause == null)
            {
                EmitIndentedLine("#endif");
            }
            else
            {
                Visit(node.ElseClause);
            }
        }

        public override void VisitElseDirectiveNode(ElseDirectiveNode node)
        {
            EmitIndentedLine("#else");
            VisitMany(node.Body);
            EmitIndentedLine("#endif");
        }
    }
}


// HLSL/HLSLSyntaxElements.cs
namespace UnityShaderParser.HLSL
{
    using HLSLToken = Token<TokenKind>;

    #region Common types
    public enum TokenKind
    {
        InvalidToken,

        AppendStructuredBufferKeyword,
        BlendStateKeyword,
        BoolKeyword,
        Bool1Keyword,
        Bool2Keyword,
        Bool3Keyword,
        Bool4Keyword,
        Bool1x1Keyword,
        Bool1x2Keyword,
        Bool1x3Keyword,
        Bool1x4Keyword,
        Bool2x1Keyword,
        Bool2x2Keyword,
        Bool2x3Keyword,
        Bool2x4Keyword,
        Bool3x1Keyword,
        Bool3x2Keyword,
        Bool3x3Keyword,
        Bool3x4Keyword,
        Bool4x1Keyword,
        Bool4x2Keyword,
        Bool4x3Keyword,
        Bool4x4Keyword,
        BufferKeyword,
        ByteAddressBufferKeyword,
        BreakKeyword,
        CaseKeyword,
        CBufferKeyword,
        CentroidKeyword,
        ClassKeyword,
        ColumnMajorKeyword,
        CompileKeyword,
        ConstKeyword,
        ConsumeStructuredBufferKeyword,
        ContinueKeyword,
        DefaultKeyword,
        DefKeyword,
        DepthStencilStateKeyword,
        DiscardKeyword,
        DoKeyword,
        DoubleKeyword,
        Double1Keyword,
        Double2Keyword,
        Double3Keyword,
        Double4Keyword,
        Double1x1Keyword,
        Double1x2Keyword,
        Double1x3Keyword,
        Double1x4Keyword,
        Double2x1Keyword,
        Double2x2Keyword,
        Double2x3Keyword,
        Double2x4Keyword,
        Double3x1Keyword,
        Double3x2Keyword,
        Double3x3Keyword,
        Double3x4Keyword,
        Double4x1Keyword,
        Double4x2Keyword,
        Double4x3Keyword,
        Double4x4Keyword,
        ElseKeyword,
        ErrorKeyword,
        ExportKeyword,
        ExternKeyword,
        FloatKeyword,
        Float1Keyword,
        Float2Keyword,
        Float3Keyword,
        Float4Keyword,
        Float1x1Keyword,
        Float1x2Keyword,
        Float1x3Keyword,
        Float1x4Keyword,
        Float2x1Keyword,
        Float2x2Keyword,
        Float2x3Keyword,
        Float2x4Keyword,
        Float3x1Keyword,
        Float3x2Keyword,
        Float3x3Keyword,
        Float3x4Keyword,
        Float4x1Keyword,
        Float4x2Keyword,
        Float4x3Keyword,
        Float4x4Keyword,
        ForKeyword,
        GloballycoherentKeyword,
        GroupsharedKeyword,
        HalfKeyword,
        Half1Keyword,
        Half2Keyword,
        Half3Keyword,
        Half4Keyword,
        Half1x1Keyword,
        Half1x2Keyword,
        Half1x3Keyword,
        Half1x4Keyword,
        Half2x1Keyword,
        Half2x2Keyword,
        Half2x3Keyword,
        Half2x4Keyword,
        Half3x1Keyword,
        Half3x2Keyword,
        Half3x3Keyword,
        Half3x4Keyword,
        Half4x1Keyword,
        Half4x2Keyword,
        Half4x3Keyword,
        Half4x4Keyword,
        IfKeyword,
        IndicesKeyword,
        InKeyword,
        InlineKeyword,
        InoutKeyword,
        InputPatchKeyword,
        IntKeyword,
        Int1Keyword,
        Int2Keyword,
        Int3Keyword,
        Int4Keyword,
        Int1x1Keyword,
        Int1x2Keyword,
        Int1x3Keyword,
        Int1x4Keyword,
        Int2x1Keyword,
        Int2x2Keyword,
        Int2x3Keyword,
        Int2x4Keyword,
        Int3x1Keyword,
        Int3x2Keyword,
        Int3x3Keyword,
        Int3x4Keyword,
        Int4x1Keyword,
        Int4x2Keyword,
        Int4x3Keyword,
        Int4x4Keyword,
        InterfaceKeyword,
        LineKeyword,
        LineAdjKeyword,
        LinearKeyword,
        LineStreamKeyword,
        MatrixKeyword,
        MessageKeyword,
        Min10FloatKeyword,
        Min10Float1Keyword,
        Min10Float2Keyword,
        Min10Float3Keyword,
        Min10Float4Keyword,
        Min10Float1x1Keyword,
        Min10Float1x2Keyword,
        Min10Float1x3Keyword,
        Min10Float1x4Keyword,
        Min10Float2x1Keyword,
        Min10Float2x2Keyword,
        Min10Float2x3Keyword,
        Min10Float2x4Keyword,
        Min10Float3x1Keyword,
        Min10Float3x2Keyword,
        Min10Float3x3Keyword,
        Min10Float3x4Keyword,
        Min10Float4x1Keyword,
        Min10Float4x2Keyword,
        Min10Float4x3Keyword,
        Min10Float4x4Keyword,
        Min12IntKeyword,
        Min12Int1Keyword,
        Min12Int2Keyword,
        Min12Int3Keyword,
        Min12Int4Keyword,
        Min12Int1x1Keyword,
        Min12Int1x2Keyword,
        Min12Int1x3Keyword,
        Min12Int1x4Keyword,
        Min12Int2x1Keyword,
        Min12Int2x2Keyword,
        Min12Int2x3Keyword,
        Min12Int2x4Keyword,
        Min12Int3x1Keyword,
        Min12Int3x2Keyword,
        Min12Int3x3Keyword,
        Min12Int3x4Keyword,
        Min12Int4x1Keyword,
        Min12Int4x2Keyword,
        Min12Int4x3Keyword,
        Min12Int4x4Keyword,
        Min12UintKeyword,
        Min12Uint1Keyword,
        Min12Uint2Keyword,
        Min12Uint3Keyword,
        Min12Uint4Keyword,
        Min12Uint1x1Keyword,
        Min12Uint1x2Keyword,
        Min12Uint1x3Keyword,
        Min12Uint1x4Keyword,
        Min12Uint2x1Keyword,
        Min12Uint2x2Keyword,
        Min12Uint2x3Keyword,
        Min12Uint2x4Keyword,
        Min12Uint3x1Keyword,
        Min12Uint3x2Keyword,
        Min12Uint3x3Keyword,
        Min12Uint3x4Keyword,
        Min12Uint4x1Keyword,
        Min12Uint4x2Keyword,
        Min12Uint4x3Keyword,
        Min12Uint4x4Keyword,
        Min16FloatKeyword,
        Min16Float1Keyword,
        Min16Float2Keyword,
        Min16Float3Keyword,
        Min16Float4Keyword,
        Min16Float1x1Keyword,
        Min16Float1x2Keyword,
        Min16Float1x3Keyword,
        Min16Float1x4Keyword,
        Min16Float2x1Keyword,
        Min16Float2x2Keyword,
        Min16Float2x3Keyword,
        Min16Float2x4Keyword,
        Min16Float3x1Keyword,
        Min16Float3x2Keyword,
        Min16Float3x3Keyword,
        Min16Float3x4Keyword,
        Min16Float4x1Keyword,
        Min16Float4x2Keyword,
        Min16Float4x3Keyword,
        Min16Float4x4Keyword,
        Min16IntKeyword,
        Min16Int1Keyword,
        Min16Int2Keyword,
        Min16Int3Keyword,
        Min16Int4Keyword,
        Min16Int1x1Keyword,
        Min16Int1x2Keyword,
        Min16Int1x3Keyword,
        Min16Int1x4Keyword,
        Min16Int2x1Keyword,
        Min16Int2x2Keyword,
        Min16Int2x3Keyword,
        Min16Int2x4Keyword,
        Min16Int3x1Keyword,
        Min16Int3x2Keyword,
        Min16Int3x3Keyword,
        Min16Int3x4Keyword,
        Min16Int4x1Keyword,
        Min16Int4x2Keyword,
        Min16Int4x3Keyword,
        Min16Int4x4Keyword,
        Min16UintKeyword,
        Min16Uint1Keyword,
        Min16Uint2Keyword,
        Min16Uint3Keyword,
        Min16Uint4Keyword,
        Min16Uint1x1Keyword,
        Min16Uint1x2Keyword,
        Min16Uint1x3Keyword,
        Min16Uint1x4Keyword,
        Min16Uint2x1Keyword,
        Min16Uint2x2Keyword,
        Min16Uint2x3Keyword,
        Min16Uint2x4Keyword,
        Min16Uint3x1Keyword,
        Min16Uint3x2Keyword,
        Min16Uint3x3Keyword,
        Min16Uint3x4Keyword,
        Min16Uint4x1Keyword,
        Min16Uint4x2Keyword,
        Min16Uint4x3Keyword,
        Min16Uint4x4Keyword,
        NamespaceKeyword,
        NointerpolationKeyword,
        NoperspectiveKeyword,
        NullKeyword,
        OutKeyword,
        OutputPatchKeyword,
        PackMatrixKeyword,
        PackoffsetKeyword,
        PassKeyword,
        PayloadKeyword,
        PointKeyword,
        PointStreamKeyword,
        PragmaKeyword,
        PreciseKeyword,
        PrimitivesKeyword,
        RasterizerOrderedBufferKeyword,
        RasterizerOrderedByteAddressBufferKeyword,
        RasterizerOrderedStructuredBufferKeyword,
        RasterizerOrderedTexture1DKeyword,
        RasterizerOrderedTexture1DArrayKeyword,
        RasterizerOrderedTexture2DKeyword,
        RasterizerOrderedTexture2DArrayKeyword,
        RasterizerOrderedTexture3DKeyword,
        RasterizerStateKeyword,
        RegisterKeyword,
        ReturnKeyword,
        RowMajorKeyword,
        RWBufferKeyword,
        RWByteAddressBufferKeyword,
        RWStructuredBufferKeyword,
        RWTexture1DKeyword,
        RWTexture1DArrayKeyword,
        RWTexture2DKeyword,
        RWTexture2DArrayKeyword,
        RWTexture3DKeyword,
        SamplerKeyword,
        Sampler1DKeyword,
        Sampler2DKeyword,
        Sampler3DKeyword,
        SamplerCubeKeyword,
        SamplerComparisonStateKeyword,
        SamplerStateKeyword,
        SamplerStateLegacyKeyword,
        SharedKeyword,
        SNormKeyword,
        StaticKeyword,
        StringKeyword,
        StructKeyword,
        StructuredBufferKeyword,
        SwitchKeyword,
        TBufferKeyword,
        TechniqueKeyword,
        Technique10Keyword,
        Technique11Keyword,
        TextureKeyword,
        Texture2DLegacyKeyword,
        TextureCubeLegacyKeyword,
        Texture1DKeyword,
        Texture1DArrayKeyword,
        Texture2DKeyword,
        Texture2DArrayKeyword,
        Texture2DMSKeyword,
        Texture2DMSArrayKeyword,
        Texture3DKeyword,
        TextureCubeKeyword,
        TextureCubeArrayKeyword,
        TriangleKeyword,
        TriangleAdjKeyword,
        TriangleStreamKeyword,
        TypedefKeyword,
        UniformKeyword,
        UNormKeyword,
        UintKeyword,
        Uint1Keyword,
        Uint2Keyword,
        Uint3Keyword,
        Uint4Keyword,
        Uint1x1Keyword,
        Uint1x2Keyword,
        Uint1x3Keyword,
        Uint1x4Keyword,
        Uint2x1Keyword,
        Uint2x2Keyword,
        Uint2x3Keyword,
        Uint2x4Keyword,
        Uint3x1Keyword,
        Uint3x2Keyword,
        Uint3x3Keyword,
        Uint3x4Keyword,
        Uint4x1Keyword,
        Uint4x2Keyword,
        Uint4x3Keyword,
        Uint4x4Keyword,
        VectorKeyword,
        VerticesKeyword,
        VolatileKeyword,
        VoidKeyword,
        WarningKeyword,
        WhileKeyword,
        TrueKeyword,
        FalseKeyword,
        UnsignedKeyword,
        DwordKeyword,
        CompileFragmentKeyword,
        DepthStencilViewKeyword,
        PixelfragmentKeyword,
        RenderTargetViewKeyword,
        StateblockStateKeyword,
        StateblockKeyword,

        OpenParenToken,
        CloseParenToken,
        OpenBracketToken,
        CloseBracketToken,
        OpenBraceToken,
        CloseBraceToken,
        SemiToken,
        CommaToken,
        LessThanToken,
        LessThanEqualsToken,
        GreaterThanToken,
        GreaterThanEqualsToken,
        LessThanLessThanToken,
        GreaterThanGreaterThanToken,
        PlusToken,
        PlusPlusToken,
        MinusToken,
        MinusMinusToken,
        AsteriskToken,
        SlashToken,
        PercentToken,
        AmpersandToken,
        BarToken,
        AmpersandAmpersandToken,
        BarBarToken,
        CaretToken,
        NotToken,
        TildeToken,
        QuestionToken,
        ColonToken,
        ColonColonToken,
        EqualsToken,
        AsteriskEqualsToken,
        SlashEqualsToken,
        PercentEqualsToken,
        PlusEqualsToken,
        MinusEqualsToken,
        LessThanLessThanEqualsToken,
        GreaterThanGreaterThanEqualsToken,
        AmpersandEqualsToken,
        CaretEqualsToken,
        BarEqualsToken,
        EqualsEqualsToken,
        ExclamationEqualsToken,
        DotToken,
        HashToken,
        HashHashToken,

        IdentifierToken,
        IntegerLiteralToken,
        FloatLiteralToken,
        CharacterLiteralToken,
        StringLiteralToken,

        DefineDirectiveKeyword,
        IncludeDirectiveKeyword,
        LineDirectiveKeyword,
        UndefDirectiveKeyword,
        ErrorDirectiveKeyword,
        PragmaDirectiveKeyword,
        IfDirectiveKeyword,
        IfdefDirectiveKeyword,
        IfndefDirectiveKeyword,
        ElifDirectiveKeyword,
        ElseDirectiveKeyword,
        EndifDirectiveKeyword,
        SystemIncludeLiteralToken,
        EndDirectiveToken,
        OpenFunctionLikeMacroParenToken,
    }

    [PrettyEnum(PrettyEnumStyle.AllLowerCase)]
    public enum ScalarType
    {
        Void,
        Bool,
        Int,
        Uint,
        Half,
        Float,
        Double,
        Min16Float,
        Min10Float,
        Min16Int,
        Min12Int,
        Min16Uint,
        Min12Uint,
        String,
        [PrettyName("unorm float")] UNormFloat,
        [PrettyName("snorm float")] SNormFloat,
    }

    [PrettyEnum(PrettyEnumStyle.AllLowerCase)]
    public enum LiteralKind
    {
        String,
        Float,
        [PrettyName("int")] Integer,
        [PrettyName("char")] Character,
        [PrettyName("bool")] Boolean,
        [PrettyName("NULL")] Null,
    }

    [PrettyEnum(PrettyEnumStyle.AllLowerCase)]
    public enum RegisterKind
    {
        [PrettyName("t")] Texture,
        [PrettyName("s")] Sampler,
        [PrettyName("u")] UAV,
        [PrettyName("b")] Buffer,
    }

    [PrettyEnum(PrettyEnumStyle.PascalCase)]
    public enum PredefinedObjectType
    {
        [PrettyName("texture")] Texture,
        Texture1D,
        Texture1DArray,
        Texture2D,
        Texture2DArray,
        Texture3D,
        TextureCube,
        TextureCubeArray,
        Texture2DMS,
        Texture2DMSArray,
        RWTexture1D,
        RWTexture1DArray,
        RWTexture2D,
        RWTexture2DArray,
        RWTexture3D,
        AppendStructuredBuffer,
        Buffer,
        ByteAddressBuffer,
        ConsumeStructuredBuffer,
        StructuredBuffer,
        ConstantBuffer,
        RasterizerOrderedBuffer,
        RasterizerOrderedByteAddressBuffer,
        RasterizerOrderedStructuredBuffer,
        RasterizerOrderedTexture1D,
        RasterizerOrderedTexture1DArray,
        RasterizerOrderedTexture2D,
        RasterizerOrderedTexture2DArray,
        RasterizerOrderedTexture3D,
        RWBuffer,
        RWByteAddressBuffer,
        RWStructuredBuffer,
        InputPatch,
        OutputPatch,
        PointStream,
        LineStream,
        TriangleStream,
        BlendState,
        DepthStencilState,
        RasterizerState,
        [PrettyName("sampler")] Sampler,
        [PrettyName("sampler1D")] Sampler1D,
        [PrettyName("sampler2D")] Sampler2D,
        [PrettyName("sampler3D")] Sampler3D,
        [PrettyName("samplerCUBE")] SamplerCube,
        SamplerState,
        SamplerComparisonState,
        BuiltInTriangleIntersectionAttributes,
        RayDesc,
        RaytracingAccelerationStructure
    }

    [PrettyEnum(PrettyEnumStyle.AllLowerCase)]
    public enum BindingModifier
    {
        Const,
        [PrettyName("row_major")] RowMajor,
        [PrettyName("column_major")] ColumnMajor,
        Export,
        Extern,
        Inline,
        Precise,
        Shared,
        Globallycoherent,
        Groupshared,
        Static,
        Uniform,
        Volatile,
        SNorm,
        UNorm,
        Linear,
        Centroid,
        Nointerpolation,
        Noperspective,
        Sample,

        In,
        Out,
        Inout,
        Point,
        Triangle,
        TriangleAdj,
        Line,
        LineAdj,
    }

    [PrettyEnum(PrettyEnumStyle.PascalCase)]
    public enum StateKind
    {
        SamplerState,
        SamplerComparisonState,
        BlendState,
    }

    [PrettyEnum(PrettyEnumStyle.AllLowerCase)]
    public enum OperatorKind
    {
        [PrettyName("=")] Assignment,
        [PrettyName("+=")] PlusAssignment,
        [PrettyName("-=")] MinusAssignment,
        [PrettyName("*=")] MulAssignment,
        [PrettyName("/=")] DivAssignment,
        [PrettyName("%=")] ModAssignment,
        [PrettyName("<<=")] ShiftLeftAssignment,
        [PrettyName(">>=")] ShiftRightAssignment,
        [PrettyName("&=")] BitwiseAndAssignment,
        [PrettyName("^=")] BitwiseXorAssignment,
        [PrettyName("|=")] BitwiseOrAssignment,

        [PrettyName("||")] LogicalOr,
        [PrettyName("&&")] LogicalAnd,
        [PrettyName("|")] BitwiseOr,
        [PrettyName("&")] BitwiseAnd,
        [PrettyName("^")] BitwiseXor,

        [PrettyName(",")] Compound,
        [PrettyName("?")] Ternary,

        [PrettyName("==")] Equals,
        [PrettyName("!=")] NotEquals,
        [PrettyName("<")] LessThan,
        [PrettyName("<=")] LessThanOrEquals,
        [PrettyName(">")] GreaterThan,
        [PrettyName(">=")] GreaterThanOrEquals,

        [PrettyName("<<")] ShiftLeft,
        [PrettyName(">>")] ShiftRight,

        [PrettyName("+")] Plus,
        [PrettyName("-")] Minus,
        [PrettyName("*")] Mul,
        [PrettyName("/")] Div,
        [PrettyName("%")] Mod,

        [PrettyName("++")] Increment,
        [PrettyName("--")] Decrement,

        [PrettyName("!")] Not,
        [PrettyName("~")] BitFlip,
    }

    public enum OperatorFixity
    {
        Prefix,
        Postfix,
        Infix,
    }

    public enum OperatorPrecedence
    {                 // Associativity:
        Compound,     // left
        Assignment,   // right
        Ternary,      // right
        LogicalOr,    // left
        LogicalAnd,   // left
        BitwiseOr,    // left
        BitwiseXor,   // left
        BitwiseAnd,   // left
        Equality,     // left
        Comparison,   // left
        BitShift,     // left
        AddSub,       // left
        MulDivMod,    // left
        PrefixUnary,  // right
        PostFixUnary, // left
    }
    #endregion

    #region Syntax tree
    public abstract class HLSLSyntaxNode : SyntaxNode<HLSLSyntaxNode>
    {
        public abstract void Accept(HLSLSyntaxVisitor visitor);
        public abstract T Accept<T>(HLSLSyntaxVisitor<T> visitor);

        public override SourceSpan Span => span;

        [DebuggerBrowsable(DebuggerBrowsableState.Never)]
        private SourceSpan span;

        public override SourceSpan OriginalSpan => originalSpan;

        [DebuggerBrowsable(DebuggerBrowsableState.Never)]
        private SourceSpan originalSpan;

        public List<HLSLToken> Tokens => tokens;

        [DebuggerBrowsable(DebuggerBrowsableState.Never)]
        private List<HLSLToken> tokens;

        public string GetCodeInSourceText(string sourceText) => Span.GetCodeInSourceText(sourceText);
        public string GetPrettyPrintedCode()
        {
            HLSLPrinter printer = new HLSLPrinter();
            printer.Visit(this);
            return printer.Text;
        }

        public HLSLSyntaxNode(List<HLSLToken> tokens)
        {
            if (tokens.Count > 0)
            {
                this.span = SourceSpan.Between(tokens.First().Span, tokens.Last().Span);
                this.originalSpan = SourceSpan.Between(tokens.First().OriginalSpan, tokens.Last().OriginalSpan);
            }
            this.tokens = tokens;
        }
    }

    public class IdentifierNode : HLSLSyntaxNode
    {
        public string Identifier { get; set; }

        public static implicit operator string(IdentifierNode node) => node.Identifier;
        public override string ToString() => Identifier;

        protected override IEnumerable<HLSLSyntaxNode> GetChildren =>
            Enumerable.Empty<HLSLSyntaxNode>();

        public override void Accept(HLSLSyntaxVisitor visitor) => visitor.VisitIdentifierNode(this);
        public override T Accept<T>(HLSLSyntaxVisitor<T> visitor) => visitor.VisitIdentifierNode(this);

        public IdentifierNode(List<HLSLToken> tokens) : base(tokens) { }
    }

    public abstract class FunctionNode : HLSLSyntaxNode
    {
        public List<AttributeNode> Attributes { get; set; }
        public List<BindingModifier> Modifiers { get; set; }
        public TypeNode ReturnType { get; set; }
        public UserDefinedNamedTypeNode Name { get; set; }
        public List<FormalParameterNode> Parameters { get; set; }
        public SemanticNode Semantic { get; set; }

        protected override IEnumerable<HLSLSyntaxNode> GetChildren =>
            MergeChildren(Attributes, Child(ReturnType), Child(Name), Parameters, OptionalChild(Semantic));

        public FunctionNode(List<HLSLToken> tokens) : base(tokens) { }
    }

    public class FormalParameterNode : HLSLSyntaxNode
    {
        public List<AttributeNode> Attributes { get; set; }
        public List<BindingModifier> Modifiers { get; set; }
        public TypeNode ParamType { get; set; }
        public VariableDeclaratorNode Declarator { get; set; }

        protected override IEnumerable<HLSLSyntaxNode> GetChildren =>
            MergeChildren(Attributes, Child(ParamType), Child(Declarator));

        public override void Accept(HLSLSyntaxVisitor visitor) => visitor.VisitFormalParameterNode(this);
        public override T Accept<T>(HLSLSyntaxVisitor<T> visitor) => visitor.VisitFormalParameterNode(this);

        public FormalParameterNode(List<HLSLToken> tokens) : base(tokens) { }   
    }

    public class VariableDeclaratorNode : HLSLSyntaxNode
    {
        public IdentifierNode Name { get; set; }
        public List<ArrayRankNode> ArrayRanks { get; set; }
        public List<VariableDeclaratorQualifierNode> Qualifiers { get; set; }
        public List<VariableDeclarationStatementNode> Annotations { get; set; }
        public InitializerNode Initializer { get; set; } // Optional

        protected override IEnumerable<HLSLSyntaxNode> GetChildren =>
            MergeChildren(Child(Name), ArrayRanks, Qualifiers, Annotations, OptionalChild(Initializer));

        public override void Accept(HLSLSyntaxVisitor visitor) => visitor.VisitVariableDeclaratorNode(this);
        public override T Accept<T>(HLSLSyntaxVisitor<T> visitor) => visitor.VisitVariableDeclaratorNode(this);

        public VariableDeclaratorNode(List<HLSLToken> tokens) : base(tokens) { }   
    }

    public class ArrayRankNode : HLSLSyntaxNode
    {
        public ExpressionNode Dimension { get; set; } // Optional

        protected override IEnumerable<HLSLSyntaxNode> GetChildren =>
            OptionalChild(Dimension);

        public override void Accept(HLSLSyntaxVisitor visitor) => visitor.VisitArrayRankNode(this);
        public override T Accept<T>(HLSLSyntaxVisitor<T> visitor) => visitor.VisitArrayRankNode(this);

        public ArrayRankNode(List<HLSLToken> tokens) : base(tokens) { }   
    }

    public abstract class InitializerNode : HLSLSyntaxNode
    {
        public InitializerNode(List<HLSLToken> tokens) : base(tokens) { }   
    }

    public class ValueInitializerNode : InitializerNode
    {
        public ExpressionNode Expression { get; set; }

        protected override IEnumerable<HLSLSyntaxNode> GetChildren =>
            Child(Expression);

        public override void Accept(HLSLSyntaxVisitor visitor) => visitor.VisitValueInitializerNode(this);
        public override T Accept<T>(HLSLSyntaxVisitor<T> visitor) => visitor.VisitValueInitializerNode(this);

        public ValueInitializerNode(List<HLSLToken> tokens) : base(tokens) { }   
    }

    // BlendState, SamplerState, etc.
    public class StateInitializerNode : InitializerNode
    {
        public List<StatePropertyNode> States { get; set; }

        protected override IEnumerable<HLSLSyntaxNode> GetChildren =>
            States;

        public override void Accept(HLSLSyntaxVisitor visitor) => visitor.VisitStateInitializerNode(this);
        public override T Accept<T>(HLSLSyntaxVisitor<T> visitor) => visitor.VisitStateInitializerNode(this);

        public StateInitializerNode(List<HLSLToken> tokens) : base(tokens) { }   
    }

    public class StateArrayInitializerNode : InitializerNode
    {
        public List<StateInitializerNode> Initializers { get; set; }

        protected override IEnumerable<HLSLSyntaxNode> GetChildren =>
            Initializers;

        public override void Accept(HLSLSyntaxVisitor visitor) => visitor.VisitStateArrayInitializerNode(this);
        public override T Accept<T>(HLSLSyntaxVisitor<T> visitor) => visitor.VisitStateArrayInitializerNode(this);

        public StateArrayInitializerNode(List<HLSLToken> tokens) : base(tokens) { }   
    }

    public class FunctionDeclarationNode : FunctionNode
    {
        public override void Accept(HLSLSyntaxVisitor visitor) => visitor.VisitFunctionDeclarationNode(this);
        public override T Accept<T>(HLSLSyntaxVisitor<T> visitor) => visitor.VisitFunctionDeclarationNode(this);

        public FunctionDeclarationNode(List<HLSLToken> tokens) : base(tokens) { }   
    }

    public class FunctionDefinitionNode : FunctionNode
    {
        public BlockNode Body { get; set; }

        public bool BodyIsSingleStatement => !(Body is BlockNode);

        protected override IEnumerable<HLSLSyntaxNode> GetChildren =>
            MergeChildren(base.GetChildren, Child(Body));

        public override void Accept(HLSLSyntaxVisitor visitor) => visitor.VisitFunctionDefinitionNode(this);
        public override T Accept<T>(HLSLSyntaxVisitor<T> visitor) => visitor.VisitFunctionDefinitionNode(this);

        public FunctionDefinitionNode(List<HLSLToken> tokens) : base(tokens) { }   
    }

    public class StructDefinitionNode : StatementNode
    {
        public StructTypeNode StructType { get; set; }

        protected override IEnumerable<HLSLSyntaxNode> GetChildren =>
            MergeChildren(base.GetChildren, Child(StructType));

        public override void Accept(HLSLSyntaxVisitor visitor) => visitor.VisitStructDefinitionNode(this);
        public override T Accept<T>(HLSLSyntaxVisitor<T> visitor) => visitor.VisitStructDefinitionNode(this);

        public StructDefinitionNode(List<HLSLToken> tokens) : base(tokens) { }   
    }

    public class InterfaceDefinitionNode : StatementNode
    {
        public UserDefinedNamedTypeNode Name { get; set; }
        public List<FunctionDeclarationNode> Functions { get; set; }

        protected override IEnumerable<HLSLSyntaxNode> GetChildren =>
            MergeChildren(base.GetChildren, Child(Name), Functions);

        public override void Accept(HLSLSyntaxVisitor visitor) => visitor.VisitInterfaceDefinitionNode(this);
        public override T Accept<T>(HLSLSyntaxVisitor<T> visitor) => visitor.VisitInterfaceDefinitionNode(this);

        public InterfaceDefinitionNode(List<HLSLToken> tokens) : base(tokens) { }   
    }

    public class ConstantBufferNode : HLSLSyntaxNode
    {
        public UserDefinedNamedTypeNode Name { get; set; }
        public RegisterLocationNode RegisterLocation { get; set; } // Optional
        public List<VariableDeclarationStatementNode> Declarations { get; set; }
        public bool IsTextureBuffer { get; set; }

        protected override IEnumerable<HLSLSyntaxNode> GetChildren =>
            MergeChildren(Child(Name), OptionalChild(RegisterLocation), Declarations);

        public override void Accept(HLSLSyntaxVisitor visitor) => visitor.VisitConstantBufferNode(this);
        public override T Accept<T>(HLSLSyntaxVisitor<T> visitor) => visitor.VisitConstantBufferNode(this);

        public ConstantBufferNode(List<HLSLToken> tokens) : base(tokens) { }   
    }

    public class NamespaceNode : HLSLSyntaxNode
    {
        public UserDefinedNamedTypeNode Name { get; set; }
        public List<HLSLSyntaxNode> Declarations { get; set; }

        protected override IEnumerable<HLSLSyntaxNode> GetChildren =>
            MergeChildren(Child(Name), Declarations);

        public override void Accept(HLSLSyntaxVisitor visitor) => visitor.VisitNamespaceNode(this);
        public override T Accept<T>(HLSLSyntaxVisitor<T> visitor) => visitor.VisitNamespaceNode(this);

        public NamespaceNode(List<HLSLToken> tokens) : base(tokens) { }
    }

    public class TypedefNode : StatementNode
    {
        public TypeNode FromType { get; set; }
        public List<UserDefinedNamedTypeNode> ToNames { get; set; }
        public bool IsConst { get; set; }

        protected override IEnumerable<HLSLSyntaxNode> GetChildren =>
            MergeChildren(base.GetChildren, Child(FromType), ToNames);

        public override void Accept(HLSLSyntaxVisitor visitor) => visitor.VisitTypedefNode(this);
        public override T Accept<T>(HLSLSyntaxVisitor<T> visitor) => visitor.VisitTypedefNode(this);

        public TypedefNode(List<HLSLToken> tokens) : base(tokens) { }   
    }

    public abstract class VariableDeclaratorQualifierNode : HLSLSyntaxNode
    {
        public VariableDeclaratorQualifierNode(List<HLSLToken> tokens) : base(tokens) { }   
    }

    public class SemanticNode : VariableDeclaratorQualifierNode
    {
        public IdentifierNode Name { get; set; }

        protected override IEnumerable<HLSLSyntaxNode> GetChildren =>
            Child(Name);

        public override void Accept(HLSLSyntaxVisitor visitor) => visitor.VisitSemanticNode(this);
        public override T Accept<T>(HLSLSyntaxVisitor<T> visitor) => visitor.VisitSemanticNode(this);

        public SemanticNode(List<HLSLToken> tokens) : base(tokens) { }   
    }

    public class RegisterLocationNode : VariableDeclaratorQualifierNode
    {
        public RegisterKind Kind { get; set; }
        public int Location { get; set; }
        public int? Space { get; set; } // Optional

        protected override IEnumerable<HLSLSyntaxNode> GetChildren =>
            Enumerable.Empty<HLSLSyntaxNode>();

        public override void Accept(HLSLSyntaxVisitor visitor) => visitor.VisitRegisterLocationNode(this);
        public override T Accept<T>(HLSLSyntaxVisitor<T> visitor) => visitor.VisitRegisterLocationNode(this);

        public RegisterLocationNode(List<HLSLToken> tokens) : base(tokens) { }   
    }

    public class PackoffsetNode : VariableDeclaratorQualifierNode
    {
        public int Location { get; set; }
        public string Swizzle { get; set; } // Optional

        protected override IEnumerable<HLSLSyntaxNode> GetChildren =>
            Enumerable.Empty<HLSLSyntaxNode>();

        public override void Accept(HLSLSyntaxVisitor visitor) => visitor.VisitPackoffsetNode(this);
        public override T Accept<T>(HLSLSyntaxVisitor<T> visitor) => visitor.VisitPackoffsetNode(this);

        public PackoffsetNode(List<HLSLToken> tokens) : base(tokens) { }   
    }

    public abstract class StatementNode : HLSLSyntaxNode
    {
        public List<AttributeNode> Attributes { get; set; }

        protected override IEnumerable<HLSLSyntaxNode> GetChildren =>
            Attributes;

        public StatementNode(List<HLSLToken> tokens) : base(tokens) { }   
    }

    public class BlockNode : StatementNode
    {
        public List<StatementNode> Statements { get; set; }

        protected override IEnumerable<HLSLSyntaxNode> GetChildren =>
            MergeChildren(base.GetChildren, Statements);

        public override void Accept(HLSLSyntaxVisitor visitor) => visitor.VisitBlockNode(this);
        public override T Accept<T>(HLSLSyntaxVisitor<T> visitor) => visitor.VisitBlockNode(this);

        public BlockNode(List<HLSLToken> tokens) : base(tokens) { }   
    }

    public class VariableDeclarationStatementNode : StatementNode
    {
        public List<BindingModifier> Modifiers { get; set; }
        public TypeNode Kind { get; set; }
        public List<VariableDeclaratorNode> Declarators { get; set; }

        protected override IEnumerable<HLSLSyntaxNode> GetChildren =>
            MergeChildren(base.GetChildren, Child(Kind), Declarators);

        public override void Accept(HLSLSyntaxVisitor visitor) => visitor.VisitVariableDeclarationStatementNode(this);
        public override T Accept<T>(HLSLSyntaxVisitor<T> visitor) => visitor.VisitVariableDeclarationStatementNode(this);

        public VariableDeclarationStatementNode(List<HLSLToken> tokens) : base(tokens) { }   
    }

    public class ReturnStatementNode : StatementNode
    {
        public ExpressionNode Expression { get; set; } // Optional

        protected override IEnumerable<HLSLSyntaxNode> GetChildren => 
            MergeChildren(base.GetChildren, OptionalChild(Expression));

        public override void Accept(HLSLSyntaxVisitor visitor) => visitor.VisitReturnStatementNode(this);
        public override T Accept<T>(HLSLSyntaxVisitor<T> visitor) => visitor.VisitReturnStatementNode(this);

        public ReturnStatementNode(List<HLSLToken> tokens) : base(tokens) { }   
    }

    public class BreakStatementNode : StatementNode
    {
        public override void Accept(HLSLSyntaxVisitor visitor) => visitor.VisitBreakStatementNode(this);
        public override T Accept<T>(HLSLSyntaxVisitor<T> visitor) => visitor.VisitBreakStatementNode(this);

        public BreakStatementNode(List<HLSLToken> tokens) : base(tokens) { }   
    }

    public class ContinueStatementNode : StatementNode
    {
        public override void Accept(HLSLSyntaxVisitor visitor) => visitor.VisitContinueStatementNode(this);
        public override T Accept<T>(HLSLSyntaxVisitor<T> visitor) => visitor.VisitContinueStatementNode(this);

        public ContinueStatementNode(List<HLSLToken> tokens) : base(tokens) { }   
    }

    public class DiscardStatementNode : StatementNode
    {
        public override void Accept(HLSLSyntaxVisitor visitor) => visitor.VisitDiscardStatementNode(this);
        public override T Accept<T>(HLSLSyntaxVisitor<T> visitor) => visitor.VisitDiscardStatementNode(this);

        public DiscardStatementNode(List<HLSLToken> tokens) : base(tokens) { }   
    }

    public class EmptyStatementNode : StatementNode
    {
        public override void Accept(HLSLSyntaxVisitor visitor) => visitor.VisitEmptyStatementNode(this);
        public override T Accept<T>(HLSLSyntaxVisitor<T> visitor) => visitor.VisitEmptyStatementNode(this);

        public EmptyStatementNode(List<HLSLToken> tokens) : base(tokens) { }   
    }

    public class ForStatementNode : StatementNode
    {
        public VariableDeclarationStatementNode Declaration { get; set; } // This is mutually exclusive with Initializer
        public ExpressionNode Initializer { get; set; }

        public ExpressionNode Condition { get; set; } // Optional
        public ExpressionNode Increment { get; set; } // Optional
        public StatementNode Body { get; set; }

        public bool FirstIsDeclaration => Declaration != null;
        public bool FirstIsExpression => Initializer != null;
        public bool BodyIsSingleStatement => !(Body is BlockNode);

        protected override IEnumerable<HLSLSyntaxNode> GetChildren =>
            MergeChildren(base.GetChildren, OptionalChild(Declaration), OptionalChild(Initializer), OptionalChild(Condition), OptionalChild(Increment), Child(Body));

        public override void Accept(HLSLSyntaxVisitor visitor) => visitor.VisitForStatementNode(this);
        public override T Accept<T>(HLSLSyntaxVisitor<T> visitor) => visitor.VisitForStatementNode(this);

        public ForStatementNode(List<HLSLToken> tokens) : base(tokens) { }   
    }

    public class WhileStatementNode : StatementNode
    {
        public ExpressionNode Condition { get; set; }
        public StatementNode Body { get; set; }

        public bool BodyIsSingleStatement => !(Body is BlockNode);

        protected override IEnumerable<HLSLSyntaxNode> GetChildren =>
            MergeChildren(base.GetChildren, Child(Condition), Child(Body));

        public override void Accept(HLSLSyntaxVisitor visitor) => visitor.VisitWhileStatementNode(this);
        public override T Accept<T>(HLSLSyntaxVisitor<T> visitor) => visitor.VisitWhileStatementNode(this);

        public WhileStatementNode(List<HLSLToken> tokens) : base(tokens) { }   
    }

    public class DoWhileStatementNode : StatementNode
    {
        public StatementNode Body { get; set; }
        public ExpressionNode Condition { get; set; }

        public bool BodyIsSingleStatement => !(Body is BlockNode);

        protected override IEnumerable<HLSLSyntaxNode> GetChildren =>
            MergeChildren(base.GetChildren, Child(Body), Child(Condition));

        public override void Accept(HLSLSyntaxVisitor visitor) => visitor.VisitDoWhileStatementNode(this);
        public override T Accept<T>(HLSLSyntaxVisitor<T> visitor) => visitor.VisitDoWhileStatementNode(this);

        public DoWhileStatementNode(List<HLSLToken> tokens) : base(tokens) { }   
    }

    public class IfStatementNode : StatementNode
    {
        public ExpressionNode Condition { get; set; }
        public StatementNode Body { get; set; }
        public StatementNode ElseClause { get; set; } // Optional

        public bool BodyIsSingleStatement => !(Body is BlockNode);
        public bool BodyIsElseIfClause => Parent is IfStatementNode;
        public bool ElseClauseIsSingleStatement => !(ElseClause is BlockNode);
        public bool ElseClauseIsElseIfClause => ElseClause is IfStatementNode;

        protected override IEnumerable<HLSLSyntaxNode> GetChildren =>
            MergeChildren(base.GetChildren, Child(Condition), Child(Body), OptionalChild(ElseClause));

        public override void Accept(HLSLSyntaxVisitor visitor) => visitor.VisitIfStatementNode(this);
        public override T Accept<T>(HLSLSyntaxVisitor<T> visitor) => visitor.VisitIfStatementNode(this);

        public IfStatementNode(List<HLSLToken> tokens) : base(tokens) { }   
    }

    public class SwitchStatementNode : StatementNode
    {
        public ExpressionNode Expression { get; set; }
        public List<SwitchClauseNode> Clauses { get; set; }

        protected override IEnumerable<HLSLSyntaxNode> GetChildren =>
            MergeChildren(base.GetChildren, Child(Expression), Clauses);

        public override void Accept(HLSLSyntaxVisitor visitor) => visitor.VisitSwitchStatementNode(this);
        public override T Accept<T>(HLSLSyntaxVisitor<T> visitor) => visitor.VisitSwitchStatementNode(this);

        public SwitchStatementNode(List<HLSLToken> tokens) : base(tokens) { }   
    }

    public class SwitchClauseNode : HLSLSyntaxNode
    {
        public List<SwitchLabelNode> Labels { get; set; }
        public List<StatementNode> Statements { get; set; }

        protected override IEnumerable<HLSLSyntaxNode> GetChildren =>
            MergeChildren(Labels, Statements);

        public override void Accept(HLSLSyntaxVisitor visitor) => visitor.VisitSwitchClauseNode(this);
        public override T Accept<T>(HLSLSyntaxVisitor<T> visitor) => visitor.VisitSwitchClauseNode(this);

        public SwitchClauseNode(List<HLSLToken> tokens) : base(tokens) { }   
    }

    public abstract class SwitchLabelNode : HLSLSyntaxNode
    {
        public SwitchLabelNode(List<HLSLToken> tokens) : base(tokens) { }   
    }

    public class SwitchCaseLabelNode : SwitchLabelNode
    {
        public ExpressionNode Value { get; set; }

        protected override IEnumerable<HLSLSyntaxNode> GetChildren =>
            Child(Value);

        public override void Accept(HLSLSyntaxVisitor visitor) => visitor.VisitSwitchCaseLabelNode(this);
        public override T Accept<T>(HLSLSyntaxVisitor<T> visitor) => visitor.VisitSwitchCaseLabelNode(this);

        public SwitchCaseLabelNode(List<HLSLToken> tokens) : base(tokens) { }   
    }

    public class SwitchDefaultLabelNode : SwitchLabelNode
    {
        protected override IEnumerable<HLSLSyntaxNode> GetChildren =>
            Enumerable.Empty<HLSLSyntaxNode>();

        public override void Accept(HLSLSyntaxVisitor visitor) => visitor.VisitSwitchDefaultLabelNode(this);
        public override T Accept<T>(HLSLSyntaxVisitor<T> visitor) => visitor.VisitSwitchDefaultLabelNode(this);

        public SwitchDefaultLabelNode(List<HLSLToken> tokens) : base(tokens) { }   
    }

    public class ExpressionStatementNode : StatementNode
    {
        public ExpressionNode Expression { get; set; }

        protected override IEnumerable<HLSLSyntaxNode> GetChildren =>
            MergeChildren(base.GetChildren, Child(Expression));

        public override void Accept(HLSLSyntaxVisitor visitor) => visitor.VisitExpressionStatementNode(this);
        public override T Accept<T>(HLSLSyntaxVisitor<T> visitor) => visitor.VisitExpressionStatementNode(this);

        public ExpressionStatementNode(List<HLSLToken> tokens) : base(tokens) { }   
    }

    public class AttributeNode : HLSLSyntaxNode
    {
        public IdentifierNode Name { get; set; }
        public List<LiteralExpressionNode> Arguments { get; set; }

        protected override IEnumerable<HLSLSyntaxNode> GetChildren =>
            MergeChildren(Child(Name), Arguments);

        public override void Accept(HLSLSyntaxVisitor visitor) => visitor.VisitAttributeNode(this);
        public override T Accept<T>(HLSLSyntaxVisitor<T> visitor) => visitor.VisitAttributeNode(this);

        public AttributeNode(List<HLSLToken> tokens) : base(tokens) { }   
    }

    public abstract class ExpressionNode : HLSLSyntaxNode
    {
        public ExpressionNode(List<HLSLToken> tokens) : base(tokens) { }   
    }

    public abstract class NamedExpressionNode : ExpressionNode
    {
        public abstract string GetName();
        public abstract string GetUnqualifiedName();

        public NamedExpressionNode(List<HLSLToken> tokens) : base(tokens) { }   
    }

    public class QualifiedIdentifierExpressionNode : NamedExpressionNode
    {
        public IdentifierExpressionNode Left { get; set; }
        public NamedExpressionNode Right { get; set; }

        public override string GetName() => $"{Left.GetName()}::{Right.GetName()}";
        public override string GetUnqualifiedName() => Right.GetUnqualifiedName();

        protected override IEnumerable<HLSLSyntaxNode> GetChildren =>
            MergeChildren(Child(Left), Child(Right));

        public override void Accept(HLSLSyntaxVisitor visitor) => visitor.VisitQualifiedIdentifierExpressionNode(this);
        public override T Accept<T>(HLSLSyntaxVisitor<T> visitor) => visitor.VisitQualifiedIdentifierExpressionNode(this);

        public QualifiedIdentifierExpressionNode(List<HLSLToken> tokens) : base(tokens) { }   
    }

    public class IdentifierExpressionNode : NamedExpressionNode
    {
        public IdentifierNode Name { get; set; }

        public override string GetName() => Name.Identifier;
        public override string GetUnqualifiedName() => Name.Identifier;

        protected override IEnumerable<HLSLSyntaxNode> GetChildren =>
            Child(Name);

        public override void Accept(HLSLSyntaxVisitor visitor) => visitor.VisitIdentifierExpressionNode(this);
        public override T Accept<T>(HLSLSyntaxVisitor<T> visitor) => visitor.VisitIdentifierExpressionNode(this);

        public IdentifierExpressionNode(List<HLSLToken> tokens) : base(tokens) { }   
    }

    public class LiteralExpressionNode : ExpressionNode
    {
        public string Lexeme { get; set; }
        public LiteralKind Kind { get; set; }

        protected override IEnumerable<HLSLSyntaxNode> GetChildren =>
            Enumerable.Empty<HLSLSyntaxNode>();

        public override void Accept(HLSLSyntaxVisitor visitor) => visitor.VisitLiteralExpressionNode(this);
        public override T Accept<T>(HLSLSyntaxVisitor<T> visitor) => visitor.VisitLiteralExpressionNode(this);

        public LiteralExpressionNode(List<HLSLToken> tokens) : base(tokens) { }   
    }

    public class AssignmentExpressionNode : ExpressionNode
    {
        public ExpressionNode Left { get; set; }
        public OperatorKind Operator { get; set; }
        public ExpressionNode Right { get; set; }

        protected override IEnumerable<HLSLSyntaxNode> GetChildren =>
            MergeChildren(Child(Left), Child(Right));

        public override void Accept(HLSLSyntaxVisitor visitor) => visitor.VisitAssignmentExpressionNode(this);
        public override T Accept<T>(HLSLSyntaxVisitor<T> visitor) => visitor.VisitAssignmentExpressionNode(this);

        public AssignmentExpressionNode(List<HLSLToken> tokens) : base(tokens) { }   
    }

    public class BinaryExpressionNode : ExpressionNode
    {
        public ExpressionNode Left { get; set; }
        public OperatorKind Operator { get; set; }
        public ExpressionNode Right { get; set; }

        protected override IEnumerable<HLSLSyntaxNode> GetChildren =>
            MergeChildren(Child(Left), Child(Right));

        public override void Accept(HLSLSyntaxVisitor visitor) => visitor.VisitBinaryExpressionNode(this);
        public override T Accept<T>(HLSLSyntaxVisitor<T> visitor) => visitor.VisitBinaryExpressionNode(this);

        public BinaryExpressionNode(List<HLSLToken> tokens) : base(tokens) { }   
    }

    public class CompoundExpressionNode : ExpressionNode
    {
        public ExpressionNode Left { get; set; }
        public ExpressionNode Right { get; set; }

        protected override IEnumerable<HLSLSyntaxNode> GetChildren =>
            MergeChildren(Child(Left), Child(Right));

        public override void Accept(HLSLSyntaxVisitor visitor) => visitor.VisitCompoundExpressionNode(this);
        public override T Accept<T>(HLSLSyntaxVisitor<T> visitor) => visitor.VisitCompoundExpressionNode(this);

        public CompoundExpressionNode(List<HLSLToken> tokens) : base(tokens) { }   
    }

    public class PrefixUnaryExpressionNode : ExpressionNode
    {
        public OperatorKind Operator { get; set; }
        public ExpressionNode Expression { get; set; }

        protected override IEnumerable<HLSLSyntaxNode> GetChildren =>
            Child(Expression);

        public override void Accept(HLSLSyntaxVisitor visitor) => visitor.VisitPrefixUnaryExpressionNode(this);
        public override T Accept<T>(HLSLSyntaxVisitor<T> visitor) => visitor.VisitPrefixUnaryExpressionNode(this);

        public PrefixUnaryExpressionNode(List<HLSLToken> tokens) : base(tokens) { }   
    }

    public class PostfixUnaryExpressionNode : ExpressionNode
    {
        public ExpressionNode Expression { get; set; }
        public OperatorKind Operator { get; set; }

        protected override IEnumerable<HLSLSyntaxNode> GetChildren =>
            Child(Expression);

        public override void Accept(HLSLSyntaxVisitor visitor) => visitor.VisitPostfixUnaryExpressionNode(this);
        public override T Accept<T>(HLSLSyntaxVisitor<T> visitor) => visitor.VisitPostfixUnaryExpressionNode(this);

        public PostfixUnaryExpressionNode(List<HLSLToken> tokens) : base(tokens) { }   
    }

    public class FieldAccessExpressionNode : ExpressionNode
    {
        public ExpressionNode Target { get; set; }
        public IdentifierNode Name { get; set; }

        protected override IEnumerable<HLSLSyntaxNode> GetChildren =>
            new HLSLSyntaxNode[] { Target, Name };

        public override void Accept(HLSLSyntaxVisitor visitor) => visitor.VisitFieldAccessExpressionNode(this);
        public override T Accept<T>(HLSLSyntaxVisitor<T> visitor) => visitor.VisitFieldAccessExpressionNode(this);

        public FieldAccessExpressionNode(List<HLSLToken> tokens) : base(tokens) { }   
    }

    public class MethodCallExpressionNode : ExpressionNode
    {
        public ExpressionNode Target { get; set; }
        public IdentifierNode Name { get; set; }
        public List<ExpressionNode> Arguments { get; set; }

        protected override IEnumerable<HLSLSyntaxNode> GetChildren =>
            MergeChildren(Child(Name), Child(Target), Arguments);

        public override void Accept(HLSLSyntaxVisitor visitor) => visitor.VisitMethodCallExpressionNode(this);
        public override T Accept<T>(HLSLSyntaxVisitor<T> visitor) => visitor.VisitMethodCallExpressionNode(this);

        public MethodCallExpressionNode(List<HLSLToken> tokens) : base(tokens) { }   
    }

    public class FunctionCallExpressionNode : ExpressionNode
    {
        public NamedExpressionNode Name { get; set; }
        public List<ExpressionNode> Arguments { get; set; }

        protected override IEnumerable<HLSLSyntaxNode> GetChildren =>
            MergeChildren(Child(Name), Arguments);

        public override void Accept(HLSLSyntaxVisitor visitor) => visitor.VisitFunctionCallExpressionNode(this);
        public override T Accept<T>(HLSLSyntaxVisitor<T> visitor) => visitor.VisitFunctionCallExpressionNode(this);

        public FunctionCallExpressionNode(List<HLSLToken> tokens) : base(tokens) { }   
    }

    public class NumericConstructorCallExpressionNode : ExpressionNode
    {
        public NumericTypeNode Kind { get; set; }
        public List<ExpressionNode> Arguments { get; set; }

        protected override IEnumerable<HLSLSyntaxNode> GetChildren =>
            MergeChildren(Child(Kind), Arguments);

        public override void Accept(HLSLSyntaxVisitor visitor) => visitor.VisitNumericConstructorCallExpressionNode(this);
        public override T Accept<T>(HLSLSyntaxVisitor<T> visitor) => visitor.VisitNumericConstructorCallExpressionNode(this);

        public NumericConstructorCallExpressionNode(List<HLSLToken> tokens) : base(tokens) { }   
    }

    public class ElementAccessExpressionNode : ExpressionNode
    {
        public ExpressionNode Target { get; set; }
        public ExpressionNode Index { get; set; }

        protected override IEnumerable<HLSLSyntaxNode> GetChildren =>
            MergeChildren(Child(Target), Child(Index));

        public override void Accept(HLSLSyntaxVisitor visitor) => visitor.VisitElementAccessExpressionNode(this);
        public override T Accept<T>(HLSLSyntaxVisitor<T> visitor) => visitor.VisitElementAccessExpressionNode(this);

        public ElementAccessExpressionNode(List<HLSLToken> tokens) : base(tokens) { }   
    }

    public class CastExpressionNode : ExpressionNode
    {
        public TypeNode Kind { get; set; }
        public ExpressionNode Expression { get; set; }
        public List<ArrayRankNode> ArrayRanks { get; set; }
        public bool IsFunctionLike { get; set; }
        protected override IEnumerable<HLSLSyntaxNode> GetChildren =>
            MergeChildren(Child(Kind), Child(Expression), ArrayRanks);

        public override void Accept(HLSLSyntaxVisitor visitor) => visitor.VisitCastExpressionNode(this);
        public override T Accept<T>(HLSLSyntaxVisitor<T> visitor) => visitor.VisitCastExpressionNode(this);

        public CastExpressionNode(List<HLSLToken> tokens) : base(tokens) { }   
    }

    public class ArrayInitializerExpressionNode : ExpressionNode
    {
        public List<ExpressionNode> Elements { get; set; }

        protected override IEnumerable<HLSLSyntaxNode> GetChildren =>
            Elements;

        public override void Accept(HLSLSyntaxVisitor visitor) => visitor.VisitArrayInitializerExpressionNode(this);
        public override T Accept<T>(HLSLSyntaxVisitor<T> visitor) => visitor.VisitArrayInitializerExpressionNode(this);

        public ArrayInitializerExpressionNode(List<HLSLToken> tokens) : base(tokens) { }   
    }

    public class TernaryExpressionNode : ExpressionNode
    {
        public ExpressionNode Condition { get; set; }
        public ExpressionNode TrueCase { get; set; }
        public ExpressionNode FalseCase { get; set; }

        protected override IEnumerable<HLSLSyntaxNode> GetChildren =>
            MergeChildren(Child(Condition), Child(TrueCase), Child(FalseCase));

        public override void Accept(HLSLSyntaxVisitor visitor) => visitor.VisitTernaryExpressionNode(this);
        public override T Accept<T>(HLSLSyntaxVisitor<T> visitor) => visitor.VisitTernaryExpressionNode(this);

        public TernaryExpressionNode(List<HLSLToken> tokens) : base(tokens) { }   
    }

    // Part of legacy sampler syntax (d3d9)
    public class SamplerStateLiteralExpressionNode : ExpressionNode
    {
        public List<StatePropertyNode> States { get; set; }

        protected override IEnumerable<HLSLSyntaxNode> GetChildren =>
            States;

        public override void Accept(HLSLSyntaxVisitor visitor) => visitor.VisitSamplerStateLiteralExpressionNode(this);
        public override T Accept<T>(HLSLSyntaxVisitor<T> visitor) => visitor.VisitSamplerStateLiteralExpressionNode(this);

        public SamplerStateLiteralExpressionNode(List<HLSLToken> tokens) : base(tokens) { }   
    }

    // From FX framework
    public class CompileExpressionNode : ExpressionNode
    {
        public IdentifierNode Target { get; set; }
        public FunctionCallExpressionNode Invocation { get; set; }

        protected override IEnumerable<HLSLSyntaxNode> GetChildren =>
            new HLSLSyntaxNode[] { Target, Invocation };

        public override void Accept(HLSLSyntaxVisitor visitor) => visitor.VisitCompileExpressionNode(this);
        public override T Accept<T>(HLSLSyntaxVisitor<T> visitor) => visitor.VisitCompileExpressionNode(this);

        public CompileExpressionNode(List<HLSLToken> tokens) : base(tokens) { }   
    }

    public abstract class TypeNode : HLSLSyntaxNode
    {
        public TypeNode(List<HLSLToken> tokens) : base(tokens) { }   
    }
    public abstract class UserDefinedTypeNode : TypeNode
    {
        public UserDefinedTypeNode(List<HLSLToken> tokens) : base(tokens) { }   
    }
    public abstract class UserDefinedNamedTypeNode : UserDefinedTypeNode
    {
        public abstract string GetName();
        public abstract string GetUnqualifiedName();

        public UserDefinedNamedTypeNode(List<HLSLToken> tokens) : base(tokens) { }   
    }
    public abstract class PredefinedTypeNode : TypeNode
    {
        public PredefinedTypeNode(List<HLSLToken> tokens) : base(tokens) { }   
    }

    public class QualifiedNamedTypeNode : UserDefinedNamedTypeNode
    {
        public NamedTypeNode Left { get; set; }
        public UserDefinedNamedTypeNode Right { get; set; }

        public override string GetName() => $"{Left.GetName()}::{Right.GetName()}";
        public override string GetUnqualifiedName() => Right.GetUnqualifiedName();

        protected override IEnumerable<HLSLSyntaxNode> GetChildren =>
            MergeChildren(Child(Left), Child(Right));

        public override void Accept(HLSLSyntaxVisitor visitor) => visitor.VisitQualifiedNamedTypeNode(this);
        public override T Accept<T>(HLSLSyntaxVisitor<T> visitor) => visitor.VisitQualifiedNamedTypeNode(this);

        public QualifiedNamedTypeNode(List<HLSLToken> tokens) : base(tokens) { }   
    }

    public class NamedTypeNode : UserDefinedNamedTypeNode
    {
        public IdentifierNode Name { get; set; }

        public override string GetName() => Name.Identifier;
        public override string GetUnqualifiedName() => Name.Identifier;

        protected override IEnumerable<HLSLSyntaxNode> GetChildren =>
            Child(Name);

        public override void Accept(HLSLSyntaxVisitor visitor) => visitor.VisitNamedTypeNode(this);
        public override T Accept<T>(HLSLSyntaxVisitor<T> visitor) => visitor.VisitNamedTypeNode(this);

        public NamedTypeNode(List<HLSLToken> tokens) : base(tokens) { }   
    }

    public class PredefinedObjectTypeNode : PredefinedTypeNode
    {
        public PredefinedObjectType Kind { get; set; }
        public List<TypeNode> TemplateArguments { get; set; }

        protected override IEnumerable<HLSLSyntaxNode> GetChildren =>
            TemplateArguments;

        public override void Accept(HLSLSyntaxVisitor visitor) => visitor.VisitPredefinedObjectTypeNode(this);
        public override T Accept<T>(HLSLSyntaxVisitor<T> visitor) => visitor.VisitPredefinedObjectTypeNode(this);

        public PredefinedObjectTypeNode(List<HLSLToken> tokens) : base(tokens) { }   
    }

    public class StructTypeNode : UserDefinedTypeNode
    {
        public UserDefinedNamedTypeNode Name { get; set; }
        public List<UserDefinedNamedTypeNode> Inherits { get; set; }
        public List<VariableDeclarationStatementNode> Fields { get; set; }
        public List<FunctionNode> Methods { get; set; }
        public bool IsClass { get; set; }

        protected override IEnumerable<HLSLSyntaxNode> GetChildren =>
            MergeChildren(OptionalChild(Name), Inherits, Fields, Methods);

        public override void Accept(HLSLSyntaxVisitor visitor) => visitor.VisitStructTypeNode(this);
        public override T Accept<T>(HLSLSyntaxVisitor<T> visitor) => visitor.VisitStructTypeNode(this);

        public StructTypeNode(List<HLSLToken> tokens) : base(tokens) { }   
    }

    public abstract class NumericTypeNode : PredefinedTypeNode
    {
        public ScalarType Kind { get; set; }

        public NumericTypeNode(List<HLSLToken> tokens) : base(tokens) { }   
    }

    public class ScalarTypeNode : NumericTypeNode
    {
        protected override IEnumerable<HLSLSyntaxNode> GetChildren =>
            Enumerable.Empty<HLSLSyntaxNode>();

        public override void Accept(HLSLSyntaxVisitor visitor) => visitor.VisitScalarTypeNode(this);
        public override T Accept<T>(HLSLSyntaxVisitor<T> visitor) => visitor.VisitScalarTypeNode(this);

        public ScalarTypeNode(List<HLSLToken> tokens) : base(tokens) { }   
    }

    public abstract class BaseMatrixTypeNode : NumericTypeNode
    {
        public BaseMatrixTypeNode(List<HLSLToken> tokens) : base(tokens) { }
    }

    public abstract class BaseVectorTypeNode : NumericTypeNode
    {
        public BaseVectorTypeNode(List<HLSLToken> tokens) : base(tokens) { }
    }

    public class MatrixTypeNode : BaseMatrixTypeNode
    {
        public int FirstDimension { get; set; }
        public int SecondDimension { get; set; }

        protected override IEnumerable<HLSLSyntaxNode> GetChildren =>
            Enumerable.Empty<HLSLSyntaxNode>();

        public override void Accept(HLSLSyntaxVisitor visitor) => visitor.VisitMatrixTypeNode(this);
        public override T Accept<T>(HLSLSyntaxVisitor<T> visitor) => visitor.VisitMatrixTypeNode(this);

        public MatrixTypeNode(List<HLSLToken> tokens) : base(tokens) { }   
    }

    public class GenericMatrixTypeNode : BaseMatrixTypeNode
    {
        public ExpressionNode FirstDimension { get; set; }
        public ExpressionNode SecondDimension { get; set; }

        protected override IEnumerable<HLSLSyntaxNode> GetChildren =>
            MergeChildren(Child(FirstDimension), Child(SecondDimension));

        public override void Accept(HLSLSyntaxVisitor visitor) => visitor.VisitGenericMatrixTypeNode(this);
        public override T Accept<T>(HLSLSyntaxVisitor<T> visitor) => visitor.VisitGenericMatrixTypeNode(this);

        public GenericMatrixTypeNode(List<HLSLToken> tokens) : base(tokens) { }
    }

    public class VectorTypeNode : BaseVectorTypeNode
    {
        public int Dimension { get; set; }

        protected override IEnumerable<HLSLSyntaxNode> GetChildren =>
            Enumerable.Empty<HLSLSyntaxNode>();

        public override void Accept(HLSLSyntaxVisitor visitor) => visitor.VisitVectorTypeNode(this);
        public override T Accept<T>(HLSLSyntaxVisitor<T> visitor) => visitor.VisitVectorTypeNode(this);

        public VectorTypeNode(List<HLSLToken> tokens) : base(tokens) { }   
    }

    public class GenericVectorTypeNode : BaseVectorTypeNode
    {
        public ExpressionNode Dimension { get; set; }

        protected override IEnumerable<HLSLSyntaxNode> GetChildren =>
            Child(Dimension);

        public override void Accept(HLSLSyntaxVisitor visitor) => visitor.VisitGenericVectorTypeNode(this);
        public override T Accept<T>(HLSLSyntaxVisitor<T> visitor) => visitor.VisitGenericVectorTypeNode(this);

        public GenericVectorTypeNode(List<HLSLToken> tokens) : base(tokens) { }
    }

    // This type mostly exists such that template can receive literal arguments.
    // It's basically constexpr.
    public class LiteralTemplateArgumentType : TypeNode
    {
        public LiteralExpressionNode Literal { get; set; }

        protected override IEnumerable<HLSLSyntaxNode> GetChildren =>
            Child(Literal);

        public override void Accept(HLSLSyntaxVisitor visitor) => visitor.VisitLiteralTemplateArgumentType(this);
        public override T Accept<T>(HLSLSyntaxVisitor<T> visitor) => visitor.VisitLiteralTemplateArgumentType(this);

        public LiteralTemplateArgumentType(List<HLSLToken> tokens) : base(tokens) { }   
    }

    // Part of an object literal (SamplerState, BlendState, etc)
    public class StatePropertyNode : StatementNode
    {
        public UserDefinedNamedTypeNode Name { get; set; }
        public ArrayRankNode ArrayRank { get; set; } // Optional
        public ExpressionNode Value { get; set; }
        public bool IsReference { get; set; }

        protected override IEnumerable<HLSLSyntaxNode> GetChildren =>
            MergeChildren(OptionalChild(ArrayRank), Child(Value));

        public override void Accept(HLSLSyntaxVisitor visitor) => visitor.VisitStatePropertyNode(this);
        public override T Accept<T>(HLSLSyntaxVisitor<T> visitor) => visitor.VisitStatePropertyNode(this);

        public StatePropertyNode(List<HLSLToken> tokens) : base(tokens) { }   
    }

    // Old FX pipeline syntax
    public class TechniqueNode : HLSLSyntaxNode
    {
        public int Version { get; set; }
        public UserDefinedNamedTypeNode Name { get; set; } // Optional
        public List<VariableDeclarationStatementNode> Annotations { get; set; }
        public List<PassNode> Passes { get; set; }

        protected override IEnumerable<HLSLSyntaxNode> GetChildren =>
            MergeChildren(OptionalChild(Name), Annotations, Passes);

        public override void Accept(HLSLSyntaxVisitor visitor) => visitor.VisitTechniqueNode(this);
        public override T Accept<T>(HLSLSyntaxVisitor<T> visitor) => visitor.VisitTechniqueNode(this);

        public TechniqueNode(List<HLSLToken> tokens) : base(tokens) { }   
    }

    // Old FX pipeline syntax
    public class PassNode : HLSLSyntaxNode
    {
        public UserDefinedNamedTypeNode Name { get; set; } // Optional
        public List<VariableDeclarationStatementNode> Annotations { get; set; }
        public List<StatementNode> Statements { get; set; }

        protected override IEnumerable<HLSLSyntaxNode> GetChildren =>
            MergeChildren(OptionalChild(Name), Annotations, Statements);

        public override void Accept(HLSLSyntaxVisitor visitor) => visitor.VisitPassNode(this);
        public override T Accept<T>(HLSLSyntaxVisitor<T> visitor) => visitor.VisitPassNode(this);

        public PassNode(List<HLSLToken> tokens) : base(tokens) { }   
    }

    public abstract class PreProcessorDirectiveNode : StatementNode
    {
        protected PreProcessorDirectiveNode(List<HLSLToken> tokens) : base(tokens) { }
    }

    public class ObjectLikeMacroNode : PreProcessorDirectiveNode
    {
        public string Name { get; set; }
        public List<HLSLToken> Value { get; set; }

        protected override IEnumerable<HLSLSyntaxNode> GetChildren =>
            Enumerable.Empty<HLSLSyntaxNode>();

        public override void Accept(HLSLSyntaxVisitor visitor) => visitor.VisitObjectLikeMacroNode(this);
        public override T Accept<T>(HLSLSyntaxVisitor<T> visitor) => visitor.VisitObjectLikeMacroNode(this);

        public ObjectLikeMacroNode(List<HLSLToken> tokens) : base(tokens) { }
    }

    public class FunctionLikeMacroNode : PreProcessorDirectiveNode
    {
        public string Name { get; set; }
        public List<string> Arguments { get; set; }
        public List<HLSLToken> Value { get; set; }

        protected override IEnumerable<HLSLSyntaxNode> GetChildren =>
            Enumerable.Empty<HLSLSyntaxNode>();

        public override void Accept(HLSLSyntaxVisitor visitor) => visitor.VisitFunctionLikeMacroNode(this);
        public override T Accept<T>(HLSLSyntaxVisitor<T> visitor) => visitor.VisitFunctionLikeMacroNode(this);

        public FunctionLikeMacroNode(List<HLSLToken> tokens) : base(tokens) { }
    }

    public class IncludeDirectiveNode : PreProcessorDirectiveNode
    {
        public string Path { get; set; }

        protected override IEnumerable<HLSLSyntaxNode> GetChildren =>
            Enumerable.Empty<HLSLSyntaxNode>();

        public override void Accept(HLSLSyntaxVisitor visitor) => visitor.VisitIncludeDirectiveNode(this);
        public override T Accept<T>(HLSLSyntaxVisitor<T> visitor) => visitor.VisitIncludeDirectiveNode(this);

        public IncludeDirectiveNode(List<HLSLToken> tokens) : base(tokens) { }
    }

    public class LineDirectiveNode : PreProcessorDirectiveNode
    {
        public int Line { get; set; }

        protected override IEnumerable<HLSLSyntaxNode> GetChildren =>
            Enumerable.Empty<HLSLSyntaxNode>();

        public override void Accept(HLSLSyntaxVisitor visitor) => visitor.VisitLineDirectiveNode(this);
        public override T Accept<T>(HLSLSyntaxVisitor<T> visitor) => visitor.VisitLineDirectiveNode(this);

        public LineDirectiveNode(List<HLSLToken> tokens) : base(tokens) { }
    }

    public class UndefDirectiveNode : PreProcessorDirectiveNode
    {
        public string Name { get; set; }

        protected override IEnumerable<HLSLSyntaxNode> GetChildren =>
            Enumerable.Empty<HLSLSyntaxNode>();

        public override void Accept(HLSLSyntaxVisitor visitor) => visitor.VisitUndefDirectiveNode(this);
        public override T Accept<T>(HLSLSyntaxVisitor<T> visitor) => visitor.VisitUndefDirectiveNode(this);

        public UndefDirectiveNode(List<HLSLToken> tokens) : base(tokens) { }
    }

    public class ErrorDirectiveNode : PreProcessorDirectiveNode
    {
        public List<HLSLToken> Value { get; set; }

        protected override IEnumerable<HLSLSyntaxNode> GetChildren =>
            Enumerable.Empty<HLSLSyntaxNode>();

        public override void Accept(HLSLSyntaxVisitor visitor) => visitor.VisitErrorDirectiveNode(this);
        public override T Accept<T>(HLSLSyntaxVisitor<T> visitor) => visitor.VisitErrorDirectiveNode(this);

        public ErrorDirectiveNode(List<HLSLToken> tokens) : base(tokens) { }
    }

    public class PragmaDirectiveNode : PreProcessorDirectiveNode
    {
        public List<HLSLToken> Value { get; set; }

        protected override IEnumerable<HLSLSyntaxNode> GetChildren =>
            Enumerable.Empty<HLSLSyntaxNode>();

        public override void Accept(HLSLSyntaxVisitor visitor) => visitor.VisitPragmaDirectiveNode(this);
        public override T Accept<T>(HLSLSyntaxVisitor<T> visitor) => visitor.VisitPragmaDirectiveNode(this);

        public PragmaDirectiveNode(List<HLSLToken> tokens) : base(tokens) { }
    }

    public class IfDefDirectiveNode : PreProcessorDirectiveNode
    {
        public string Condition { get; set; }
        public List<HLSLSyntaxNode> Body { get; set; }
        public PreProcessorDirectiveNode ElseClause { get; set; }

        protected override IEnumerable<HLSLSyntaxNode> GetChildren =>
            MergeChildren(Body, OptionalChild(ElseClause));

        public override void Accept(HLSLSyntaxVisitor visitor) => visitor.VisitIfDefDirectiveNode(this);
        public override T Accept<T>(HLSLSyntaxVisitor<T> visitor) => visitor.VisitIfDefDirectiveNode(this);

        public IfDefDirectiveNode(List<HLSLToken> tokens) : base(tokens) { }
    }

    public class IfNotDefDirectiveNode : PreProcessorDirectiveNode
    {
        public string Condition { get; set; }
        public List<HLSLSyntaxNode> Body { get; set; }
        public PreProcessorDirectiveNode ElseClause { get; set; }

        protected override IEnumerable<HLSLSyntaxNode> GetChildren =>
            MergeChildren(Body, OptionalChild(ElseClause));

        public override void Accept(HLSLSyntaxVisitor visitor) => visitor.VisitIfNotDefDirectiveNode(this);
        public override T Accept<T>(HLSLSyntaxVisitor<T> visitor) => visitor.VisitIfNotDefDirectiveNode(this);

        public IfNotDefDirectiveNode(List<HLSLToken> tokens) : base(tokens) { }
    }

    public class IfDirectiveNode : PreProcessorDirectiveNode
    {
        public ExpressionNode Condition { get; set; }
        public List<HLSLSyntaxNode> Body { get; set; }
        public PreProcessorDirectiveNode ElseClause { get; set; }

        public bool IsElif
        {
            get
            {
                switch (Parent)
                {
                    case IfDefDirectiveNode p: return p.ElseClause == this;
                    case IfNotDefDirectiveNode p: return p.ElseClause == this;
                    case IfDirectiveNode p: return p.ElseClause == this;
                    default: return false;
                }
            }
        }

        protected override IEnumerable<HLSLSyntaxNode> GetChildren =>
            MergeChildren(Child(Condition), Body, OptionalChild(ElseClause));

        public override void Accept(HLSLSyntaxVisitor visitor) => visitor.VisitIfDirectiveNode(this);
        public override T Accept<T>(HLSLSyntaxVisitor<T> visitor) => visitor.VisitIfDirectiveNode(this);

        public IfDirectiveNode(List<HLSLToken> tokens) : base(tokens) { }
    }

    // The remainder of an if-directive
    public class ElseDirectiveNode : PreProcessorDirectiveNode
    {
        public List<HLSLSyntaxNode> Body { get; set; }

        protected override IEnumerable<HLSLSyntaxNode> GetChildren =>
            Body;

        public override void Accept(HLSLSyntaxVisitor visitor) => visitor.VisitElseDirectiveNode(this);
        public override T Accept<T>(HLSLSyntaxVisitor<T> visitor) => visitor.VisitElseDirectiveNode(this);

        public ElseDirectiveNode(List<HLSLToken> tokens) : base(tokens) { }
    }
    #endregion
}


// HLSL/HLSLSyntaxFacts.cs
namespace UnityShaderParser.HLSL
{
    public static class HLSLSyntaxFacts
    {
        public static bool TryParseHLSLKeyword(string keyword, out TokenKind token)
        {
            token = default;

            switch (keyword)
            {
                case "AppendStructuredBuffer": token = TokenKind.AppendStructuredBufferKeyword; return true;
                case "BlendState": token = TokenKind.BlendStateKeyword; return true;
                case "bool": token = TokenKind.BoolKeyword; return true;
                case "bool1": token = TokenKind.Bool1Keyword; return true;
                case "bool2": token = TokenKind.Bool2Keyword; return true;
                case "bool3": token = TokenKind.Bool3Keyword; return true;
                case "bool4": token = TokenKind.Bool4Keyword; return true;
                case "bool1x1": token = TokenKind.Bool1x1Keyword; return true;
                case "bool1x2": token = TokenKind.Bool1x2Keyword; return true;
                case "bool1x3": token = TokenKind.Bool1x3Keyword; return true;
                case "bool1x4": token = TokenKind.Bool1x4Keyword; return true;
                case "bool2x1": token = TokenKind.Bool2x1Keyword; return true;
                case "bool2x2": token = TokenKind.Bool2x2Keyword; return true;
                case "bool2x3": token = TokenKind.Bool2x3Keyword; return true;
                case "bool2x4": token = TokenKind.Bool2x4Keyword; return true;
                case "bool3x1": token = TokenKind.Bool3x1Keyword; return true;
                case "bool3x2": token = TokenKind.Bool3x2Keyword; return true;
                case "bool3x3": token = TokenKind.Bool3x3Keyword; return true;
                case "bool3x4": token = TokenKind.Bool3x4Keyword; return true;
                case "bool4x1": token = TokenKind.Bool4x1Keyword; return true;
                case "bool4x2": token = TokenKind.Bool4x2Keyword; return true;
                case "bool4x3": token = TokenKind.Bool4x3Keyword; return true;
                case "bool4x4": token = TokenKind.Bool4x4Keyword; return true;
                case "Buffer": token = TokenKind.BufferKeyword; return true;
                case "ByteAddressBuffer": token = TokenKind.ByteAddressBufferKeyword; return true;
                case "break": token = TokenKind.BreakKeyword; return true;
                case "case": token = TokenKind.CaseKeyword; return true;
                case "cbuffer": token = TokenKind.CBufferKeyword; return true;
                case "centroid": token = TokenKind.CentroidKeyword; return true;
                case "class": token = TokenKind.ClassKeyword; return true;
                case "column_major": token = TokenKind.ColumnMajorKeyword; return true;
                case "compile": token = TokenKind.CompileKeyword; return true;
                case "const": token = TokenKind.ConstKeyword; return true;
                case "ConsumeStructuredBuffer": token = TokenKind.ConsumeStructuredBufferKeyword; return true;
                case "continue": token = TokenKind.ContinueKeyword; return true;
                case "default": token = TokenKind.DefaultKeyword; return true;
                case "def": token = TokenKind.DefKeyword; return true;
                case "DepthStencilState": token = TokenKind.DepthStencilStateKeyword; return true;
                case "discard": token = TokenKind.DiscardKeyword; return true;
                case "do": token = TokenKind.DoKeyword; return true;
                case "double": token = TokenKind.DoubleKeyword; return true;
                case "double1": token = TokenKind.Double1Keyword; return true;
                case "double2": token = TokenKind.Double2Keyword; return true;
                case "double3": token = TokenKind.Double3Keyword; return true;
                case "double4": token = TokenKind.Double4Keyword; return true;
                case "double1x1": token = TokenKind.Double1x1Keyword; return true;
                case "double1x2": token = TokenKind.Double1x2Keyword; return true;
                case "double1x3": token = TokenKind.Double1x3Keyword; return true;
                case "double1x4": token = TokenKind.Double1x4Keyword; return true;
                case "double2x1": token = TokenKind.Double2x1Keyword; return true;
                case "double2x2": token = TokenKind.Double2x2Keyword; return true;
                case "double2x3": token = TokenKind.Double2x3Keyword; return true;
                case "double2x4": token = TokenKind.Double2x4Keyword; return true;
                case "double3x1": token = TokenKind.Double3x1Keyword; return true;
                case "double3x2": token = TokenKind.Double3x2Keyword; return true;
                case "double3x3": token = TokenKind.Double3x3Keyword; return true;
                case "double3x4": token = TokenKind.Double3x4Keyword; return true;
                case "double4x1": token = TokenKind.Double4x1Keyword; return true;
                case "double4x2": token = TokenKind.Double4x2Keyword; return true;
                case "double4x3": token = TokenKind.Double4x3Keyword; return true;
                case "double4x4": token = TokenKind.Double4x4Keyword; return true;
                case "else": token = TokenKind.ElseKeyword; return true;
                case "export": token = TokenKind.ExportKeyword; return true;
                case "extern": token = TokenKind.ExternKeyword; return true;
                case "float": token = TokenKind.FloatKeyword; return true;
                case "float1": token = TokenKind.Float1Keyword; return true;
                case "float2": token = TokenKind.Float2Keyword; return true;
                case "float3": token = TokenKind.Float3Keyword; return true;
                case "float4": token = TokenKind.Float4Keyword; return true;
                case "float1x1": token = TokenKind.Float1x1Keyword; return true;
                case "float1x2": token = TokenKind.Float1x2Keyword; return true;
                case "float1x3": token = TokenKind.Float1x3Keyword; return true;
                case "float1x4": token = TokenKind.Float1x4Keyword; return true;
                case "float2x1": token = TokenKind.Float2x1Keyword; return true;
                case "float2x2": token = TokenKind.Float2x2Keyword; return true;
                case "float2x3": token = TokenKind.Float2x3Keyword; return true;
                case "float2x4": token = TokenKind.Float2x4Keyword; return true;
                case "float3x1": token = TokenKind.Float3x1Keyword; return true;
                case "float3x2": token = TokenKind.Float3x2Keyword; return true;
                case "float3x3": token = TokenKind.Float3x3Keyword; return true;
                case "float3x4": token = TokenKind.Float3x4Keyword; return true;
                case "float4x1": token = TokenKind.Float4x1Keyword; return true;
                case "float4x2": token = TokenKind.Float4x2Keyword; return true;
                case "float4x3": token = TokenKind.Float4x3Keyword; return true;
                case "float4x4": token = TokenKind.Float4x4Keyword; return true;
                case "for": token = TokenKind.ForKeyword; return true;
                case "globallycoherent": token = TokenKind.GloballycoherentKeyword; return true;
                case "groupshared": token = TokenKind.GroupsharedKeyword; return true;
                case "half": token = TokenKind.HalfKeyword; return true;
                case "half1": token = TokenKind.Half1Keyword; return true;
                case "half2": token = TokenKind.Half2Keyword; return true;
                case "half3": token = TokenKind.Half3Keyword; return true;
                case "half4": token = TokenKind.Half4Keyword; return true;
                case "half1x1": token = TokenKind.Half1x1Keyword; return true;
                case "half1x2": token = TokenKind.Half1x2Keyword; return true;
                case "half1x3": token = TokenKind.Half1x3Keyword; return true;
                case "half1x4": token = TokenKind.Half1x4Keyword; return true;
                case "half2x1": token = TokenKind.Half2x1Keyword; return true;
                case "half2x2": token = TokenKind.Half2x2Keyword; return true;
                case "half2x3": token = TokenKind.Half2x3Keyword; return true;
                case "half2x4": token = TokenKind.Half2x4Keyword; return true;
                case "half3x1": token = TokenKind.Half3x1Keyword; return true;
                case "half3x2": token = TokenKind.Half3x2Keyword; return true;
                case "half3x3": token = TokenKind.Half3x3Keyword; return true;
                case "half3x4": token = TokenKind.Half3x4Keyword; return true;
                case "half4x1": token = TokenKind.Half4x1Keyword; return true;
                case "half4x2": token = TokenKind.Half4x2Keyword; return true;
                case "half4x3": token = TokenKind.Half4x3Keyword; return true;
                case "half4x4": token = TokenKind.Half4x4Keyword; return true;
                case "if": token = TokenKind.IfKeyword; return true;
                case "indices": token = TokenKind.IndicesKeyword; return true;
                case "in": token = TokenKind.InKeyword; return true;
                case "inline": token = TokenKind.InlineKeyword; return true;
                case "inout": token = TokenKind.InoutKeyword; return true;
                case "InputPatch": token = TokenKind.InputPatchKeyword; return true;
                case "int": token = TokenKind.IntKeyword; return true;
                case "int1": token = TokenKind.Int1Keyword; return true;
                case "int2": token = TokenKind.Int2Keyword; return true;
                case "int3": token = TokenKind.Int3Keyword; return true;
                case "int4": token = TokenKind.Int4Keyword; return true;
                case "int1x1": token = TokenKind.Int1x1Keyword; return true;
                case "int1x2": token = TokenKind.Int1x2Keyword; return true;
                case "int1x3": token = TokenKind.Int1x3Keyword; return true;
                case "int1x4": token = TokenKind.Int1x4Keyword; return true;
                case "int2x1": token = TokenKind.Int2x1Keyword; return true;
                case "int2x2": token = TokenKind.Int2x2Keyword; return true;
                case "int2x3": token = TokenKind.Int2x3Keyword; return true;
                case "int2x4": token = TokenKind.Int2x4Keyword; return true;
                case "int3x1": token = TokenKind.Int3x1Keyword; return true;
                case "int3x2": token = TokenKind.Int3x2Keyword; return true;
                case "int3x3": token = TokenKind.Int3x3Keyword; return true;
                case "int3x4": token = TokenKind.Int3x4Keyword; return true;
                case "int4x1": token = TokenKind.Int4x1Keyword; return true;
                case "int4x2": token = TokenKind.Int4x2Keyword; return true;
                case "int4x3": token = TokenKind.Int4x3Keyword; return true;
                case "int4x4": token = TokenKind.Int4x4Keyword; return true;
                case "interface": token = TokenKind.InterfaceKeyword; return true;
                case "line": token = TokenKind.LineKeyword; return true;
                case "lineadj": token = TokenKind.LineAdjKeyword; return true;
                case "linear": token = TokenKind.LinearKeyword; return true;
                case "LineStream": token = TokenKind.LineStreamKeyword; return true;
                case "matrix": token = TokenKind.MatrixKeyword; return true;
                case "message": token = TokenKind.MessageKeyword; return true;
                case "min10float": token = TokenKind.Min10FloatKeyword; return true;
                case "min10float1": token = TokenKind.Min10Float1Keyword; return true;
                case "min10float2": token = TokenKind.Min10Float2Keyword; return true;
                case "min10float3": token = TokenKind.Min10Float3Keyword; return true;
                case "min10float4": token = TokenKind.Min10Float4Keyword; return true;
                case "min10float1x1": token = TokenKind.Min10Float1x1Keyword; return true;
                case "min10float1x2": token = TokenKind.Min10Float1x2Keyword; return true;
                case "min10float1x3": token = TokenKind.Min10Float1x3Keyword; return true;
                case "min10float1x4": token = TokenKind.Min10Float1x4Keyword; return true;
                case "min10float2x1": token = TokenKind.Min10Float2x1Keyword; return true;
                case "min10float2x2": token = TokenKind.Min10Float2x2Keyword; return true;
                case "min10float2x3": token = TokenKind.Min10Float2x3Keyword; return true;
                case "min10float2x4": token = TokenKind.Min10Float2x4Keyword; return true;
                case "min10float3x1": token = TokenKind.Min10Float3x1Keyword; return true;
                case "min10float3x2": token = TokenKind.Min10Float3x2Keyword; return true;
                case "min10float3x3": token = TokenKind.Min10Float3x3Keyword; return true;
                case "min10float3x4": token = TokenKind.Min10Float3x4Keyword; return true;
                case "min10float4x1": token = TokenKind.Min10Float4x1Keyword; return true;
                case "min10float4x2": token = TokenKind.Min10Float4x2Keyword; return true;
                case "min10float4x3": token = TokenKind.Min10Float4x3Keyword; return true;
                case "min10float4x4": token = TokenKind.Min10Float4x4Keyword; return true;
                case "min12int": token = TokenKind.Min12IntKeyword; return true;
                case "min12int1": token = TokenKind.Min12Int1Keyword; return true;
                case "min12int2": token = TokenKind.Min12Int2Keyword; return true;
                case "min12int3": token = TokenKind.Min12Int3Keyword; return true;
                case "min12int4": token = TokenKind.Min12Int4Keyword; return true;
                case "min12int1x1": token = TokenKind.Min12Int1x1Keyword; return true;
                case "min12int1x2": token = TokenKind.Min12Int1x2Keyword; return true;
                case "min12int1x3": token = TokenKind.Min12Int1x3Keyword; return true;
                case "min12int1x4": token = TokenKind.Min12Int1x4Keyword; return true;
                case "min12int2x1": token = TokenKind.Min12Int2x1Keyword; return true;
                case "min12int2x2": token = TokenKind.Min12Int2x2Keyword; return true;
                case "min12int2x3": token = TokenKind.Min12Int2x3Keyword; return true;
                case "min12int2x4": token = TokenKind.Min12Int2x4Keyword; return true;
                case "min12int3x1": token = TokenKind.Min12Int3x1Keyword; return true;
                case "min12int3x2": token = TokenKind.Min12Int3x2Keyword; return true;
                case "min12int3x3": token = TokenKind.Min12Int3x3Keyword; return true;
                case "min12int3x4": token = TokenKind.Min12Int3x4Keyword; return true;
                case "min12int4x1": token = TokenKind.Min12Int4x1Keyword; return true;
                case "min12int4x2": token = TokenKind.Min12Int4x2Keyword; return true;
                case "min12int4x3": token = TokenKind.Min12Int4x3Keyword; return true;
                case "min12int4x4": token = TokenKind.Min12Int4x4Keyword; return true;
                case "min12uint": token = TokenKind.Min12UintKeyword; return true;
                case "min12uint1": token = TokenKind.Min12Uint1Keyword; return true;
                case "min12uint2": token = TokenKind.Min12Uint2Keyword; return true;
                case "min12uint3": token = TokenKind.Min12Uint3Keyword; return true;
                case "min12uint4": token = TokenKind.Min12Uint4Keyword; return true;
                case "min12uint1x1": token = TokenKind.Min12Uint1x1Keyword; return true;
                case "min12uint1x2": token = TokenKind.Min12Uint1x2Keyword; return true;
                case "min12uint1x3": token = TokenKind.Min12Uint1x3Keyword; return true;
                case "min12uint1x4": token = TokenKind.Min12Uint1x4Keyword; return true;
                case "min12uint2x1": token = TokenKind.Min12Uint2x1Keyword; return true;
                case "min12uint2x2": token = TokenKind.Min12Uint2x2Keyword; return true;
                case "min12uint2x3": token = TokenKind.Min12Uint2x3Keyword; return true;
                case "min12uint2x4": token = TokenKind.Min12Uint2x4Keyword; return true;
                case "min12uint3x1": token = TokenKind.Min12Uint3x1Keyword; return true;
                case "min12uint3x2": token = TokenKind.Min12Uint3x2Keyword; return true;
                case "min12uint3x3": token = TokenKind.Min12Uint3x3Keyword; return true;
                case "min12uint3x4": token = TokenKind.Min12Uint3x4Keyword; return true;
                case "min12uint4x1": token = TokenKind.Min12Uint4x1Keyword; return true;
                case "min12uint4x2": token = TokenKind.Min12Uint4x2Keyword; return true;
                case "min12uint4x3": token = TokenKind.Min12Uint4x3Keyword; return true;
                case "min12uint4x4": token = TokenKind.Min12Uint4x4Keyword; return true;
                case "min16float": token = TokenKind.Min16FloatKeyword; return true;
                case "min16float1": token = TokenKind.Min16Float1Keyword; return true;
                case "min16float2": token = TokenKind.Min16Float2Keyword; return true;
                case "min16float3": token = TokenKind.Min16Float3Keyword; return true;
                case "min16float4": token = TokenKind.Min16Float4Keyword; return true;
                case "min16float1x1": token = TokenKind.Min16Float1x1Keyword; return true;
                case "min16float1x2": token = TokenKind.Min16Float1x2Keyword; return true;
                case "min16float1x3": token = TokenKind.Min16Float1x3Keyword; return true;
                case "min16float1x4": token = TokenKind.Min16Float1x4Keyword; return true;
                case "min16float2x1": token = TokenKind.Min16Float2x1Keyword; return true;
                case "min16float2x2": token = TokenKind.Min16Float2x2Keyword; return true;
                case "min16float2x3": token = TokenKind.Min16Float2x3Keyword; return true;
                case "min16float2x4": token = TokenKind.Min16Float2x4Keyword; return true;
                case "min16float3x1": token = TokenKind.Min16Float3x1Keyword; return true;
                case "min16float3x2": token = TokenKind.Min16Float3x2Keyword; return true;
                case "min16float3x3": token = TokenKind.Min16Float3x3Keyword; return true;
                case "min16float3x4": token = TokenKind.Min16Float3x4Keyword; return true;
                case "min16float4x1": token = TokenKind.Min16Float4x1Keyword; return true;
                case "min16float4x2": token = TokenKind.Min16Float4x2Keyword; return true;
                case "min16float4x3": token = TokenKind.Min16Float4x3Keyword; return true;
                case "min16float4x4": token = TokenKind.Min16Float4x4Keyword; return true;
                case "min16int": token = TokenKind.Min16IntKeyword; return true;
                case "min16int1": token = TokenKind.Min16Int1Keyword; return true;
                case "min16int2": token = TokenKind.Min16Int2Keyword; return true;
                case "min16int3": token = TokenKind.Min16Int3Keyword; return true;
                case "min16int4": token = TokenKind.Min16Int4Keyword; return true;
                case "min16int1x1": token = TokenKind.Min16Int1x1Keyword; return true;
                case "min16int1x2": token = TokenKind.Min16Int1x2Keyword; return true;
                case "min16int1x3": token = TokenKind.Min16Int1x3Keyword; return true;
                case "min16int1x4": token = TokenKind.Min16Int1x4Keyword; return true;
                case "min16int2x1": token = TokenKind.Min16Int2x1Keyword; return true;
                case "min16int2x2": token = TokenKind.Min16Int2x2Keyword; return true;
                case "min16int2x3": token = TokenKind.Min16Int2x3Keyword; return true;
                case "min16int2x4": token = TokenKind.Min16Int2x4Keyword; return true;
                case "min16int3x1": token = TokenKind.Min16Int3x1Keyword; return true;
                case "min16int3x2": token = TokenKind.Min16Int3x2Keyword; return true;
                case "min16int3x3": token = TokenKind.Min16Int3x3Keyword; return true;
                case "min16int3x4": token = TokenKind.Min16Int3x4Keyword; return true;
                case "min16int4x1": token = TokenKind.Min16Int4x1Keyword; return true;
                case "min16int4x2": token = TokenKind.Min16Int4x2Keyword; return true;
                case "min16int4x3": token = TokenKind.Min16Int4x3Keyword; return true;
                case "min16int4x4": token = TokenKind.Min16Int4x4Keyword; return true;
                case "min16uint": token = TokenKind.Min16UintKeyword; return true;
                case "min16uint1": token = TokenKind.Min16Uint1Keyword; return true;
                case "min16uint2": token = TokenKind.Min16Uint2Keyword; return true;
                case "min16uint3": token = TokenKind.Min16Uint3Keyword; return true;
                case "min16uint4": token = TokenKind.Min16Uint4Keyword; return true;
                case "min16uint1x1": token = TokenKind.Min16Uint1x1Keyword; return true;
                case "min16uint1x2": token = TokenKind.Min16Uint1x2Keyword; return true;
                case "min16uint1x3": token = TokenKind.Min16Uint1x3Keyword; return true;
                case "min16uint1x4": token = TokenKind.Min16Uint1x4Keyword; return true;
                case "min16uint2x1": token = TokenKind.Min16Uint2x1Keyword; return true;
                case "min16uint2x2": token = TokenKind.Min16Uint2x2Keyword; return true;
                case "min16uint2x3": token = TokenKind.Min16Uint2x3Keyword; return true;
                case "min16uint2x4": token = TokenKind.Min16Uint2x4Keyword; return true;
                case "min16uint3x1": token = TokenKind.Min16Uint3x1Keyword; return true;
                case "min16uint3x2": token = TokenKind.Min16Uint3x2Keyword; return true;
                case "min16uint3x3": token = TokenKind.Min16Uint3x3Keyword; return true;
                case "min16uint3x4": token = TokenKind.Min16Uint3x4Keyword; return true;
                case "min16uint4x1": token = TokenKind.Min16Uint4x1Keyword; return true;
                case "min16uint4x2": token = TokenKind.Min16Uint4x2Keyword; return true;
                case "min16uint4x3": token = TokenKind.Min16Uint4x3Keyword; return true;
                case "min16uint4x4": token = TokenKind.Min16Uint4x4Keyword; return true;
                case "namespace": token = TokenKind.NamespaceKeyword; return true;
                case "nointerpolation": token = TokenKind.NointerpolationKeyword; return true;
                case "noperspective": token = TokenKind.NoperspectiveKeyword; return true;
                case "NULL": token = TokenKind.NullKeyword; return true;
                case "out": token = TokenKind.OutKeyword; return true;
                case "OutputPatch": token = TokenKind.OutputPatchKeyword; return true;
                case "packmatrix": token = TokenKind.PackMatrixKeyword; return true;
                case "packoffset": token = TokenKind.PackoffsetKeyword; return true;
                case "Pass": token = TokenKind.PassKeyword; return true;
                case "pass": token = TokenKind.PassKeyword; return true;
                case "payload": token = TokenKind.PayloadKeyword; return true;
                case "point": token = TokenKind.PointKeyword; return true;
                case "PointStream": token = TokenKind.PointStreamKeyword; return true;
                case "pragma": token = TokenKind.PragmaKeyword; return true;
                case "precise": token = TokenKind.PreciseKeyword; return true;
                case "primitives": token = TokenKind.PrimitivesKeyword; return true;
                case "rasterizerorderedbuffer": token = TokenKind.RasterizerOrderedBufferKeyword; return true;
                case "rasterizerorderedbyteaddressbuffer": token = TokenKind.RasterizerOrderedByteAddressBufferKeyword; return true;
                case "rasterizerorderedstructuredbuffer": token = TokenKind.RasterizerOrderedStructuredBufferKeyword; return true;
                case "rasterizerorderedtexture1d": token = TokenKind.RasterizerOrderedTexture1DKeyword; return true;
                case "rasterizerorderedtexture1darray": token = TokenKind.RasterizerOrderedTexture1DArrayKeyword; return true;
                case "rasterizerorderedtexture2d": token = TokenKind.RasterizerOrderedTexture2DKeyword; return true;
                case "rasterizerorderedtexture2darray": token = TokenKind.RasterizerOrderedTexture2DArrayKeyword; return true;
                case "rasterizerorderedtexture3d": token = TokenKind.RasterizerOrderedTexture3DKeyword; return true;
                case "RasterizerState": token = TokenKind.RasterizerStateKeyword; return true;
                case "register": token = TokenKind.RegisterKeyword; return true;
                case "return": token = TokenKind.ReturnKeyword; return true;
                case "row_major": token = TokenKind.RowMajorKeyword; return true;
                case "RWBuffer": token = TokenKind.RWBufferKeyword; return true;
                case "RWByteAddressBuffer": token = TokenKind.RWByteAddressBufferKeyword; return true;
                case "RWStructuredBuffer": token = TokenKind.RWStructuredBufferKeyword; return true;
                case "RWTexture1D": token = TokenKind.RWTexture1DKeyword; return true;
                case "RWTexture1DArray": token = TokenKind.RWTexture1DArrayKeyword; return true;
                case "RWTexture2D": token = TokenKind.RWTexture2DKeyword; return true;
                case "RWTexture2DArray": token = TokenKind.RWTexture2DArrayKeyword; return true;
                case "RWTexture3D": token = TokenKind.RWTexture3DKeyword; return true;
                case "sampler": token = TokenKind.SamplerKeyword; return true;
                case "sampler1D": token = TokenKind.Sampler1DKeyword; return true;
                case "sampler2D": token = TokenKind.Sampler2DKeyword; return true;
                case "sampler3D": token = TokenKind.Sampler3DKeyword; return true;
                case "samplercube": token = TokenKind.SamplerCubeKeyword; return true;
                case "SamplerComparisonState": token = TokenKind.SamplerComparisonStateKeyword; return true;
                case "SamplerState": token = TokenKind.SamplerStateKeyword; return true;
                case "sampler_state": token = TokenKind.SamplerStateLegacyKeyword; return true;
                case "shared": token = TokenKind.SharedKeyword; return true;
                case "snorm": token = TokenKind.SNormKeyword; return true;
                case "static": token = TokenKind.StaticKeyword; return true;
                case "string": token = TokenKind.StringKeyword; return true;
                case "struct": token = TokenKind.StructKeyword; return true;
                case "StructuredBuffer": token = TokenKind.StructuredBufferKeyword; return true;
                case "switch": token = TokenKind.SwitchKeyword; return true;
                case "tbuffer": token = TokenKind.TBufferKeyword; return true;
                case "Technique": token = TokenKind.TechniqueKeyword; return true;
                case "technique": token = TokenKind.TechniqueKeyword; return true;
                case "technique10": token = TokenKind.Technique10Keyword; return true;
                case "technique11": token = TokenKind.Technique11Keyword; return true;
                case "texture": token = TokenKind.TextureKeyword; return true;
                case "Texture2DLegacy": token = TokenKind.Texture2DLegacyKeyword; return true;
                case "TextureCubeLegacy": token = TokenKind.TextureCubeLegacyKeyword; return true;
                case "Texture1D": token = TokenKind.Texture1DKeyword; return true;
                case "Texture1DArray": token = TokenKind.Texture1DArrayKeyword; return true;
                case "Texture2D": token = TokenKind.Texture2DKeyword; return true;
                case "Texture2DArray": token = TokenKind.Texture2DArrayKeyword; return true;
                case "Texture2DMS": token = TokenKind.Texture2DMSKeyword; return true;
                case "Texture2DMSArray": token = TokenKind.Texture2DMSArrayKeyword; return true;
                case "Texture3D": token = TokenKind.Texture3DKeyword; return true;
                case "TextureCube": token = TokenKind.TextureCubeKeyword; return true;
                case "TextureCubeArray": token = TokenKind.TextureCubeArrayKeyword; return true;
                case "triangle": token = TokenKind.TriangleKeyword; return true;
                case "triangleadj": token = TokenKind.TriangleAdjKeyword; return true;
                case "TriangleStream": token = TokenKind.TriangleStreamKeyword; return true;
                case "typedef": token = TokenKind.TypedefKeyword; return true;
                case "uniform": token = TokenKind.UniformKeyword; return true;
                case "unorm": token = TokenKind.UNormKeyword; return true;
                case "uint": token = TokenKind.UintKeyword; return true;
                case "uint1": token = TokenKind.Uint1Keyword; return true;
                case "uint2": token = TokenKind.Uint2Keyword; return true;
                case "uint3": token = TokenKind.Uint3Keyword; return true;
                case "uint4": token = TokenKind.Uint4Keyword; return true;
                case "uint1x1": token = TokenKind.Uint1x1Keyword; return true;
                case "uint1x2": token = TokenKind.Uint1x2Keyword; return true;
                case "uint1x3": token = TokenKind.Uint1x3Keyword; return true;
                case "uint1x4": token = TokenKind.Uint1x4Keyword; return true;
                case "uint2x1": token = TokenKind.Uint2x1Keyword; return true;
                case "uint2x2": token = TokenKind.Uint2x2Keyword; return true;
                case "uint2x3": token = TokenKind.Uint2x3Keyword; return true;
                case "uint2x4": token = TokenKind.Uint2x4Keyword; return true;
                case "uint3x1": token = TokenKind.Uint3x1Keyword; return true;
                case "uint3x2": token = TokenKind.Uint3x2Keyword; return true;
                case "uint3x3": token = TokenKind.Uint3x3Keyword; return true;
                case "uint3x4": token = TokenKind.Uint3x4Keyword; return true;
                case "uint4x1": token = TokenKind.Uint4x1Keyword; return true;
                case "uint4x2": token = TokenKind.Uint4x2Keyword; return true;
                case "uint4x3": token = TokenKind.Uint4x3Keyword; return true;
                case "uint4x4": token = TokenKind.Uint4x4Keyword; return true;
                case "vector": token = TokenKind.VectorKeyword; return true;
                case "vertices": token = TokenKind.VerticesKeyword; return true;
                case "volatile": token = TokenKind.VolatileKeyword; return true;
                case "void": token = TokenKind.VoidKeyword; return true;
                case "warning": token = TokenKind.WarningKeyword; return true;
                case "while": token = TokenKind.WhileKeyword; return true;
                case "true": token = TokenKind.TrueKeyword; return true;
                case "false": token = TokenKind.FalseKeyword; return true;
                case "unsigned": token = TokenKind.UnsignedKeyword; return true;
                case "dword": token = TokenKind.DwordKeyword; return true;
                case "compile_fragment": token = TokenKind.CompileFragmentKeyword; return true;
                case "DepthStencilView": token = TokenKind.DepthStencilViewKeyword; return true;
                case "pixelfragment": token = TokenKind.PixelfragmentKeyword; return true;
                case "RenderTargetView": token = TokenKind.RenderTargetViewKeyword; return true;
                case "stateblock_state": token = TokenKind.StateblockStateKeyword; return true;
                case "stateblock": token = TokenKind.StateblockKeyword; return true;
                default: token = TokenKind.InvalidToken; return false;
            }
        }

        public static bool TryConvertToScalarType(TokenKind kind, out ScalarType type)
        {
            switch (kind)
            {
                case TokenKind.VoidKeyword: type = ScalarType.Void; return true;
                case TokenKind.BoolKeyword: type = ScalarType.Bool; return true;
                case TokenKind.IntKeyword: type = ScalarType.Int; return true;
                case TokenKind.UintKeyword: type = ScalarType.Uint; return true;
                case TokenKind.HalfKeyword: type = ScalarType.Half; return true;
                case TokenKind.FloatKeyword: type = ScalarType.Float; return true;
                case TokenKind.DoubleKeyword: type = ScalarType.Double; return true;
                case TokenKind.Min16FloatKeyword: type = ScalarType.Min16Float; return true;
                case TokenKind.Min10FloatKeyword: type = ScalarType.Min10Float; return true;
                case TokenKind.Min16IntKeyword: type = ScalarType.Min16Int; return true;
                case TokenKind.Min12IntKeyword: type = ScalarType.Min12Int; return true;
                case TokenKind.Min16UintKeyword: type = ScalarType.Min16Uint; return true;
                case TokenKind.Min12UintKeyword: type = ScalarType.Min12Uint; return true;
                case TokenKind.StringKeyword: type = ScalarType.String; return true;
                default: type = ScalarType.Void; return false;
            }
        }

        public static bool TryConvertToMonomorphicVectorType(TokenKind kind, out ScalarType type, out int dimension)
        {
            switch (kind)
            {
                case TokenKind.Bool1Keyword: type = ScalarType.Bool; dimension = 1; return true;
                case TokenKind.Bool2Keyword: type = ScalarType.Bool; dimension = 2; return true;
                case TokenKind.Bool3Keyword: type = ScalarType.Bool; dimension = 3; return true;
                case TokenKind.Bool4Keyword: type = ScalarType.Bool; dimension = 4; return true;
                case TokenKind.Half1Keyword: type = ScalarType.Half; dimension = 1; return true;
                case TokenKind.Half2Keyword: type = ScalarType.Half; dimension = 2; return true;
                case TokenKind.Half3Keyword: type = ScalarType.Half; dimension = 3; return true;
                case TokenKind.Half4Keyword: type = ScalarType.Half; dimension = 4; return true;
                case TokenKind.Int1Keyword: type = ScalarType.Int; dimension = 1; return true;
                case TokenKind.Int2Keyword: type = ScalarType.Int; dimension = 2; return true;
                case TokenKind.Int3Keyword: type = ScalarType.Int; dimension = 3; return true;
                case TokenKind.Int4Keyword: type = ScalarType.Int; dimension = 4; return true;
                case TokenKind.Uint1Keyword: type = ScalarType.Uint; dimension = 1; return true;
                case TokenKind.Uint2Keyword: type = ScalarType.Uint; dimension = 2; return true;
                case TokenKind.Uint3Keyword: type = ScalarType.Uint; dimension = 3; return true;
                case TokenKind.Uint4Keyword: type = ScalarType.Uint; dimension = 4; return true;
                case TokenKind.Float1Keyword: type = ScalarType.Float; dimension = 1; return true;
                case TokenKind.Float2Keyword: type = ScalarType.Float; dimension = 2; return true;
                case TokenKind.Float3Keyword: type = ScalarType.Float; dimension = 3; return true;
                case TokenKind.Float4Keyword: type = ScalarType.Float; dimension = 4; return true;
                case TokenKind.Double1Keyword: type = ScalarType.Double; dimension = 1; return true;
                case TokenKind.Double2Keyword: type = ScalarType.Double; dimension = 2; return true;
                case TokenKind.Double3Keyword: type = ScalarType.Double; dimension = 3; return true;
                case TokenKind.Double4Keyword: type = ScalarType.Double; dimension = 4; return true;
                case TokenKind.Min16Float1Keyword: type = ScalarType.Min16Float; dimension = 1; return true;
                case TokenKind.Min16Float2Keyword: type = ScalarType.Min16Float; dimension = 2; return true;
                case TokenKind.Min16Float3Keyword: type = ScalarType.Min16Float; dimension = 3; return true;
                case TokenKind.Min16Float4Keyword: type = ScalarType.Min16Float; dimension = 4; return true;
                case TokenKind.Min10Float1Keyword: type = ScalarType.Min10Float; dimension = 1; return true;
                case TokenKind.Min10Float2Keyword: type = ScalarType.Min10Float; dimension = 2; return true;
                case TokenKind.Min10Float3Keyword: type = ScalarType.Min10Float; dimension = 3; return true;
                case TokenKind.Min10Float4Keyword: type = ScalarType.Min10Float; dimension = 4; return true;
                case TokenKind.Min16Int1Keyword: type = ScalarType.Min16Int; dimension = 1; return true;
                case TokenKind.Min16Int2Keyword: type = ScalarType.Min16Int; dimension = 2; return true;
                case TokenKind.Min16Int3Keyword: type = ScalarType.Min16Int; dimension = 3; return true;
                case TokenKind.Min16Int4Keyword: type = ScalarType.Min16Int; dimension = 4; return true;
                case TokenKind.Min12Int1Keyword: type = ScalarType.Min12Int; dimension = 1; return true;
                case TokenKind.Min12Int2Keyword: type = ScalarType.Min12Int; dimension = 2; return true;
                case TokenKind.Min12Int3Keyword: type = ScalarType.Min12Int; dimension = 3; return true;
                case TokenKind.Min12Int4Keyword: type = ScalarType.Min12Int; dimension = 4; return true;
                case TokenKind.Min16Uint1Keyword: type = ScalarType.Min16Uint; dimension = 1; return true;
                case TokenKind.Min16Uint2Keyword: type = ScalarType.Min16Uint; dimension = 2; return true;
                case TokenKind.Min16Uint3Keyword: type = ScalarType.Min16Uint; dimension = 3; return true;
                case TokenKind.Min16Uint4Keyword: type = ScalarType.Min16Uint; dimension = 4; return true;
                case TokenKind.Min12Uint1Keyword: type = ScalarType.Min12Uint; dimension = 1; return true;
                case TokenKind.Min12Uint2Keyword: type = ScalarType.Min12Uint; dimension = 2; return true;
                case TokenKind.Min12Uint3Keyword: type = ScalarType.Min12Uint; dimension = 3; return true;
                case TokenKind.Min12Uint4Keyword: type = ScalarType.Min12Uint; dimension = 4; return true;
                case TokenKind.VectorKeyword: type = ScalarType.Float; dimension = 4; return true;
                default: type = default; dimension = 0; return false;
            }
        }

        public static bool TryConvertToPredefinedObjectType(Token<TokenKind> token, out PredefinedObjectType type)
        {
            switch (token.Kind)
            {
                case TokenKind.AppendStructuredBufferKeyword: type = PredefinedObjectType.AppendStructuredBuffer; return true;
                case TokenKind.BlendStateKeyword: type = PredefinedObjectType.BlendState; return true;
                case TokenKind.BufferKeyword: type = PredefinedObjectType.Buffer; return true;
                case TokenKind.ByteAddressBufferKeyword: type = PredefinedObjectType.ByteAddressBuffer; return true;
                case TokenKind.ConsumeStructuredBufferKeyword: type = PredefinedObjectType.ConsumeStructuredBuffer; return true;
                case TokenKind.DepthStencilStateKeyword: type = PredefinedObjectType.DepthStencilState; return true;
                case TokenKind.InputPatchKeyword: type = PredefinedObjectType.InputPatch; return true;
                case TokenKind.LineStreamKeyword: type = PredefinedObjectType.LineStream; return true;
                case TokenKind.OutputPatchKeyword: type = PredefinedObjectType.OutputPatch; return true;
                case TokenKind.PointStreamKeyword: type = PredefinedObjectType.PointStream; return true;
                case TokenKind.RasterizerStateKeyword: type = PredefinedObjectType.RasterizerState; return true;
                case TokenKind.RWBufferKeyword: type = PredefinedObjectType.RWBuffer; return true;
                case TokenKind.RWByteAddressBufferKeyword: type = PredefinedObjectType.RWByteAddressBuffer; return true;
                case TokenKind.RWStructuredBufferKeyword: type = PredefinedObjectType.RWStructuredBuffer; return true;
                case TokenKind.RWTexture1DKeyword: type = PredefinedObjectType.RWTexture1D; return true;
                case TokenKind.RWTexture1DArrayKeyword: type = PredefinedObjectType.RWTexture1DArray; return true;
                case TokenKind.RWTexture2DKeyword: type = PredefinedObjectType.RWTexture2D; return true;
                case TokenKind.RWTexture2DArrayKeyword: type = PredefinedObjectType.RWTexture2DArray; return true;
                case TokenKind.RWTexture3DKeyword: type = PredefinedObjectType.RWTexture3D; return true;
                case TokenKind.Sampler1DKeyword: type = PredefinedObjectType.Sampler1D; return true;
                case TokenKind.SamplerKeyword: type = PredefinedObjectType.Sampler; return true;
                case TokenKind.Sampler2DKeyword: type = PredefinedObjectType.Sampler2D; return true;
                case TokenKind.Sampler3DKeyword: type = PredefinedObjectType.Sampler3D; return true;
                case TokenKind.SamplerCubeKeyword: type = PredefinedObjectType.SamplerCube; return true;
                case TokenKind.SamplerStateKeyword: type = PredefinedObjectType.SamplerState; return true;
                case TokenKind.SamplerComparisonStateKeyword: type = PredefinedObjectType.SamplerComparisonState; return true;
                case TokenKind.StructuredBufferKeyword: type = PredefinedObjectType.StructuredBuffer; return true;
                case TokenKind.TextureKeyword: type = PredefinedObjectType.Texture; return true;
                case TokenKind.Texture2DLegacyKeyword: type = PredefinedObjectType.Texture; return true;
                case TokenKind.TextureCubeLegacyKeyword: type = PredefinedObjectType.Texture; return true;
                case TokenKind.Texture1DKeyword: type = PredefinedObjectType.Texture1D; return true;
                case TokenKind.Texture1DArrayKeyword: type = PredefinedObjectType.Texture1DArray; return true;
                case TokenKind.Texture2DKeyword: type = PredefinedObjectType.Texture2D; return true;
                case TokenKind.Texture2DArrayKeyword: type = PredefinedObjectType.Texture2DArray; return true;
                case TokenKind.Texture2DMSKeyword: type = PredefinedObjectType.Texture2DMS; return true;
                case TokenKind.Texture2DMSArrayKeyword: type = PredefinedObjectType.Texture2DMSArray; return true;
                case TokenKind.Texture3DKeyword: type = PredefinedObjectType.Texture3D; return true;
                case TokenKind.TextureCubeKeyword: type = PredefinedObjectType.TextureCube; return true;
                case TokenKind.TextureCubeArrayKeyword: type = PredefinedObjectType.TextureCubeArray; return true;
                case TokenKind.TriangleStreamKeyword: type = PredefinedObjectType.TriangleStream; return true;
                case TokenKind.RasterizerOrderedBufferKeyword: type = PredefinedObjectType.RasterizerOrderedBuffer; return true;
                case TokenKind.RasterizerOrderedByteAddressBufferKeyword: type = PredefinedObjectType.RasterizerOrderedByteAddressBuffer; return true;
                case TokenKind.RasterizerOrderedStructuredBufferKeyword: type = PredefinedObjectType.RasterizerOrderedStructuredBuffer; return true;
                case TokenKind.RasterizerOrderedTexture1DArrayKeyword: type = PredefinedObjectType.RasterizerOrderedTexture1DArray; return true;
                case TokenKind.RasterizerOrderedTexture1DKeyword: type = PredefinedObjectType.RasterizerOrderedTexture1D; return true;
                case TokenKind.RasterizerOrderedTexture2DArrayKeyword: type = PredefinedObjectType.RasterizerOrderedTexture2DArray; return true;
                case TokenKind.RasterizerOrderedTexture2DKeyword: type = PredefinedObjectType.RasterizerOrderedTexture2D; return true;
                case TokenKind.RasterizerOrderedTexture3DKeyword: type = PredefinedObjectType.RasterizerOrderedTexture3D; return true;
                // Weird edge case of HLSL grammar - 'ConstantBuffer' is not a real keyword, but is allowed as a generic type.
                case TokenKind.IdentifierToken when token.Identifier == "ConstantBuffer": type = PredefinedObjectType.ConstantBuffer; return true;
                default: type = default; return false;
            }
        }

        public static bool TryConvertToMonomorphicMatrixType(TokenKind kind, out ScalarType type, out int dimensionX, out int dimensionY)
        {
            switch (kind)
            {
                case TokenKind.Bool1x1Keyword: type = ScalarType.Bool; dimensionX = 1; dimensionY = 1; return true;
                case TokenKind.Bool1x2Keyword: type = ScalarType.Bool; dimensionX = 1; dimensionY = 2; return true;
                case TokenKind.Bool1x3Keyword: type = ScalarType.Bool; dimensionX = 1; dimensionY = 3; return true;
                case TokenKind.Bool1x4Keyword: type = ScalarType.Bool; dimensionX = 1; dimensionY = 4; return true;
                case TokenKind.Bool2x1Keyword: type = ScalarType.Bool; dimensionX = 2; dimensionY = 1; return true;
                case TokenKind.Bool2x2Keyword: type = ScalarType.Bool; dimensionX = 2; dimensionY = 2; return true;
                case TokenKind.Bool2x3Keyword: type = ScalarType.Bool; dimensionX = 2; dimensionY = 3; return true;
                case TokenKind.Bool2x4Keyword: type = ScalarType.Bool; dimensionX = 2; dimensionY = 4; return true;
                case TokenKind.Bool3x1Keyword: type = ScalarType.Bool; dimensionX = 3; dimensionY = 1; return true;
                case TokenKind.Bool3x2Keyword: type = ScalarType.Bool; dimensionX = 3; dimensionY = 2; return true;
                case TokenKind.Bool3x3Keyword: type = ScalarType.Bool; dimensionX = 3; dimensionY = 3; return true;
                case TokenKind.Bool3x4Keyword: type = ScalarType.Bool; dimensionX = 3; dimensionY = 4; return true;
                case TokenKind.Bool4x1Keyword: type = ScalarType.Bool; dimensionX = 4; dimensionY = 1; return true;
                case TokenKind.Bool4x2Keyword: type = ScalarType.Bool; dimensionX = 4; dimensionY = 2; return true;
                case TokenKind.Bool4x3Keyword: type = ScalarType.Bool; dimensionX = 4; dimensionY = 3; return true;
                case TokenKind.Bool4x4Keyword: type = ScalarType.Bool; dimensionX = 4; dimensionY = 4; return true;
                case TokenKind.Double1x1Keyword: type = ScalarType.Double; dimensionX = 1; dimensionY = 1; return true;
                case TokenKind.Double1x2Keyword: type = ScalarType.Double; dimensionX = 1; dimensionY = 2; return true;
                case TokenKind.Double1x3Keyword: type = ScalarType.Double; dimensionX = 1; dimensionY = 3; return true;
                case TokenKind.Double1x4Keyword: type = ScalarType.Double; dimensionX = 1; dimensionY = 4; return true;
                case TokenKind.Double2x1Keyword: type = ScalarType.Double; dimensionX = 2; dimensionY = 1; return true;
                case TokenKind.Double2x2Keyword: type = ScalarType.Double; dimensionX = 2; dimensionY = 2; return true;
                case TokenKind.Double2x3Keyword: type = ScalarType.Double; dimensionX = 2; dimensionY = 3; return true;
                case TokenKind.Double2x4Keyword: type = ScalarType.Double; dimensionX = 2; dimensionY = 4; return true;
                case TokenKind.Double3x1Keyword: type = ScalarType.Double; dimensionX = 3; dimensionY = 1; return true;
                case TokenKind.Double3x2Keyword: type = ScalarType.Double; dimensionX = 3; dimensionY = 2; return true;
                case TokenKind.Double3x3Keyword: type = ScalarType.Double; dimensionX = 3; dimensionY = 3; return true;
                case TokenKind.Double3x4Keyword: type = ScalarType.Double; dimensionX = 3; dimensionY = 4; return true;
                case TokenKind.Double4x1Keyword: type = ScalarType.Double; dimensionX = 4; dimensionY = 1; return true;
                case TokenKind.Double4x2Keyword: type = ScalarType.Double; dimensionX = 4; dimensionY = 2; return true;
                case TokenKind.Double4x3Keyword: type = ScalarType.Double; dimensionX = 4; dimensionY = 3; return true;
                case TokenKind.Double4x4Keyword: type = ScalarType.Double; dimensionX = 4; dimensionY = 4; return true;
                case TokenKind.Float1x1Keyword: type = ScalarType.Float; dimensionX = 1; dimensionY = 1; return true;
                case TokenKind.Float1x2Keyword: type = ScalarType.Float; dimensionX = 1; dimensionY = 2; return true;
                case TokenKind.Float1x3Keyword: type = ScalarType.Float; dimensionX = 1; dimensionY = 3; return true;
                case TokenKind.Float1x4Keyword: type = ScalarType.Float; dimensionX = 1; dimensionY = 4; return true;
                case TokenKind.Float2x1Keyword: type = ScalarType.Float; dimensionX = 2; dimensionY = 1; return true;
                case TokenKind.Float2x2Keyword: type = ScalarType.Float; dimensionX = 2; dimensionY = 2; return true;
                case TokenKind.Float2x3Keyword: type = ScalarType.Float; dimensionX = 2; dimensionY = 3; return true;
                case TokenKind.Float2x4Keyword: type = ScalarType.Float; dimensionX = 2; dimensionY = 4; return true;
                case TokenKind.Float3x1Keyword: type = ScalarType.Float; dimensionX = 3; dimensionY = 1; return true;
                case TokenKind.Float3x2Keyword: type = ScalarType.Float; dimensionX = 3; dimensionY = 2; return true;
                case TokenKind.Float3x3Keyword: type = ScalarType.Float; dimensionX = 3; dimensionY = 3; return true;
                case TokenKind.Float3x4Keyword: type = ScalarType.Float; dimensionX = 3; dimensionY = 4; return true;
                case TokenKind.Float4x1Keyword: type = ScalarType.Float; dimensionX = 4; dimensionY = 1; return true;
                case TokenKind.Float4x2Keyword: type = ScalarType.Float; dimensionX = 4; dimensionY = 2; return true;
                case TokenKind.Float4x3Keyword: type = ScalarType.Float; dimensionX = 4; dimensionY = 3; return true;
                case TokenKind.Float4x4Keyword: type = ScalarType.Float; dimensionX = 4; dimensionY = 4; return true;
                case TokenKind.Half1x1Keyword: type = ScalarType.Half; dimensionX = 1; dimensionY = 1; return true;
                case TokenKind.Half1x2Keyword: type = ScalarType.Half; dimensionX = 1; dimensionY = 2; return true;
                case TokenKind.Half1x3Keyword: type = ScalarType.Half; dimensionX = 1; dimensionY = 3; return true;
                case TokenKind.Half1x4Keyword: type = ScalarType.Half; dimensionX = 1; dimensionY = 4; return true;
                case TokenKind.Half2x1Keyword: type = ScalarType.Half; dimensionX = 2; dimensionY = 1; return true;
                case TokenKind.Half2x2Keyword: type = ScalarType.Half; dimensionX = 2; dimensionY = 2; return true;
                case TokenKind.Half2x3Keyword: type = ScalarType.Half; dimensionX = 2; dimensionY = 3; return true;
                case TokenKind.Half2x4Keyword: type = ScalarType.Half; dimensionX = 2; dimensionY = 4; return true;
                case TokenKind.Half3x1Keyword: type = ScalarType.Half; dimensionX = 3; dimensionY = 1; return true;
                case TokenKind.Half3x2Keyword: type = ScalarType.Half; dimensionX = 3; dimensionY = 2; return true;
                case TokenKind.Half3x3Keyword: type = ScalarType.Half; dimensionX = 3; dimensionY = 3; return true;
                case TokenKind.Half3x4Keyword: type = ScalarType.Half; dimensionX = 3; dimensionY = 4; return true;
                case TokenKind.Half4x1Keyword: type = ScalarType.Half; dimensionX = 4; dimensionY = 1; return true;
                case TokenKind.Half4x2Keyword: type = ScalarType.Half; dimensionX = 4; dimensionY = 2; return true;
                case TokenKind.Half4x3Keyword: type = ScalarType.Half; dimensionX = 4; dimensionY = 3; return true;
                case TokenKind.Half4x4Keyword: type = ScalarType.Half; dimensionX = 4; dimensionY = 4; return true;
                case TokenKind.Int1x1Keyword: type = ScalarType.Int; dimensionX = 1; dimensionY = 1; return true;
                case TokenKind.Int1x2Keyword: type = ScalarType.Int; dimensionX = 1; dimensionY = 2; return true;
                case TokenKind.Int1x3Keyword: type = ScalarType.Int; dimensionX = 1; dimensionY = 3; return true;
                case TokenKind.Int1x4Keyword: type = ScalarType.Int; dimensionX = 1; dimensionY = 4; return true;
                case TokenKind.Int2x1Keyword: type = ScalarType.Int; dimensionX = 2; dimensionY = 1; return true;
                case TokenKind.Int2x2Keyword: type = ScalarType.Int; dimensionX = 2; dimensionY = 2; return true;
                case TokenKind.Int2x3Keyword: type = ScalarType.Int; dimensionX = 2; dimensionY = 3; return true;
                case TokenKind.Int2x4Keyword: type = ScalarType.Int; dimensionX = 2; dimensionY = 4; return true;
                case TokenKind.Int3x1Keyword: type = ScalarType.Int; dimensionX = 3; dimensionY = 1; return true;
                case TokenKind.Int3x2Keyword: type = ScalarType.Int; dimensionX = 3; dimensionY = 2; return true;
                case TokenKind.Int3x3Keyword: type = ScalarType.Int; dimensionX = 3; dimensionY = 3; return true;
                case TokenKind.Int3x4Keyword: type = ScalarType.Int; dimensionX = 3; dimensionY = 4; return true;
                case TokenKind.Int4x1Keyword: type = ScalarType.Int; dimensionX = 4; dimensionY = 1; return true;
                case TokenKind.Int4x2Keyword: type = ScalarType.Int; dimensionX = 4; dimensionY = 2; return true;
                case TokenKind.Int4x3Keyword: type = ScalarType.Int; dimensionX = 4; dimensionY = 3; return true;
                case TokenKind.Int4x4Keyword: type = ScalarType.Int; dimensionX = 4; dimensionY = 4; return true;
                case TokenKind.Min10Float1x1Keyword: type = ScalarType.Min10Float; dimensionX = 1; dimensionY = 1; return true;
                case TokenKind.Min10Float1x2Keyword: type = ScalarType.Min10Float; dimensionX = 1; dimensionY = 2; return true;
                case TokenKind.Min10Float1x3Keyword: type = ScalarType.Min10Float; dimensionX = 1; dimensionY = 3; return true;
                case TokenKind.Min10Float1x4Keyword: type = ScalarType.Min10Float; dimensionX = 1; dimensionY = 4; return true;
                case TokenKind.Min10Float2x1Keyword: type = ScalarType.Min10Float; dimensionX = 2; dimensionY = 1; return true;
                case TokenKind.Min10Float2x2Keyword: type = ScalarType.Min10Float; dimensionX = 2; dimensionY = 2; return true;
                case TokenKind.Min10Float2x3Keyword: type = ScalarType.Min10Float; dimensionX = 2; dimensionY = 3; return true;
                case TokenKind.Min10Float2x4Keyword: type = ScalarType.Min10Float; dimensionX = 2; dimensionY = 4; return true;
                case TokenKind.Min10Float3x1Keyword: type = ScalarType.Min10Float; dimensionX = 3; dimensionY = 1; return true;
                case TokenKind.Min10Float3x2Keyword: type = ScalarType.Min10Float; dimensionX = 3; dimensionY = 2; return true;
                case TokenKind.Min10Float3x3Keyword: type = ScalarType.Min10Float; dimensionX = 3; dimensionY = 3; return true;
                case TokenKind.Min10Float3x4Keyword: type = ScalarType.Min10Float; dimensionX = 3; dimensionY = 4; return true;
                case TokenKind.Min10Float4x1Keyword: type = ScalarType.Min10Float; dimensionX = 4; dimensionY = 1; return true;
                case TokenKind.Min10Float4x2Keyword: type = ScalarType.Min10Float; dimensionX = 4; dimensionY = 2; return true;
                case TokenKind.Min10Float4x3Keyword: type = ScalarType.Min10Float; dimensionX = 4; dimensionY = 3; return true;
                case TokenKind.Min10Float4x4Keyword: type = ScalarType.Min10Float; dimensionX = 4; dimensionY = 4; return true;
                case TokenKind.Min12Int1x1Keyword: type = ScalarType.Min12Int; dimensionX = 1; dimensionY = 1; return true;
                case TokenKind.Min12Int1x2Keyword: type = ScalarType.Min12Int; dimensionX = 1; dimensionY = 2; return true;
                case TokenKind.Min12Int1x3Keyword: type = ScalarType.Min12Int; dimensionX = 1; dimensionY = 3; return true;
                case TokenKind.Min12Int1x4Keyword: type = ScalarType.Min12Int; dimensionX = 1; dimensionY = 4; return true;
                case TokenKind.Min12Int2x1Keyword: type = ScalarType.Min12Int; dimensionX = 2; dimensionY = 1; return true;
                case TokenKind.Min12Int2x2Keyword: type = ScalarType.Min12Int; dimensionX = 2; dimensionY = 2; return true;
                case TokenKind.Min12Int2x3Keyword: type = ScalarType.Min12Int; dimensionX = 2; dimensionY = 3; return true;
                case TokenKind.Min12Int2x4Keyword: type = ScalarType.Min12Int; dimensionX = 2; dimensionY = 4; return true;
                case TokenKind.Min12Int3x1Keyword: type = ScalarType.Min12Int; dimensionX = 3; dimensionY = 1; return true;
                case TokenKind.Min12Int3x2Keyword: type = ScalarType.Min12Int; dimensionX = 3; dimensionY = 2; return true;
                case TokenKind.Min12Int3x3Keyword: type = ScalarType.Min12Int; dimensionX = 3; dimensionY = 3; return true;
                case TokenKind.Min12Int3x4Keyword: type = ScalarType.Min12Int; dimensionX = 3; dimensionY = 4; return true;
                case TokenKind.Min12Int4x1Keyword: type = ScalarType.Min12Int; dimensionX = 4; dimensionY = 1; return true;
                case TokenKind.Min12Int4x2Keyword: type = ScalarType.Min12Int; dimensionX = 4; dimensionY = 2; return true;
                case TokenKind.Min12Int4x3Keyword: type = ScalarType.Min12Int; dimensionX = 4; dimensionY = 3; return true;
                case TokenKind.Min12Int4x4Keyword: type = ScalarType.Min12Int; dimensionX = 4; dimensionY = 4; return true;
                case TokenKind.Min16Float1x1Keyword: type = ScalarType.Min16Float; dimensionX = 1; dimensionY = 1; return true;
                case TokenKind.Min16Float1x2Keyword: type = ScalarType.Min16Float; dimensionX = 1; dimensionY = 2; return true;
                case TokenKind.Min16Float1x3Keyword: type = ScalarType.Min16Float; dimensionX = 1; dimensionY = 3; return true;
                case TokenKind.Min16Float1x4Keyword: type = ScalarType.Min16Float; dimensionX = 1; dimensionY = 4; return true;
                case TokenKind.Min16Float2x1Keyword: type = ScalarType.Min16Float; dimensionX = 2; dimensionY = 1; return true;
                case TokenKind.Min16Float2x2Keyword: type = ScalarType.Min16Float; dimensionX = 2; dimensionY = 2; return true;
                case TokenKind.Min16Float2x3Keyword: type = ScalarType.Min16Float; dimensionX = 2; dimensionY = 3; return true;
                case TokenKind.Min16Float2x4Keyword: type = ScalarType.Min16Float; dimensionX = 2; dimensionY = 4; return true;
                case TokenKind.Min16Float3x1Keyword: type = ScalarType.Min16Float; dimensionX = 3; dimensionY = 1; return true;
                case TokenKind.Min16Float3x2Keyword: type = ScalarType.Min16Float; dimensionX = 3; dimensionY = 2; return true;
                case TokenKind.Min16Float3x3Keyword: type = ScalarType.Min16Float; dimensionX = 3; dimensionY = 3; return true;
                case TokenKind.Min16Float3x4Keyword: type = ScalarType.Min16Float; dimensionX = 3; dimensionY = 4; return true;
                case TokenKind.Min16Float4x1Keyword: type = ScalarType.Min16Float; dimensionX = 4; dimensionY = 1; return true;
                case TokenKind.Min16Float4x2Keyword: type = ScalarType.Min16Float; dimensionX = 4; dimensionY = 2; return true;
                case TokenKind.Min16Float4x3Keyword: type = ScalarType.Min16Float; dimensionX = 4; dimensionY = 3; return true;
                case TokenKind.Min16Float4x4Keyword: type = ScalarType.Min16Float; dimensionX = 4; dimensionY = 4; return true;
                case TokenKind.Min16Int1x1Keyword: type = ScalarType.Min16Int; dimensionX = 1; dimensionY = 1; return true;
                case TokenKind.Min16Int1x2Keyword: type = ScalarType.Min16Int; dimensionX = 1; dimensionY = 2; return true;
                case TokenKind.Min16Int1x3Keyword: type = ScalarType.Min16Int; dimensionX = 1; dimensionY = 3; return true;
                case TokenKind.Min16Int1x4Keyword: type = ScalarType.Min16Int; dimensionX = 1; dimensionY = 4; return true;
                case TokenKind.Min16Int2x1Keyword: type = ScalarType.Min16Int; dimensionX = 2; dimensionY = 1; return true;
                case TokenKind.Min16Int2x2Keyword: type = ScalarType.Min16Int; dimensionX = 2; dimensionY = 2; return true;
                case TokenKind.Min16Int2x3Keyword: type = ScalarType.Min16Int; dimensionX = 2; dimensionY = 3; return true;
                case TokenKind.Min16Int2x4Keyword: type = ScalarType.Min16Int; dimensionX = 2; dimensionY = 4; return true;
                case TokenKind.Min16Int3x1Keyword: type = ScalarType.Min16Int; dimensionX = 3; dimensionY = 1; return true;
                case TokenKind.Min16Int3x2Keyword: type = ScalarType.Min16Int; dimensionX = 3; dimensionY = 2; return true;
                case TokenKind.Min16Int3x3Keyword: type = ScalarType.Min16Int; dimensionX = 3; dimensionY = 3; return true;
                case TokenKind.Min16Int3x4Keyword: type = ScalarType.Min16Int; dimensionX = 3; dimensionY = 4; return true;
                case TokenKind.Min16Int4x1Keyword: type = ScalarType.Min16Int; dimensionX = 4; dimensionY = 1; return true;
                case TokenKind.Min16Int4x2Keyword: type = ScalarType.Min16Int; dimensionX = 4; dimensionY = 2; return true;
                case TokenKind.Min16Int4x3Keyword: type = ScalarType.Min16Int; dimensionX = 4; dimensionY = 3; return true;
                case TokenKind.Min16Int4x4Keyword: type = ScalarType.Min16Int; dimensionX = 4; dimensionY = 4; return true;
                case TokenKind.Min16Uint1x1Keyword: type = ScalarType.Min16Uint; dimensionX = 1; dimensionY = 1; return true;
                case TokenKind.Min16Uint1x2Keyword: type = ScalarType.Min16Uint; dimensionX = 1; dimensionY = 2; return true;
                case TokenKind.Min16Uint1x3Keyword: type = ScalarType.Min16Uint; dimensionX = 1; dimensionY = 3; return true;
                case TokenKind.Min16Uint1x4Keyword: type = ScalarType.Min16Uint; dimensionX = 1; dimensionY = 4; return true;
                case TokenKind.Min16Uint2x1Keyword: type = ScalarType.Min16Uint; dimensionX = 2; dimensionY = 1; return true;
                case TokenKind.Min16Uint2x2Keyword: type = ScalarType.Min16Uint; dimensionX = 2; dimensionY = 2; return true;
                case TokenKind.Min16Uint2x3Keyword: type = ScalarType.Min16Uint; dimensionX = 2; dimensionY = 3; return true;
                case TokenKind.Min16Uint2x4Keyword: type = ScalarType.Min16Uint; dimensionX = 2; dimensionY = 4; return true;
                case TokenKind.Min16Uint3x1Keyword: type = ScalarType.Min16Uint; dimensionX = 3; dimensionY = 1; return true;
                case TokenKind.Min16Uint3x2Keyword: type = ScalarType.Min16Uint; dimensionX = 3; dimensionY = 2; return true;
                case TokenKind.Min16Uint3x3Keyword: type = ScalarType.Min16Uint; dimensionX = 3; dimensionY = 3; return true;
                case TokenKind.Min16Uint3x4Keyword: type = ScalarType.Min16Uint; dimensionX = 3; dimensionY = 4; return true;
                case TokenKind.Min16Uint4x1Keyword: type = ScalarType.Min16Uint; dimensionX = 4; dimensionY = 1; return true;
                case TokenKind.Min16Uint4x2Keyword: type = ScalarType.Min16Uint; dimensionX = 4; dimensionY = 2; return true;
                case TokenKind.Min16Uint4x3Keyword: type = ScalarType.Min16Uint; dimensionX = 4; dimensionY = 3; return true;
                case TokenKind.Min16Uint4x4Keyword: type = ScalarType.Min16Uint; dimensionX = 4; dimensionY = 4; return true;
                case TokenKind.Uint1x1Keyword: type = ScalarType.Uint; dimensionX = 1; dimensionY = 1; return true;
                case TokenKind.Uint1x2Keyword: type = ScalarType.Uint; dimensionX = 1; dimensionY = 2; return true;
                case TokenKind.Uint1x3Keyword: type = ScalarType.Uint; dimensionX = 1; dimensionY = 3; return true;
                case TokenKind.Uint1x4Keyword: type = ScalarType.Uint; dimensionX = 1; dimensionY = 4; return true;
                case TokenKind.Uint2x1Keyword: type = ScalarType.Uint; dimensionX = 2; dimensionY = 1; return true;
                case TokenKind.Uint2x2Keyword: type = ScalarType.Uint; dimensionX = 2; dimensionY = 2; return true;
                case TokenKind.Uint2x3Keyword: type = ScalarType.Uint; dimensionX = 2; dimensionY = 3; return true;
                case TokenKind.Uint2x4Keyword: type = ScalarType.Uint; dimensionX = 2; dimensionY = 4; return true;
                case TokenKind.Uint3x1Keyword: type = ScalarType.Uint; dimensionX = 3; dimensionY = 1; return true;
                case TokenKind.Uint3x2Keyword: type = ScalarType.Uint; dimensionX = 3; dimensionY = 2; return true;
                case TokenKind.Uint3x3Keyword: type = ScalarType.Uint; dimensionX = 3; dimensionY = 3; return true;
                case TokenKind.Uint3x4Keyword: type = ScalarType.Uint; dimensionX = 3; dimensionY = 4; return true;
                case TokenKind.Uint4x1Keyword: type = ScalarType.Uint; dimensionX = 4; dimensionY = 1; return true;
                case TokenKind.Uint4x2Keyword: type = ScalarType.Uint; dimensionX = 4; dimensionY = 2; return true;
                case TokenKind.Uint4x3Keyword: type = ScalarType.Uint; dimensionX = 4; dimensionY = 3; return true;
                case TokenKind.Uint4x4Keyword: type = ScalarType.Uint; dimensionX = 4; dimensionY = 4; return true;
                case TokenKind.MatrixKeyword: type = ScalarType.Float; dimensionX = 4; dimensionY = 4; return true;
                case TokenKind.Min12Uint1x1Keyword: type = ScalarType.Min12Uint; dimensionX = 1; dimensionY = 1; return true;
                case TokenKind.Min12Uint1x2Keyword: type = ScalarType.Min12Uint; dimensionX = 1; dimensionY = 2; return true;
                case TokenKind.Min12Uint1x3Keyword: type = ScalarType.Min12Uint; dimensionX = 1; dimensionY = 3; return true;
                case TokenKind.Min12Uint1x4Keyword: type = ScalarType.Min12Uint; dimensionX = 1; dimensionY = 4; return true;
                case TokenKind.Min12Uint2x1Keyword: type = ScalarType.Min12Uint; dimensionX = 2; dimensionY = 1; return true;
                case TokenKind.Min12Uint2x2Keyword: type = ScalarType.Min12Uint; dimensionX = 2; dimensionY = 2; return true;
                case TokenKind.Min12Uint2x3Keyword: type = ScalarType.Min12Uint; dimensionX = 2; dimensionY = 3; return true;
                case TokenKind.Min12Uint2x4Keyword: type = ScalarType.Min12Uint; dimensionX = 2; dimensionY = 4; return true;
                case TokenKind.Min12Uint3x1Keyword: type = ScalarType.Min12Uint; dimensionX = 3; dimensionY = 1; return true;
                case TokenKind.Min12Uint3x2Keyword: type = ScalarType.Min12Uint; dimensionX = 3; dimensionY = 2; return true;
                case TokenKind.Min12Uint3x3Keyword: type = ScalarType.Min12Uint; dimensionX = 3; dimensionY = 3; return true;
                case TokenKind.Min12Uint3x4Keyword: type = ScalarType.Min12Uint; dimensionX = 3; dimensionY = 4; return true;
                case TokenKind.Min12Uint4x1Keyword: type = ScalarType.Min12Uint; dimensionX = 4; dimensionY = 1; return true;
                case TokenKind.Min12Uint4x2Keyword: type = ScalarType.Min12Uint; dimensionX = 4; dimensionY = 2; return true;
                case TokenKind.Min12Uint4x3Keyword: type = ScalarType.Min12Uint; dimensionX = 4; dimensionY = 3; return true;
                case TokenKind.Min12Uint4x4Keyword: type = ScalarType.Min12Uint; dimensionX = 4; dimensionY = 4; return true;
                default: type = default; dimensionX = 0; dimensionY = 0; return false;
            }
        }

        public static bool IsMultiArityNumericConstructor(TokenKind kind)
        {
            switch (kind)
            {
                case TokenKind.VectorKeyword:
                case TokenKind.Bool1Keyword:
                case TokenKind.Bool2Keyword:
                case TokenKind.Bool3Keyword:
                case TokenKind.Bool4Keyword:
                case TokenKind.Half1Keyword:
                case TokenKind.Half2Keyword:
                case TokenKind.Half3Keyword:
                case TokenKind.Half4Keyword:
                case TokenKind.Int1Keyword:
                case TokenKind.Int2Keyword:
                case TokenKind.Int3Keyword:
                case TokenKind.Int4Keyword:
                case TokenKind.Uint1Keyword:
                case TokenKind.Uint2Keyword:
                case TokenKind.Uint3Keyword:
                case TokenKind.Uint4Keyword:
                case TokenKind.Float1Keyword:
                case TokenKind.Float2Keyword:
                case TokenKind.Float3Keyword:
                case TokenKind.Float4Keyword:
                case TokenKind.Double1Keyword:
                case TokenKind.Double2Keyword:
                case TokenKind.Double3Keyword:
                case TokenKind.Double4Keyword:
                case TokenKind.Min16Float1Keyword:
                case TokenKind.Min16Float2Keyword:
                case TokenKind.Min16Float3Keyword:
                case TokenKind.Min16Float4Keyword:
                case TokenKind.Min10Float1Keyword:
                case TokenKind.Min10Float2Keyword:
                case TokenKind.Min10Float3Keyword:
                case TokenKind.Min10Float4Keyword:
                case TokenKind.Min16Int1Keyword:
                case TokenKind.Min16Int2Keyword:
                case TokenKind.Min16Int3Keyword:
                case TokenKind.Min16Int4Keyword:
                case TokenKind.Min12Int1Keyword:
                case TokenKind.Min12Int2Keyword:
                case TokenKind.Min12Int3Keyword:
                case TokenKind.Min12Int4Keyword:
                case TokenKind.Min16Uint1Keyword:
                case TokenKind.Min16Uint2Keyword:
                case TokenKind.Min16Uint3Keyword:
                case TokenKind.Min16Uint4Keyword:
                case TokenKind.Min12Uint1Keyword:
                case TokenKind.Min12Uint2Keyword:
                case TokenKind.Min12Uint3Keyword:
                case TokenKind.Min12Uint4Keyword:
                case TokenKind.SNormKeyword:
                case TokenKind.UNormKeyword:

                case TokenKind.MatrixKeyword:
                case TokenKind.Bool1x1Keyword:
                case TokenKind.Bool1x2Keyword:
                case TokenKind.Bool1x3Keyword:
                case TokenKind.Bool1x4Keyword:
                case TokenKind.Bool2x1Keyword:
                case TokenKind.Bool2x2Keyword:
                case TokenKind.Bool2x3Keyword:
                case TokenKind.Bool2x4Keyword:
                case TokenKind.Bool3x1Keyword:
                case TokenKind.Bool3x2Keyword:
                case TokenKind.Bool3x3Keyword:
                case TokenKind.Bool3x4Keyword:
                case TokenKind.Bool4x1Keyword:
                case TokenKind.Bool4x2Keyword:
                case TokenKind.Bool4x3Keyword:
                case TokenKind.Bool4x4Keyword:
                case TokenKind.Double1x1Keyword:
                case TokenKind.Double1x2Keyword:
                case TokenKind.Double1x3Keyword:
                case TokenKind.Double1x4Keyword:
                case TokenKind.Double2x1Keyword:
                case TokenKind.Double2x2Keyword:
                case TokenKind.Double2x3Keyword:
                case TokenKind.Double2x4Keyword:
                case TokenKind.Double3x1Keyword:
                case TokenKind.Double3x2Keyword:
                case TokenKind.Double3x3Keyword:
                case TokenKind.Double3x4Keyword:
                case TokenKind.Double4x1Keyword:
                case TokenKind.Double4x2Keyword:
                case TokenKind.Double4x3Keyword:
                case TokenKind.Double4x4Keyword:
                case TokenKind.Float1x1Keyword:
                case TokenKind.Float1x2Keyword:
                case TokenKind.Float1x3Keyword:
                case TokenKind.Float1x4Keyword:
                case TokenKind.Float2x1Keyword:
                case TokenKind.Float2x2Keyword:
                case TokenKind.Float2x3Keyword:
                case TokenKind.Float2x4Keyword:
                case TokenKind.Float3x1Keyword:
                case TokenKind.Float3x2Keyword:
                case TokenKind.Float3x3Keyword:
                case TokenKind.Float3x4Keyword:
                case TokenKind.Float4x1Keyword:
                case TokenKind.Float4x2Keyword:
                case TokenKind.Float4x3Keyword:
                case TokenKind.Float4x4Keyword:
                case TokenKind.Half1x1Keyword:
                case TokenKind.Half1x2Keyword:
                case TokenKind.Half1x3Keyword:
                case TokenKind.Half1x4Keyword:
                case TokenKind.Half2x1Keyword:
                case TokenKind.Half2x2Keyword:
                case TokenKind.Half2x3Keyword:
                case TokenKind.Half2x4Keyword:
                case TokenKind.Half3x1Keyword:
                case TokenKind.Half3x2Keyword:
                case TokenKind.Half3x3Keyword:
                case TokenKind.Half3x4Keyword:
                case TokenKind.Half4x1Keyword:
                case TokenKind.Half4x2Keyword:
                case TokenKind.Half4x3Keyword:
                case TokenKind.Half4x4Keyword:
                case TokenKind.Int1x1Keyword:
                case TokenKind.Int1x2Keyword:
                case TokenKind.Int1x3Keyword:
                case TokenKind.Int1x4Keyword:
                case TokenKind.Int2x1Keyword:
                case TokenKind.Int2x2Keyword:
                case TokenKind.Int2x3Keyword:
                case TokenKind.Int2x4Keyword:
                case TokenKind.Int3x1Keyword:
                case TokenKind.Int3x2Keyword:
                case TokenKind.Int3x3Keyword:
                case TokenKind.Int3x4Keyword:
                case TokenKind.Int4x1Keyword:
                case TokenKind.Int4x2Keyword:
                case TokenKind.Int4x3Keyword:
                case TokenKind.Int4x4Keyword:
                case TokenKind.Min10Float1x1Keyword:
                case TokenKind.Min10Float1x2Keyword:
                case TokenKind.Min10Float1x3Keyword:
                case TokenKind.Min10Float1x4Keyword:
                case TokenKind.Min10Float2x1Keyword:
                case TokenKind.Min10Float2x2Keyword:
                case TokenKind.Min10Float2x3Keyword:
                case TokenKind.Min10Float2x4Keyword:
                case TokenKind.Min10Float3x1Keyword:
                case TokenKind.Min10Float3x2Keyword:
                case TokenKind.Min10Float3x3Keyword:
                case TokenKind.Min10Float3x4Keyword:
                case TokenKind.Min10Float4x1Keyword:
                case TokenKind.Min10Float4x2Keyword:
                case TokenKind.Min10Float4x3Keyword:
                case TokenKind.Min10Float4x4Keyword:
                case TokenKind.Min12Int1x1Keyword:
                case TokenKind.Min12Int1x2Keyword:
                case TokenKind.Min12Int1x3Keyword:
                case TokenKind.Min12Int1x4Keyword:
                case TokenKind.Min12Int2x1Keyword:
                case TokenKind.Min12Int2x2Keyword:
                case TokenKind.Min12Int2x3Keyword:
                case TokenKind.Min12Int2x4Keyword:
                case TokenKind.Min12Int3x1Keyword:
                case TokenKind.Min12Int3x2Keyword:
                case TokenKind.Min12Int3x3Keyword:
                case TokenKind.Min12Int3x4Keyword:
                case TokenKind.Min12Int4x1Keyword:
                case TokenKind.Min12Int4x2Keyword:
                case TokenKind.Min12Int4x3Keyword:
                case TokenKind.Min12Int4x4Keyword:
                case TokenKind.Min16Float1x1Keyword:
                case TokenKind.Min16Float1x2Keyword:
                case TokenKind.Min16Float1x3Keyword:
                case TokenKind.Min16Float1x4Keyword:
                case TokenKind.Min16Float2x1Keyword:
                case TokenKind.Min16Float2x2Keyword:
                case TokenKind.Min16Float2x3Keyword:
                case TokenKind.Min16Float2x4Keyword:
                case TokenKind.Min16Float3x1Keyword:
                case TokenKind.Min16Float3x2Keyword:
                case TokenKind.Min16Float3x3Keyword:
                case TokenKind.Min16Float3x4Keyword:
                case TokenKind.Min16Float4x1Keyword:
                case TokenKind.Min16Float4x2Keyword:
                case TokenKind.Min16Float4x3Keyword:
                case TokenKind.Min16Float4x4Keyword:
                case TokenKind.Min12Uint1x1Keyword:
                case TokenKind.Min12Uint1x2Keyword:
                case TokenKind.Min12Uint1x3Keyword:
                case TokenKind.Min12Uint1x4Keyword:
                case TokenKind.Min12Uint2x1Keyword:
                case TokenKind.Min12Uint2x2Keyword:
                case TokenKind.Min12Uint2x3Keyword:
                case TokenKind.Min12Uint2x4Keyword:
                case TokenKind.Min12Uint3x1Keyword:
                case TokenKind.Min12Uint3x2Keyword:
                case TokenKind.Min12Uint3x3Keyword:
                case TokenKind.Min12Uint3x4Keyword:
                case TokenKind.Min12Uint4x1Keyword:
                case TokenKind.Min12Uint4x2Keyword:
                case TokenKind.Min12Uint4x3Keyword:
                case TokenKind.Min12Uint4x4Keyword:
                case TokenKind.Min16Int1x1Keyword:
                case TokenKind.Min16Int1x2Keyword:
                case TokenKind.Min16Int1x3Keyword:
                case TokenKind.Min16Int1x4Keyword:
                case TokenKind.Min16Int2x1Keyword:
                case TokenKind.Min16Int2x2Keyword:
                case TokenKind.Min16Int2x3Keyword:
                case TokenKind.Min16Int2x4Keyword:
                case TokenKind.Min16Int3x1Keyword:
                case TokenKind.Min16Int3x2Keyword:
                case TokenKind.Min16Int3x3Keyword:
                case TokenKind.Min16Int3x4Keyword:
                case TokenKind.Min16Int4x1Keyword:
                case TokenKind.Min16Int4x2Keyword:
                case TokenKind.Min16Int4x3Keyword:
                case TokenKind.Min16Int4x4Keyword:
                case TokenKind.Min16Uint1x1Keyword:
                case TokenKind.Min16Uint1x2Keyword:
                case TokenKind.Min16Uint1x3Keyword:
                case TokenKind.Min16Uint1x4Keyword:
                case TokenKind.Min16Uint2x1Keyword:
                case TokenKind.Min16Uint2x2Keyword:
                case TokenKind.Min16Uint2x3Keyword:
                case TokenKind.Min16Uint2x4Keyword:
                case TokenKind.Min16Uint3x1Keyword:
                case TokenKind.Min16Uint3x2Keyword:
                case TokenKind.Min16Uint3x3Keyword:
                case TokenKind.Min16Uint3x4Keyword:
                case TokenKind.Min16Uint4x1Keyword:
                case TokenKind.Min16Uint4x2Keyword:
                case TokenKind.Min16Uint4x3Keyword:
                case TokenKind.Min16Uint4x4Keyword:
                case TokenKind.Uint1x1Keyword:
                case TokenKind.Uint1x2Keyword:
                case TokenKind.Uint1x3Keyword:
                case TokenKind.Uint1x4Keyword:
                case TokenKind.Uint2x1Keyword:
                case TokenKind.Uint2x2Keyword:
                case TokenKind.Uint2x3Keyword:
                case TokenKind.Uint2x4Keyword:
                case TokenKind.Uint3x1Keyword:
                case TokenKind.Uint3x2Keyword:
                case TokenKind.Uint3x3Keyword:
                case TokenKind.Uint3x4Keyword:
                case TokenKind.Uint4x1Keyword:
                case TokenKind.Uint4x2Keyword:
                case TokenKind.Uint4x3Keyword:
                case TokenKind.Uint4x4Keyword:
                //case TokenKind.SNormKeyword:
                //case TokenKind.UNormKeyword:
                    return true;

                default:
                    return false;
            }
        }

        public static bool IsSingleArityNumericConstructor(TokenKind kind)
        {
            switch (kind)
            {
                case TokenKind.BoolKeyword:
                case TokenKind.HalfKeyword:
                case TokenKind.IntKeyword:
                case TokenKind.UintKeyword:
                case TokenKind.FloatKeyword:
                case TokenKind.DoubleKeyword:
                case TokenKind.Min16FloatKeyword:
                case TokenKind.Min16IntKeyword:
                case TokenKind.Min16UintKeyword:
                case TokenKind.StringKeyword:
                    return true;

                default:
                    return false;
            }
        }

        public static bool IsBuiltinType(TokenKind kind)
        {
            switch (kind)
            {
                case TokenKind.BoolKeyword:
                case TokenKind.IntKeyword:
                case TokenKind.UnsignedKeyword:
                case TokenKind.DwordKeyword:
                case TokenKind.UintKeyword:
                case TokenKind.HalfKeyword:
                case TokenKind.FloatKeyword:
                case TokenKind.DoubleKeyword:
                case TokenKind.Min16FloatKeyword:
                case TokenKind.Min10FloatKeyword:
                case TokenKind.Min16IntKeyword:
                case TokenKind.Min12IntKeyword:
                case TokenKind.Min16UintKeyword:
                case TokenKind.Min12UintKeyword:
                case TokenKind.VoidKeyword:
                case TokenKind.StringKeyword:
                case TokenKind.SNormKeyword:
                case TokenKind.UNormKeyword:

                case TokenKind.AppendStructuredBufferKeyword:
                case TokenKind.BlendStateKeyword:
                case TokenKind.BufferKeyword:
                case TokenKind.ByteAddressBufferKeyword:
                case TokenKind.ConsumeStructuredBufferKeyword:
                case TokenKind.DepthStencilStateKeyword:
                case TokenKind.InputPatchKeyword:
                case TokenKind.LineStreamKeyword:
                case TokenKind.OutputPatchKeyword:
                case TokenKind.PointStreamKeyword:
                case TokenKind.RasterizerOrderedBufferKeyword:
                case TokenKind.RasterizerOrderedByteAddressBufferKeyword:
                case TokenKind.RasterizerOrderedStructuredBufferKeyword:
                case TokenKind.RasterizerOrderedTexture1DKeyword:
                case TokenKind.RasterizerOrderedTexture1DArrayKeyword:
                case TokenKind.RasterizerOrderedTexture2DKeyword:
                case TokenKind.RasterizerOrderedTexture2DArrayKeyword:
                case TokenKind.RasterizerOrderedTexture3DKeyword:
                case TokenKind.RasterizerStateKeyword:
                case TokenKind.RWBufferKeyword:
                case TokenKind.RWByteAddressBufferKeyword:
                case TokenKind.RWStructuredBufferKeyword:
                case TokenKind.RWTexture1DKeyword:
                case TokenKind.RWTexture1DArrayKeyword:
                case TokenKind.RWTexture2DKeyword:
                case TokenKind.RWTexture2DArrayKeyword:
                case TokenKind.RWTexture3DKeyword:
                case TokenKind.SamplerKeyword:
                case TokenKind.Sampler1DKeyword:
                case TokenKind.Sampler2DKeyword:
                case TokenKind.Sampler3DKeyword:
                case TokenKind.SamplerCubeKeyword:
                case TokenKind.SamplerStateKeyword:
                case TokenKind.SamplerComparisonStateKeyword:
                case TokenKind.StructuredBufferKeyword:
                case TokenKind.Texture2DLegacyKeyword:
                case TokenKind.TextureCubeLegacyKeyword:
                case TokenKind.Texture1DKeyword:
                case TokenKind.Texture1DArrayKeyword:
                case TokenKind.Texture2DKeyword:
                case TokenKind.Texture2DArrayKeyword:
                case TokenKind.Texture2DMSKeyword:
                case TokenKind.Texture2DMSArrayKeyword:
                case TokenKind.Texture3DKeyword:
                case TokenKind.TextureCubeKeyword:
                case TokenKind.TextureCubeArrayKeyword:
                case TokenKind.TriangleStreamKeyword:
                    return true;

                default:
                    return IsMultiArityNumericConstructor(kind);
            }
        }

        public static bool IsModifier(TokenKind kind)
        {
            switch (kind)
            {
                case TokenKind.ConstKeyword:
                case TokenKind.RowMajorKeyword:
                case TokenKind.ColumnMajorKeyword:
                    return true;

                case TokenKind.ExportKeyword:
                case TokenKind.ExternKeyword:
                case TokenKind.InlineKeyword:
                case TokenKind.PreciseKeyword:
                case TokenKind.SharedKeyword:
                case TokenKind.GloballycoherentKeyword:
                case TokenKind.GroupsharedKeyword:
                case TokenKind.StaticKeyword:
                case TokenKind.UniformKeyword:
                case TokenKind.VolatileKeyword:
                    return true;

                case TokenKind.SNormKeyword:
                case TokenKind.UNormKeyword:
                    return true;

                case TokenKind.LinearKeyword:
                case TokenKind.CentroidKeyword:
                case TokenKind.NointerpolationKeyword:
                case TokenKind.NoperspectiveKeyword:
                    return true;

                default:
                    return false;
            }
        }

        public static bool IsPrefixUnaryToken(TokenKind kind)
        {
            switch (kind)
            {
                case TokenKind.PlusPlusToken:
                case TokenKind.MinusMinusToken:
                case TokenKind.PlusToken:
                case TokenKind.MinusToken:
                case TokenKind.NotToken:
                case TokenKind.TildeToken:
                    return true;

                default:
                    return false;
            }
        }

        public static bool TryConvertLiteralKind(TokenKind kind, out LiteralKind outKind)
        {
            switch (kind)
            {
                case TokenKind.StringLiteralToken: outKind = LiteralKind.String; return true;
                case TokenKind.FloatLiteralToken: outKind = LiteralKind.Float; return true;
                case TokenKind.IntegerLiteralToken: outKind = LiteralKind.Integer; return true;
                case TokenKind.CharacterLiteralToken: outKind = LiteralKind.Character; return true;
                case TokenKind.TrueKeyword: outKind = LiteralKind.Boolean; return true;
                case TokenKind.FalseKeyword: outKind = LiteralKind.Boolean; return true;
                case TokenKind.NullKeyword: outKind = LiteralKind.Null; return true;
                default: outKind = default; return false;
            }
        }

        public static bool CanTokenComeAfterCast(TokenKind kind)
        {
            switch (kind)
            {
                case TokenKind.SemiToken:
                case TokenKind.CloseParenToken:
                case TokenKind.CloseBracketToken:
                case TokenKind.OpenBraceToken:
                case TokenKind.CloseBraceToken:
                case TokenKind.CommaToken:
                case TokenKind.EqualsToken:
                case TokenKind.PlusEqualsToken:
                case TokenKind.MinusEqualsToken:
                case TokenKind.AsteriskEqualsToken:
                case TokenKind.SlashEqualsToken:
                case TokenKind.PercentEqualsToken:
                case TokenKind.AmpersandEqualsToken:
                case TokenKind.CaretEqualsToken:
                case TokenKind.BarEqualsToken:
                case TokenKind.LessThanLessThanEqualsToken:
                case TokenKind.GreaterThanGreaterThanEqualsToken:
                case TokenKind.QuestionToken:
                case TokenKind.ColonToken:
                case TokenKind.BarBarToken:
                case TokenKind.AmpersandAmpersandToken:
                case TokenKind.BarToken:
                case TokenKind.CaretToken:
                case TokenKind.AmpersandToken:
                case TokenKind.EqualsEqualsToken:
                case TokenKind.ExclamationEqualsToken:
                case TokenKind.LessThanToken:
                case TokenKind.LessThanEqualsToken:
                case TokenKind.GreaterThanToken:
                case TokenKind.GreaterThanEqualsToken:
                case TokenKind.LessThanLessThanToken:
                case TokenKind.GreaterThanGreaterThanToken:
                case TokenKind.PlusToken:
                case TokenKind.MinusToken:
                case TokenKind.AsteriskToken:
                case TokenKind.SlashToken:
                case TokenKind.PercentToken:
                case TokenKind.PlusPlusToken:
                case TokenKind.MinusMinusToken:
                case TokenKind.OpenBracketToken:
                case TokenKind.DotToken:
                    return false;

                default:
                    return true;
            }
        }

        public static bool TryConvertToDeclarationModifier(Token<TokenKind> token, out BindingModifier modifier)
        {
            switch (token.Kind)
            {
                case TokenKind.ConstKeyword: modifier = BindingModifier.Const; return true;
                case TokenKind.RowMajorKeyword: modifier = BindingModifier.RowMajor; return true;
                case TokenKind.ColumnMajorKeyword: modifier = BindingModifier.ColumnMajor; return true;
                case TokenKind.ExportKeyword: modifier = BindingModifier.Export; return true;
                case TokenKind.ExternKeyword: modifier = BindingModifier.Extern; return true;
                case TokenKind.InlineKeyword: modifier = BindingModifier.Inline; return true;
                case TokenKind.PreciseKeyword: modifier = BindingModifier.Precise; return true;
                case TokenKind.SharedKeyword: modifier = BindingModifier.Shared; return true;
                case TokenKind.GloballycoherentKeyword: modifier = BindingModifier.Globallycoherent; return true;
                case TokenKind.GroupsharedKeyword: modifier = BindingModifier.Groupshared; return true;
                case TokenKind.StaticKeyword: modifier = BindingModifier.Static; return true;
                case TokenKind.UniformKeyword: modifier = BindingModifier.Uniform; return true;
                case TokenKind.VolatileKeyword: modifier = BindingModifier.Volatile; return true;
                case TokenKind.SNormKeyword: modifier = BindingModifier.SNorm; return true;
                case TokenKind.UNormKeyword: modifier = BindingModifier.UNorm; return true;
                case TokenKind.LinearKeyword: modifier = BindingModifier.Linear; return true;
                case TokenKind.CentroidKeyword: modifier = BindingModifier.Centroid; return true;
                case TokenKind.NointerpolationKeyword: modifier = BindingModifier.Nointerpolation; return true;
                case TokenKind.NoperspectiveKeyword: modifier = BindingModifier.Noperspective; return true;
                // Weird edge case of HLSL grammar - 'sample' is not a real keyword.
                case TokenKind.IdentifierToken when token.Identifier == "sample": modifier = BindingModifier.Sample; return true;
                default: modifier = default; return false;
            }
        }

        public static bool TryConvertToParameterModifier(Token<TokenKind> token, out BindingModifier modifier)
        {
            if (TryConvertToDeclarationModifier(token, out modifier))
                return true;

            switch (token.Kind)
            {
                case TokenKind.InKeyword: modifier = BindingModifier.In; return true;
                case TokenKind.OutKeyword: modifier = BindingModifier.Out; return true;
                case TokenKind.InoutKeyword: modifier = BindingModifier.Inout; return true;
                case TokenKind.PointKeyword: modifier = BindingModifier.Point; return true;
                case TokenKind.TriangleKeyword: modifier = BindingModifier.Triangle; return true;
                case TokenKind.TriangleAdjKeyword: modifier = BindingModifier.TriangleAdj; return true;
                case TokenKind.LineKeyword: modifier = BindingModifier.Line; return true;
                case TokenKind.LineAdjKeyword: modifier = BindingModifier.LineAdj; return true;
                default: modifier = default; return false;
            }
        }

        public static ScalarType MakeUnsigned(ScalarType type)
        {
            switch (type)
            {
                case ScalarType.Int: return ScalarType.Uint;
                case ScalarType.Min12Int: return ScalarType.Min12Uint;
                case ScalarType.Min16Int: return ScalarType.Min16Uint;
                default: return type;
            }
        }

        public static ScalarType MakeNormed(ScalarType type, TokenKind norm)
        {
            if (type == ScalarType.Float)
            {
                if (norm == TokenKind.UNormKeyword)
                    return ScalarType.UNormFloat;
                else if (norm == TokenKind.SNormKeyword)
                    return ScalarType.SNormFloat;
                else
                    return type;
            }
            else
            {
                return type;
            }
        }

        public static bool TryConvertToOperator(TokenKind kind, out OperatorKind op)
        {
            switch (kind)
            {
                case TokenKind.EqualsToken: op =  OperatorKind.Assignment; return true;
                case TokenKind.PlusEqualsToken: op =  OperatorKind.PlusAssignment; return true;
                case TokenKind.MinusEqualsToken: op =  OperatorKind.MinusAssignment; return true;
                case TokenKind.AsteriskEqualsToken: op =  OperatorKind.MulAssignment; return true;
                case TokenKind.SlashEqualsToken: op =  OperatorKind.DivAssignment; return true;
                case TokenKind.PercentEqualsToken: op =  OperatorKind.ModAssignment; return true;
                case TokenKind.LessThanLessThanEqualsToken: op =  OperatorKind.ShiftLeftAssignment; return true;
                case TokenKind.GreaterThanGreaterThanEqualsToken: op =  OperatorKind.ShiftRightAssignment; return true;
                case TokenKind.AmpersandEqualsToken: op =  OperatorKind.BitwiseAndAssignment; return true;
                case TokenKind.CaretEqualsToken: op =  OperatorKind.BitwiseXorAssignment; return true;
                case TokenKind.BarEqualsToken: op =  OperatorKind.BitwiseOrAssignment; return true;
                case TokenKind.BarBarToken: op =  OperatorKind.LogicalOr; return true;
                case TokenKind.AmpersandAmpersandToken: op =  OperatorKind.LogicalAnd; return true;
                case TokenKind.BarToken: op =  OperatorKind.BitwiseOr; return true;
                case TokenKind.AmpersandToken: op =  OperatorKind.BitwiseAnd; return true;
                case TokenKind.CaretToken: op =  OperatorKind.BitwiseXor; return true;
                case TokenKind.CommaToken: op =  OperatorKind.Compound; return true;
                case TokenKind.QuestionToken: op =  OperatorKind.Ternary; return true;
                case TokenKind.EqualsEqualsToken: op =  OperatorKind.Equals; return true;
                case TokenKind.ExclamationEqualsToken: op =  OperatorKind.NotEquals; return true;
                case TokenKind.LessThanToken: op =  OperatorKind.LessThan; return true;
                case TokenKind.LessThanEqualsToken: op =  OperatorKind.LessThanOrEquals; return true;
                case TokenKind.GreaterThanToken: op =  OperatorKind.GreaterThan; return true;
                case TokenKind.GreaterThanEqualsToken: op =  OperatorKind.GreaterThanOrEquals; return true;
                case TokenKind.LessThanLessThanToken: op =  OperatorKind.ShiftLeft; return true;
                case TokenKind.GreaterThanGreaterThanToken: op =  OperatorKind.ShiftRight; return true;
                case TokenKind.PlusToken: op =  OperatorKind.Plus; return true;
                case TokenKind.MinusToken: op =  OperatorKind.Minus; return true;
                case TokenKind.AsteriskToken: op =  OperatorKind.Mul; return true;
                case TokenKind.SlashToken: op =  OperatorKind.Div; return true;
                case TokenKind.PercentToken: op =  OperatorKind.Mod; return true;
                case TokenKind.PlusPlusToken: op = OperatorKind.Increment; return true;
                case TokenKind.MinusMinusToken: op = OperatorKind.Decrement; return true;
                case TokenKind.NotToken: op = OperatorKind.Not; return true;
                case TokenKind.TildeToken: op = OperatorKind.BitFlip; return true;
                default: op = default; 
                    return false;
            }
        }

        public static OperatorPrecedence GetPrecedence(OperatorKind op, OperatorFixity fixity)
        {
            switch (op)
            {
                case OperatorKind.Compound:
                    return OperatorPrecedence.Compound;
                case OperatorKind.Assignment:
                case OperatorKind.PlusAssignment:
                case OperatorKind.MinusAssignment:
                case OperatorKind.MulAssignment:
                case OperatorKind.DivAssignment:
                case OperatorKind.ModAssignment:
                case OperatorKind.ShiftLeftAssignment:
                case OperatorKind.ShiftRightAssignment:
                case OperatorKind.BitwiseAndAssignment:
                case OperatorKind.BitwiseXorAssignment:
                case OperatorKind.BitwiseOrAssignment:
                    return OperatorPrecedence.Assignment;
                case OperatorKind.Ternary:
                    return OperatorPrecedence.Ternary;
                case OperatorKind.LogicalOr:
                    return OperatorPrecedence.LogicalOr;
                case OperatorKind.LogicalAnd:
                    return OperatorPrecedence.LogicalAnd;
                case OperatorKind.BitwiseOr:
                    return OperatorPrecedence.BitwiseOr;
                case OperatorKind.BitwiseXor:
                    return OperatorPrecedence.BitwiseXor;
                case OperatorKind.BitwiseAnd:
                    return OperatorPrecedence.BitwiseAnd;
                case OperatorKind.Equals:
                case OperatorKind.NotEquals:
                    return OperatorPrecedence.Equality;
                case OperatorKind.LessThan:
                case OperatorKind.LessThanOrEquals:
                case OperatorKind.GreaterThan:
                case OperatorKind.GreaterThanOrEquals:
                    return OperatorPrecedence.Comparison;
                case OperatorKind.ShiftLeft:
                case OperatorKind.ShiftRight:
                    return OperatorPrecedence.BitShift;
                case OperatorKind.Plus when fixity == OperatorFixity.Infix:
                case OperatorKind.Minus when fixity == OperatorFixity.Infix:
                    return OperatorPrecedence.AddSub;
                case OperatorKind.Mul:
                case OperatorKind.Div:
                case OperatorKind.Mod:
                    return OperatorPrecedence.MulDivMod;
                case OperatorKind.Plus:
                case OperatorKind.Minus:
                case OperatorKind.Not:
                case OperatorKind.BitFlip:
                case OperatorKind.Increment when fixity == OperatorFixity.Prefix:
                case OperatorKind.Decrement when fixity == OperatorFixity.Prefix:
                    return OperatorPrecedence.PrefixUnary;
                case OperatorKind.Increment:
                case OperatorKind.Decrement:
                    return OperatorPrecedence.PostFixUnary;
                default:
                    return OperatorPrecedence.Compound;
            }
        }

        public static bool TryConvertKeywordToString(TokenKind kind, out string result)
        {
            switch (kind)
            {
                case TokenKind.AppendStructuredBufferKeyword: result = "AppendStructuredBuffer"; return true;
                case TokenKind.BlendStateKeyword: result = "BlendState"; return true;
                case TokenKind.BoolKeyword: result = "bool"; return true;
                case TokenKind.Bool1Keyword: result = "bool1"; return true;
                case TokenKind.Bool2Keyword: result = "bool2"; return true;
                case TokenKind.Bool3Keyword: result = "bool3"; return true;
                case TokenKind.Bool4Keyword: result = "bool4"; return true;
                case TokenKind.Bool1x1Keyword: result = "bool1x1"; return true;
                case TokenKind.Bool1x2Keyword: result = "bool1x2"; return true;
                case TokenKind.Bool1x3Keyword: result = "bool1x3"; return true;
                case TokenKind.Bool1x4Keyword: result = "bool1x4"; return true;
                case TokenKind.Bool2x1Keyword: result = "bool2x1"; return true;
                case TokenKind.Bool2x2Keyword: result = "bool2x2"; return true;
                case TokenKind.Bool2x3Keyword: result = "bool2x3"; return true;
                case TokenKind.Bool2x4Keyword: result = "bool2x4"; return true;
                case TokenKind.Bool3x1Keyword: result = "bool3x1"; return true;
                case TokenKind.Bool3x2Keyword: result = "bool3x2"; return true;
                case TokenKind.Bool3x3Keyword: result = "bool3x3"; return true;
                case TokenKind.Bool3x4Keyword: result = "bool3x4"; return true;
                case TokenKind.Bool4x1Keyword: result = "bool4x1"; return true;
                case TokenKind.Bool4x2Keyword: result = "bool4x2"; return true;
                case TokenKind.Bool4x3Keyword: result = "bool4x3"; return true;
                case TokenKind.Bool4x4Keyword: result = "bool4x4"; return true;
                case TokenKind.BufferKeyword: result = "Buffer"; return true;
                case TokenKind.ByteAddressBufferKeyword: result = "ByteAddressBuffer"; return true;
                case TokenKind.BreakKeyword: result = "break"; return true;
                case TokenKind.CaseKeyword: result = "case"; return true;
                case TokenKind.CBufferKeyword: result = "cbuffer"; return true;
                case TokenKind.CentroidKeyword: result = "centroid"; return true;
                case TokenKind.ClassKeyword: result = "class"; return true;
                case TokenKind.ColumnMajorKeyword: result = "column_major"; return true;
                case TokenKind.CompileKeyword: result = "compile"; return true;
                case TokenKind.ConstKeyword: result = "const"; return true;
                case TokenKind.ConsumeStructuredBufferKeyword: result = "ConsumeStructuredBuffer"; return true;
                case TokenKind.ContinueKeyword: result = "continue"; return true;
                case TokenKind.DefaultKeyword: result = "default"; return true;
                case TokenKind.DefKeyword: result = "def"; return true;
                case TokenKind.DepthStencilStateKeyword: result = "DepthStencilState"; return true;
                case TokenKind.DiscardKeyword: result = "discard"; return true;
                case TokenKind.DoKeyword: result = "do"; return true;
                case TokenKind.DoubleKeyword: result = "double"; return true;
                case TokenKind.Double1Keyword: result = "double1"; return true;
                case TokenKind.Double2Keyword: result = "double2"; return true;
                case TokenKind.Double3Keyword: result = "double3"; return true;
                case TokenKind.Double4Keyword: result = "double4"; return true;
                case TokenKind.Double1x1Keyword: result = "double1x1"; return true;
                case TokenKind.Double1x2Keyword: result = "double1x2"; return true;
                case TokenKind.Double1x3Keyword: result = "double1x3"; return true;
                case TokenKind.Double1x4Keyword: result = "double1x4"; return true;
                case TokenKind.Double2x1Keyword: result = "double2x1"; return true;
                case TokenKind.Double2x2Keyword: result = "double2x2"; return true;
                case TokenKind.Double2x3Keyword: result = "double2x3"; return true;
                case TokenKind.Double2x4Keyword: result = "double2x4"; return true;
                case TokenKind.Double3x1Keyword: result = "double3x1"; return true;
                case TokenKind.Double3x2Keyword: result = "double3x2"; return true;
                case TokenKind.Double3x3Keyword: result = "double3x3"; return true;
                case TokenKind.Double3x4Keyword: result = "double3x4"; return true;
                case TokenKind.Double4x1Keyword: result = "double4x1"; return true;
                case TokenKind.Double4x2Keyword: result = "double4x2"; return true;
                case TokenKind.Double4x3Keyword: result = "double4x3"; return true;
                case TokenKind.Double4x4Keyword: result = "double4x4"; return true;
                case TokenKind.ElseKeyword: result = "else"; return true;
                case TokenKind.ErrorKeyword: result = "error"; return true;
                case TokenKind.ExportKeyword: result = "export"; return true;
                case TokenKind.ExternKeyword: result = "extern"; return true;
                case TokenKind.FloatKeyword: result = "float"; return true;
                case TokenKind.Float1Keyword: result = "float1"; return true;
                case TokenKind.Float2Keyword: result = "float2"; return true;
                case TokenKind.Float3Keyword: result = "float3"; return true;
                case TokenKind.Float4Keyword: result = "float4"; return true;
                case TokenKind.Float1x1Keyword: result = "float1x1"; return true;
                case TokenKind.Float1x2Keyword: result = "float1x2"; return true;
                case TokenKind.Float1x3Keyword: result = "float1x3"; return true;
                case TokenKind.Float1x4Keyword: result = "float1x4"; return true;
                case TokenKind.Float2x1Keyword: result = "float2x1"; return true;
                case TokenKind.Float2x2Keyword: result = "float2x2"; return true;
                case TokenKind.Float2x3Keyword: result = "float2x3"; return true;
                case TokenKind.Float2x4Keyword: result = "float2x4"; return true;
                case TokenKind.Float3x1Keyword: result = "float3x1"; return true;
                case TokenKind.Float3x2Keyword: result = "float3x2"; return true;
                case TokenKind.Float3x3Keyword: result = "float3x3"; return true;
                case TokenKind.Float3x4Keyword: result = "float3x4"; return true;
                case TokenKind.Float4x1Keyword: result = "float4x1"; return true;
                case TokenKind.Float4x2Keyword: result = "float4x2"; return true;
                case TokenKind.Float4x3Keyword: result = "float4x3"; return true;
                case TokenKind.Float4x4Keyword: result = "float4x4"; return true;
                case TokenKind.ForKeyword: result = "for"; return true;
                case TokenKind.GloballycoherentKeyword: result = "globallycoherent"; return true;
                case TokenKind.GroupsharedKeyword: result = "groupshared"; return true;
                case TokenKind.HalfKeyword: result = "half"; return true;
                case TokenKind.Half1Keyword: result = "half1"; return true;
                case TokenKind.Half2Keyword: result = "half2"; return true;
                case TokenKind.Half3Keyword: result = "half3"; return true;
                case TokenKind.Half4Keyword: result = "half4"; return true;
                case TokenKind.Half1x1Keyword: result = "half1x1"; return true;
                case TokenKind.Half1x2Keyword: result = "half1x2"; return true;
                case TokenKind.Half1x3Keyword: result = "half1x3"; return true;
                case TokenKind.Half1x4Keyword: result = "half1x4"; return true;
                case TokenKind.Half2x1Keyword: result = "half2x1"; return true;
                case TokenKind.Half2x2Keyword: result = "half2x2"; return true;
                case TokenKind.Half2x3Keyword: result = "half2x3"; return true;
                case TokenKind.Half2x4Keyword: result = "half2x4"; return true;
                case TokenKind.Half3x1Keyword: result = "half3x1"; return true;
                case TokenKind.Half3x2Keyword: result = "half3x2"; return true;
                case TokenKind.Half3x3Keyword: result = "half3x3"; return true;
                case TokenKind.Half3x4Keyword: result = "half3x4"; return true;
                case TokenKind.Half4x1Keyword: result = "half4x1"; return true;
                case TokenKind.Half4x2Keyword: result = "half4x2"; return true;
                case TokenKind.Half4x3Keyword: result = "half4x3"; return true;
                case TokenKind.Half4x4Keyword: result = "half4x4"; return true;
                case TokenKind.IfKeyword: result = "if"; return true;
                case TokenKind.IndicesKeyword: result = "indices"; return true;
                case TokenKind.InKeyword: result = "in"; return true;
                case TokenKind.InlineKeyword: result = "inline"; return true;
                case TokenKind.InoutKeyword: result = "inout"; return true;
                case TokenKind.InputPatchKeyword: result = "InputPatch"; return true;
                case TokenKind.IntKeyword: result = "int"; return true;
                case TokenKind.Int1Keyword: result = "int1"; return true;
                case TokenKind.Int2Keyword: result = "int2"; return true;
                case TokenKind.Int3Keyword: result = "int3"; return true;
                case TokenKind.Int4Keyword: result = "int4"; return true;
                case TokenKind.Int1x1Keyword: result = "int1x1"; return true;
                case TokenKind.Int1x2Keyword: result = "int1x2"; return true;
                case TokenKind.Int1x3Keyword: result = "int1x3"; return true;
                case TokenKind.Int1x4Keyword: result = "int1x4"; return true;
                case TokenKind.Int2x1Keyword: result = "int2x1"; return true;
                case TokenKind.Int2x2Keyword: result = "int2x2"; return true;
                case TokenKind.Int2x3Keyword: result = "int2x3"; return true;
                case TokenKind.Int2x4Keyword: result = "int2x4"; return true;
                case TokenKind.Int3x1Keyword: result = "int3x1"; return true;
                case TokenKind.Int3x2Keyword: result = "int3x2"; return true;
                case TokenKind.Int3x3Keyword: result = "int3x3"; return true;
                case TokenKind.Int3x4Keyword: result = "int3x4"; return true;
                case TokenKind.Int4x1Keyword: result = "int4x1"; return true;
                case TokenKind.Int4x2Keyword: result = "int4x2"; return true;
                case TokenKind.Int4x3Keyword: result = "int4x3"; return true;
                case TokenKind.Int4x4Keyword: result = "int4x4"; return true;
                case TokenKind.InterfaceKeyword: result = "interface"; return true;
                case TokenKind.LineKeyword: result = "line"; return true;
                case TokenKind.LineAdjKeyword: result = "lineadj"; return true;
                case TokenKind.LinearKeyword: result = "linear"; return true;
                case TokenKind.LineStreamKeyword: result = "LineStream"; return true;
                case TokenKind.MatrixKeyword: result = "matrix"; return true;
                case TokenKind.MessageKeyword: result = "message"; return true;
                case TokenKind.Min10FloatKeyword: result = "min10float"; return true;
                case TokenKind.Min10Float1Keyword: result = "min10float1"; return true;
                case TokenKind.Min10Float2Keyword: result = "min10float2"; return true;
                case TokenKind.Min10Float3Keyword: result = "min10float3"; return true;
                case TokenKind.Min10Float4Keyword: result = "min10float4"; return true;
                case TokenKind.Min10Float1x1Keyword: result = "min10float1x1"; return true;
                case TokenKind.Min10Float1x2Keyword: result = "min10float1x2"; return true;
                case TokenKind.Min10Float1x3Keyword: result = "min10float1x3"; return true;
                case TokenKind.Min10Float1x4Keyword: result = "min10float1x4"; return true;
                case TokenKind.Min10Float2x1Keyword: result = "min10float2x1"; return true;
                case TokenKind.Min10Float2x2Keyword: result = "min10float2x2"; return true;
                case TokenKind.Min10Float2x3Keyword: result = "min10float2x3"; return true;
                case TokenKind.Min10Float2x4Keyword: result = "min10float2x4"; return true;
                case TokenKind.Min10Float3x1Keyword: result = "min10float3x1"; return true;
                case TokenKind.Min10Float3x2Keyword: result = "min10float3x2"; return true;
                case TokenKind.Min10Float3x3Keyword: result = "min10float3x3"; return true;
                case TokenKind.Min10Float3x4Keyword: result = "min10float3x4"; return true;
                case TokenKind.Min10Float4x1Keyword: result = "min10float4x1"; return true;
                case TokenKind.Min10Float4x2Keyword: result = "min10float4x2"; return true;
                case TokenKind.Min10Float4x3Keyword: result = "min10float4x3"; return true;
                case TokenKind.Min10Float4x4Keyword: result = "min10float4x4"; return true;
                case TokenKind.Min12IntKeyword: result = "min12int"; return true;
                case TokenKind.Min12Int1Keyword: result = "min12int1"; return true;
                case TokenKind.Min12Int2Keyword: result = "min12int2"; return true;
                case TokenKind.Min12Int3Keyword: result = "min12int3"; return true;
                case TokenKind.Min12Int4Keyword: result = "min12int4"; return true;
                case TokenKind.Min12Int1x1Keyword: result = "min12int1x1"; return true;
                case TokenKind.Min12Int1x2Keyword: result = "min12int1x2"; return true;
                case TokenKind.Min12Int1x3Keyword: result = "min12int1x3"; return true;
                case TokenKind.Min12Int1x4Keyword: result = "min12int1x4"; return true;
                case TokenKind.Min12Int2x1Keyword: result = "min12int2x1"; return true;
                case TokenKind.Min12Int2x2Keyword: result = "min12int2x2"; return true;
                case TokenKind.Min12Int2x3Keyword: result = "min12int2x3"; return true;
                case TokenKind.Min12Int2x4Keyword: result = "min12int2x4"; return true;
                case TokenKind.Min12Int3x1Keyword: result = "min12int3x1"; return true;
                case TokenKind.Min12Int3x2Keyword: result = "min12int3x2"; return true;
                case TokenKind.Min12Int3x3Keyword: result = "min12int3x3"; return true;
                case TokenKind.Min12Int3x4Keyword: result = "min12int3x4"; return true;
                case TokenKind.Min12Int4x1Keyword: result = "min12int4x1"; return true;
                case TokenKind.Min12Int4x2Keyword: result = "min12int4x2"; return true;
                case TokenKind.Min12Int4x3Keyword: result = "min12int4x3"; return true;
                case TokenKind.Min12Int4x4Keyword: result = "min12int4x4"; return true;
                case TokenKind.Min12UintKeyword: result = "min12uint"; return true;
                case TokenKind.Min12Uint1Keyword: result = "min12uint1"; return true;
                case TokenKind.Min12Uint2Keyword: result = "min12uint2"; return true;
                case TokenKind.Min12Uint3Keyword: result = "min12uint3"; return true;
                case TokenKind.Min12Uint4Keyword: result = "min12uint4"; return true;
                case TokenKind.Min12Uint1x1Keyword: result = "min12uint1x1"; return true;
                case TokenKind.Min12Uint1x2Keyword: result = "min12uint1x2"; return true;
                case TokenKind.Min12Uint1x3Keyword: result = "min12uint1x3"; return true;
                case TokenKind.Min12Uint1x4Keyword: result = "min12uint1x4"; return true;
                case TokenKind.Min12Uint2x1Keyword: result = "min12uint2x1"; return true;
                case TokenKind.Min12Uint2x2Keyword: result = "min12uint2x2"; return true;
                case TokenKind.Min12Uint2x3Keyword: result = "min12uint2x3"; return true;
                case TokenKind.Min12Uint2x4Keyword: result = "min12uint2x4"; return true;
                case TokenKind.Min12Uint3x1Keyword: result = "min12uint3x1"; return true;
                case TokenKind.Min12Uint3x2Keyword: result = "min12uint3x2"; return true;
                case TokenKind.Min12Uint3x3Keyword: result = "min12uint3x3"; return true;
                case TokenKind.Min12Uint3x4Keyword: result = "min12uint3x4"; return true;
                case TokenKind.Min12Uint4x1Keyword: result = "min12uint4x1"; return true;
                case TokenKind.Min12Uint4x2Keyword: result = "min12uint4x2"; return true;
                case TokenKind.Min12Uint4x3Keyword: result = "min12uint4x3"; return true;
                case TokenKind.Min12Uint4x4Keyword: result = "min12uint4x4"; return true;
                case TokenKind.Min16FloatKeyword: result = "min16float"; return true;
                case TokenKind.Min16Float1Keyword: result = "min16float1"; return true;
                case TokenKind.Min16Float2Keyword: result = "min16float2"; return true;
                case TokenKind.Min16Float3Keyword: result = "min16float3"; return true;
                case TokenKind.Min16Float4Keyword: result = "min16float4"; return true;
                case TokenKind.Min16Float1x1Keyword: result = "min16float1x1"; return true;
                case TokenKind.Min16Float1x2Keyword: result = "min16float1x2"; return true;
                case TokenKind.Min16Float1x3Keyword: result = "min16float1x3"; return true;
                case TokenKind.Min16Float1x4Keyword: result = "min16float1x4"; return true;
                case TokenKind.Min16Float2x1Keyword: result = "min16float2x1"; return true;
                case TokenKind.Min16Float2x2Keyword: result = "min16float2x2"; return true;
                case TokenKind.Min16Float2x3Keyword: result = "min16float2x3"; return true;
                case TokenKind.Min16Float2x4Keyword: result = "min16float2x4"; return true;
                case TokenKind.Min16Float3x1Keyword: result = "min16float3x1"; return true;
                case TokenKind.Min16Float3x2Keyword: result = "min16float3x2"; return true;
                case TokenKind.Min16Float3x3Keyword: result = "min16float3x3"; return true;
                case TokenKind.Min16Float3x4Keyword: result = "min16float3x4"; return true;
                case TokenKind.Min16Float4x1Keyword: result = "min16float4x1"; return true;
                case TokenKind.Min16Float4x2Keyword: result = "min16float4x2"; return true;
                case TokenKind.Min16Float4x3Keyword: result = "min16float4x3"; return true;
                case TokenKind.Min16Float4x4Keyword: result = "min16float4x4"; return true;
                case TokenKind.Min16IntKeyword: result = "min16int"; return true;
                case TokenKind.Min16Int1Keyword: result = "min16int1"; return true;
                case TokenKind.Min16Int2Keyword: result = "min16int2"; return true;
                case TokenKind.Min16Int3Keyword: result = "min16int3"; return true;
                case TokenKind.Min16Int4Keyword: result = "min16int4"; return true;
                case TokenKind.Min16Int1x1Keyword: result = "min16int1x1"; return true;
                case TokenKind.Min16Int1x2Keyword: result = "min16int1x2"; return true;
                case TokenKind.Min16Int1x3Keyword: result = "min16int1x3"; return true;
                case TokenKind.Min16Int1x4Keyword: result = "min16int1x4"; return true;
                case TokenKind.Min16Int2x1Keyword: result = "min16int2x1"; return true;
                case TokenKind.Min16Int2x2Keyword: result = "min16int2x2"; return true;
                case TokenKind.Min16Int2x3Keyword: result = "min16int2x3"; return true;
                case TokenKind.Min16Int2x4Keyword: result = "min16int2x4"; return true;
                case TokenKind.Min16Int3x1Keyword: result = "min16int3x1"; return true;
                case TokenKind.Min16Int3x2Keyword: result = "min16int3x2"; return true;
                case TokenKind.Min16Int3x3Keyword: result = "min16int3x3"; return true;
                case TokenKind.Min16Int3x4Keyword: result = "min16int3x4"; return true;
                case TokenKind.Min16Int4x1Keyword: result = "min16int4x1"; return true;
                case TokenKind.Min16Int4x2Keyword: result = "min16int4x2"; return true;
                case TokenKind.Min16Int4x3Keyword: result = "min16int4x3"; return true;
                case TokenKind.Min16Int4x4Keyword: result = "min16int4x4"; return true;
                case TokenKind.Min16UintKeyword: result = "min16uint"; return true;
                case TokenKind.Min16Uint1Keyword: result = "min16uint1"; return true;
                case TokenKind.Min16Uint2Keyword: result = "min16uint2"; return true;
                case TokenKind.Min16Uint3Keyword: result = "min16uint3"; return true;
                case TokenKind.Min16Uint4Keyword: result = "min16uint4"; return true;
                case TokenKind.Min16Uint1x1Keyword: result = "min16uint1x1"; return true;
                case TokenKind.Min16Uint1x2Keyword: result = "min16uint1x2"; return true;
                case TokenKind.Min16Uint1x3Keyword: result = "min16uint1x3"; return true;
                case TokenKind.Min16Uint1x4Keyword: result = "min16uint1x4"; return true;
                case TokenKind.Min16Uint2x1Keyword: result = "min16uint2x1"; return true;
                case TokenKind.Min16Uint2x2Keyword: result = "min16uint2x2"; return true;
                case TokenKind.Min16Uint2x3Keyword: result = "min16uint2x3"; return true;
                case TokenKind.Min16Uint2x4Keyword: result = "min16uint2x4"; return true;
                case TokenKind.Min16Uint3x1Keyword: result = "min16uint3x1"; return true;
                case TokenKind.Min16Uint3x2Keyword: result = "min16uint3x2"; return true;
                case TokenKind.Min16Uint3x3Keyword: result = "min16uint3x3"; return true;
                case TokenKind.Min16Uint3x4Keyword: result = "min16uint3x4"; return true;
                case TokenKind.Min16Uint4x1Keyword: result = "min16uint4x1"; return true;
                case TokenKind.Min16Uint4x2Keyword: result = "min16uint4x2"; return true;
                case TokenKind.Min16Uint4x3Keyword: result = "min16uint4x3"; return true;
                case TokenKind.Min16Uint4x4Keyword: result = "min16uint4x4"; return true;
                case TokenKind.NamespaceKeyword: result = "namespace"; return true;
                case TokenKind.NointerpolationKeyword: result = "nointerpolation"; return true;
                case TokenKind.NoperspectiveKeyword: result = "noperspective"; return true;
                case TokenKind.NullKeyword: result = "NULL"; return true;
                case TokenKind.OutKeyword: result = "out"; return true;
                case TokenKind.OutputPatchKeyword: result = "OutputPatch"; return true;
                case TokenKind.PackMatrixKeyword: result = "packmatrix"; return true;
                case TokenKind.PackoffsetKeyword: result = "packoffset"; return true;
                case TokenKind.PassKeyword: result = "pass"; return true;
                case TokenKind.PayloadKeyword: result = "payload"; return true;
                case TokenKind.PointKeyword: result = "point"; return true;
                case TokenKind.PointStreamKeyword: result = "PointStream"; return true;
                case TokenKind.PragmaKeyword: result = "pragma"; return true;
                case TokenKind.PreciseKeyword: result = "precise"; return true;
                case TokenKind.PrimitivesKeyword: result = "primitives"; return true;
                case TokenKind.RasterizerOrderedBufferKeyword: result = "rasterizerorderedbuffer"; return true;
                case TokenKind.RasterizerOrderedByteAddressBufferKeyword: result = "rasterizerorderedbyteaddressbuffer"; return true;
                case TokenKind.RasterizerOrderedStructuredBufferKeyword: result = "rasterizerorderedstructuredbuffer"; return true;
                case TokenKind.RasterizerOrderedTexture1DKeyword: result = "rasterizerorderedtexture1d"; return true;
                case TokenKind.RasterizerOrderedTexture1DArrayKeyword: result = "rasterizerorderedtexture1darray"; return true;
                case TokenKind.RasterizerOrderedTexture2DKeyword: result = "rasterizerorderedtexture2d"; return true;
                case TokenKind.RasterizerOrderedTexture2DArrayKeyword: result = "rasterizerorderedtexture2darray"; return true;
                case TokenKind.RasterizerOrderedTexture3DKeyword: result = "rasterizerorderedtexture3d"; return true;
                case TokenKind.RasterizerStateKeyword: result = "RasterizerState"; return true;
                case TokenKind.RegisterKeyword: result = "register"; return true;
                case TokenKind.ReturnKeyword: result = "return"; return true;
                case TokenKind.RowMajorKeyword: result = "row_major"; return true;
                case TokenKind.RWBufferKeyword: result = "RWBuffer"; return true;
                case TokenKind.RWByteAddressBufferKeyword: result = "RWByteAddressBuffer"; return true;
                case TokenKind.RWStructuredBufferKeyword: result = "RWStructuredBuffer"; return true;
                case TokenKind.RWTexture1DKeyword: result = "RWTexture1D"; return true;
                case TokenKind.RWTexture1DArrayKeyword: result = "RWTexture1DArray"; return true;
                case TokenKind.RWTexture2DKeyword: result = "RWTexture2D"; return true;
                case TokenKind.RWTexture2DArrayKeyword: result = "RWTexture2DArray"; return true;
                case TokenKind.RWTexture3DKeyword: result = "RWTexture3D"; return true;
                case TokenKind.SamplerKeyword: result = "sampler"; return true;
                case TokenKind.Sampler1DKeyword: result = "sampler1d"; return true;
                case TokenKind.Sampler2DKeyword: result = "sampler2d"; return true;
                case TokenKind.Sampler3DKeyword: result = "sampler3d"; return true;
                case TokenKind.SamplerCubeKeyword: result = "samplercube"; return true;
                case TokenKind.SamplerComparisonStateKeyword: result = "SamplerComparisonState"; return true;
                case TokenKind.SamplerStateKeyword: result = "SamplerState"; return true;
                case TokenKind.SamplerStateLegacyKeyword: result = "sampler_state"; return true;
                case TokenKind.SharedKeyword: result = "shared"; return true;
                case TokenKind.SNormKeyword: result = "snorm"; return true;
                case TokenKind.StaticKeyword: result = "static"; return true;
                case TokenKind.StringKeyword: result = "string"; return true;
                case TokenKind.StructKeyword: result = "struct"; return true;
                case TokenKind.StructuredBufferKeyword: result = "StructuredBuffer"; return true;
                case TokenKind.SwitchKeyword: result = "switch"; return true;
                case TokenKind.TBufferKeyword: result = "tbuffer"; return true;
                case TokenKind.TechniqueKeyword: result = "technique"; return true;
                case TokenKind.Technique10Keyword: result = "technique10"; return true;
                case TokenKind.Technique11Keyword: result = "technique11"; return true;
                case TokenKind.TextureKeyword: result = "texture"; return true;
                case TokenKind.Texture2DLegacyKeyword: result = "Texture2DLegacy"; return true;
                case TokenKind.TextureCubeLegacyKeyword: result = "TextureCubeLegacy"; return true;
                case TokenKind.Texture1DKeyword: result = "Texture1D"; return true;
                case TokenKind.Texture1DArrayKeyword: result = "Texture1DArray"; return true;
                case TokenKind.Texture2DKeyword: result = "Texture2D"; return true;
                case TokenKind.Texture2DArrayKeyword: result = "Texture2DArray"; return true;
                case TokenKind.Texture2DMSKeyword: result = "Texture2DMS"; return true;
                case TokenKind.Texture2DMSArrayKeyword: result = "Texture2DMSArray"; return true;
                case TokenKind.Texture3DKeyword: result = "Texture3D"; return true;
                case TokenKind.TextureCubeKeyword: result = "TextureCube"; return true;
                case TokenKind.TextureCubeArrayKeyword: result = "TextureCubeArray"; return true;
                case TokenKind.TriangleKeyword: result = "triangle"; return true;
                case TokenKind.TriangleAdjKeyword: result = "triangleadj"; return true;
                case TokenKind.TriangleStreamKeyword: result = "TriangleStream"; return true;
                case TokenKind.TypedefKeyword: result = "typedef"; return true;
                case TokenKind.UniformKeyword: result = "uniform"; return true;
                case TokenKind.UNormKeyword: result = "unorm"; return true;
                case TokenKind.UintKeyword: result = "uint"; return true;
                case TokenKind.Uint1Keyword: result = "uint1"; return true;
                case TokenKind.Uint2Keyword: result = "uint2"; return true;
                case TokenKind.Uint3Keyword: result = "uint3"; return true;
                case TokenKind.Uint4Keyword: result = "uint4"; return true;
                case TokenKind.Uint1x1Keyword: result = "uint1x1"; return true;
                case TokenKind.Uint1x2Keyword: result = "uint1x2"; return true;
                case TokenKind.Uint1x3Keyword: result = "uint1x3"; return true;
                case TokenKind.Uint1x4Keyword: result = "uint1x4"; return true;
                case TokenKind.Uint2x1Keyword: result = "uint2x1"; return true;
                case TokenKind.Uint2x2Keyword: result = "uint2x2"; return true;
                case TokenKind.Uint2x3Keyword: result = "uint2x3"; return true;
                case TokenKind.Uint2x4Keyword: result = "uint2x4"; return true;
                case TokenKind.Uint3x1Keyword: result = "uint3x1"; return true;
                case TokenKind.Uint3x2Keyword: result = "uint3x2"; return true;
                case TokenKind.Uint3x3Keyword: result = "uint3x3"; return true;
                case TokenKind.Uint3x4Keyword: result = "uint3x4"; return true;
                case TokenKind.Uint4x1Keyword: result = "uint4x1"; return true;
                case TokenKind.Uint4x2Keyword: result = "uint4x2"; return true;
                case TokenKind.Uint4x3Keyword: result = "uint4x3"; return true;
                case TokenKind.Uint4x4Keyword: result = "uint4x4"; return true;
                case TokenKind.VectorKeyword: result = "vector"; return true;
                case TokenKind.VerticesKeyword: result = "vertices"; return true;
                case TokenKind.VolatileKeyword: result = "volatile"; return true;
                case TokenKind.VoidKeyword: result = "void"; return true;
                case TokenKind.WarningKeyword: result = "warning"; return true;
                case TokenKind.WhileKeyword: result = "while"; return true;
                case TokenKind.TrueKeyword: result = "true"; return true;
                case TokenKind.FalseKeyword: result = "false"; return true;
                case TokenKind.UnsignedKeyword: result = "unsigned"; return true;
                case TokenKind.DwordKeyword: result = "dword"; return true;
                case TokenKind.CompileFragmentKeyword: result = "compile_fragment"; return true;
                case TokenKind.DepthStencilViewKeyword: result = "DepthStencilView"; return true;
                case TokenKind.PixelfragmentKeyword: result = "pixelfragment"; return true;
                case TokenKind.RenderTargetViewKeyword: result = "RenderTargetView"; return true;
                case TokenKind.StateblockStateKeyword: result = "stateblock_state"; return true;
                case TokenKind.StateblockKeyword: result = "stateblock"; return true;
                default: result = string.Empty;  return false;
            }
        }

        public static bool TryConvertIdentifierOrKeywordToString(Token<TokenKind> token, out string result)
        {
            if (token.Identifier != null)
            {
                result = token.Identifier;
                return true;
            }

            if (TryConvertKeywordToString(token.Kind, out result))
            {
                return true;
            }

            result = string.Empty;
            return false;
        }

        public static string IdentifierOrKeywordToString(Token<TokenKind> token)
        {
            if (token.Identifier != null)
                return token.Identifier;

            if (TryConvertKeywordToString(token.Kind, out string result))
                return result;

            return "__INVALID";
        }

        public static string TokenToString(Token<TokenKind> token)
        {
            switch (token.Kind)
            {
                case TokenKind.OpenParenToken: return "(";
                case TokenKind.CloseParenToken: return ")";
                case TokenKind.OpenBracketToken: return "[";
                case TokenKind.CloseBracketToken: return "]";
                case TokenKind.OpenBraceToken: return "{";
                case TokenKind.CloseBraceToken: return "}";
                case TokenKind.SemiToken: return ";";
                case TokenKind.CommaToken: return ",";
                case TokenKind.LessThanToken: return "<";
                case TokenKind.LessThanEqualsToken: return "<=";
                case TokenKind.GreaterThanToken: return ">";
                case TokenKind.GreaterThanEqualsToken: return ">=";
                case TokenKind.LessThanLessThanToken: return "<<";
                case TokenKind.GreaterThanGreaterThanToken: return ">>";
                case TokenKind.PlusToken: return "+";
                case TokenKind.PlusPlusToken: return "++";
                case TokenKind.MinusToken: return "-";
                case TokenKind.MinusMinusToken: return "--";
                case TokenKind.AsteriskToken: return "*";
                case TokenKind.SlashToken: return "/";
                case TokenKind.PercentToken: return "%";
                case TokenKind.AmpersandToken: return "&";
                case TokenKind.BarToken: return "|";
                case TokenKind.AmpersandAmpersandToken: return "&&";
                case TokenKind.BarBarToken: return "||";
                case TokenKind.CaretToken: return "^";
                case TokenKind.NotToken: return "!";
                case TokenKind.TildeToken: return "~";
                case TokenKind.QuestionToken: return "?";
                case TokenKind.ColonToken: return ":";
                case TokenKind.ColonColonToken: return "::";
                case TokenKind.EqualsToken: return "=";
                case TokenKind.AsteriskEqualsToken: return "*=";
                case TokenKind.SlashEqualsToken: return "/=";
                case TokenKind.PercentEqualsToken: return "%=";
                case TokenKind.PlusEqualsToken: return "+=";
                case TokenKind.MinusEqualsToken: return "-=";
                case TokenKind.LessThanLessThanEqualsToken: return "<<=";
                case TokenKind.GreaterThanGreaterThanEqualsToken: return ">>=";
                case TokenKind.AmpersandEqualsToken: return "&=";
                case TokenKind.CaretEqualsToken: return "^=";
                case TokenKind.BarEqualsToken: return "|=";
                case TokenKind.EqualsEqualsToken: return "==";
                case TokenKind.ExclamationEqualsToken: return "!=";
                case TokenKind.DotToken: return ".";
                case TokenKind.HashToken: return "#";
                case TokenKind.HashHashToken: return "##";

                case TokenKind.StringLiteralToken: return $"\"{token.Identifier}\"";
                case TokenKind.CharacterLiteralToken: return $"'{token.Identifier}'";
                case TokenKind.SystemIncludeLiteralToken: return $"<{token.Identifier}>";

                case TokenKind.DefineDirectiveKeyword: return "#define";
                case TokenKind.IncludeDirectiveKeyword: return "#include";
                case TokenKind.LineDirectiveKeyword: return "#line";
                case TokenKind.UndefDirectiveKeyword: return "#undef";
                case TokenKind.ErrorDirectiveKeyword: return "#error";
                case TokenKind.PragmaDirectiveKeyword: return "#pragma";
                case TokenKind.IfDirectiveKeyword: return "#if";
                case TokenKind.IfdefDirectiveKeyword: return "#ifdef";
                case TokenKind.IfndefDirectiveKeyword: return "#ifndef";
                case TokenKind.ElifDirectiveKeyword: return "#elif";
                case TokenKind.ElseDirectiveKeyword: return "#else";
                case TokenKind.EndifDirectiveKeyword: return "#endif";
                case TokenKind.EndDirectiveToken: return "\n";

                default: return IdentifierOrKeywordToString(token);
            }
        }

        public static string TokensToString(IEnumerable<Token<TokenKind>> tokens)
        {
            return string.Join(" ", tokens.Select(x => TokenToString(x)));
        }

        public static bool IsStringLikeLiteral(TokenKind kind)
        {
            switch (kind)
            {
                case TokenKind.StringLiteralToken:
                case TokenKind.CharacterLiteralToken:
                case TokenKind.SystemIncludeLiteralToken:
                    return true;
                default:
                    return false;
            }
        }
    }
}


// HLSL/HLSLSyntaxVisitor.cs
namespace UnityShaderParser.HLSL
{
    public abstract class HLSLSyntaxVisitor
    {
        protected virtual void DefaultVisit(HLSLSyntaxNode node)
        {
            foreach (var child in node.Children)
            {
                child.Accept(this);
            }
        }

        public void VisitMany(IEnumerable<HLSLSyntaxNode> nodes)
        {
            foreach (HLSLSyntaxNode node in nodes)
            {
                Visit(node);
            }
        }

        public void VisitMany<T>(IList<T> nodes, Action runBetween)
            where T: HLSLSyntaxNode
        {
            for (int i = 0; i < nodes.Count; i++)
            {
                Visit(nodes[i]);
                if (i < nodes.Count - 1)
                    runBetween();
            }
        }

        public virtual void Visit(HLSLSyntaxNode node) => node?.Accept(this);
        public virtual void VisitIdentifierNode(IdentifierNode node) => DefaultVisit(node);
        public virtual void VisitFormalParameterNode(FormalParameterNode node) => DefaultVisit(node);
        public virtual void VisitVariableDeclaratorNode(VariableDeclaratorNode node) => DefaultVisit(node);
        public virtual void VisitArrayRankNode(ArrayRankNode node) => DefaultVisit(node);
        public virtual void VisitValueInitializerNode(ValueInitializerNode node) => DefaultVisit(node);
        public virtual void VisitStateInitializerNode(StateInitializerNode node) => DefaultVisit(node);
        public virtual void VisitStateArrayInitializerNode(StateArrayInitializerNode node) => DefaultVisit(node);
        public virtual void VisitFunctionDeclarationNode(FunctionDeclarationNode node) => DefaultVisit(node);
        public virtual void VisitFunctionDefinitionNode(FunctionDefinitionNode node) => DefaultVisit(node);
        public virtual void VisitStructDefinitionNode(StructDefinitionNode node) => DefaultVisit(node);
        public virtual void VisitInterfaceDefinitionNode(InterfaceDefinitionNode node) => DefaultVisit(node);
        public virtual void VisitConstantBufferNode(ConstantBufferNode node) => DefaultVisit(node);
        public virtual void VisitNamespaceNode(NamespaceNode node) => DefaultVisit(node);
        public virtual void VisitTypedefNode(TypedefNode node) => DefaultVisit(node);
        public virtual void VisitSemanticNode(SemanticNode node) => DefaultVisit(node);
        public virtual void VisitRegisterLocationNode(RegisterLocationNode node) => DefaultVisit(node);
        public virtual void VisitPackoffsetNode(PackoffsetNode node) => DefaultVisit(node);
        public virtual void VisitBlockNode(BlockNode node) => DefaultVisit(node);
        public virtual void VisitVariableDeclarationStatementNode(VariableDeclarationStatementNode node) => DefaultVisit(node);
        public virtual void VisitReturnStatementNode(ReturnStatementNode node) => DefaultVisit(node);
        public virtual void VisitBreakStatementNode(BreakStatementNode node) => DefaultVisit(node);
        public virtual void VisitContinueStatementNode(ContinueStatementNode node) => DefaultVisit(node);
        public virtual void VisitDiscardStatementNode(DiscardStatementNode node) => DefaultVisit(node);
        public virtual void VisitEmptyStatementNode(EmptyStatementNode node) => DefaultVisit(node);
        public virtual void VisitForStatementNode(ForStatementNode node) => DefaultVisit(node);
        public virtual void VisitWhileStatementNode(WhileStatementNode node) => DefaultVisit(node);
        public virtual void VisitDoWhileStatementNode(DoWhileStatementNode node) => DefaultVisit(node);
        public virtual void VisitIfStatementNode(IfStatementNode node) => DefaultVisit(node);
        public virtual void VisitSwitchStatementNode(SwitchStatementNode node) => DefaultVisit(node);
        public virtual void VisitSwitchClauseNode(SwitchClauseNode node) => DefaultVisit(node);
        public virtual void VisitSwitchCaseLabelNode(SwitchCaseLabelNode node) => DefaultVisit(node);
        public virtual void VisitSwitchDefaultLabelNode(SwitchDefaultLabelNode node) => DefaultVisit(node);
        public virtual void VisitExpressionStatementNode(ExpressionStatementNode node) => DefaultVisit(node);
        public virtual void VisitAttributeNode(AttributeNode node) => DefaultVisit(node);
        public virtual void VisitQualifiedIdentifierExpressionNode(QualifiedIdentifierExpressionNode node) => DefaultVisit(node);
        public virtual void VisitIdentifierExpressionNode(IdentifierExpressionNode node) => DefaultVisit(node);
        public virtual void VisitLiteralExpressionNode(LiteralExpressionNode node) => DefaultVisit(node);
        public virtual void VisitAssignmentExpressionNode(AssignmentExpressionNode node) => DefaultVisit(node);
        public virtual void VisitBinaryExpressionNode(BinaryExpressionNode node) => DefaultVisit(node);
        public virtual void VisitCompoundExpressionNode(CompoundExpressionNode node) => DefaultVisit(node);
        public virtual void VisitPrefixUnaryExpressionNode(PrefixUnaryExpressionNode node) => DefaultVisit(node);
        public virtual void VisitPostfixUnaryExpressionNode(PostfixUnaryExpressionNode node) => DefaultVisit(node);
        public virtual void VisitFieldAccessExpressionNode(FieldAccessExpressionNode node) => DefaultVisit(node);
        public virtual void VisitMethodCallExpressionNode(MethodCallExpressionNode node) => DefaultVisit(node);
        public virtual void VisitFunctionCallExpressionNode(FunctionCallExpressionNode node) => DefaultVisit(node);
        public virtual void VisitNumericConstructorCallExpressionNode(NumericConstructorCallExpressionNode node) => DefaultVisit(node);
        public virtual void VisitElementAccessExpressionNode(ElementAccessExpressionNode node) => DefaultVisit(node);
        public virtual void VisitCastExpressionNode(CastExpressionNode node) => DefaultVisit(node);
        public virtual void VisitArrayInitializerExpressionNode(ArrayInitializerExpressionNode node) => DefaultVisit(node);
        public virtual void VisitTernaryExpressionNode(TernaryExpressionNode node) => DefaultVisit(node);
        public virtual void VisitSamplerStateLiteralExpressionNode(SamplerStateLiteralExpressionNode node) => DefaultVisit(node);
        public virtual void VisitCompileExpressionNode(CompileExpressionNode node) => DefaultVisit(node);
        public virtual void VisitQualifiedNamedTypeNode(QualifiedNamedTypeNode node) => DefaultVisit(node);
        public virtual void VisitNamedTypeNode(NamedTypeNode node) => DefaultVisit(node);
        public virtual void VisitPredefinedObjectTypeNode(PredefinedObjectTypeNode node) => DefaultVisit(node);
        public virtual void VisitStructTypeNode(StructTypeNode node) => DefaultVisit(node);
        public virtual void VisitScalarTypeNode(ScalarTypeNode node) => DefaultVisit(node);
        public virtual void VisitMatrixTypeNode(MatrixTypeNode node) => DefaultVisit(node);
        public virtual void VisitGenericMatrixTypeNode(GenericMatrixTypeNode node) => DefaultVisit(node);
        public virtual void VisitVectorTypeNode(VectorTypeNode node) => DefaultVisit(node);
        public virtual void VisitGenericVectorTypeNode(GenericVectorTypeNode node) => DefaultVisit(node);
        public virtual void VisitTechniqueNode(TechniqueNode node) => DefaultVisit(node);
        public virtual void VisitLiteralTemplateArgumentType(LiteralTemplateArgumentType node) => DefaultVisit(node);
        public virtual void VisitStatePropertyNode(StatePropertyNode node) => DefaultVisit(node);
        public virtual void VisitPassNode(PassNode node) => DefaultVisit(node);
        public virtual void VisitObjectLikeMacroNode(ObjectLikeMacroNode node) => DefaultVisit(node);
        public virtual void VisitFunctionLikeMacroNode(FunctionLikeMacroNode node) => DefaultVisit(node);
        public virtual void VisitIncludeDirectiveNode(IncludeDirectiveNode node) => DefaultVisit(node);
        public virtual void VisitLineDirectiveNode(LineDirectiveNode node) => DefaultVisit(node);
        public virtual void VisitUndefDirectiveNode(UndefDirectiveNode node) => DefaultVisit(node);
        public virtual void VisitErrorDirectiveNode(ErrorDirectiveNode node) => DefaultVisit(node);
        public virtual void VisitPragmaDirectiveNode(PragmaDirectiveNode node) => DefaultVisit(node);
        public virtual void VisitIfDefDirectiveNode(IfDefDirectiveNode node) => DefaultVisit(node);
        public virtual void VisitIfNotDefDirectiveNode(IfNotDefDirectiveNode node) => DefaultVisit(node);
        public virtual void VisitIfDirectiveNode(IfDirectiveNode node) => DefaultVisit(node);
        public virtual void VisitElseDirectiveNode(ElseDirectiveNode node) => DefaultVisit(node);
    }

    public abstract class HLSLSyntaxVisitor<TReturn>
    {
        protected virtual TReturn DefaultVisit(HLSLSyntaxNode node)
        {
            foreach (var child in node.Children)
            {
                child.Accept(this);
            }
            return default;
        }

        public List<TReturn> VisitMany(IEnumerable<HLSLSyntaxNode> nodes)
        {
            List<TReturn> result = new List<TReturn>();
            foreach (HLSLSyntaxNode node in nodes)
            {
                result.Add(Visit(node));
            }
            return result;
        }

        public List<TReturn> VisitMany<T>(IList<T> nodes, Action runBetween)
            where T : HLSLSyntaxNode
        {
            List<TReturn> result = new List<TReturn>();
            for (int i = 0; i < nodes.Count; i++)
            {
                result.Add(Visit(nodes[i]));
                if (i < nodes.Count - 1)
                    runBetween();
            }
            return result;
        }

        public virtual TReturn Visit(HLSLSyntaxNode node) => node == null ? default : node.Accept(this);
        public virtual TReturn VisitIdentifierNode(IdentifierNode node) => DefaultVisit(node);
        public virtual TReturn VisitFormalParameterNode(FormalParameterNode node) => DefaultVisit(node);
        public virtual TReturn VisitVariableDeclaratorNode(VariableDeclaratorNode node) => DefaultVisit(node);
        public virtual TReturn VisitArrayRankNode(ArrayRankNode node) => DefaultVisit(node);
        public virtual TReturn VisitValueInitializerNode(ValueInitializerNode node) => DefaultVisit(node);
        public virtual TReturn VisitStateInitializerNode(StateInitializerNode node) => DefaultVisit(node);
        public virtual TReturn VisitStateArrayInitializerNode(StateArrayInitializerNode node) => DefaultVisit(node);
        public virtual TReturn VisitFunctionDeclarationNode(FunctionDeclarationNode node) => DefaultVisit(node);
        public virtual TReturn VisitFunctionDefinitionNode(FunctionDefinitionNode node) => DefaultVisit(node);
        public virtual TReturn VisitStructDefinitionNode(StructDefinitionNode node) => DefaultVisit(node);
        public virtual TReturn VisitInterfaceDefinitionNode(InterfaceDefinitionNode node) => DefaultVisit(node);
        public virtual TReturn VisitConstantBufferNode(ConstantBufferNode node) => DefaultVisit(node);
        public virtual TReturn VisitNamespaceNode(NamespaceNode node) => DefaultVisit(node);
        public virtual TReturn VisitTypedefNode(TypedefNode node) => DefaultVisit(node);
        public virtual TReturn VisitSemanticNode(SemanticNode node) => DefaultVisit(node);
        public virtual TReturn VisitRegisterLocationNode(RegisterLocationNode node) => DefaultVisit(node);
        public virtual TReturn VisitPackoffsetNode(PackoffsetNode node) => DefaultVisit(node);
        public virtual TReturn VisitBlockNode(BlockNode node) => DefaultVisit(node);
        public virtual TReturn VisitVariableDeclarationStatementNode(VariableDeclarationStatementNode node) => DefaultVisit(node);
        public virtual TReturn VisitReturnStatementNode(ReturnStatementNode node) => DefaultVisit(node);
        public virtual TReturn VisitBreakStatementNode(BreakStatementNode node) => DefaultVisit(node);
        public virtual TReturn VisitContinueStatementNode(ContinueStatementNode node) => DefaultVisit(node);
        public virtual TReturn VisitDiscardStatementNode(DiscardStatementNode node) => DefaultVisit(node);
        public virtual TReturn VisitEmptyStatementNode(EmptyStatementNode node) => DefaultVisit(node);
        public virtual TReturn VisitForStatementNode(ForStatementNode node) => DefaultVisit(node);
        public virtual TReturn VisitWhileStatementNode(WhileStatementNode node) => DefaultVisit(node);
        public virtual TReturn VisitDoWhileStatementNode(DoWhileStatementNode node) => DefaultVisit(node);
        public virtual TReturn VisitIfStatementNode(IfStatementNode node) => DefaultVisit(node);
        public virtual TReturn VisitSwitchStatementNode(SwitchStatementNode node) => DefaultVisit(node);
        public virtual TReturn VisitSwitchClauseNode(SwitchClauseNode node) => DefaultVisit(node);
        public virtual TReturn VisitSwitchCaseLabelNode(SwitchCaseLabelNode node) => DefaultVisit(node);
        public virtual TReturn VisitSwitchDefaultLabelNode(SwitchDefaultLabelNode node) => DefaultVisit(node);
        public virtual TReturn VisitExpressionStatementNode(ExpressionStatementNode node) => DefaultVisit(node);
        public virtual TReturn VisitAttributeNode(AttributeNode node) => DefaultVisit(node);
        public virtual TReturn VisitQualifiedIdentifierExpressionNode(QualifiedIdentifierExpressionNode node) => DefaultVisit(node);
        public virtual TReturn VisitIdentifierExpressionNode(IdentifierExpressionNode node) => DefaultVisit(node);
        public virtual TReturn VisitLiteralExpressionNode(LiteralExpressionNode node) => DefaultVisit(node);
        public virtual TReturn VisitAssignmentExpressionNode(AssignmentExpressionNode node) => DefaultVisit(node);
        public virtual TReturn VisitBinaryExpressionNode(BinaryExpressionNode node) => DefaultVisit(node);
        public virtual TReturn VisitCompoundExpressionNode(CompoundExpressionNode node) => DefaultVisit(node);
        public virtual TReturn VisitPrefixUnaryExpressionNode(PrefixUnaryExpressionNode node) => DefaultVisit(node);
        public virtual TReturn VisitPostfixUnaryExpressionNode(PostfixUnaryExpressionNode node) => DefaultVisit(node);
        public virtual TReturn VisitFieldAccessExpressionNode(FieldAccessExpressionNode node) => DefaultVisit(node);
        public virtual TReturn VisitMethodCallExpressionNode(MethodCallExpressionNode node) => DefaultVisit(node);
        public virtual TReturn VisitFunctionCallExpressionNode(FunctionCallExpressionNode node) => DefaultVisit(node);
        public virtual TReturn VisitNumericConstructorCallExpressionNode(NumericConstructorCallExpressionNode node) => DefaultVisit(node);
        public virtual TReturn VisitElementAccessExpressionNode(ElementAccessExpressionNode node) => DefaultVisit(node);
        public virtual TReturn VisitCastExpressionNode(CastExpressionNode node) => DefaultVisit(node);
        public virtual TReturn VisitArrayInitializerExpressionNode(ArrayInitializerExpressionNode node) => DefaultVisit(node);
        public virtual TReturn VisitTernaryExpressionNode(TernaryExpressionNode node) => DefaultVisit(node);
        public virtual TReturn VisitSamplerStateLiteralExpressionNode(SamplerStateLiteralExpressionNode node) => DefaultVisit(node);
        public virtual TReturn VisitCompileExpressionNode(CompileExpressionNode node) => DefaultVisit(node);
        public virtual TReturn VisitQualifiedNamedTypeNode(QualifiedNamedTypeNode node) => DefaultVisit(node);
        public virtual TReturn VisitNamedTypeNode(NamedTypeNode node) => DefaultVisit(node);
        public virtual TReturn VisitPredefinedObjectTypeNode(PredefinedObjectTypeNode node) => DefaultVisit(node);
        public virtual TReturn VisitStructTypeNode(StructTypeNode node) => DefaultVisit(node);
        public virtual TReturn VisitScalarTypeNode(ScalarTypeNode node) => DefaultVisit(node);
        public virtual TReturn VisitMatrixTypeNode(MatrixTypeNode node) => DefaultVisit(node);
        public virtual TReturn VisitGenericMatrixTypeNode(GenericMatrixTypeNode node) => DefaultVisit(node);
        public virtual TReturn VisitVectorTypeNode(VectorTypeNode node) => DefaultVisit(node);
        public virtual TReturn VisitGenericVectorTypeNode(GenericVectorTypeNode node) => DefaultVisit(node);
        public virtual TReturn VisitTechniqueNode(TechniqueNode node) => DefaultVisit(node);
        public virtual TReturn VisitLiteralTemplateArgumentType(LiteralTemplateArgumentType node) => DefaultVisit(node);
        public virtual TReturn VisitStatePropertyNode(StatePropertyNode node) => DefaultVisit(node);
        public virtual TReturn VisitPassNode(PassNode node) => DefaultVisit(node);
        public virtual TReturn VisitObjectLikeMacroNode(ObjectLikeMacroNode node) => DefaultVisit(node);
        public virtual TReturn VisitFunctionLikeMacroNode(FunctionLikeMacroNode node) => DefaultVisit(node);
        public virtual TReturn VisitIncludeDirectiveNode(IncludeDirectiveNode node) => DefaultVisit(node);
        public virtual TReturn VisitLineDirectiveNode(LineDirectiveNode node) => DefaultVisit(node);
        public virtual TReturn VisitUndefDirectiveNode(UndefDirectiveNode node) => DefaultVisit(node);
        public virtual TReturn VisitErrorDirectiveNode(ErrorDirectiveNode node) => DefaultVisit(node);
        public virtual TReturn VisitPragmaDirectiveNode(PragmaDirectiveNode node) => DefaultVisit(node);
        public virtual TReturn VisitIfDefDirectiveNode(IfDefDirectiveNode node) => DefaultVisit(node);
        public virtual TReturn VisitIfNotDefDirectiveNode(IfNotDefDirectiveNode node) => DefaultVisit(node);
        public virtual TReturn VisitIfDirectiveNode(IfDirectiveNode node) => DefaultVisit(node);
        public virtual TReturn VisitElseDirectiveNode(ElseDirectiveNode node) => DefaultVisit(node);
    }
}


// Common/BaseLexer.cs
namespace UnityShaderParser.Common
{
    public abstract class BaseLexer<T>
        where T : struct
    {
        protected abstract ParserStage Stage { get; }

        protected bool throwExceptionOnError = false;
        protected string source = string.Empty;
        protected int position = 0;
        protected int line = 1;
        protected int column = 1;
        protected int anchorLine = 1;
        protected int anchorColumn = 1;
        protected int anchorPosition = 0;
        protected string basePath;
        protected string fileName;
        protected DiagnosticFlags diagnosticFilter = DiagnosticFlags.All;

        protected List<Token<T>> tokens = new List<Token<T>>();
        protected List<Diagnostic> diagnostics = new List<Diagnostic>();

        public BaseLexer(string source, string basePath, string fileName, bool throwExceptionOnError, SourceLocation offset)
        {
            this.source = source;
            this.throwExceptionOnError = throwExceptionOnError;
            this.line = offset.Line;
            this.column = offset.Column;
            this.basePath = basePath;
            this.fileName = fileName;
        }

        protected char Peek() => IsAtEnd() ? '\0' : source[position];
        protected char LookAhead(int offset = 1) => IsAtEnd(offset) ? '\0' : source[position + offset];
        protected bool LookAhead(char c, int offset = 1) => LookAhead(offset) == c;
        protected bool Match(char tok) => Peek() == tok;
        protected bool IsAtEnd(int offset = 0) => position + offset >= source.Length;
        protected void Add(string identifier, T kind) => tokens.Add(new Token<T>(kind, identifier, GetCurrentSpan(), tokens.Count));
        protected void Add(T kind) => tokens.Add(new Token<T>(kind, null, GetCurrentSpan(), tokens.Count));
        protected void Eat(char tok)
        {
            if (!Match(tok))
                Error(DiagnosticFlags.SyntaxError, $"Expected token '{tok}', got '{Peek()}'.");
            Advance();
        }
        protected char Advance(int amount = 1)
        {
            if (IsAtEnd(amount - 1))
                return '\0';
            column++;
            if (Peek() == '\n')
            {
                column = 1;
                line++;
            }
            char result = source[position];
            position += amount;
            return result;
        }
        protected void Error(DiagnosticFlags kind, string err)
        {
            if (!diagnosticFilter.HasFlag(kind))
                return;

            if (throwExceptionOnError && kind != DiagnosticFlags.Warning)
            {
                throw new Exception($"Error at line {line}, column {column} during {Stage}: {err}");
            }
            diagnostics.Add(new Diagnostic(GetCurrentSpan(), kind, this.Stage, err));
        }

        protected void StartCurrentSpan()
        {
            anchorLine = line;
            anchorColumn = column;
            anchorPosition = position;
        }

        protected SourceSpan GetCurrentSpan()
        {
            return new SourceSpan(basePath, fileName, new SourceLocation(anchorLine, anchorColumn, anchorPosition), new SourceLocation(line, column, position));
        }

        protected string EatStringLiteral(char start, char end)
        {
            StringBuilder builder = new StringBuilder();
            Eat(start);
            while (Peek() != end)
            {
                builder.Append(Advance());
            }
            Eat(end);
            return builder.ToString();
        }

        protected string EatIdentifier()
        {
            StringBuilder builder = new StringBuilder();
            while (IsAlphaNumericOrUnderscore(Peek()))
            {
                builder.Append(Advance());
            }
            return builder.ToString();
        }

        protected string EatNumber(out bool isFloat)
        {
            StringBuilder builder = new StringBuilder();
            if (Match('-'))
            {
                builder.Append(Advance());
            }
            while (true)
            {
                char c = Peek();
                if (char.IsDigit(c) || c == '.')
                {
                    builder.Append(Advance());
                }
                // Scientific notation
                else if (c == 'e' || c == 'E')
                {
                    builder.Append(Advance());
                    var sign = Peek();
                    if (sign == '-' || sign == '+')
                        builder.Append(Advance());
                }
                else
                {
                    break;
                }
            }
            if (Match('f') || Match('F') || Match('h') || Match('H') || Match('u') || Match('U'))
            {
                builder.Append(Advance());
            }
            string number = builder.ToString();
            isFloat = number.Contains(".") ||
                number.EndsWith("f") ||
                number.EndsWith("F") ||
                number.EndsWith("h") ||
                number.EndsWith("H");
            return number;
        }

        protected void SkipWhitespace(bool skipNewLines = false)
        {
            while (Peek() == ' ' || Peek() == '\t' || Peek() == '\r' || (skipNewLines && Peek() == '\n'))
            {
                Advance();
            }
        }

        protected static bool IsAlphaNumericOrUnderscore(char c) => c == '_' || char.IsLetterOrDigit(c);

        protected abstract void ProcessChar(char nextChar);

        public void Lex()
        {
            while (!IsAtEnd())
            {
                StartCurrentSpan();
                ProcessChar(Peek());
            }
        }
    }
}


// Common/BaseParser.cs
namespace UnityShaderParser.Common
{
    public abstract class BaseParser<T>
        where T : struct, Enum
    {
        // Require token kinds
        protected abstract T StringLiteralTokenKind { get; }
        protected abstract T IntegerLiteralTokenKind { get; }
        protected abstract T FloatLiteralTokenKind { get; }
        protected abstract T IdentifierTokenKind { get; }
        protected abstract T InvalidTokenKind { get; }
        protected abstract ParserStage Stage { get; }

        protected Token<T> InvalidToken => new Token<T>(InvalidTokenKind, null, anchorSpan, position);

        protected List<Token<T>> tokens = new List<Token<T>>();
        protected int position = 0;
        protected SourceSpan anchorSpan = default;
        protected List<Diagnostic> diagnostics = new List<Diagnostic>();
        protected bool isRecovering = false;

        protected bool throwExceptionOnError = false;
        protected DiagnosticFlags diagnosticFilter = DiagnosticFlags.All;
        public List<Diagnostic> Diagnostics => diagnostics;

        public BaseParser(List<Token<T>> tokens, bool throwExceptionOnError, DiagnosticFlags diagnosticFilter)
        {
            // Need to copy since the parser might want to modify tokens in place
            this.tokens = new List<Token<T>>(tokens);
            this.throwExceptionOnError = throwExceptionOnError;
            this.diagnosticFilter = diagnosticFilter;
        }

        protected Stack<(int position, bool isRecovering, SourceSpan span, int diagnosticCount)> snapshots = new Stack<(int position, bool isRecovering, SourceSpan span, int diagnosticCount)>();

        protected void SnapshotState()
        {
            snapshots.Push((position, isRecovering, anchorSpan, diagnostics.Count));
        }

        protected void RestoreState()
        {
            var snapshot = snapshots.Pop();
            position = snapshot.position;
            isRecovering = snapshot.isRecovering;
            anchorSpan = snapshot.span;
            diagnostics.RemoveRange(snapshot.diagnosticCount, diagnostics.Count - snapshot.diagnosticCount);
        }

        protected void DropState()
        {
            snapshots.Pop();
        }

        protected bool Speculate(Func<bool> parser)
        {
            SnapshotState();

            try
            {
                // Try the parser
                bool result = parser();

                // If we encountered any errors, report false
                if (diagnostics.Count > snapshots.Peek().diagnosticCount)
                {
                    return false;
                }

                // Otherwise report whatever the parser got
                return result;
            }
            finally
            {
                RestoreState();   
            }
        }

        protected bool TryParse<P>(Func<P> parser, out P parsed)
        {
            SnapshotState();

            // Try the parser
            parsed = parser();

            // If we encountered any errors, report false
            if (diagnostics.Count > snapshots.Peek().diagnosticCount)
            {
                RestoreState();
                parsed = default;
                return false;
            }

            // Otherwise return whatever the parser got
            DropState();
            return true;
        }

        protected Token<T> LookAhead(int offset = 1)
        {
            if (IsAtEnd(offset))
                return InvalidToken;
            // If we are currently recovering from an error, return an error token.
            else if (isRecovering)
                return InvalidToken;
            else
                return tokens[position + offset];
        }
        protected Token<T> Peek() => LookAhead(0);
        protected bool Match(Func<Token<T>, bool> predicate) => predicate(Peek());
        protected bool Match(Func<T, bool> predicate) => predicate(Peek().Kind);
        protected bool Match(T kind) => Match(tok => EqualityComparer<T>.Default.Equals(tok.Kind, kind));
        protected bool Match(params T[] alternatives) => Match(tok => alternatives.Contains(tok.Kind));
        protected bool IsAtEnd(int offset = 0) => position + offset >= tokens.Count;
        protected bool LoopShouldContinue() => !IsAtEnd() && !isRecovering;
        protected Token<T> Eat(Func<T, bool> predicate)
        {
            if (!Match(predicate))
                Error(DiagnosticFlags.SyntaxError, $"Unexpected token '{Peek()}'.");
            return Advance();
        }
        protected Token<T> Eat(T kind)
        {
            if (!Match(kind))
                Error(DiagnosticFlags.SyntaxError, $"Expected token type '{kind}', got '{Peek().Kind}'.");
            return Advance();
        }
        protected Token<T> Eat(params T[] alternatives)
        {
            if (!Match(alternatives))
            {
                string allowed = string.Join(", ", alternatives);
                Error(DiagnosticFlags.SyntaxError, $"Unexpected token '{Peek()}', expected one of the following token types: {allowed}.");
            }
            return Advance();
        }
        protected Token<T> Advance(int amount = 1)
        {
            if (IsAtEnd(amount - 1))
                return InvalidToken; 
            // If we are currently recovering from an error, don't keep eating tokens, and instead return an error token.
            else if (isRecovering)
                return InvalidToken;
            Token<T> result = tokens[position];
            position += amount;
            anchorSpan = Peek().Span;
            return result;
        }
        protected Token<T> Previous() => LookAhead(-1);

        protected void Error(DiagnosticFlags kind, string msg)
        {
            // If we don't care about this kind of warning, or we are currently recovering from an error, bail
            if (!diagnosticFilter.HasFlag(kind) || isRecovering)
                return;

            // If we have hit an actual error, start error recovery mode
            if (kind != DiagnosticFlags.Warning)
            {
                isRecovering = true;
            }

            // Throw an exception if requested and while we aren't speculating
            if (throwExceptionOnError && snapshots.Count == 0 && kind != DiagnosticFlags.Warning)
            {
                throw new Exception($"Error at line {anchorSpan.Start.Line}, column {anchorSpan.Start.Column} during {Stage}: {msg}");
            }

            // Log the diagnostic
            diagnostics.Add(new Diagnostic(anchorSpan, kind, Stage, msg));
        }

        protected void Error(DiagnosticFlags kind, string msg, SourceSpan span)
        {
            anchorSpan = span;
            Error(kind, msg);
        }

        protected void Error(string expected, Token<T> token)
        {
            Error(DiagnosticFlags.SyntaxError, $"Expected {expected}, got token ({token})", token.Span);
        }

        protected List<Token<T>> Range(Token<T> first, Token<T> last)
        {
            if (first == null || last == null) return new List<Token<T>>();
            int count = last.Position - first.Position + 1;
            if (count < 0) count = 0;
            if (first.Position + count > tokens.Count) count = tokens.Count - first.Position;
            return tokens.GetRange(first.Position, count);
        }

        protected string ParseIdentifier()
        {
            Token<T> identifierToken = Eat(IdentifierTokenKind);
            string identifier = identifierToken.Identifier ?? string.Empty;
            if (string.IsNullOrEmpty(identifier))
                Error("a valid identifier", identifierToken);
            return identifier;
        }

        protected string ParseStringLiteral()
        {
            Token<T> literalToken = Eat(StringLiteralTokenKind);
            return literalToken.Identifier ?? string.Empty;
        }

        protected float ParseNumericLiteral()
        {
            Token<T> literalToken = Eat(FloatLiteralTokenKind, IntegerLiteralTokenKind);
            string literal = literalToken.Identifier ?? string.Empty;
            if (string.IsNullOrEmpty(literal))
                Error("a valid numeric literal", literalToken);
            return float.Parse(literal, System.Globalization.NumberStyles.Any, System.Globalization.CultureInfo.InvariantCulture);
        }

        protected int ParseIntegerLiteral()
        {
            return (int)ParseNumericLiteral();
        }

        protected byte ParseByteLiteral()
        {
            return (byte)ParseNumericLiteral();
        }

        protected TEnum ParseEnum<TEnum>(string expected)
            where TEnum : struct
        {
            Token<T> next = Advance();
            // ShaderLab has a lot of ambiguous syntax, many keywords are reused in multiple places as regular identifiers.
            // If we fail to use the identifier directly, it might be an overlapping keyword, so try that instead.
            string identifier = next.Identifier ?? next.Kind.ToString()?.Replace("Keyword", "") ?? String.Empty;
            if (Enum.TryParse(identifier, true, out TEnum result))
            {
                return result;
            }
            else
            {
                Error(expected, next);
                return default;
            }
        }

        #region Parser combinators
        protected List<P> ParseSeparatedList0<P>(T end, T separator, Func<P> parser, bool allowTrailingSeparator = false)
        {
            if (Match(end))
                return new List<P>();

            List<P> result = new List<P>();

            result.Add(parser());

            if (isRecovering)
                return result;

            while (Match(separator))
            {
                int lastPosition = position;

                Advance();
                if (!allowTrailingSeparator || !Match(end))
                {
                    result.Add(parser());
                }

                if (isRecovering)
                    return result;

                if (lastPosition == position)
                {
#if DEBUG
                    throw new Exception($"Parser got stuck parsing {Peek()}. Please file a bug report.");
#else
                    return result;
#endif
                }
            }

            return result;
        }

        protected List<P> ParseSeparatedList1<P>(T seperator, Func<P> parser)
        {
            List<P> result = new List<P>();

            result.Add(parser());

            if (isRecovering)
                return result;

            while (Match(seperator))
            {
                int lastPosition = position;

                Eat(seperator);
                result.Add(parser());

                if (isRecovering)
                    return result;

                if (lastPosition == position)
                {
#if DEBUG
                    throw new Exception($"Parser got stuck parsing {Peek()}. Please file a bug report.");
#else
                    return result;
#endif
                }
            }

            return result;
        }

        protected List<P> ParseMany1<P>(T first, Func<P> parser)
        {
            List<P> result = new List<P>();

            result.Add(parser());

            if (isRecovering)
                return result;

            while (Match(first))
            {
                int lastPosition = position;

                result.Add(parser());

                if (isRecovering)
                    return result;

                if (lastPosition == position)
                {
#if DEBUG
                    throw new Exception($"Parser got stuck parsing {Peek()}. Please file a bug report.");
#else
                    return result;
#endif
                }
            }

            return result;
        }

        protected List<P> ParseMany0<P>(T first, Func<P> parser)
        {
            if (!Match(first))
                return new List<P>();

            return ParseMany1(first, parser);
        }

        protected List<P> ParseMany1<P>(Func<bool> first, Func<P> parser)
        {
            List<P> result = new List<P>();

            result.Add(parser());

            if (isRecovering)
                return result;

            while (first())
            {
                int lastPosition = position;

                result.Add(parser());

                if (isRecovering)
                    return result;

                if (lastPosition == position)
                {
#if DEBUG
                    throw new Exception($"Parser got stuck parsing {Peek()}. Please file a bug report.");
#else
                    return result;
#endif
                }
            }

            return result;
        }

        protected List<P> ParseMany0<P>(Func<bool> first, Func<P> parser)
        {
            if (!first())
                return new List<P>();

            return ParseMany1(first, parser);
        }

        protected P ParseOptional<P>(T first, Func<P> parser)
        {
            if (Match(first))
                return parser();
            return default;
        }

        protected P ParseOptional<P>(Func<bool> first, Func<P> parser)
        {
            if (first())
                return parser();
            return default;
        }

        protected void RecoverTo(T sync, bool inclusive = true)
        {
            // If not recovering, nothing to do
            if (!isRecovering)
                return;

            // Otherwise advance until the sync token
            isRecovering = false;
            while (!IsAtEnd() && !Match(sync)) Advance();
            if (inclusive && Match(sync)) Advance();
        }

        protected void RecoverTo(Func<T, bool> predicate, bool inclusive = true)
        {
            // If not recovering, nothing to do
            if (!isRecovering)
                return;

            // Otherwise advance until the sync token
            isRecovering = false;
            while (!IsAtEnd() && !predicate(Peek().Kind)) Advance();
            if (inclusive && predicate(Peek().Kind)) Advance();
        }

        protected void RecoverTo(params T[] syncs)
        {
            // If not recovering, nothing to do
            if (!isRecovering)
                return;

            // Otherwise advance until the sync token
            isRecovering = false;
            while (!IsAtEnd() && !Match(syncs)) Advance();
            if (Match(syncs)) Advance();
        }
        #endregion
    }
}


// Common/BaseSyntaxElements.cs
namespace UnityShaderParser.Common
{
    public enum ParserStage
    {
        HLSLLexing,
        HLSLPreProcessing,
        HLSLParsing,
        ShaderLabLexing,
        ShaderLabParsing,
    }

    public struct SourceLocation
    {
        // For better diagnostics
        public int Line { get; }
        public int Column { get; }

        // For analysis
        public int Index { get; }

        public SourceLocation(int line, int column, int index)
        {
            Line = line;
            Column = column;
            Index = index;
        }

        public override string ToString() => $"({Line}, {Column})";
    }

    [Flags]
    public enum DiagnosticFlags
    {
        None = 0,
        SyntaxError = 1 << 0,       // Ill-formed source code
        SemanticError = 1 << 1,     // Well-formed source code, but incorrect meaning
        PreProcessorError = 1 << 2, // Error during preprocessing
        Warning = 1 << 3,           // Well-formed source code, but probably not what was intended

        OnlyErrors = SyntaxError | SemanticError | PreProcessorError,
        All = OnlyErrors | Warning
    }

    public struct Diagnostic
    {
        public SourceLocation Location => Span.Start;
        public SourceSpan Span { get; }
        public DiagnosticFlags Kind { get; }
        public ParserStage Stage { get; }
        public string Text { get; }

        public Diagnostic(SourceSpan span, DiagnosticFlags kind, ParserStage stage, string text)
        {
            Span = span;
            Kind = kind;
            Stage = stage;
            Text = text;
        }

        public override string ToString()
        {
            return $"Error during {Stage}, file '{Span.FileName}', line {Location.Line}, col {Location.Column}: {Text}";
        }
    }

    public struct SourceSpan
    {
        public string BasePath { get; }
        public string FileName { get; }
        public SourceLocation Start { get; }
        public SourceLocation End { get; }

        public int StartIndex => Start.Index;
        public int EndIndex => End.Index;
        public int Length => EndIndex - StartIndex;

        public SourceSpan(string basePath, string fileName, SourceLocation start, SourceLocation end)
        {
            BasePath = basePath;
            FileName = fileName;
            Start = start;
            End = end;
        }

        public override string ToString() => $"({Start.Line}:{Start.Column} - {End.Line}:{End.Column})";

        public string GetCodeInSourceText(string sourceText) => sourceText.Substring(StartIndex, Length);

        public static SourceSpan FromTokens<T>(IEnumerable<Token<T>> tokens)
            where T : struct
        {
            if (tokens == null || !tokens.Any())
                throw new ArgumentException(nameof(tokens));
            var ordered = tokens.OrderBy(x => x.Span.StartIndex);
            var first = ordered.First();
            var last = ordered.Last();
            return BetweenTokens(first, last);
        }

        public static SourceSpan BetweenTokens<T>(Token<T> first, Token<T> last)
            where T : struct => new SourceSpan(first.Span.BasePath, first.Span.FileName, first.Span.Start, last.Span.End);

        public static SourceSpan Between(SourceSpan first, SourceSpan last)
            => new SourceSpan(first.BasePath, first.FileName, first.Start, last.End);
    }

    public class Token<T>
        where T : struct
    {
        public T Kind { get; private set; }
        public string Identifier { get; private set; }       // Optional
        public SourceSpan Span { get; private set; }         // Location in source code
        public SourceSpan OriginalSpan { get; private set; }
        public int Position { get; private set; }            // Location in token stream

        public Token(T kind, string identifier, SourceSpan span, int position)
        {
            Kind = kind;
            Identifier = identifier;
            Span = span;
            OriginalSpan = span;
            Position = position;
        }

        public Token(T kind, string identifier, SourceSpan span, SourceSpan originalSpan, int position)
        {
            Kind = kind;
            Identifier = identifier;
            Span = span;
            OriginalSpan = originalSpan;
            Position = position;
        }

        // TODO: Trivia
        public override string ToString()
        {
            if (Identifier == null)
                return Kind.ToString() ?? string.Empty;
            else
                return $"{Kind}({Identifier})";
        }

        public string GetCodeInSourceText(string sourceText) => Span.GetCodeInSourceText(sourceText);
    }

    public abstract class SyntaxNode<TSelf>
        where TSelf : SyntaxNode<TSelf>
    {
        // Helpers
        protected static IEnumerable<TSelf> MergeChildren(params IEnumerable<TSelf>[] children)
            => children.SelectMany(x => x);
        protected static IEnumerable<TSelf> OptionalChild(TSelf child)
            => child == null ? Enumerable.Empty<TSelf>() : new[] { child };
        protected static IEnumerable<TSelf> Child(TSelf child)
            => new[] { child };

        [DebuggerBrowsable(DebuggerBrowsableState.Never)]
        protected abstract IEnumerable<TSelf> GetChildren { get; }

        [DebuggerBrowsable(DebuggerBrowsableState.Never)]
        private TSelf parent;
        internal void ComputeParents()
        {
            foreach (var child in GetChildren)
            {
                if (child == null) continue;
                child.parent = (TSelf)this;
                child.ComputeParents();
            }
        }

        // Public API
        public List<TSelf> Children => GetChildren.Where(x => x != null).ToList();
        public TSelf Parent => parent;
        public abstract SourceSpan Span { get; }
        public abstract SourceSpan OriginalSpan { get; }
    }

    public enum PrettyEnumStyle
    {
        AllLowerCase,
        AllUpperCase,
        CamelCase,
        PascalCase,
    }

    public class PrettyEnumAttribute : Attribute
    {
        public PrettyEnumStyle Style { get; set; }
        public PrettyEnumAttribute(PrettyEnumStyle firstIsLowerCase)
        {
            Style = firstIsLowerCase;
        }
    }

    public class PrettyNameAttribute : Attribute
    {
        public string Name { get; set; }

        public PrettyNameAttribute(string name)
        {
            Name = name;
        }
    }

    public static class PrintingUtil
    {
        // Slower type-erased version. Need to duplicate code to avoid another reflection call :(
        public static string GetEnumNameTypeErased(object val)
        {
            string name;
            PrettyEnumAttribute[] enumAttrs = val.GetType().GetCustomAttributes<PrettyEnumAttribute>().ToArray();
            if (enumAttrs == null || enumAttrs.Length == 0)
            {
                name = Enum.GetName(val.GetType(), val);
            }
            else
            {
                MemberInfo[] memberInfo = val.GetType().GetMember(val.ToString());
                if (memberInfo != null && memberInfo.Length > 0)
                {
                    foreach (MemberInfo member in memberInfo)
                    {
                        PrettyNameAttribute[] attrs = member.GetCustomAttributes<PrettyNameAttribute>().ToArray();

                        if (attrs != null && attrs.Length > 0)
                        {
                            //Pull out the description value
                            return attrs[0].Name;
                        }
                    }
                }
                name = Enum.GetName(val.GetType(), val);
            }

            switch (enumAttrs[0].Style)
            {
                case PrettyEnumStyle.AllLowerCase: return name.ToLower();
                case PrettyEnumStyle.AllUpperCase: return name.ToUpper();
                case PrettyEnumStyle.CamelCase:
                    if (name.Length > 0)
                    {
                        name = $"{char.ToLower(name[0])}{name.Substring(1)}";
                    }
                    return name;
                default:
                    return name;
            }
        }

        public static string GetEnumName<T>(T val)
            where T : Enum
        {
            string name;
            PrettyEnumAttribute[] enumAttrs = typeof(T).GetCustomAttributes<PrettyEnumAttribute>().ToArray();
            if (enumAttrs == null || enumAttrs.Length == 0)
            {
                name = Enum.GetName(typeof(T), val);
            }
            else
            {
                MemberInfo[] memberInfo = typeof(T).GetMember(val.ToString());
                if (memberInfo != null && memberInfo.Length > 0)
                {
                    foreach (MemberInfo member in memberInfo)
                    {
                        PrettyNameAttribute[] attrs = member.GetCustomAttributes<PrettyNameAttribute>().ToArray();

                        if (attrs != null && attrs.Length > 0)
                        {
                            //Pull out the description value
                            return attrs[0].Name;
                        }
                    }
                }
                name = Enum.GetName(typeof(T), val);
            }

            switch (enumAttrs[0].Style)
            {
                case PrettyEnumStyle.AllLowerCase: return name.ToLower();
                case PrettyEnumStyle.AllUpperCase: return name.ToUpper();
                case PrettyEnumStyle.CamelCase:
                    if (name.Length > 0)
                    {
                        name = $"{char.ToLower(name[0])}{name.Substring(1)}";
                    }
                    return name;
                default:
                    return name;
            }
        }

        // TODO: Edits across macro boundaries
        public static string ApplyEditsToSourceText(IEnumerable<(SourceSpan span, string newText)> edits, string source)
        {
            var orderedEdits = edits.OrderBy(x => x.span.Start.Index);
            var editedSourced = new StringBuilder(source);
            int offset = 0;
            foreach ((SourceSpan span, string newText) in orderedEdits)
            {
                editedSourced.Remove(span.Start.Index + offset, span.Length);
                editedSourced.Insert(span.Start.Index + offset, newText);
                offset -= span.Length;
                offset += newText.Length;
            }
            return editedSourced.ToString();
        }
    }
}


// Common/ShaderParser.cs
namespace UnityShaderParser.Common
{
    public static class ShaderParser
    {
        private static HLSLParserConfig DefaultHLSLConfig = new HLSLParserConfig();
        private static ShaderLabParserConfig DefaultShaderLabConfig = new ShaderLabParserConfig();

        public static ShaderNode ParseUnityShader(string source, ShaderLabParserConfig config, out List<Diagnostic> diagnostics)
        {
            var tokens = ShaderLabLexer.Lex(source, config.BasePath, config.FileName, config.ThrowExceptionOnError, out var lexerDiags);
            var rootNode = ShaderLabParser.ParseShader(tokens, config, out var parserDiags);
            diagnostics = lexerDiags.Concat(parserDiags).ToList();
            return rootNode;
        }
        public static ShaderNode ParseUnityShader(string source, ShaderLabParserConfig config) => ParseUnityShader(source, config, out _);
        public static ShaderNode ParseUnityShader(string source, out List<Diagnostic> diagnostics) => ParseUnityShader(source, DefaultShaderLabConfig, out diagnostics);
        public static ShaderNode ParseUnityShader(string source) => ParseUnityShader(source, DefaultShaderLabConfig, out _);

        public static List<HLSLSyntaxNode> ParseTopLevelDeclarations(string source, HLSLParserConfig config, out List<Diagnostic> diagnostics, out List<string> pragmas)
        {
            var tokens = HLSLLexer.Lex(source, config.BasePath, config.FileName, config.ThrowExceptionOnError, out var lexerDiags);
            var decls = HLSLParser.ParseTopLevelDeclarations(tokens, config, out var parserDiags, out pragmas);
            diagnostics = lexerDiags.Concat(parserDiags).ToList();
            return decls;
        }
        public static List<HLSLSyntaxNode> ParseTopLevelDeclarations(string source, HLSLParserConfig config) => ParseTopLevelDeclarations(source, config, out _, out _);
        public static List<HLSLSyntaxNode> ParseTopLevelDeclarations(string source, out List<Diagnostic> diagnostics, out List<string> pragmas) => ParseTopLevelDeclarations(source, DefaultHLSLConfig, out diagnostics, out pragmas);
        public static List<HLSLSyntaxNode> ParseTopLevelDeclarations(string source) => ParseTopLevelDeclarations(source, DefaultHLSLConfig, out _, out _);

        public static HLSLSyntaxNode ParseTopLevelDeclaration(string source, HLSLParserConfig config, out List<Diagnostic> diagnostics, out List<string> pragmas)
        {
            var tokens = HLSLLexer.Lex(source, config.BasePath, config.FileName, config.ThrowExceptionOnError, out var lexerDiags);
            var decl = HLSLParser.ParseTopLevelDeclaration(tokens, config, out var parserDiags, out pragmas);
            diagnostics = lexerDiags.Concat(parserDiags).ToList();
            return decl;
        }
        public static HLSLSyntaxNode ParseTopLevelDeclaration(string source, HLSLParserConfig config) => ParseTopLevelDeclaration(source, config, out _, out _);
        public static HLSLSyntaxNode ParseTopLevelDeclaration(string source, out List<Diagnostic> diagnostics, out List<string> pragmas) => ParseTopLevelDeclaration(source, DefaultHLSLConfig, out diagnostics, out pragmas);
        public static HLSLSyntaxNode ParseTopLevelDeclaration(string source) => ParseTopLevelDeclaration(source, DefaultHLSLConfig, out _, out _);

        public static List<StatementNode> ParseStatements(string source, HLSLParserConfig config, out List<Diagnostic> diagnostics, out List<string> pragmas)
        {
            var tokens = HLSLLexer.Lex(source, config.BasePath, config.FileName, config.ThrowExceptionOnError, out var lexerDiags);
            var stmt = HLSLParser.ParseStatements(tokens, config, out var parserDiags, out pragmas);
            diagnostics = lexerDiags.Concat(parserDiags).ToList();
            return stmt;
        }
        public static List<StatementNode> ParseStatements(string source, HLSLParserConfig config) => ParseStatements(source, config, out _, out _);
        public static List<StatementNode> ParseStatements(string source, out List<Diagnostic> diagnostics, out List<string> pragmas) => ParseStatements(source, DefaultHLSLConfig, out diagnostics, out pragmas);
        public static List<StatementNode> ParseStatements(string source) => ParseStatements(source, DefaultHLSLConfig, out _, out _);

        public static StatementNode ParseStatement(string source, HLSLParserConfig config, out List<Diagnostic> diagnostics, out List<string> pragmas)
        {
            var tokens = HLSLLexer.Lex(source, config.BasePath, config.FileName, config.ThrowExceptionOnError, out var lexerDiags);
            var stmt = HLSLParser.ParseStatement(tokens, config, out var parserDiags, out pragmas);
            diagnostics = lexerDiags.Concat(parserDiags).ToList();
            return stmt;
        }
        public static StatementNode ParseStatement(string source, HLSLParserConfig config) => ParseStatement(source, config, out _, out _);
        public static StatementNode ParseStatement(string source, out List<Diagnostic> diagnostics, out List<string> pragmas) => ParseStatement(source, DefaultHLSLConfig, out diagnostics, out pragmas);
        public static StatementNode ParseStatement(string source) => ParseStatement(source, DefaultHLSLConfig, out _, out _);

        public static ExpressionNode ParseExpression(string source, HLSLParserConfig config, out List<Diagnostic> diagnostics, out List<string> pragmas)
        {
            var tokens = HLSLLexer.Lex(source, config.BasePath, config.FileName, config.ThrowExceptionOnError, out var lexerDiags);
            var expr = HLSLParser.ParseExpression(tokens, config, out var parserDiags, out pragmas);
            diagnostics = lexerDiags.Concat(parserDiags).ToList();
            return expr;
        }
        public static ExpressionNode ParseExpression(string source, HLSLParserConfig config) => ParseExpression(source, config, out _, out _);
        public static ExpressionNode ParseExpression(string source, out List<Diagnostic> diagnostics, out List<string> pragmas) => ParseExpression(source, DefaultHLSLConfig, out diagnostics, out pragmas);
        public static ExpressionNode ParseExpression(string source) => ParseExpression(source, DefaultHLSLConfig, out _, out _);

        public static SubShaderNode ParseUnitySubShader(string source, ShaderLabParserConfig config, out List<Diagnostic> diagnostics)
        {
            var tokens = ShaderLabLexer.Lex(source, config.BasePath, config.FileName, config.ThrowExceptionOnError, out var lexerDiags);
            var rootNode = ShaderLabParser.ParseSubShader(tokens, config, out var parserDiags);
            diagnostics = lexerDiags.Concat(parserDiags).ToList();
            return rootNode;
        }
        public static SubShaderNode ParseUnitySubShader(string source, ShaderLabParserConfig config) => ParseUnitySubShader(source, config, out _);
        public static SubShaderNode ParseUnitySubShader(string source, out List<Diagnostic> diagnostics) => ParseUnitySubShader(source, DefaultShaderLabConfig, out diagnostics);
        public static SubShaderNode ParseUnitySubShader(string source) => ParseUnitySubShader(source, DefaultShaderLabConfig, out _);

        public static ShaderPassNode ParseUnityShaderPass(string source, ShaderLabParserConfig config, out List<Diagnostic> diagnostics)
        {
            var tokens = ShaderLabLexer.Lex(source, config.BasePath, config.FileName, config.ThrowExceptionOnError, out var lexerDiags);
            var rootNode = ShaderLabParser.ParseShaderPass(tokens, config, out var parserDiags);
            diagnostics = lexerDiags.Concat(parserDiags).ToList();
            return rootNode;
        }
        public static ShaderPassNode ParseUnityShaderPass(string source, ShaderLabParserConfig config) => ParseUnityShaderPass(source, config, out _);
        public static ShaderPassNode ParseUnityShaderPass(string source, out List<Diagnostic> diagnostics) => ParseUnityShaderPass(source, DefaultShaderLabConfig, out diagnostics);
        public static ShaderPassNode ParseUnityShaderPass(string source) => ParseUnityShaderPass(source, DefaultShaderLabConfig, out _);

        public static ShaderPropertyNode ParseUnityShaderProperty(string source, ShaderLabParserConfig config, out List<Diagnostic> diagnostics)
        {
            var tokens = ShaderLabLexer.Lex(source, config.BasePath, config.FileName, config.ThrowExceptionOnError, out var lexerDiags);
            var rootNode = ShaderLabParser.ParseShaderProperty(tokens, config, out var parserDiags);
            diagnostics = lexerDiags.Concat(parserDiags).ToList();
            return rootNode;
        }
        public static ShaderPropertyNode ParseUnityShaderProperty(string source, ShaderLabParserConfig config) => ParseUnityShaderProperty(source, config, out _);
        public static ShaderPropertyNode ParseUnityShaderProperty(string source, out List<Diagnostic> diagnostics) => ParseUnityShaderProperty(source, DefaultShaderLabConfig, out diagnostics);
        public static ShaderPropertyNode ParseUnityShaderProperty(string source) => ParseUnityShaderProperty(source, DefaultShaderLabConfig, out _);

        public static List<ShaderPropertyNode> ParseUnityShaderProperties(string source, ShaderLabParserConfig config, out List<Diagnostic> diagnostics)
        {
            var tokens = ShaderLabLexer.Lex(source, config.BasePath, config.FileName, config.ThrowExceptionOnError, out var lexerDiags);
            var rootNode = ShaderLabParser.ParseShaderProperties(tokens, config, out var parserDiags);
            diagnostics = lexerDiags.Concat(parserDiags).ToList();
            return rootNode;
        }
        public static List<ShaderPropertyNode> ParseUnityShaderProperties(string source, ShaderLabParserConfig config) => ParseUnityShaderProperties(source, config, out _);
        public static List<ShaderPropertyNode> ParseUnityShaderProperties(string source, out List<Diagnostic> diagnostics) => ParseUnityShaderProperties(source, DefaultShaderLabConfig, out diagnostics);
        public static List<ShaderPropertyNode> ParseUnityShaderProperties(string source) => ParseUnityShaderProperties(source, DefaultShaderLabConfig, out _);

        public static List<ShaderPropertyNode> ParseUnityShaderPropertyBlock(string source, ShaderLabParserConfig config, out List<Diagnostic> diagnostics)
        {
            var tokens = ShaderLabLexer.Lex(source, config.BasePath, config.FileName, config.ThrowExceptionOnError, out var lexerDiags);
            var rootNode = ShaderLabParser.ParseShaderPropertyBlock(tokens, config, out var parserDiags);
            diagnostics = lexerDiags.Concat(parserDiags).ToList();
            return rootNode;
        }
        public static List<ShaderPropertyNode> ParseUnityShaderPropertyBlock(string source, ShaderLabParserConfig config) => ParseUnityShaderPropertyBlock(source, config, out _);
        public static List<ShaderPropertyNode> ParseUnityShaderPropertyBlock(string source, out List<Diagnostic> diagnostics) => ParseUnityShaderPropertyBlock(source, DefaultShaderLabConfig, out diagnostics);
        public static List<ShaderPropertyNode> ParseUnityShaderPropertyBlock(string source) => ParseUnityShaderPropertyBlock(source, DefaultShaderLabConfig, out _);

        public static ShaderLabCommandNode ParseUnityShaderCommand(string source, ShaderLabParserConfig config, out List<Diagnostic> diagnostics)
        {
            var tokens = ShaderLabLexer.Lex(source, config.BasePath, config.FileName, config.ThrowExceptionOnError, out var lexerDiags);
            var rootNode = ShaderLabParser.ParseShaderLabCommand(tokens, config, out var parserDiags);
            diagnostics = lexerDiags.Concat(parserDiags).ToList();
            return rootNode;
        }
        public static ShaderLabCommandNode ParseUnityShaderCommand(string source, ShaderLabParserConfig config) => ParseUnityShaderCommand(source, config, out _);
        public static ShaderLabCommandNode ParseUnityShaderCommand(string source, out List<Diagnostic> diagnostics) => ParseUnityShaderCommand(source, DefaultShaderLabConfig, out diagnostics);
        public static ShaderLabCommandNode ParseUnityShaderCommand(string source) => ParseUnityShaderCommand(source, DefaultShaderLabConfig, out _);

        public static List<ShaderLabCommandNode> ParseUnityShaderCommands(string source, ShaderLabParserConfig config, out List<Diagnostic> diagnostics)
        {
            var tokens = ShaderLabLexer.Lex(source, config.BasePath, config.FileName, config.ThrowExceptionOnError, out var lexerDiags);
            var rootNode = ShaderLabParser.ParseShaderLabCommands(tokens, config, out var parserDiags);
            diagnostics = lexerDiags.Concat(parserDiags).ToList();
            return rootNode;
        }
        public static List<ShaderLabCommandNode> ParseUnityShaderCommands(string source, ShaderLabParserConfig config) => ParseUnityShaderCommands(source, config, out _);
        public static List<ShaderLabCommandNode> ParseUnityShaderCommands(string source, out List<Diagnostic> diagnostics) => ParseUnityShaderCommands(source, DefaultShaderLabConfig, out diagnostics);
        public static List<ShaderLabCommandNode> ParseUnityShaderCommands(string source) => ParseUnityShaderCommands(source, DefaultShaderLabConfig, out _);

        public static List<Token<HLSL.TokenKind>> PreProcessToTokens(string source, HLSLParserConfig config, out List<Diagnostic> diagnostics, out List<string> pragmas)
        {
            var tokens = HLSLLexer.Lex(source, config.BasePath, config.FileName, config.ThrowExceptionOnError, out var lexerDiags);
            var ppTokens = HLSLPreProcessor.PreProcess(
                tokens,
                config.ThrowExceptionOnError,
                config.DiagnosticFilter,
                config.PreProcessorMode,
                config.BasePath,
                config.IncludeResolver,
                config.Defines,
                out pragmas,
                out var ppDiags);
            diagnostics = lexerDiags.Concat(ppDiags).ToList();
            return ppTokens;
        }
        public static List<Token<HLSL.TokenKind>> PreProcessToTokens(string source, HLSLParserConfig config) => PreProcessToTokens(source, config, out _, out _);
        public static List<Token<HLSL.TokenKind>> PreProcessToTokens(string source, out List<Diagnostic> diagnostics, out List<string> pragmas) => PreProcessToTokens(source, DefaultHLSLConfig, out diagnostics, out pragmas);
        public static List<Token<HLSL.TokenKind>> PreProcessToTokens(string source) => PreProcessToTokens(source, DefaultHLSLConfig, out _, out _);

        public static string PreProcessToString(string source, HLSLParserConfig config, out List<Diagnostic> diagnostics, out List<string> pragmas)
        {
            return HLSLSyntaxFacts.TokensToString(PreProcessToTokens(source, config, out diagnostics, out pragmas));
        }
        public static string PreProcessToString(string source, HLSLParserConfig config) => PreProcessToString(source, config, out _, out _);
        public static string PreProcessToString(string source, out List<Diagnostic> diagnostics, out List<string> pragmas) => PreProcessToString(source, DefaultHLSLConfig, out diagnostics, out pragmas);
        public static string PreProcessToString(string source) => PreProcessToString(source, DefaultHLSLConfig, out _, out _);
    }
}


// ShaderLab/ShaderLabEditor.cs
namespace UnityShaderParser.ShaderLab
{
    public abstract class ShaderLabEditor : ShaderLabSyntaxVisitor
    {
        public string Source { get; private set; }
        public List<Token<TokenKind>> Tokens { get; private set; }

        public ShaderLabEditor(string source, List<Token<TokenKind>> tokens)
        {
            Source = source;
            Tokens = tokens;
        }

        protected HashSet<(SourceSpan span, string newText)> Edits = new HashSet<(SourceSpan, string)>();

        protected void Edit(SourceSpan span, string newText) => Edits.Add((span, newText));
        protected void Edit(Token<TokenKind> token, string newText) => Edit(token.Span, newText);
        protected void Edit(ShaderLabSyntaxNode node, string newText) => Edit(node.Span, newText);
        protected void AddBefore(SourceSpan span, string newText) => Edit(new SourceSpan(span.BasePath, span.FileName, span.Start, span.Start), newText);
        protected void AddBefore(Token<TokenKind> token, string newText) => Edit(new SourceSpan(token.Span.BasePath, token.Span.FileName, token.Span.Start, token.Span.Start), newText);
        protected void AddBefore(ShaderLabSyntaxNode node, string newText) => Edit(new SourceSpan(node.Span.BasePath, node.Span.FileName, node.Span.Start, node.Span.Start), newText);
        protected void AddAfter(SourceSpan span, string newText) => Edit(new SourceSpan(span.BasePath, span.FileName, span.End, span.End), newText);
        protected void AddAfter(Token<TokenKind> token, string newText) => Edit(new SourceSpan(token.Span.BasePath, token.Span.FileName, token.Span.End, token.Span.End), newText);
        protected void AddAfter(ShaderLabSyntaxNode node, string newText) => Edit(new SourceSpan(node.Span.BasePath, node.Span.FileName, node.Span.End, node.Span.End), newText);

        public string ApplyCurrentEdits() => PrintingUtil.ApplyEditsToSourceText(Edits, Source);

        public string ApplyEdits(ShaderLabSyntaxNode node)
        {
            Visit(node);
            return ApplyCurrentEdits();
        }

        public string ApplyEdits(IEnumerable<ShaderLabSyntaxNode> nodes)
        {
            VisitMany(nodes);
            return ApplyCurrentEdits();
        }

        public static string RunEditor<T>(string source, ShaderLabSyntaxNode node)
            where T : ShaderLabEditor
        {
            var editor = (ShaderLabEditor)Activator.CreateInstance(typeof(T), source, node.Tokens);
            return editor.ApplyEdits(node);
        }

        public static string RunEditor<T>(string source, IEnumerable<ShaderLabSyntaxNode> node)
            where T : ShaderLabEditor
        {
            var editor = (ShaderLabEditor)Activator.CreateInstance(typeof(T), source, node.SelectMany(x => x.Tokens).ToList());
            return editor.ApplyEdits(node);
        }
    }
}


// ShaderLab/ShaderLabLexer.cs
namespace UnityShaderParser.ShaderLab
{
    using SLToken = Token<TokenKind>;

    public class ShaderLabLexer : BaseLexer<TokenKind>
    {
        protected override ParserStage Stage => ParserStage.ShaderLabLexing;

        public ShaderLabLexer(string source, string basePath, string fileName, bool throwExceptionOnError)
            : base(source, basePath, fileName, throwExceptionOnError, new SourceLocation(1, 1, 0)) { }

        public static List<SLToken> Lex(string source, string basePath, string fileName, bool throwExceptionOnError, out List<Diagnostic> diagnostics)
        {
            ShaderLabLexer lexer = new ShaderLabLexer(source, basePath, fileName, throwExceptionOnError);

            lexer.Lex();

            diagnostics = lexer.diagnostics;
            return lexer.tokens;
        }

        protected override void ProcessChar(char nextChar)
        {
            switch (nextChar)
            {
                case char c when char.IsLetter(c) || c == '_':
                    LexIdentifier();
                    break;

                case '2' when LookAhead('D') || LookAhead('d'):
                case '3' when LookAhead('D') || LookAhead('d'):
                    LexDimensionalTextureType();
                    break;

                case char c when char.IsDigit(c) || ((c == '.' || c == '-') && char.IsDigit(LookAhead())):
                    string num = EatNumber(out bool isFloat);
                    TokenKind kind = isFloat ? TokenKind.FloatLiteralToken : TokenKind.IntegerLiteralToken;
                    Add(num, kind);
                    break;

                case '"':
                    Add(EatStringLiteral('"', '"'), TokenKind.StringLiteralToken);
                    break;

                case '[' when IsAlphaNumericOrUnderscore(LookAhead()):
                    Add(EatStringLiteral('[', ']'), TokenKind.BracketedStringLiteralToken);
                    break;

                case ' ':
                case '\t':
                case '\r':
                case '\n':
                    Advance();
                    break;

                case '/' when LookAhead('/'):
                    Advance(2);
                    while (!Match('\n'))
                    {
                        Advance();
                        if (IsAtEnd())
                            break;
                    }
                    break;

                case '/' when LookAhead('*'):
                    Advance(2);
                    while (!(Match('*') && LookAhead('/')))
                    {
                        Advance();
                        if (IsAtEnd())
                        {
                            Error(DiagnosticFlags.SyntaxError, $"Unterminated comment.");
                            break;
                        }
                    }
                    Advance(2);
                    break;

                case '(': Advance(); Add(TokenKind.OpenParenToken); break;
                case ')': Advance(); Add(TokenKind.CloseParenToken); break;
                case '[': Advance(); Add(TokenKind.OpenBracketToken); break;
                case ']': Advance(); Add(TokenKind.CloseBracketToken); break;
                case '{': Advance(); Add(TokenKind.OpenBraceToken); break;
                case '}': Advance(); Add(TokenKind.CloseBraceToken); break;
                case ';': Advance(); Add(TokenKind.SemiToken); break;
                case ',': Advance(); Add(TokenKind.CommaToken); break;
                case '.': Advance(); Add(TokenKind.DotToken); break;
                case '~': Advance(); Add(TokenKind.TildeToken); break;
                case '?': Advance(); Add(TokenKind.QuestionToken); break;

                case '<' when LookAhead('='): Advance(2); Add(TokenKind.LessThanEqualsToken); break;
                case '<' when LookAhead('<') && LookAhead('=', 2): Advance(3); Add(TokenKind.LessThanLessThanEqualsToken); break;
                case '<' when LookAhead('<'): Advance(2); Add(TokenKind.LessThanLessThanToken); break;
                case '<': Advance(); Add(TokenKind.LessThanToken); break;

                case '>' when LookAhead('='): Advance(2); Add(TokenKind.GreaterThanEqualsToken); break;
                case '>' when LookAhead('>') && LookAhead('=', 2): Advance(3); Add(TokenKind.GreaterThanGreaterThanEqualsToken); break;
                case '>' when LookAhead('>'): Advance(2); Add(TokenKind.GreaterThanGreaterThanToken); break;
                case '>': Advance(); Add(TokenKind.GreaterThanToken); break;

                case '+' when LookAhead('+'): Advance(2); Add(TokenKind.PlusPlusToken); break;
                case '+' when LookAhead('='): Advance(2); Add(TokenKind.PlusEqualsToken); break;
                case '+': Advance(); Add(TokenKind.PlusToken); break;

                case '-' when LookAhead('-'): Advance(2); Add(TokenKind.MinusMinusToken); break;
                case '-' when LookAhead('='): Advance(2); Add(TokenKind.MinusEqualsToken); break;
                case '-': Advance(); Add(TokenKind.MinusToken); break;

                case '*' when LookAhead('='): Advance(2); Add(TokenKind.AsteriskEqualsToken); break;
                case '*': Advance(); Add(TokenKind.AsteriskToken); break;

                case '/' when LookAhead('='): Advance(2); Add(TokenKind.SlashEqualsToken); break;
                case '/': Advance(); Add(TokenKind.SlashToken); break;

                case '%' when LookAhead('='): Advance(2); Add(TokenKind.PercentEqualsToken); break;
                case '%': Advance(); Add(TokenKind.PercentToken); break;

                case '&' when LookAhead('&'): Advance(2); Add(TokenKind.AmpersandAmpersandToken); break;
                case '&' when LookAhead('='): Advance(2); Add(TokenKind.AmpersandEqualsToken); break;
                case '&': Advance(); Add(TokenKind.AmpersandToken); break;

                case '|' when LookAhead('|'): Advance(2); Add(TokenKind.BarBarToken); break;
                case '|' when LookAhead('='): Advance(2); Add(TokenKind.BarEqualsToken); break;
                case '|': Advance(); Add(TokenKind.BarToken); break;

                case '^' when LookAhead('='): Advance(2); Add(TokenKind.CaretEqualsToken); break;
                case '^': Advance(); Add(TokenKind.CaretToken); break;

                case ':' when LookAhead(':'): Advance(2); Add(TokenKind.ColonColonToken); break;
                case ':': Advance(); Add(TokenKind.ColonToken); break;

                case '=' when LookAhead('='): Advance(2); Add(TokenKind.EqualsEqualsToken); break;
                case '=': Advance(); Add(TokenKind.EqualsToken); break;

                case '!' when LookAhead('='): Advance(2); Add(TokenKind.ExclamationEqualsToken); break;
                case '!': Advance(); Add(TokenKind.NotToken); break;

                case char c:
                    Advance();
                    Error(DiagnosticFlags.SyntaxError, $"Unexpected token '{c}'.");
                    break;
            }
        }

        private string SkipProgramBody(string expectedEnd)
        {
            StringBuilder builder = new StringBuilder();
            while (true)
            {
                // If there is still space for the terminator
                if (!IsAtEnd(expectedEnd.Length))
                {
                    // And we have reached the terminator, stop
                    if (source.Substring(position, expectedEnd.Length) == expectedEnd)
                    {
                        Advance(expectedEnd.Length);
                        break;
                    }

                    // Otherwise advance
                    builder.Append(Advance());
                }
                // No space for terminator, error
                else
                {
                    Error(DiagnosticFlags.SyntaxError, $"Unterminated program block.");
                    break;
                }
            }

            return builder.ToString();
        }

        private void LexDimensionalTextureType()
        {
            StringBuilder builder = new StringBuilder();
            builder.Append(Advance());
            while (char.IsLetter(Peek()))
            {
                builder.Append(Advance());
            }

            switch (builder.ToString().ToLower())
            {
                case "2darray": Add(TokenKind._2DArrayKeyword); break;
                case "3darray": Add(TokenKind._3DArrayKeyword); break;
                case "2d": Add(TokenKind._2DKeyword); break;
                case "3d": Add(TokenKind._3DKeyword); break;
            }
        }

        private void LexIdentifier()
        {
            string identifier = EatIdentifier();
            if (ShaderLabSyntaxFacts.TryParseShaderLabKeyword(identifier, out TokenKind token))
            {
                if (token == TokenKind.CgProgramKeyword)
                {
                    string body = SkipProgramBody("ENDCG");
                    Add(body, TokenKind.CgProgramBlock);
                }
                else if (token == TokenKind.CgIncludeKeyword)
                {
                    string body = SkipProgramBody("ENDCG");
                    Add(body, TokenKind.CgIncludeBlock);
                }
                else if (token == TokenKind.HlslProgramKeyword)
                {
                    string body = SkipProgramBody("ENDHLSL");
                    Add(body, TokenKind.HlslProgramBlock);
                }
                else if (token == TokenKind.HlslIncludeKeyword)
                {
                    string body = SkipProgramBody("ENDHLSL");
                    Add(body, TokenKind.HlslIncludeBlock);
                }
                else if (token == TokenKind.GlslProgramKeyword)
                {
                    string body = SkipProgramBody("ENDGLSL");
                    Add(body, TokenKind.GlslProgramBlock);
                }
                else if (token == TokenKind.GlslIncludeKeyword)
                {
                    string body = SkipProgramBody("ENDGLSL");
                    Add(body, TokenKind.GlslIncludeBlock);
                }
                else
                {
                    Add(token);
                }
            }
            else
            {
                Add(identifier, TokenKind.IdentifierToken);
            }
        }
    }
}


// ShaderLab/ShaderLabParser.cs
namespace UnityShaderParser.ShaderLab
{
    using SLToken = Token<TokenKind>;
    using HLSLToken = Token<HLSL.TokenKind>;

    public class ShaderLabParserConfig : HLSLParserConfig
    {
        public bool ParseEmbeddedHLSL { get; set; }

        public ShaderLabParserConfig()
            : base()
        {
            ParseEmbeddedHLSL = true;
        }

        public ShaderLabParserConfig(ShaderLabParserConfig config)
            : base(config)
        {
            ParseEmbeddedHLSL = config.ParseEmbeddedHLSL;
        }
    }

    public class ShaderLabParser : BaseParser<TokenKind>
    {
        public ShaderLabParser(List<SLToken> tokens, ShaderLabParserConfig config)
            : base(tokens, config.ThrowExceptionOnError, config.DiagnosticFilter)
        {
            this.config = config;
        }

        protected override TokenKind StringLiteralTokenKind => TokenKind.StringLiteralToken;
        protected override TokenKind IntegerLiteralTokenKind => TokenKind.IntegerLiteralToken;
        protected override TokenKind FloatLiteralTokenKind => TokenKind.FloatLiteralToken;
        protected override TokenKind IdentifierTokenKind => TokenKind.IdentifierToken;
        protected override TokenKind InvalidTokenKind => TokenKind.InvalidToken;
        protected override ParserStage Stage => ParserStage.ShaderLabParsing;

        // Tokens that we may be able to recover to after encountered an error in a command.
        private static readonly HashSet<TokenKind> commandSyncTokens = new HashSet<TokenKind>()
        {
            TokenKind.TagsKeyword, TokenKind.LodKeyword, TokenKind.LightingKeyword, TokenKind.SeparateSpecularKeyword,
            TokenKind.ZWriteKeyword,TokenKind.AlphaToMaskKeyword, TokenKind.ZClipKeyword, TokenKind.ConservativeKeyword,
            TokenKind.CullKeyword, TokenKind.ZTestKeyword, TokenKind.BlendKeyword, TokenKind.OffsetKeyword, TokenKind.ColorMaskKeyword,
            TokenKind.AlphaTestKeyword, TokenKind.FogKeyword, TokenKind.NameKeyword, TokenKind.BindChannelsKeyword, TokenKind.ColorKeyword,
            TokenKind.BlendOpKeyword,TokenKind.MaterialKeyword, TokenKind.SetTextureKeyword, TokenKind.ColorMaterialKeyword, TokenKind.StencilKeyword,
            TokenKind.SubShaderKeyword, TokenKind.ShaderKeyword, TokenKind.PassKeyword, TokenKind.CategoryKeyword, TokenKind.GrabPassKeyword,
            TokenKind.UsePassKeyword, TokenKind.FallbackKeyword, TokenKind.CustomEditorKeyword,
        };

        protected ShaderLabParserConfig config = default;
        protected Stack<List<HLSLIncludeBlock>> currentIncludeBlocks = new Stack<List<HLSLIncludeBlock>>();

        public static ShaderNode Parse(List<SLToken> tokens, ShaderLabParserConfig config, out List<Diagnostic> diagnostics)
        {
            ShaderLabParser parser = new ShaderLabParser(tokens, config);
            var result = parser.ParseShader();
            result.ComputeParents();
            diagnostics = parser.diagnostics;
            return result;
        }

        public static ShaderNode ParseShader(List<SLToken> tokens, ShaderLabParserConfig config, out List<Diagnostic> diagnostics)
        {
            return Parse(tokens, config, out diagnostics);
        }

        public static SubShaderNode ParseSubShader(List<SLToken> tokens, ShaderLabParserConfig config, out List<Diagnostic> diagnostics)
        {
            ShaderLabParser parser = new ShaderLabParser(tokens, config);
            var result = parser.ParseSubShader();
            result.ComputeParents();
            diagnostics = parser.diagnostics;
            return result;
        }

        public static ShaderPassNode ParseShaderPass(List<SLToken> tokens, ShaderLabParserConfig config, out List<Diagnostic> diagnostics)
        {
            ShaderLabParser parser = new ShaderLabParser(tokens, config);
            ShaderPassNode result = null;
            switch (parser.Peek().Kind)
            {
                case TokenKind.PassKeyword: result = parser.ParseCodePass(); break;
                case TokenKind.GrabPassKeyword: result = parser.ParseGrabPass(); break;
                case TokenKind.UsePassKeyword: result = parser.ParseUsePass(); break;
            }
            result.ComputeParents();
            diagnostics = parser.diagnostics;
            return result;
        }

        public static ShaderPropertyNode ParseShaderProperty(List<SLToken> tokens, ShaderLabParserConfig config, out List<Diagnostic> diagnostics)
        {
            ShaderLabParser parser = new ShaderLabParser(tokens, config);
            var result = parser.ParseProperty();
            result.ComputeParents();
            diagnostics = parser.diagnostics;
            return result;
        }

        public static List<ShaderPropertyNode> ParseShaderProperties(List<SLToken> tokens, ShaderLabParserConfig config, out List<Diagnostic> diagnostics)
        {
            ShaderLabParser parser = new ShaderLabParser(tokens, config);
            List<ShaderPropertyNode> result = new List<ShaderPropertyNode>();
            while (parser.Match(TokenKind.IdentifierToken, TokenKind.BracketedStringLiteralToken))
            {
                result.Add(parser.ParseProperty());
            }
            foreach (var property in result)
            {
                property.ComputeParents();
            }
            diagnostics = parser.diagnostics;
            return result;
        }

        public static List<ShaderPropertyNode> ParseShaderPropertyBlock(List<SLToken> tokens, ShaderLabParserConfig config, out List<Diagnostic> diagnostics)
        {
            ShaderLabParser parser = new ShaderLabParser(tokens, config);
            List<ShaderPropertyNode> result = new List<ShaderPropertyNode>();
            parser.ParsePropertySection(result);
            foreach (var property in result)
            {
                property.ComputeParents();
            }
            diagnostics = parser.diagnostics;
            return result;
        }

        public static ShaderLabCommandNode ParseShaderLabCommand(List<SLToken> tokens, ShaderLabParserConfig config, out List<Diagnostic> diagnostics)
        {
            ShaderLabParser parser = new ShaderLabParser(tokens, config);
            parser.TryParseCommand(out var result);
            result.ComputeParents();
            diagnostics = parser.diagnostics;
            return result;
        }

        public static List<ShaderLabCommandNode> ParseShaderLabCommands(List<SLToken> tokens, ShaderLabParserConfig config, out List<Diagnostic> diagnostics)
        {
            ShaderLabParser parser = new ShaderLabParser(tokens, config);
            List<ShaderLabCommandNode> result = new List<ShaderLabCommandNode>();
            parser.ParseCommandsIfPresent(result);
            foreach (var property in result)
            {
                property.ComputeParents();
            }
            diagnostics = parser.diagnostics;
            return result;
        }

        protected void ProcessCurrentIncludes(
            SLToken programToken,
            bool lexEmbeddedHLSL,
            out string fullCode,
            out List<HLSLToken> tokenStream)
        {
            tokenStream = new List<HLSLToken>();
            StringBuilder sb = new StringBuilder();
            for (int i = 0; i < currentIncludeBlocks.Count; i++)
            {
                var includeBlockList = currentIncludeBlocks.ElementAt(currentIncludeBlocks.Count - 1 - i);
                foreach (var includeBlock in includeBlockList)
                {
                    if (lexEmbeddedHLSL)
                    {
                        tokenStream.AddRange(HLSLLexer.Lex(includeBlock.Code, config.BasePath, config.FileName, config.ThrowExceptionOnError, includeBlock.Span.Start, out var includeLexerDiags));
                        diagnostics.AddRange(includeLexerDiags);
                    }
                    sb.Append(includeBlock.Code);
                }
            }
            if (lexEmbeddedHLSL)
            {
                tokenStream.AddRange(HLSLLexer.Lex(programToken.Identifier, config.BasePath, config.FileName, config.ThrowExceptionOnError, programToken.Span.Start, out var lexerDiags));
                diagnostics.AddRange(lexerDiags);
            }
            sb.Append(programToken.Identifier);
            fullCode = sb.ToString();
        }
        protected HLSLProgramBlock ParseOrSkipEmbeddedHLSL()
        {
            var programToken = Eat(TokenKind.CgProgramBlock, TokenKind.HlslProgramBlock, TokenKind.GlslProgramBlock);
            ProgramKind kind = ProgramKind.Cg;
            if (programToken.Kind == TokenKind.HlslProgramBlock)
                kind = ProgramKind.Hlsl;
            else if (programToken.Kind == TokenKind.GlslProgramBlock)
                kind = ProgramKind.Glsl;

            string program = programToken.Identifier;
            
            // Prepend include blocks
            ProcessCurrentIncludes(
                programToken,
                config.ParseEmbeddedHLSL,
                out string fullCode,
                out var tokenStream);

            // Try to figure out if we have surface shader.
            // Surface shaders have some additional implicit includes.
            string[] lines = fullCode.Split('\n');
            bool isSurfaceShader = false;
            foreach (string line in lines)
            {
                if (line.TrimStart().StartsWith("#pragma"))
                {
                    string[] args = line.TrimStart().Split(' ');
                    if (args.Length > 0)
                    {
                        if (args[1] == "surface")
                        {
                            isSurfaceShader = true;
                            break;
                        }
                        else if (args[1] == "vertex" || args[1] == "fragment")
                        {
                            isSurfaceShader = false;
                            break;
                        }
                    }
                }
            }

            // Add preamble
            string preamble = string.Empty;
            if (isSurfaceShader)
            {
                // Surface shader compiler has some secret INTERNAL_DATA macro and special includes :(
                preamble = $"#ifndef INTERNAL_DATA\n#define INTERNAL_DATA\n#endif\n#include \"UnityCG.cginc\"\n";
            }
            else if (programToken.Kind != TokenKind.HlslProgramBlock) // HLSLPROGRAM doesn't include anything implicitly.
            {
                // UnityShaderVariables.cginc should always be included otherwise
                preamble = $"#include \"UnityShaderVariables.cginc\"\n"; 
            }
            fullCode = $"{preamble}{fullCode}";
            if (!config.ParseEmbeddedHLSL)
            {
                return new HLSLProgramBlock
                {
                    CodeWithoutIncludes = program,
                    FullCode = fullCode,
                    Span = programToken.Span,
                    Pragmas = new List<string>(),
                    TopLevelDeclarations = new List<HLSLSyntaxNode>(),
                    Kind = kind,
                };
            }

            // Lex preamble
            var premableTokens = HLSLLexer.Lex(preamble, config.BasePath, config.FileName, config.ThrowExceptionOnError, out var lexerDiags);
            diagnostics.InsertRange(0, lexerDiags);
            tokenStream.InsertRange(0, premableTokens);

            // TODO: Don't redo the parsing work every time - it's slow x)
            var decls = HLSLParser.ParseTopLevelDeclarations(tokenStream, config, out var parserDiags, out var pragmas);
            diagnostics.AddRange(parserDiags);
            return new HLSLProgramBlock
            {
                CodeWithoutIncludes = program,
                FullCode = fullCode,
                Span = programToken.Span,
                Pragmas = pragmas,
                TopLevelDeclarations = decls,
                Kind = kind,
            };
        }
        protected void PushIncludes() => currentIncludeBlocks.Push(new List<HLSLIncludeBlock>());
        protected void PopIncludes() => currentIncludeBlocks.Pop();
        protected void SetIncludes(List<HLSLIncludeBlock> includes)
        {
            currentIncludeBlocks.Pop();
            currentIncludeBlocks.Push(includes);
        }

        public ShaderNode ParseShader()
        {
            PushIncludes();

            var keywordTok = Eat(TokenKind.ShaderKeyword);
            string name = Eat(TokenKind.StringLiteralToken).Identifier ?? string.Empty;
            Eat(TokenKind.OpenBraceToken);

            List<HLSLIncludeBlock> includeBlocks = new List<HLSLIncludeBlock>();

            ParseIncludeBlocksIfPresent(includeBlocks);

            List<ShaderPropertyNode> properties = new List<ShaderPropertyNode>();
            if (Match(TokenKind.PropertiesKeyword))
            {
                ParsePropertySection(properties);
            }

            List<SubShaderNode> subshaders = new List<SubShaderNode>();
            string fallback = null;
            bool fallbackDisabledExplicitly = false;
            string customEditor = null;
            Dictionary<string, string> dependencies = new Dictionary<string, string>();

            // Keep track of commands inherited by categories as we parse.
            // We essentially pretend categories don't exist, since they are a niche feature.
            Stack<List<ShaderLabCommandNode>> categoryCommands = new Stack<List<ShaderLabCommandNode>>();

            while (LoopShouldContinue())
            {
                ParseIncludeBlocksIfPresent(includeBlocks);
                SetIncludes(includeBlocks);

                // If we are in a category, put the commands there
                if (categoryCommands.Count > 0)
                    ParseCommandsIfPresent(categoryCommands.Peek());

                SLToken next = Peek();
                if (next.Kind == TokenKind.CloseBraceToken)
                    break;

                switch (next.Kind)
                {
                    case TokenKind.SubShaderKeyword:
                        var subShader = ParseSubShader();
                        subShader.Commands.AddRange(categoryCommands.SelectMany(x => x));
                        subshaders.Add(subShader);
                        break;
                    case TokenKind.FallbackKeyword:
                        Advance();
                        if (Match(TokenKind.OffKeyword, TokenKind.FalseKeyword))
                        {
                            fallbackDisabledExplicitly = true;
                            Advance();
                        }
                        else
                        {
                            fallback = Eat(TokenKind.StringLiteralToken).Identifier ?? string.Empty;
                        }
                        break;
                    case TokenKind.DependencyKeyword:
                        Advance();
                        string key = ParseStringLiteral();
                        Eat(TokenKind.EqualsToken);
                        string val = ParseStringLiteral();
                        dependencies[key] = val;
                        break;
                    case TokenKind.CustomEditorKeyword:
                        Advance();
                        customEditor = Eat(TokenKind.StringLiteralToken).Identifier ?? string.Empty;
                        break;
                    case TokenKind.CategoryKeyword:
                        Advance();
                        Eat(TokenKind.OpenBraceToken);
                        categoryCommands.Push(new List<ShaderLabCommandNode>());
                        break;
                    case TokenKind.CloseBraceToken when categoryCommands.Count > 0:
                        Advance();
                        categoryCommands.Pop();
                        break;
                    default:
                        Advance();
                        Error($"SubShader, Fallback, Dependency or CustomEditor", next);
                        break;
                }
            }

            ParseIncludeBlocksIfPresent(includeBlocks);

            var closeTok = Eat(TokenKind.CloseBraceToken);
            RecoverTo(TokenKind.CloseBraceToken);

            PopIncludes();

            return new ShaderNode(Range(keywordTok, closeTok))
            {
                Name = name,
                Properties = properties,
                SubShaders = subshaders,
                Fallback = fallback,
                FallbackDisabledExplicitly = fallbackDisabledExplicitly,
                CustomEditor = customEditor,
                Dependencies = dependencies,
                IncludeBlocks = includeBlocks,
            };
        }

        public void ParseIncludeBlocksIfPresent(List<HLSLIncludeBlock> outIncludeBlocks)
        {
            while (true)
            {
                SLToken next = Peek();
                if ((next.Kind == TokenKind.CgIncludeBlock || next.Kind == TokenKind.HlslIncludeBlock || next.Kind == TokenKind.GlslIncludeBlock)
                    && !string.IsNullOrEmpty(next.Identifier))
                {
                    ProgramKind kind = ProgramKind.Cg;
                    if (next.Kind == TokenKind.HlslProgramBlock)
                        kind = ProgramKind.Hlsl;
                    else if (next.Kind == TokenKind.GlslProgramBlock)
                        kind = ProgramKind.Glsl;

                    outIncludeBlocks.Add(new HLSLIncludeBlock { Span = next.Span, Code = next.Identifier, Kind = kind });
                    Advance();
                }
                else
                {
                    break;
                }
            }
        }

        // TODO: Actually parse contents. In rare cases it can matter.
        public string ParseBracketedStringLiteral()
        {
            SLToken literalToken = Eat(TokenKind.BracketedStringLiteralToken);
            string literal = literalToken.Identifier ?? string.Empty;
            if (string.IsNullOrEmpty(literal))
                Error("a valid bracketed string literal / property reference", literalToken);
            return literal;
        }

        public void ParsePropertySection(List<ShaderPropertyNode> outProperties)
        {
            Eat(TokenKind.PropertiesKeyword);
            Eat(TokenKind.OpenBraceToken);

            while (Match(TokenKind.IdentifierToken, TokenKind.BracketedStringLiteralToken))
            {
                outProperties.Add(ParseProperty());
            }

            Eat(TokenKind.CloseBraceToken);
            RecoverTo(TokenKind.CloseBraceToken);
        }

        public ShaderPropertyNode ParseProperty()
        {
            var firstTok = Peek();
            List<string> attributes = new List<string>();
            while (Match(TokenKind.BracketedStringLiteralToken))
            {
                attributes.Add(ParseBracketedStringLiteral());
            }

            string uniform = ParseIdentifier();

            Eat(TokenKind.OpenParenToken);

            string name = ParseStringLiteral();
            Eat(TokenKind.CommaToken);

            ShaderPropertyKind kind = ShaderPropertyKind.None;
            (float Min, float Max)? rangeMinMax = null;
            SLToken typeToken = Advance();
            switch (typeToken.Kind)
            {
                case TokenKind.FloatKeyword: kind = ShaderPropertyKind.Float; break;
                case TokenKind.IntegerKeyword: kind = ShaderPropertyKind.Integer; break;
                case TokenKind.IntKeyword: kind = ShaderPropertyKind.Int; break;
                case TokenKind.ColorKeyword: kind = ShaderPropertyKind.Color; break;
                case TokenKind.VectorKeyword: kind = ShaderPropertyKind.Vector; break;
                case TokenKind._2DKeyword: case TokenKind.RectKeyword: kind = ShaderPropertyKind.Texture2D; break;
                case TokenKind._3DKeyword: kind = ShaderPropertyKind.Texture3D; break;
                case TokenKind.CubeKeyword: kind = ShaderPropertyKind.TextureCube; break;
                case TokenKind._2DArrayKeyword: kind = ShaderPropertyKind.Texture2DArray; break;
                case TokenKind._3DArrayKeyword: kind = ShaderPropertyKind.Texture3DArray; break;
                case TokenKind.CubeArrayKeyword: kind = ShaderPropertyKind.TextureCubeArray; break;
                case TokenKind.AnyKeyword: kind = ShaderPropertyKind.TextureAny; break;
                case TokenKind.RangeKeyword:
                    kind = ShaderPropertyKind.Range;
                    Eat(TokenKind.OpenParenToken);
                    float min = ParseNumericLiteral();
                    Eat(TokenKind.CommaToken);
                    float max = ParseNumericLiteral();
                    Eat(TokenKind.CloseParenToken);
                    rangeMinMax = (min, max);
                    break;
                default:
                    Error("a valid type", typeToken);
                    break;
            }

            Eat(TokenKind.CloseParenToken);

            Eat(TokenKind.EqualsToken);

            var valueNodeFirstTok = Peek();
            ShaderPropertyValueNode valueNode = null;
            switch (kind)
            {
                case ShaderPropertyKind.Color:
                case ShaderPropertyKind.Vector:
                    Eat(TokenKind.OpenParenToken);
                    float x = ParseNumericLiteral();
                    Eat(TokenKind.CommaToken);
                    float y = ParseNumericLiteral();
                    Eat(TokenKind.CommaToken);
                    float z = ParseNumericLiteral();
                    float w = 1;
                    bool hasLastChannel = false;
                    if (Match(TokenKind.CommaToken))
                    {
                        Eat(TokenKind.CommaToken);
                        w = ParseNumericLiteral();
                        hasLastChannel = true;
                    }
                    var closeTok = Eat(TokenKind.CloseParenToken);
                    if (kind == ShaderPropertyKind.Color)
                        valueNode = new ShaderPropertyValueColorNode(Range(valueNodeFirstTok, closeTok)) { HasAlphaChannel = hasLastChannel, Color = (x, y, z, w) };
                    else
                        valueNode = new ShaderPropertyValueVectorNode(Range(valueNodeFirstTok, closeTok)) { HasWChannel = hasLastChannel, Vector = (x, y, z, w) };
                    break;

                case ShaderPropertyKind.TextureCube:
                case ShaderPropertyKind.Texture2D:
                case ShaderPropertyKind.Texture3D:
                case ShaderPropertyKind.TextureAny:
                case ShaderPropertyKind.TextureCubeArray:
                case ShaderPropertyKind.Texture2DArray:
                case ShaderPropertyKind.Texture3DArray:
                    string texName = ParseStringLiteral();
                    valueNode = new ShaderPropertyValueTextureNode(Range(valueNodeFirstTok, Previous())) { Kind = ShaderLabSyntaxFacts.ShaderPropertyTypeToTextureType(kind), TextureName = texName };
                    break;

                case ShaderPropertyKind.Integer:
                case ShaderPropertyKind.Int:
                    int intVal = ParseIntegerLiteral();
                    valueNode = new ShaderPropertyValueIntegerNode(Range(valueNodeFirstTok, Previous())) { Number = intVal };
                    break;

                case ShaderPropertyKind.Float:
                case ShaderPropertyKind.Range:
                    float floatVal = ParseNumericLiteral();
                    valueNode = new ShaderPropertyValueFloatNode(Range(valueNodeFirstTok, Previous())) { Number = floatVal };
                    break;

                default:
                    break;
            }

            if (Match(TokenKind.OpenBraceToken))
            {
                Eat(TokenKind.OpenBraceToken);
                while (Peek().Kind != TokenKind.CloseBraceToken)
                    Advance();
                Eat(TokenKind.CloseBraceToken);
            }

            return new ShaderPropertyNode(Range(firstTok, Previous()))
            {
                Attributes = attributes,
                Uniform = uniform,
                Name = name,
                Kind = kind,
                RangeMinMax = rangeMinMax,
                Value = valueNode,
            };
        }

        public SubShaderNode ParseSubShader()
        {
            PushIncludes();

            var keywordTok = Eat(TokenKind.SubShaderKeyword);
            Eat(TokenKind.OpenBraceToken);

            List<ShaderPassNode> passes = new List<ShaderPassNode>();
            List<ShaderLabCommandNode> commands = new List<ShaderLabCommandNode>();
            List<HLSLProgramBlock> programBlocks = new List<HLSLProgramBlock>();
            List<HLSLIncludeBlock> includeBlocks = new List<HLSLIncludeBlock>();

            while (LoopShouldContinue())
            {
                SLToken next = Peek();
                if (next.Kind == TokenKind.CloseBraceToken)
                    break;

                int lastPosition = position;

                switch (next.Kind)
                {
                    case TokenKind.PassKeyword: passes.Add(ParseCodePass()); break;
                    case TokenKind.GrabPassKeyword: passes.Add(ParseGrabPass()); break;
                    case TokenKind.UsePassKeyword: passes.Add(ParseUsePass()); break;
                    case TokenKind.CgProgramBlock:
                    case TokenKind.HlslProgramBlock:
                    case TokenKind.GlslProgramBlock:
                        programBlocks.Add(ParseOrSkipEmbeddedHLSL()); break;
                    default:
                        ParseCommandsAndIncludeBlocksIfPresent(commands, includeBlocks);
                        SetIncludes(includeBlocks);
                        break;
                }

                // We got stuck, so error and try to recover to something sensible
                if (position == lastPosition)
                {
                    Error("a valid ShaderLab command or program block", next);
                    RecoverTo(x => x == TokenKind.CloseBraceToken || commandSyncTokens.Contains(x), false);
                }
            }

            ParseCommandsAndIncludeBlocksIfPresent(commands, includeBlocks);

            var closeTok = Eat(TokenKind.CloseBraceToken);
            RecoverTo(TokenKind.CloseBraceToken);

            PopIncludes();

            return new SubShaderNode(Range(keywordTok, closeTok))
            {
                Passes = passes,
                Commands = commands,
                IncludeBlocks = includeBlocks,
                ProgramBlocks = programBlocks,
            };
        }

        public ShaderCodePassNode ParseCodePass()
        {
            PushIncludes();

            var keywordTok = Eat(TokenKind.PassKeyword);
            Eat(TokenKind.OpenBraceToken);

            List<ShaderLabCommandNode> commands = new List<ShaderLabCommandNode>();
            List<HLSLProgramBlock> programBlocks = new List<HLSLProgramBlock>();
            List<HLSLIncludeBlock> includeBlocks = new List<HLSLIncludeBlock>();

            ParseCommandsAndIncludeBlocksIfPresent(commands, includeBlocks);
            SetIncludes(includeBlocks);

            while (Match(TokenKind.CgProgramBlock, TokenKind.HlslProgramBlock, TokenKind.GlslProgramBlock))
            {
                programBlocks.Add(ParseOrSkipEmbeddedHLSL());
                ParseCommandsAndIncludeBlocksIfPresent(commands, includeBlocks);
                SetIncludes(includeBlocks);
            }

            var closeTok = Eat(TokenKind.CloseBraceToken);
            RecoverTo(TokenKind.CloseBraceToken);

            PopIncludes();

            return new ShaderCodePassNode(Range(keywordTok, closeTok))
            {
                ProgramBlocks = programBlocks,
                Commands = commands,
                IncludeBlocks = includeBlocks
            };
        }

        public ShaderGrabPassNode ParseGrabPass()
        {
            var keywordTok = Eat(TokenKind.GrabPassKeyword);
            Eat(TokenKind.OpenBraceToken);

            List<ShaderLabCommandNode> commands = new List<ShaderLabCommandNode>();
            List<HLSLIncludeBlock> includeBlocks = new List<HLSLIncludeBlock>();

            ParseCommandsAndIncludeBlocksIfPresent(commands, includeBlocks);
            string name = null;
            if (Peek().Kind != TokenKind.CloseBraceToken)
            {
                name = ParseStringLiteral();

                ParseCommandsAndIncludeBlocksIfPresent(commands, includeBlocks);
            }

            var closeTok = Eat(TokenKind.CloseBraceToken);
            RecoverTo(TokenKind.CloseBraceToken);

            return new ShaderGrabPassNode(Range(keywordTok, closeTok))
            {
                TextureName = name,
                Commands = commands,
                IncludeBlocks = includeBlocks,
            };
        }

        public ShaderUsePassNode ParseUsePass()
        {
            var keywordTok = Eat(TokenKind.UsePassKeyword);
            string name = ParseStringLiteral();
            return new ShaderUsePassNode(Range(keywordTok, Previous()))
            {
                PassName = name
            };
        }

        public void ParseCommandsAndIncludeBlocksIfPresent(List<ShaderLabCommandNode> outCommands, List<HLSLIncludeBlock> outIncludeBlocks)
        {
            while (true)
            {
                int lastPosition = position;

                ParseCommandsIfPresent(outCommands);
                ParseIncludeBlocksIfPresent(outIncludeBlocks);

                if (lastPosition == position)
                    break;
            }
        }

        public bool TryParseCommand(out ShaderLabCommandNode result)
        {
            var next = Peek();
            switch (next.Kind)
            {
                case TokenKind.LightingKeyword: result = ParseBasicToggleCommand(next.Kind, (a, b) => new ShaderLabCommandLightingNode(Range(a, b))); return true;
                case TokenKind.SeparateSpecularKeyword: result = ParseBasicToggleCommand(next.Kind, (a, b) => new ShaderLabCommandSeparateSpecularNode(Range(a, b))); return true;
                case TokenKind.ZWriteKeyword: result = ParseBasicToggleCommand(next.Kind, (a, b) => new ShaderLabCommandZWriteNode(Range(a, b))); return true;
                case TokenKind.AlphaToMaskKeyword: result = ParseBasicToggleCommand(next.Kind, (a, b) => new ShaderLabCommandAlphaToMaskNode(Range(a, b))); return true;
                case TokenKind.ZClipKeyword: result = ParseBasicToggleCommand(next.Kind, (a, b) => new ShaderLabCommandZClipNode(Range(a, b))); return true;
                case TokenKind.ConservativeKeyword: result = ParseBasicToggleCommand(next.Kind, (a, b) => new ShaderLabCommandConservativeNode(Range(a, b))); return true;
                case TokenKind.TagsKeyword: result = ParseTagsCommand(); return true;
                case TokenKind.LodKeyword: result = ParseLodCommand(); return true;
                case TokenKind.CullKeyword: result = ParseCullCommand(); return true;
                case TokenKind.ZTestKeyword: result = ParseZTestCommand(); return true;
                case TokenKind.BlendKeyword: result = ParseBlendCommand(); return true;
                case TokenKind.OffsetKeyword: result = ParseOffsetCommand(); return true;
                case TokenKind.ColorMaskKeyword: result = ParseColorMaskCommand(); return true;
                case TokenKind.AlphaTestKeyword: result = ParseAlphaTestCommand(); return true;
                case TokenKind.FogKeyword: result = ParseFogCommand(); return true;
                case TokenKind.NameKeyword: result = ParseNameCommand(); return true;
                case TokenKind.BindChannelsKeyword: result = ParseBindChannelsCommand(); return true;
                case TokenKind.ColorKeyword: result = ParseColorCommand(); return true;
                case TokenKind.BlendOpKeyword: result = ParseBlendOpCommand(); return true;
                case TokenKind.MaterialKeyword: result = ParseMaterialCommand(); return true;
                case TokenKind.SetTextureKeyword: result = ParseSetTextureCommand(); return true;
                case TokenKind.ColorMaterialKeyword: result = ParseColorMaterialNode(); return true;
                case TokenKind.StencilKeyword: result = ParseStencilNode(); return true;
                case TokenKind.PackageRequirementsKeyword: result = ParsePackageRequirementsNode(); return true;
                default: result = null; return false;
            }
        }

        public void ParseCommandsIfPresent(List<ShaderLabCommandNode> outCommands)
        {
            bool run = true;
            while (run)
            {
                if (TryParseCommand(out var command))
                {
                    outCommands.Add(command);
                }
                else
                {
                    run = false;
                }

                // If we encountered an error, try to find the next command.
                RecoverTo(kind => commandSyncTokens.Contains(kind), false);
            }
        }

        public T ParseBasicToggleCommand<T>(TokenKind keyword, Func<SLToken, SLToken, T> ctor)
            where T : ShaderLabBasicToggleCommandNode
        {
            var firstTok = Eat(keyword);
            var prop = ParsePropertyReferenceOr(() =>
            {
                var kind = Eat(TokenKind.OnKeyword, TokenKind.OffKeyword, TokenKind.TrueKeyword, TokenKind.FalseKeyword).Kind;
                return kind == TokenKind.OnKeyword || kind == TokenKind.TrueKeyword;
            });
            var lastTok = Previous();
            var result = ctor(firstTok, lastTok);
            result.Enabled = prop;
            return result;
        }

        public ShaderLabCommandTagsNode ParseTagsCommand()
        {
            var keywordTok = Eat(TokenKind.TagsKeyword);
            Eat(TokenKind.OpenBraceToken);

            Dictionary<string, string> tags = new Dictionary<string, string>();
            while (LoopShouldContinue() && Peek().Kind != TokenKind.CloseBraceToken)
            {
                var tagKeySpan = Peek().Span;
                string key = ParseStringLiteral();
                Eat(TokenKind.EqualsToken);
                string val = ParseStringLiteral();

                if (tags.ContainsKey(key))
                {
                    Error(DiagnosticFlags.Warning, $"Duplicate definition of tag '{key}' found.", tagKeySpan);
                }
                tags[key] = val;
            }

            var closeTok = Eat(TokenKind.CloseBraceToken);
            RecoverTo(TokenKind.CloseBraceToken);

            return new ShaderLabCommandTagsNode(Range(keywordTok, closeTok))
            {
                Tags = tags
            };
        }

        public ShaderLabCommandLodNode ParseLodCommand()
        {
            var keywordTok = Eat(TokenKind.LodKeyword);
            int level = ParseIntegerLiteral();
            return new ShaderLabCommandLodNode(Range(keywordTok, Previous()))
            {
                LodLevel = level,
            };
        }

        public PropertyReferenceOr<TOther> ParsePropertyReferenceOr<TOther>(Func<TOther> otherParser)
        {
            if (Match(TokenKind.BracketedStringLiteralToken))
            {
                return new PropertyReferenceOr<TOther> { Property = ParseBracketedStringLiteral() };
            }
            else
            {
                return new PropertyReferenceOr<TOther> { Value = otherParser() };
            }
        }

        public ShaderLabCommandCullNode ParseCullCommand()
        {
            var keywordTok = Eat(TokenKind.CullKeyword);
            var prop = ParsePropertyReferenceOr(() =>
            {
                var kind = Eat(TokenKind.OffKeyword, TokenKind.FrontKeyword, TokenKind.BackKeyword, TokenKind.FalseKeyword).Kind;
                CullMode mode = default;
                if (kind == TokenKind.OffKeyword || kind == TokenKind.FalseKeyword)
                    mode = CullMode.Off;
                else if (kind == TokenKind.FrontKeyword)
                    mode = CullMode.Front;
                else if (kind == TokenKind.BackKeyword)
                    mode = CullMode.Back;
                return mode;
            });
            return new ShaderLabCommandCullNode(Range(keywordTok, Previous())) { Mode = prop };
        }

        public ShaderLabCommandZTestNode ParseZTestCommand()
        {
            var keywordTok = Eat(TokenKind.ZTestKeyword);
            var prop = ParsePropertyReferenceOr(() => ParseEnum<ComparisonMode>("a valid comparison operator"));
            return new ShaderLabCommandZTestNode(Range(keywordTok, Previous())) { Mode = prop };
        }

        private static readonly Dictionary<TokenKind, BlendFactor> blendFactors = new Dictionary<TokenKind, BlendFactor>()
        {
            { TokenKind.OneKeyword, BlendFactor.One },
            { TokenKind.ZeroKeyword, BlendFactor.Zero },
            { TokenKind.SrcColorKeyword, BlendFactor.SrcColor },
            { TokenKind.SrcAlphaKeyword, BlendFactor.SrcAlpha },
            { TokenKind.SrcAlphaSaturateKeyword, BlendFactor.SrcAlphaSaturate },
            { TokenKind.DstColorKeyword, BlendFactor.DstColor },
            { TokenKind.DstAlphaKeyword, BlendFactor.DstAlpha },
            { TokenKind.OneMinusSrcColorKeyword, BlendFactor.OneMinusSrcColor },
            { TokenKind.OneMinusSrcAlphaKeyword, BlendFactor.OneMinusSrcAlpha },
            { TokenKind.OneMinusDstColorKeyword, BlendFactor.OneMinusDstColor },
            { TokenKind.OneMinusDstAlphaKeyword, BlendFactor.OneMinusDstAlpha }
        };
        private static readonly TokenKind[] blendFactorsKeys = blendFactors.Keys.ToArray();

        private static U GetValueOrDefault<T, U>(Dictionary<T, U> dictionary, T key)
        {
            if (dictionary.TryGetValue(key, out U result))
                return result;
            else
                return default;
        }

        public ShaderLabCommandBlendNode ParseBlendCommand()
        {
            var keywordTok = Eat(TokenKind.BlendKeyword);

            int renderTarget = 0;
            if (Match(TokenKind.FloatLiteralToken, TokenKind.IntegerLiteralToken))
            {
                renderTarget = ParseIntegerLiteral();
            }

            if (Match(TokenKind.OffKeyword, TokenKind.FalseKeyword))
            {
                var offTok = Advance();
                return new ShaderLabCommandBlendNode(Range(keywordTok, offTok)) { RenderTarget = renderTarget, Enabled = false };
            }

            var srcRGB = ParsePropertyReferenceOr(() => GetValueOrDefault(blendFactors, Eat(blendFactorsKeys).Kind));
            var dstRGB = ParsePropertyReferenceOr(() => GetValueOrDefault(blendFactors, Eat(blendFactorsKeys).Kind));

            var srcAlpha = srcRGB;
            var dstAlpha = dstRGB;
            if (Match(TokenKind.CommaToken))
            {
                Eat(TokenKind.CommaToken);
                srcAlpha = ParsePropertyReferenceOr(() => GetValueOrDefault(blendFactors, Eat(blendFactorsKeys).Kind));
                dstAlpha = ParsePropertyReferenceOr(() => GetValueOrDefault(blendFactors, Eat(blendFactorsKeys).Kind));
            }

            return new ShaderLabCommandBlendNode(Range(keywordTok, Previous()))
            {
                RenderTarget = renderTarget,
                Enabled = true,
                SourceFactorRGB = srcRGB,
                DestinationFactorRGB = dstRGB,
                SourceFactorAlpha = srcAlpha,
                DestinationFactorAlpha = dstAlpha
            };
        }

        public ShaderLabCommandOffsetNode ParseOffsetCommand()
        {
            var keywordTok = Eat(TokenKind.OffsetKeyword);
            var factor = ParsePropertyReferenceOr(ParseNumericLiteral);
            Eat(TokenKind.CommaToken);
            var units = ParsePropertyReferenceOr(ParseNumericLiteral);
            return new ShaderLabCommandOffsetNode(Range(keywordTok, Previous())) { Factor = factor, Units = units };
        }

        public ShaderLabCommandColorMaskNode ParseColorMaskCommand()
        {
            var keywordTok = Eat(TokenKind.ColorMaskKeyword);
            var mask = ParsePropertyReferenceOr(() =>
            {
                SLToken next = Peek();
                if (next.Kind == TokenKind.FloatLiteralToken || next.Kind == TokenKind.IntegerLiteralToken)
                {
                    string result = ParseNumericLiteral().ToString();
                    if (result != "0")
                        Error("the numeric literal 0", next);
                    return result;
                }
                else
                {
                    string result = ParseIdentifier();
                    if (!result.ToLower().All(x => x == 'r' || x == 'g' || x == 'b' || x == 'a'))
                        Error("a valid mask containing only the letter 'r', 'g', 'b', 'a'", next);
                    return result;
                }
            });
            int renderTarget = 0;
            if (Match(TokenKind.FloatLiteralToken, TokenKind.IntegerLiteralToken))
            {
                renderTarget = ParseIntegerLiteral();
            }
            return new ShaderLabCommandColorMaskNode(Range(keywordTok, Previous())) { RenderTarget = renderTarget, Mask = mask };
        }

        public ShaderLabCommandAlphaTestNode ParseAlphaTestCommand()
        {
            var keywordTok = Eat(TokenKind.AlphaTestKeyword);
            var prop = ParsePropertyReferenceOr(() => ParseEnum<ComparisonMode>("a valid comparison operator"));
            PropertyReferenceOr<float>? alpha = null;
            if (Match(TokenKind.FloatLiteralToken, TokenKind.IntegerLiteralToken, TokenKind.BracketedStringLiteralToken))
            {
                alpha = ParsePropertyReferenceOr(ParseNumericLiteral);
            }
            return new ShaderLabCommandAlphaTestNode(Range(keywordTok, Previous())) { Mode = prop, AlphaValue = alpha };
        }

        public void ParseColor(out (float r, float g, float b, float a) color, out bool hasAlphaChannel)
        {
            hasAlphaChannel = false;
            float r, g, b, a = 1;
            Eat(TokenKind.OpenParenToken);
            r = ParseNumericLiteral();
            Eat(TokenKind.CommaToken);
            g = ParseNumericLiteral();
            Eat(TokenKind.CommaToken);
            b = ParseNumericLiteral();
            if (Match(TokenKind.CommaToken))
            {
                Eat(TokenKind.CommaToken);
                a = ParseNumericLiteral();
                hasAlphaChannel = true;
            }
            Eat(TokenKind.CloseParenToken);
            color = (r, g, b, a);
        }

        public ShaderLabCommandFogNode ParseFogCommand()
        {
            var keywordTok = Eat(TokenKind.FogKeyword);
            Eat(TokenKind.OpenBraceToken);

            (float, float, float, float)? color = null;
            bool isEnabled;
            if (Match(TokenKind.ColorKeyword))
            {
                isEnabled = true;

                Eat(TokenKind.ColorKeyword);
                ParseColor(out var parsedColor, out _);
                color = parsedColor;
            }
            else
            {
                Eat(TokenKind.ModeKeyword);

                TokenKind modeKind = Eat(TokenKind.OffKeyword, TokenKind.GlobalKeyword).Kind;
                isEnabled = modeKind == TokenKind.GlobalKeyword;
            }

            var closeTok = Eat(TokenKind.CloseBraceToken);
            RecoverTo(TokenKind.CloseBraceToken);
            return new ShaderLabCommandFogNode(Range(keywordTok, closeTok)) { Enabled = isEnabled, Color = color };
        }

        public ShaderLabCommandNameNode ParseNameCommand()
        {
            var keywordTok = Eat(TokenKind.NameKeyword);
            string name = ParseStringLiteral();
            return new ShaderLabCommandNameNode(Range(keywordTok, Previous())) { Name = name };
        }

        public ShaderLabCommandBindChannelsNode ParseBindChannelsCommand()
        {
            var keywordTok = Eat(TokenKind.BindChannelsKeyword);
            Eat(TokenKind.OpenBraceToken);

            Dictionary<BindChannel, BindChannel> bindings = new Dictionary<BindChannel, BindChannel>();
            while (LoopShouldContinue() && Peek().Kind != TokenKind.CloseBraceToken)
            {
                Eat(TokenKind.BindKeyword);
                string source = ParseStringLiteral();
                Eat(TokenKind.CommaToken);
                SLToken targetToken = Advance();
                // Handle ShaderLab's ambiguous syntax: Could be a keyword or an identifier here, in the case of color.
                string target = targetToken.Kind == TokenKind.ColorKeyword ? "color" : targetToken.Identifier ?? String.Empty;
                if (ShaderLabSyntaxFacts.TryParseBindChannelName(source, out BindChannel sourceChannel) &&
                    ShaderLabSyntaxFacts.TryParseBindChannelName(target, out BindChannel targetChannel))
                {
                    bindings[sourceChannel] = targetChannel;
                }
                else
                {
                    Error(DiagnosticFlags.SemanticError, $"Failed to parse channel binding from '{source}' to '{target}'.");
                }
            }

            var closeTok = Eat(TokenKind.CloseBraceToken);
            RecoverTo(TokenKind.CloseBraceToken);

            return new ShaderLabCommandBindChannelsNode(Range(keywordTok, closeTok)) { Bindings = bindings };
        }

        public ShaderLabCommandColorNode ParseColorCommand()
        {
            var keywordTok = Eat(TokenKind.ColorKeyword);
            bool hasAlphaChannel = false;
            var prop = ParsePropertyReferenceOr(() =>
            {
                ParseColor(out var color, out hasAlphaChannel);
                return color;
            });
            return new ShaderLabCommandColorNode(Range(keywordTok, Previous())) { Color = prop, HasAlphaChannel = hasAlphaChannel };
        }

        private static readonly Dictionary<TokenKind, BlendOp> blendOps = new Dictionary<TokenKind, BlendOp>()
        {
            { TokenKind.AddKeyword, BlendOp.Add },
            { TokenKind.SubKeyword, BlendOp.Sub },
            { TokenKind.RevSubKeyword, BlendOp.RevSub },
            { TokenKind.MinKeyword, BlendOp.Min },
            { TokenKind.MaxKeyword, BlendOp.Max },
            { TokenKind.LogicalClearKeyword, BlendOp.LogicalClear },
            { TokenKind.LogicalSetKeyword, BlendOp.LogicalSet },
            { TokenKind.LogicalCopyKeyword, BlendOp.LogicalCopy },
            { TokenKind.LogicalCopyInvertedKeyword, BlendOp.LogicalCopyInverted },
            { TokenKind.LogicalNoopKeyword, BlendOp.LogicalNoop },
            { TokenKind.LogicalInvertKeyword, BlendOp.LogicalInvert },
            { TokenKind.LogicalAndKeyword, BlendOp.LogicalAnd },
            { TokenKind.LogicalNandKeyword, BlendOp.LogicalNand },
            { TokenKind.LogicalOrKeyword, BlendOp.LogicalOr },
            { TokenKind.LogicalNorKeyword, BlendOp.LogicalNor },
            { TokenKind.LogicalXorKeyword, BlendOp.LogicalXor },
            { TokenKind.LogicalEquivKeyword, BlendOp.LogicalEquiv },
            { TokenKind.LogicalAndReverseKeyword, BlendOp.LogicalAndReverse },
            { TokenKind.LogicalOrReverseKeyword, BlendOp.LogicalOrReverse },
            { TokenKind.LogicalOrInvertedKeyword, BlendOp.LogicalOrInverted },
            { TokenKind.MultiplyKeyword, BlendOp.Multiply },
            { TokenKind.ScreenKeyword, BlendOp.Screen },
            { TokenKind.OverlayKeyword, BlendOp.Overlay },
            { TokenKind.DarkenKeyword, BlendOp.Darken },
            { TokenKind.LightenKeyword, BlendOp.Lighten },
            { TokenKind.ColorDodgeKeyword, BlendOp.ColorDodge },
            { TokenKind.ColorBurnKeyword, BlendOp.ColorBurn },
            { TokenKind.HardLightKeyword, BlendOp.HardLight },
            { TokenKind.SoftLightKeyword, BlendOp.SoftLight },
            { TokenKind.DifferenceKeyword, BlendOp.Difference },
            { TokenKind.ExclusionKeyword, BlendOp.Exclusion },
            { TokenKind.HSLHueKeyword, BlendOp.HSLHue },
            { TokenKind.HSLSaturationKeyword, BlendOp.HSLSaturation },
            { TokenKind.HSLColorKeyword, BlendOp.HSLColor },
            { TokenKind.HSLLuminosityKeyword, BlendOp.HSLLuminosity },
        };
        private static readonly TokenKind[] blendOpsKeys = blendOps.Keys.ToArray();
        public ShaderLabCommandBlendOpNode ParseBlendOpCommand()
        {
            var keywordTok = Eat(TokenKind.BlendOpKeyword);
            var op = ParsePropertyReferenceOr(() => GetValueOrDefault(blendOps, Eat(blendOpsKeys).Kind));
            PropertyReferenceOr<BlendOp>? alphaOp = null;
            if (Match(TokenKind.CommaToken))
            {
                Eat(TokenKind.CommaToken);
                alphaOp = ParsePropertyReferenceOr(() => GetValueOrDefault(blendOps, Eat(blendOpsKeys).Kind));
            }
            return new ShaderLabCommandBlendOpNode(Range(keywordTok, Previous())) { BlendOp = op, BlendOpAlpha = alphaOp };
        }

        private static readonly Dictionary<TokenKind, FixedFunctionMaterialProperty> fixedFunctionsMatProps = new Dictionary<TokenKind, FixedFunctionMaterialProperty>()
        {
            { TokenKind.DiffuseKeyword, FixedFunctionMaterialProperty.Diffuse },
            { TokenKind.SpecularKeyword, FixedFunctionMaterialProperty.Specular },
            { TokenKind.AmbientKeyword, FixedFunctionMaterialProperty.Ambient },
            { TokenKind.EmissionKeyword, FixedFunctionMaterialProperty.Emission },
            { TokenKind.ShininessKeyword, FixedFunctionMaterialProperty.Shininess },
        };
        private static readonly TokenKind[] fixedFunctionsMatPropsKeys = fixedFunctionsMatProps.Keys.ToArray();

        public ShaderLabCommandMaterialNode ParseMaterialCommand()
        {
            var keywordTok = Eat(TokenKind.MaterialKeyword);
            Eat(TokenKind.OpenBraceToken);

            var props = new Dictionary<FixedFunctionMaterialProperty, PropertyReferenceOr<(float, float, float, float)>>();
            while (LoopShouldContinue() && !Match(TokenKind.CloseBraceToken))
            {
                var prop = GetValueOrDefault(fixedFunctionsMatProps, Eat(fixedFunctionsMatPropsKeys).Kind);
                var val = ParsePropertyReferenceOr(() =>
                {
                    ParseColor(out var color, out _);
                    return color;
                });

            }

            var closeTok = Eat(TokenKind.CloseBraceToken);
            RecoverTo(TokenKind.CloseBraceToken);

            return new ShaderLabCommandMaterialNode(Range(keywordTok, closeTok)) { Properties = props };
        }

        public ShaderLabCommandSetTextureNode ParseSetTextureCommand()
        {
            var keywordTok = Eat(TokenKind.SetTextureKeyword);
            string name = ParseBracketedStringLiteral();
            Eat(TokenKind.OpenBraceToken);

            List<SLToken> tokens = new List<SLToken>();
            while (LoopShouldContinue() && !Match(TokenKind.CloseBraceToken))
            {
                tokens.Add(Advance());
            }

            var closeTok = Eat(TokenKind.CloseBraceToken);
            RecoverTo(TokenKind.CloseBraceToken);

            return new ShaderLabCommandSetTextureNode(Range(keywordTok, closeTok)) { TextureName = name, Body = tokens };
        }

        public ShaderLabCommandColorMaterialNode ParseColorMaterialNode()
        {
            var keywordTok = Eat(TokenKind.ColorMaterialKeyword);
            var modeTok = Eat(TokenKind.EmissionKeyword, TokenKind.AmbientAndDiffuseKeyword);
            bool ambient = modeTok.Kind == TokenKind.AmbientAndDiffuseKeyword;
            return new ShaderLabCommandColorMaterialNode(Range(keywordTok, modeTok)) { AmbientAndDiffuse = ambient };
        }

        public ShaderLabCommandStencilNode ParseStencilNode()
        {
            var keywordTok = Eat(TokenKind.StencilKeyword);
            Eat(TokenKind.OpenBraceToken);

            // Set defaults
            var @ref = new PropertyReferenceOr<byte> { Value = 0 };
            var readMask = new PropertyReferenceOr<byte> { Value = 255 };
            var writeMask = new PropertyReferenceOr<byte> { Value = 255 };
            var comparisonOperationBack = new PropertyReferenceOr<ComparisonMode> { Value = ComparisonMode.Always };
            var passOperationBack = new PropertyReferenceOr<StencilOp> { Value = StencilOp.Keep };
            var failOperationBack = new PropertyReferenceOr<StencilOp> { Value = StencilOp.Keep };
            var zFailOperationBack = new PropertyReferenceOr<StencilOp> { Value = StencilOp.Keep };
            var comparisonOperationFront = new PropertyReferenceOr<ComparisonMode> { Value = ComparisonMode.Always };
            var passOperationFront = new PropertyReferenceOr<StencilOp> { Value = StencilOp.Keep };
            var failOperationFront = new PropertyReferenceOr<StencilOp> { Value = StencilOp.Keep };
            var zFailOperationFront = new PropertyReferenceOr<StencilOp> { Value = StencilOp.Keep };

            StencilOp ParseStencilOp() => ParseEnum<StencilOp>("a valid stencil operator");
            ComparisonMode ParseComparisonMode() => ParseEnum<ComparisonMode>("a valid stencil comparison operator");

            while (LoopShouldContinue() && !Match(TokenKind.CloseBraceToken))
            {
                SLToken next = Advance();
                switch (next.Kind)
                {
                    case TokenKind.RefKeyword: @ref = ParsePropertyReferenceOr(ParseByteLiteral); break;
                    case TokenKind.ReadMaskKeyword: readMask = ParsePropertyReferenceOr(ParseByteLiteral); break;
                    case TokenKind.WriteMaskKeyword: writeMask = ParsePropertyReferenceOr(ParseByteLiteral); break;
                    case TokenKind.CompKeyword: comparisonOperationBack = comparisonOperationFront = ParsePropertyReferenceOr(ParseComparisonMode); break;
                    case TokenKind.PassKeyword: passOperationBack = passOperationFront = ParsePropertyReferenceOr(ParseStencilOp); break;
                    case TokenKind.FailKeyword: failOperationBack = failOperationFront = ParsePropertyReferenceOr(ParseStencilOp); break;
                    case TokenKind.ZFailKeyword: zFailOperationBack = zFailOperationFront = ParsePropertyReferenceOr(ParseStencilOp); break;
                    case TokenKind.CompBackKeyword: comparisonOperationBack = ParsePropertyReferenceOr(ParseComparisonMode); break;
                    case TokenKind.PassBackKeyword: passOperationBack = ParsePropertyReferenceOr(ParseStencilOp); break;
                    case TokenKind.FailBackKeyword: failOperationBack = ParsePropertyReferenceOr(ParseStencilOp); break;
                    case TokenKind.ZFailBackKeyword: zFailOperationBack = ParsePropertyReferenceOr(ParseStencilOp); break;
                    case TokenKind.CompFrontKeyword: comparisonOperationFront = ParsePropertyReferenceOr(ParseComparisonMode); break;
                    case TokenKind.PassFrontKeyword: passOperationFront = ParsePropertyReferenceOr(ParseStencilOp); break;
                    case TokenKind.FailFrontKeyword: failOperationFront = ParsePropertyReferenceOr(ParseStencilOp); break;
                    case TokenKind.ZFailFrontKeyword: zFailOperationFront = ParsePropertyReferenceOr(ParseStencilOp); break;

                    default:
                        Error("a valid stencil operation", next);
                        break;
                }
            }

            var closeTok = Eat(TokenKind.CloseBraceToken);
            RecoverTo(TokenKind.CloseBraceToken);

            return new ShaderLabCommandStencilNode(Range(keywordTok, closeTok))
            {
                Ref = @ref,
                ReadMask = readMask,
                WriteMask = writeMask ,
                ComparisonOperationBack = comparisonOperationBack ,
                PassOperationBack = passOperationBack ,
                FailOperationBack = failOperationBack ,
                ZFailOperationBack = zFailOperationBack ,
                ComparisonOperationFront = comparisonOperationFront ,
                PassOperationFront = passOperationFront ,
                FailOperationFront = failOperationFront ,
                ZFailOperationFront = zFailOperationFront ,
            };
        }

        public ShaderLabCommandPackageRequirementsNode ParsePackageRequirementsNode()
        {
            var keywordTok = Eat(TokenKind.PackageRequirementsKeyword);
            Eat(TokenKind.OpenBraceToken);

            var references = new Dictionary<string, string>();
            while (LoopShouldContinue() && !Match(TokenKind.CloseBraceToken))
            {
                string package = ParseStringLiteral();
                string version = null;
                if (Match(TokenKind.ColonToken))
                {
                    Advance();
                    version = ParseStringLiteral();
                }
                references[package] = version;
            }

            var closeTok = Eat(TokenKind.CloseBraceToken);

            return new ShaderLabCommandPackageRequirementsNode(Range(keywordTok, closeTok))
            {
                References = references
            };
        }
    }
}


// ShaderLab/ShaderLabPrinter.cs
namespace UnityShaderParser.ShaderLab
{
    public class ShaderLabPrinter : ShaderLabSyntaxVisitor
    {
        // Settings
        // Pretty-print embedded HLSL from the AST, or just print the original source?
        public bool PrettyPrintEmbeddedHLSL { get; set; } = false;

        // State and helpers
        protected StringBuilder sb = new StringBuilder();
        public string Text => sb.ToString();

        protected int indentLevel = 0;
        protected void PushIndent() => indentLevel++;
        protected void PopIndent() => indentLevel--;
        protected string Indent() => new string(' ', indentLevel * 4);

        protected void Emit(string text) => sb.Append(text);
        protected void EmitLine(string text = "") => sb.AppendLine(text);
        protected void EmitIndented(string text = "")
        {
            sb.Append(Indent());
            sb.Append(text);
        }
        protected void EmitIndentedLine(string text)
        {
            sb.Append(Indent());
            sb.AppendLine(text);
        }

        protected void VisitManySeparated<T>(IList<T> nodes, string separator, bool trailing = false, bool leading = false)
            where T : ShaderLabSyntaxNode
        {
            if (leading && nodes.Count > 0)
            {
                Emit(separator);
            }
            VisitMany(nodes, () => Emit(separator));
            if (trailing && nodes.Count > 0)
            {
                Emit(separator);
            }
        }

        protected void EmitPropertyReferenceOr<T>(PropertyReferenceOr<T> prop)
        {
            if (prop.IsPropertyReference)
            {
                Emit($"[{prop.Property}]");
            }
            else
            {
                if (prop.Value is bool b)
                    Emit(b ? "On" : "Off");
                else if (prop.Value is Enum)
                    Emit(PrintingUtil.GetEnumNameTypeErased(prop.Value));
                else
                    Emit(string.Format(CultureInfo.InvariantCulture, "{0}", prop.Value));
            }
        }

        protected void HandleIncludeBlocks(IEnumerable<HLSLIncludeBlock> blocks)
        {
            // We only print include blocks if we aren't pretty printing HLSL
            // (i.e. the code isn't merged into the program blocks)
            if (!PrettyPrintEmbeddedHLSL)
            {
                foreach (var block in blocks)
                {
                    switch (block.Kind)
                    {
                        case ProgramKind.Cg: EmitIndented("CGINCLUDE"); break;
                        case ProgramKind.Hlsl: EmitIndented("HLSLINCLUDE"); break;
                        case ProgramKind.Glsl: EmitIndented("GLSLINCLUDE"); break;
                    }
                    Emit(block.Code);
                    switch (block.Kind)
                    {
                        case ProgramKind.Cg: EmitLine("ENDCG"); break;
                        case ProgramKind.Hlsl: EmitLine("ENDHLSL"); break;
                        case ProgramKind.Glsl: EmitLine("ENDGLSL"); break;
                    }
                }
            }
        }

        protected void HandleProgramBlocks(IEnumerable<HLSLProgramBlock> blocks)
        {
            foreach (var block in blocks)
            {
                if (PrettyPrintEmbeddedHLSL)
                {
                    EmitIndentedLine("HLSLPROGRAM");
                    HLSL.HLSLPrinter printer = new HLSL.HLSLPrinter();
                    printer.VisitMany(block.TopLevelDeclarations);
                    Emit(printer.Text);
                    EmitLine("ENDHLSL");
                }
                else
                {
                    switch (block.Kind)
                    {
                        case ProgramKind.Cg: EmitIndented("CGPROGRAM"); break;
                        case ProgramKind.Hlsl: EmitIndented("HLSLPROGRAM"); break;
                        case ProgramKind.Glsl: EmitIndented("GLSLPROGRAM"); break;
                    }
                    Emit(block.CodeWithoutIncludes);
                    switch (block.Kind)
                    {
                        case ProgramKind.Cg: EmitLine("ENDCG"); break;
                        case ProgramKind.Hlsl: EmitLine("ENDHLSL"); break;
                        case ProgramKind.Glsl: EmitLine("ENDGLSL"); break;
                    }
                }
            }
        }

        public override void VisitShaderNode(ShaderNode node)
        {
            EmitLine($"Shader \"{node.Name}\"");
            EmitLine("{");
            PushIndent();

            EmitIndentedLine("Properties");
            EmitIndentedLine("{");
            PushIndent();
            VisitMany(node.Properties);
            PopIndent();
            EmitIndentedLine("}");

            HandleIncludeBlocks(node.IncludeBlocks);

            VisitMany(node.SubShaders);

            if (node.FallbackDisabledExplicitly)
                EmitIndentedLine("Fallback Off");
            else if (node.Fallback != null)
                EmitIndentedLine($"Fallback \"{node.Fallback}\"");

            if (node.CustomEditor != null)
                EmitIndentedLine($"CustomEditor \"{node.CustomEditor}\"");

            foreach (var kvp in node.Dependencies)
            {
                EmitIndentedLine($"Dependency \"{kvp.Key}\" = \"{kvp.Value}\"");
            }

            PopIndent();

            EmitLine("}");
        }

        public override void VisitShaderPropertyNode(ShaderPropertyNode node)
        {
            EmitIndented();

            foreach (string attribute in node.Attributes)
            {
                Emit($"[{attribute}] ");
            }

            Emit($"{node.Uniform}(\"{node.Name}\", ");

            switch (node.Kind)
            {
                case ShaderPropertyKind.Texture2D: Emit("2D"); break;
                case ShaderPropertyKind.Texture3D: Emit("3D"); break;
                case ShaderPropertyKind.TextureCube: Emit("Cube"); break;
                case ShaderPropertyKind.TextureAny: Emit("Any"); break;
                case ShaderPropertyKind.Texture2DArray: Emit("2DArray"); break;
                case ShaderPropertyKind.Texture3DArray: Emit("3DArray"); break;
                case ShaderPropertyKind.TextureCubeArray: Emit("CubeArray"); break;
                case ShaderPropertyKind.Float: Emit("Float"); break;
                case ShaderPropertyKind.Int: Emit("Int"); break;
                case ShaderPropertyKind.Integer: Emit("Integer"); break;
                case ShaderPropertyKind.Color: Emit("Color"); break;
                case ShaderPropertyKind.Vector: Emit("Vector"); break;
                case ShaderPropertyKind.Range:
                    if (node.RangeMinMax != null)
                    {
                        Emit($"Range({string.Format(CultureInfo.InvariantCulture, "{0}", node.RangeMinMax.Value.Min)}, {string.Format(CultureInfo.InvariantCulture, "{0}", node.RangeMinMax.Value.Max)})");
                    }
                    else
                    {
                        Emit("Float");
                    }
                    break;
                default: Emit("Any"); break;
            }

            Emit(") = ");
            Visit(node.Value);
            EmitLine();
        }

        public override void VisitShaderPropertyValueFloatNode(ShaderPropertyValueFloatNode node)
        {
            Emit(string.Format(CultureInfo.InvariantCulture, "{0}", node.Number));
        }

        public override void VisitShaderPropertyValueIntegerNode(ShaderPropertyValueIntegerNode node)
        {
            Emit(string.Format(CultureInfo.InvariantCulture, "{0}", node.Number));
        }

        public override void VisitShaderPropertyValueVectorNode(ShaderPropertyValueVectorNode node)
        {
            Emit($"({string.Format(CultureInfo.InvariantCulture, "{0}", node.Vector.x)}, {string.Format(CultureInfo.InvariantCulture, "{0}", node.Vector.y)}, {string.Format(CultureInfo.InvariantCulture, "{0}", node.Vector.z)}");
            if (node.HasWChannel)
                Emit($", {string.Format(CultureInfo.InvariantCulture, "{0}", node.Vector.w)}");
            Emit(")");
        }

        public override void VisitShaderPropertyValueColorNode(ShaderPropertyValueColorNode node)
        {
            Emit($"({string.Format(CultureInfo.InvariantCulture, "{0}", node.Color.r)}, {string.Format(CultureInfo.InvariantCulture, "{0}", node.Color.g)}, {string.Format(CultureInfo.InvariantCulture, "{0}", node.Color.b)}");
            if (node.HasAlphaChannel)
                Emit($", {string.Format(CultureInfo.InvariantCulture, "{0}", node.Color.a)}");
            Emit(")");
        }

        public override void VisitShaderPropertyValueTextureNode(ShaderPropertyValueTextureNode node)
        {
            Emit($"\"{node.TextureName}\" {{}}");
        }

        public override void VisitSubShaderNode(SubShaderNode node)
        {
            EmitIndentedLine("SubShader");
            EmitIndentedLine("{");
            PushIndent();
            VisitMany(node.Commands);
            VisitMany(node.Passes);
            HandleIncludeBlocks(node.IncludeBlocks);
            HandleProgramBlocks(node.ProgramBlocks);
            PopIndent();
            EmitIndentedLine("}");
        }

        public override void VisitShaderCodePassNode(ShaderCodePassNode node)
        {
            EmitIndentedLine("Pass");
            EmitIndentedLine("{");
            PushIndent();

            VisitMany(node.Commands);

            HandleIncludeBlocks(node.IncludeBlocks);
            HandleProgramBlocks(node.ProgramBlocks);

            PopIndent();
            EmitIndentedLine("}");
        }

        public override void VisitShaderGrabPassNode(ShaderGrabPassNode node)
        {
            EmitIndentedLine("GrabPass");
            EmitIndentedLine("{");
            PushIndent();

            VisitMany(node.Commands);
            HandleIncludeBlocks(node.IncludeBlocks);

            if (!node.IsUnnamed)
            {
                Emit($"\"{node.TextureName}\"");
            }

            PopIndent();
            EmitIndentedLine("}");
        }

        public override void VisitShaderUsePassNode(ShaderUsePassNode node)
        {
            EmitIndentedLine($"UsePass \"{node.PassName}\"");
        }

        public override void VisitShaderLabCommandTagsNode(ShaderLabCommandTagsNode node)
        {
            EmitIndented("Tags { ");
            foreach (var kvp in node.Tags)
            {
                Emit($"\"{kvp.Key}\" = \"{kvp.Value}\" ");
            }
            EmitLine("}");
        }

        public override void VisitShaderLabCommandLodNode(ShaderLabCommandLodNode node)
        {
            EmitIndentedLine($"LOD {node.LodLevel}");
        }

        public override void VisitShaderLabCommandLightingNode(ShaderLabCommandLightingNode node)
        {
            EmitIndented($"Lighting ");
            EmitPropertyReferenceOr(node.Enabled);
            EmitLine();
        }

        public override void VisitShaderLabCommandSeparateSpecularNode(ShaderLabCommandSeparateSpecularNode node)
        {
            EmitIndented($"SeparateSpecular ");
            EmitPropertyReferenceOr(node.Enabled);
            EmitLine();
        }

        public override void VisitShaderLabCommandZWriteNode(ShaderLabCommandZWriteNode node)
        {
            EmitIndented($"ZWrite ");
            EmitPropertyReferenceOr(node.Enabled);
            EmitLine();
        }

        public override void VisitShaderLabCommandAlphaToMaskNode(ShaderLabCommandAlphaToMaskNode node)
        {
            EmitIndented($"AlphaToMask ");
            EmitPropertyReferenceOr(node.Enabled);
            EmitLine();
        }

        public override void VisitShaderLabCommandZClipNode(ShaderLabCommandZClipNode node)
        {
            EmitIndented($"ZClip ");
            EmitPropertyReferenceOr(node.Enabled);
            EmitLine();
        }

        public override void VisitShaderLabCommandConservativeNode(ShaderLabCommandConservativeNode node)
        {
            EmitIndented($"Conservative ");
            EmitPropertyReferenceOr(node.Enabled);
            EmitLine();
        }

        public override void VisitShaderLabCommandCullNode(ShaderLabCommandCullNode node)
        {
            EmitIndented($"Cull ");
            EmitPropertyReferenceOr(node.Mode);
            EmitLine();
        }

        public override void VisitShaderLabCommandZTestNode(ShaderLabCommandZTestNode node)
        {
            EmitIndented($"ZTest ");
            EmitPropertyReferenceOr(node.Mode);
            EmitLine();
        }

        public override void VisitShaderLabCommandBlendNode(ShaderLabCommandBlendNode node)
        {
            EmitIndented("Blend ");
            Emit($"{node.RenderTarget} ");

            if (!node.Enabled)
            {
                Emit("Off");
            }
            else
            {
                if (node.SourceFactorRGB != null)
                {
                    EmitPropertyReferenceOr(node.SourceFactorRGB.Value);
                    Emit(" ");
                }
                if (node.DestinationFactorRGB != null)
                {
                    EmitPropertyReferenceOr(node.DestinationFactorRGB.Value);
                    Emit(" ");
                }

                if (node.SourceFactorAlpha != null)
                {
                    Emit(", ");
                    EmitPropertyReferenceOr(node.SourceFactorAlpha.Value);
                    Emit(" ");
                }
                if (node.DestinationFactorAlpha != null)
                {
                    EmitPropertyReferenceOr(node.DestinationFactorAlpha.Value);
                }
            }

            EmitLine();
        }

        public override void VisitShaderLabCommandOffsetNode(ShaderLabCommandOffsetNode node)
        {
            EmitIndented($"Offset ");
            EmitPropertyReferenceOr(node.Factor);
            Emit(", ");
            EmitPropertyReferenceOr(node.Units);
            EmitLine();
        }

        public override void VisitShaderLabCommandColorMaskNode(ShaderLabCommandColorMaskNode node)
        {
            EmitIndented($"ColorMask ");
            EmitPropertyReferenceOr(node.Mask);
            if (node.Mask.IsValue) // RenderTarget not allowed with property-based mask
                Emit($" {node.RenderTarget}");
            EmitLine();
        }

        public override void VisitShaderLabCommandAlphaTestNode(ShaderLabCommandAlphaTestNode node)
        {
            EmitIndented($"AlphaTest ");
            if (node.Mode.IsPropertyReference && node.Mode.Value == ComparisonMode.Off)
            {
                Emit("Off");
            }
            else
            {
                EmitPropertyReferenceOr(node.Mode);
                if (node.AlphaValue != null)
                {
                    EmitPropertyReferenceOr(node.AlphaValue.Value);
                }
            }
            EmitLine();
        }

        public override void VisitShaderLabCommandFogNode(ShaderLabCommandFogNode node)
        {
            EmitIndented("Fog ");
            if (!node.Enabled)
            {
                Emit("{ Mode Off }");
            }
            else
            {
                if (node.Color != null)
                {
                    Emit($"{{ Color ({string.Format(CultureInfo.InvariantCulture, "{0}", node.Color.Value.r)}, {string.Format(CultureInfo.InvariantCulture, "{0}", node.Color.Value.g)}, {string.Format(CultureInfo.InvariantCulture, "{0}", node.Color.Value.b)}, {string.Format(CultureInfo.InvariantCulture, "{0}", node.Color.Value.a)}) }}");
                }
                else
                {
                    Emit("{ Mode Global }");
                }
            }
            EmitLine();
        }

        public override void VisitShaderLabCommandNameNode(ShaderLabCommandNameNode node)
        {
            EmitIndentedLine($"Name \"{node.Name}\"");
        }

        public override void VisitShaderLabCommandBindChannelsNode(ShaderLabCommandBindChannelsNode node)
        {
            EmitIndentedLine("BindChannels");
            EmitIndentedLine("{");
            PushIndent();

            foreach (var binding in node.Bindings)
            {
                EmitIndented("Bind ");
                Emit($"\"{PrintingUtil.GetEnumName(binding.Key)}\", {PrintingUtil.GetEnumName(binding.Value).ToLower()}");
                EmitLine();
            }

            PopIndent();
            EmitIndentedLine("}");
        }

        public override void VisitShaderLabCommandColorNode(ShaderLabCommandColorNode node)
        {
            EmitIndented($"Color ");
            if (node.Color.IsPropertyReference)
            {
                EmitPropertyReferenceOr(node.Color);
            }
            else
            {
                Emit($"({string.Format(CultureInfo.InvariantCulture, "{0}", node.Color.Value.r)}, {string.Format(CultureInfo.InvariantCulture, "{0}", node.Color.Value.g)}, {string.Format(CultureInfo.InvariantCulture, "{0}", node.Color.Value.b)}");
                if (node.HasAlphaChannel)
                {
                    Emit($", {string.Format(CultureInfo.InvariantCulture, "{0}", node.Color.Value.a)}");
                }
                Emit(")");
            }
            EmitLine();
        }

        public override void VisitShaderLabCommandBlendOpNode(ShaderLabCommandBlendOpNode node)
        {
            EmitIndented($"BlendOp ");
            EmitPropertyReferenceOr(node.BlendOp);
            if (node.BlendOpAlpha != null)
            {
                Emit(", ");
                EmitPropertyReferenceOr(node.BlendOpAlpha.Value);
            }
            EmitLine();
        }

        public override void VisitShaderLabCommandMaterialNode(ShaderLabCommandMaterialNode node)
        {
            EmitIndentedLine("Material");
            EmitIndentedLine("{");
            PushIndent();

            foreach (var binding in node.Properties)
            {
                EmitIndented(PrintingUtil.GetEnumName(binding.Key));
                Emit(" ");
                EmitPropertyReferenceOr(binding.Value);
            }

            PopIndent();
            EmitIndentedLine("}");
        }

        public override void VisitShaderLabCommandSetTextureNode(ShaderLabCommandSetTextureNode node)
        {
            EmitIndentedLine($"SetTexture [{node.TextureName}]");
            EmitIndentedLine("{");

            PushIndent();
            EmitIndentedLine(ShaderLabSyntaxFacts.TokensToString(node.Body));
            PopIndent();

            EmitIndentedLine("}");
        }

        public override void VisitShaderLabCommandColorMaterialNode(ShaderLabCommandColorMaterialNode node)
        {
            EmitIndented($"ColorMaterial ");
            Emit(node.AmbientAndDiffuse ? "AmbientAndDiffuse" : "Emission");
            EmitLine();
        }

        public override void VisitShaderLabCommandStencilNode(ShaderLabCommandStencilNode node)
        {
            EmitIndentedLine("Stencil");
            EmitIndentedLine("{");
            PushIndent();

            EmitIndented("Ref ");
            EmitPropertyReferenceOr(node.Ref);
            EmitLine();

            EmitIndented("ReadMask ");
            EmitPropertyReferenceOr(node.ReadMask);
            EmitLine();

            EmitIndented("WriteMask ");
            EmitPropertyReferenceOr(node.WriteMask);
            EmitLine();

            EmitIndented("CompBack ");
            EmitPropertyReferenceOr(node.ComparisonOperationBack);
            EmitLine();
            EmitIndented("PassBack ");
            EmitPropertyReferenceOr(node.PassOperationBack);
            EmitLine();
            EmitIndented("FailBack ");
            EmitPropertyReferenceOr(node.FailOperationBack);
            EmitLine();
            EmitIndented("ZFailBack ");
            EmitPropertyReferenceOr(node.ZFailOperationBack);
            EmitLine();

            EmitIndented("CompFront ");
            EmitPropertyReferenceOr(node.ComparisonOperationFront);
            EmitLine();
            EmitIndented("PassFront ");
            EmitPropertyReferenceOr(node.PassOperationFront);
            EmitLine();
            EmitIndented("FailFront ");
            EmitPropertyReferenceOr(node.FailOperationFront);
            EmitLine();
            EmitIndented("ZFailFront ");
            EmitPropertyReferenceOr(node.ZFailOperationFront);
            EmitLine();

            PopIndent();
            EmitIndentedLine("}");
        }

        public override void VisitShaderLabCommandPackageRequirementsNode(ShaderLabCommandPackageRequirementsNode node)
        {
            EmitIndentedLine("PackageRequirements");
            EmitIndentedLine("{");
            PushIndent();

            foreach (var reference in node.References)
            {
                EmitIndented($"\"{reference.Key}\"");
                if (reference.Value != null)
                {
                    Emit($": \"{reference.Value}\"");
                }
                EmitLine();
            }

            PopIndent();
            EmitIndentedLine("}");
        }
    }
}


// ShaderLab/ShaderLabSyntaxElements.cs
namespace UnityShaderParser.ShaderLab
{
    using SLToken = Token<TokenKind>;

    #region Tokens
    public enum TokenKind
    {
        InvalidToken,

        OpenParenToken,
        CloseParenToken,
        OpenBracketToken,
        CloseBracketToken,
        OpenBraceToken,
        CloseBraceToken,

        SemiToken,
        CommaToken,

        LessThanToken,
        LessThanEqualsToken,
        GreaterThanToken,
        GreaterThanEqualsToken,
        LessThanLessThanToken,
        GreaterThanGreaterThanToken,
        PlusToken,
        PlusPlusToken,
        MinusToken,
        MinusMinusToken,
        AsteriskToken,
        SlashToken,
        PercentToken,
        AmpersandToken,
        BarToken,
        AmpersandAmpersandToken,
        BarBarToken,
        CaretToken,
        NotToken,
        TildeToken,
        QuestionToken,
        ColonToken,
        ColonColonToken,

        EqualsToken,
        AsteriskEqualsToken,
        SlashEqualsToken,
        PercentEqualsToken,
        PlusEqualsToken,
        MinusEqualsToken,
        LessThanLessThanEqualsToken,
        GreaterThanGreaterThanEqualsToken,
        AmpersandEqualsToken,
        CaretEqualsToken,
        BarEqualsToken,

        EqualsEqualsToken,
        ExclamationEqualsToken,
        DotToken,

        IdentifierToken,
        IntegerLiteralToken,
        FloatLiteralToken,
        StringLiteralToken,
        BracketedStringLiteralToken,

        ShaderKeyword,
        PropertiesKeyword,
        RangeKeyword,
        FloatKeyword,
        IntKeyword,
        IntegerKeyword,
        ColorKeyword,
        VectorKeyword,
        _2DKeyword,
        _3DKeyword,
        CubeKeyword,
        _2DArrayKeyword,
        _3DArrayKeyword,
        CubeArrayKeyword,
        AnyKeyword,
        RectKeyword,
        CategoryKeyword,
        SubShaderKeyword,
        TagsKeyword,
        PassKeyword,
        CgProgramKeyword,
        CgIncludeKeyword,
        EndCgKeyword,
        HlslProgramKeyword,
        HlslIncludeKeyword,
        EndHlslKeyword,
        GlslProgramKeyword,
        GlslIncludeKeyword,
        EndGlslKeyword,
        FallbackKeyword,
        CustomEditorKeyword,
        CullKeyword,
        ZWriteKeyword,
        ZTestKeyword,
        OffsetKeyword,
        BlendKeyword,
        BlendOpKeyword,
        ColorMaskKeyword,
        AlphaToMaskKeyword,
        ZClipKeyword,
        ConservativeKeyword,
        LodKeyword,
        NameKeyword,
        LightingKeyword,
        StencilKeyword,
        RefKeyword,
        ReadMaskKeyword,
        WriteMaskKeyword,
        CompKeyword,
        CompBackKeyword,
        CompFrontKeyword,
        FailKeyword,
        ZFailKeyword,
        FailBackKeyword,
        FailFrontKeyword,
        ZFailBackKeyword,
        ZFailFrontKeyword,
        PassFrontKeyword,
        PassBackKeyword,
        UsePassKeyword,
        GrabPassKeyword,
        DependencyKeyword,
        MaterialKeyword,
        DiffuseKeyword,
        AmbientKeyword,
        ShininessKeyword,
        SpecularKeyword,
        EmissionKeyword,
        AmbientAndDiffuseKeyword,
        FogKeyword,
        ModeKeyword,
        DensityKeyword,
        SeparateSpecularKeyword,
        SetTextureKeyword,
        CombineKeyword,
        AlphaKeyword,
        LerpKeyword,
        DoubleKeyword,
        QuadKeyword,
        ConstantColorKeyword,
        MatrixKeyword,
        AlphaTestKeyword,
        ColorMaterialKeyword,
        BindChannelsKeyword,
        BindKeyword,
        PackageRequirementsKeyword,

        TrueKeyword,
        FalseKeyword,
        OffKeyword,
        OnKeyword,
        FrontKeyword,
        BackKeyword,
        OneKeyword,
        ZeroKeyword,
        SrcColorKeyword,
        SrcAlphaKeyword,
        SrcAlphaSaturateKeyword,
        DstColorKeyword,
        DstAlphaKeyword,
        OneMinusSrcColorKeyword,
        OneMinusSrcAlphaKeyword,
        OneMinusDstColorKeyword,
        OneMinusDstAlphaKeyword,
        GlobalKeyword,
        AddKeyword,
        SubKeyword,
        RevSubKeyword,
        MinKeyword,
        MaxKeyword,
        LogicalClearKeyword,
        LogicalSetKeyword,
        LogicalCopyKeyword,
        LogicalCopyInvertedKeyword,
        LogicalNoopKeyword,
        LogicalInvertKeyword,
        LogicalAndKeyword,
        LogicalNandKeyword,
        LogicalOrKeyword,
        LogicalNorKeyword,
        LogicalXorKeyword,
        LogicalEquivKeyword,
        LogicalAndReverseKeyword,
        LogicalOrReverseKeyword,
        LogicalOrInvertedKeyword,
        MultiplyKeyword,
        ScreenKeyword,
        OverlayKeyword,
        DarkenKeyword,
        LightenKeyword,
        ColorDodgeKeyword,
        ColorBurnKeyword,
        HardLightKeyword,
        SoftLightKeyword,
        DifferenceKeyword,
        ExclusionKeyword,
        HSLHueKeyword,
        HSLSaturationKeyword,
        HSLColorKeyword,
        HSLLuminosityKeyword,

        HlslIncludeBlock,
        HlslProgramBlock,
        CgIncludeBlock,
        CgProgramBlock,
        GlslIncludeBlock,
        GlslProgramBlock,
    }
    #endregion

    #region Common types
    // Either a reference to a property or some other type
    public struct PropertyReferenceOr<TOther>
    {
        public TOther Value;
        public string Property;

        public bool IsValue => Value != null;
        public bool IsPropertyReference => Property != null;
        public bool IsValid => IsValue || IsPropertyReference;

        public override string ToString()
        {
            if (Property != null) return Property;
            else if (Value != null) return Value.ToString();
            else return string.Empty;
        }
    }

    [PrettyEnum(PrettyEnumStyle.PascalCase)]
    public enum ShaderPropertyKind
    {
        [PrettyName("Any")] None,
        [PrettyName("2D")] Texture2D,
        [PrettyName("3D")] Texture3D,
        [PrettyName("Cube")] TextureCube,
        [PrettyName("Any")] TextureAny,
        [PrettyName("2DArray")] Texture2DArray,
        [PrettyName("3DArray")] Texture3DArray,
        [PrettyName("CubeArray")] TextureCubeArray,
        Float,
        Int,
        Integer,
        Color,
        Vector,
        Range,
    }

    [PrettyEnum(PrettyEnumStyle.PascalCase)]
    public enum TextureType
    {
        [PrettyName("2D")] Texture2D,
        [PrettyName("3D")] Texture3D,
        [PrettyName("Cube")] TextureCube,
        [PrettyName("Any")] TextureAny,
        [PrettyName("2DArray")] Texture2DArray,
        [PrettyName("3DArray")] Texture3DArray,
        [PrettyName("CubeArray")] TextureCubeArray,
    }

    [PrettyEnum(PrettyEnumStyle.PascalCase)]
    public enum CullMode
    {
        Off,
        Front,
        Back,
    }

    [PrettyEnum(PrettyEnumStyle.PascalCase)]
    public enum ComparisonMode
    {
        Off,
        Never,
        Less,
        Equal,
        LEqual,
        Greater,
        NotEqual,
        GEqual,
        Always,
    }

    [PrettyEnum(PrettyEnumStyle.PascalCase)]
    public enum BlendFactor
    {
        One,
        Zero,
        SrcColor,
        SrcAlpha,
        SrcAlphaSaturate,
        DstColor,
        DstAlpha,
        OneMinusSrcColor,
        OneMinusSrcAlpha,
        OneMinusDstColor,
        OneMinusDstAlpha,
    }

    [PrettyEnum(PrettyEnumStyle.PascalCase)]
    public enum BindChannel
    {
        Vertex,
        Normal,
        Tangent,
        TexCoord0,
        TexCoord1,
        TexCoord2,
        TexCoord3,
        TexCoord4,
        TexCoord5,
        TexCoord6,
        TexCoord7,
        Color,
    }

    [PrettyEnum(PrettyEnumStyle.PascalCase)]
    public enum BlendOp
    {
        Add,
        Sub,
        RevSub,
        Min,
        Max,
        LogicalClear,
        LogicalSet,
        LogicalCopy,
        LogicalCopyInverted,
        LogicalNoop,
        LogicalInvert,
        LogicalAnd,
        LogicalNand,
        LogicalOr,
        LogicalNor,
        LogicalXor,
        LogicalEquiv,
        LogicalAndReverse,
        LogicalOrReverse,
        LogicalOrInverted,
        Multiply,
        Screen,
        Overlay,
        Darken,
        Lighten,
        ColorDodge,
        ColorBurn,
        HardLight,
        SoftLight,
        Difference,
        Exclusion,
        HSLHue,
        HSLSaturation,
        HSLColor,
        HSLLuminosity,
    }

    [PrettyEnum(PrettyEnumStyle.PascalCase)]
    public enum FixedFunctionMaterialProperty
    {
        Diffuse,
        Ambient,
        Shininess,
        Specular,
        Emission,
    }

    [PrettyEnum(PrettyEnumStyle.PascalCase)]
    public enum StencilOp
    {
        Keep,
        Zero,
        Replace,
        IncrSat,
        DecrSat,
        Invert,
        IncrWrap,
        DecrWrap,
    }
    #endregion

    #region Syntax Tree
    // Embedded HLSL
    public enum ProgramKind
    {
        Cg,   // CGINCLUDE, CGPROGRAM
        Hlsl, // HLSLINCLUDE, HLSLPROGRAM
        Glsl, // GLSLINCLUDE, GLSLPROGRAM
    }

    public struct HLSLProgramBlock
    {
        public string FullCode;
        public string CodeWithoutIncludes;
        public SourceSpan Span;
        public List<string> Pragmas;
        public List<HLSLSyntaxNode> TopLevelDeclarations;
        public ProgramKind Kind;
    }

    public struct HLSLIncludeBlock
    {
        public string Code;
        public SourceSpan Span;
        public ProgramKind Kind;
    }

    public abstract class ShaderLabSyntaxNode : SyntaxNode<ShaderLabSyntaxNode>
    {
        public abstract void Accept(ShaderLabSyntaxVisitor visitor);
        public abstract T Accept<T>(ShaderLabSyntaxVisitor<T> visitor);

        public override SourceSpan Span => span;

        [DebuggerBrowsable(DebuggerBrowsableState.Never)]
        private SourceSpan span;

        public override SourceSpan OriginalSpan => originalSpan;

        [DebuggerBrowsable(DebuggerBrowsableState.Never)]
        private SourceSpan originalSpan;

        public List<SLToken> Tokens => tokens;

        [DebuggerBrowsable(DebuggerBrowsableState.Never)]
        private List<SLToken> tokens;

        public string GetCodeInSourceText(string sourceText) => Span.GetCodeInSourceText(sourceText);
        public string GetPrettyPrintedCode(bool prettyPrintEmbeddedHLSL = false)
        {
            ShaderLabPrinter printer = new ShaderLabPrinter();
            printer.PrettyPrintEmbeddedHLSL = prettyPrintEmbeddedHLSL;
            printer.Visit(this);
            return printer.Text;
        }

        public ShaderLabSyntaxNode(List<SLToken> tokens)
        {
            if (tokens.Count > 0)
            {
                this.span = SourceSpan.Between(tokens.First().Span, tokens.Last().Span);
                this.originalSpan = SourceSpan.Between(tokens.First().OriginalSpan, tokens.Last().OriginalSpan);
            }
            this.tokens = tokens;
        }
    }

    public class ShaderNode : ShaderLabSyntaxNode
    {
        public string Name { get; set; }
        public List<ShaderPropertyNode> Properties { get; set; }
        public List<SubShaderNode> SubShaders { get; set; }
        public string Fallback { get; set; } // Optional
        public bool FallbackDisabledExplicitly { get; set; }
        public string CustomEditor { get; set; } // Optional
        public Dictionary<string, string> Dependencies { get; set; }
        public List<HLSLIncludeBlock> IncludeBlocks { get; set; }

        protected override IEnumerable<ShaderLabSyntaxNode> GetChildren => MergeChildren(Properties, SubShaders);
        public override void Accept(ShaderLabSyntaxVisitor visitor) => visitor.VisitShaderNode(this);
        public override T Accept<T>(ShaderLabSyntaxVisitor<T> visitor) => visitor.VisitShaderNode(this);

        public ShaderNode(List<SLToken> tokens) : base(tokens) { }
    }

    public class ShaderPropertyNode : ShaderLabSyntaxNode
    {
        public List<string> Attributes { get; set; }
        public string Uniform { get; set; }
        public string Name { get; set; }
        public ShaderPropertyKind Kind = ShaderPropertyKind.None;
        public (float Min, float Max)? RangeMinMax { get; set; } // Optional
        public ShaderPropertyValueNode Value { get; set; }

        protected override IEnumerable<ShaderLabSyntaxNode> GetChildren => new[] { Value };
        public override void Accept(ShaderLabSyntaxVisitor visitor) => visitor.VisitShaderPropertyNode(this);
        public override T Accept<T>(ShaderLabSyntaxVisitor<T> visitor) => visitor.VisitShaderPropertyNode(this);

        public ShaderPropertyNode(List<SLToken> tokens) : base(tokens) { }
    }

    public abstract class ShaderPropertyValueNode : ShaderLabSyntaxNode
    {
        protected override IEnumerable<ShaderLabSyntaxNode> GetChildren => Enumerable.Empty<ShaderLabSyntaxNode>();
        public ShaderPropertyValueNode(List<SLToken> tokens) : base(tokens) { }
    }

    public class ShaderPropertyValueFloatNode : ShaderPropertyValueNode
    {
        public float Number { get; set; } = 0;

        public override void Accept(ShaderLabSyntaxVisitor visitor) => visitor.VisitShaderPropertyValueFloatNode(this);
        public override T Accept<T>(ShaderLabSyntaxVisitor<T> visitor) => visitor.VisitShaderPropertyValueFloatNode(this);

        public ShaderPropertyValueFloatNode(List<SLToken> tokens) : base(tokens) { }
    }

    public class ShaderPropertyValueIntegerNode : ShaderPropertyValueNode
    {
        public int Number { get; set; } = 0;

        public override void Accept(ShaderLabSyntaxVisitor visitor) => visitor.VisitShaderPropertyValueIntegerNode(this);
        public override T Accept<T>(ShaderLabSyntaxVisitor<T> visitor) => visitor.VisitShaderPropertyValueIntegerNode(this);

        public ShaderPropertyValueIntegerNode(List<SLToken> tokens) : base(tokens) { }
    }

    public class ShaderPropertyValueVectorNode : ShaderPropertyValueNode
    {
        public bool HasWChannel { get; set; }
        public (float x, float y, float z, float w) Vector { get; set; } = default;

        public override void Accept(ShaderLabSyntaxVisitor visitor) => visitor.VisitShaderPropertyValueVectorNode(this);
        public override T Accept<T>(ShaderLabSyntaxVisitor<T> visitor) => visitor.VisitShaderPropertyValueVectorNode(this);

        public ShaderPropertyValueVectorNode(List<SLToken> tokens) : base(tokens) { }
    }

    public class ShaderPropertyValueColorNode : ShaderPropertyValueNode
    {
        public bool HasAlphaChannel { get; set; }
        public (float r, float g, float b, float a) Color { get; set; } = default;

        public override void Accept(ShaderLabSyntaxVisitor visitor) => visitor.VisitShaderPropertyValueColorNode(this);
        public override T Accept<T>(ShaderLabSyntaxVisitor<T> visitor) => visitor.VisitShaderPropertyValueColorNode(this);

        public ShaderPropertyValueColorNode(List<SLToken> tokens) : base(tokens) { }
    }

    public class ShaderPropertyValueTextureNode : ShaderPropertyValueNode
    {
        public TextureType Kind { get; set; }
        public string TextureName { get; set; }

        public override void Accept(ShaderLabSyntaxVisitor visitor) => visitor.VisitShaderPropertyValueTextureNode(this);
        public override T Accept<T>(ShaderLabSyntaxVisitor<T> visitor) => visitor.VisitShaderPropertyValueTextureNode(this);

        public ShaderPropertyValueTextureNode(List<SLToken> tokens) : base(tokens) { }
    }

    public class SubShaderNode : ShaderLabSyntaxNode
    {
        public List<ShaderLabCommandNode> Commands { get; set; }
        public List<ShaderPassNode> Passes { get; set; }
        public List<HLSLProgramBlock> ProgramBlocks { get; set; }
        public List<HLSLIncludeBlock> IncludeBlocks { get; set; }
        public HLSLProgramBlock? ProgramBlock => ProgramBlocks.Count > 0 ? (HLSLProgramBlock?)ProgramBlocks[0] : null;

        protected override IEnumerable<ShaderLabSyntaxNode> GetChildren => MergeChildren(Passes, Commands);
        public override void Accept(ShaderLabSyntaxVisitor visitor) => visitor.VisitSubShaderNode(this);
        public override T Accept<T>(ShaderLabSyntaxVisitor<T> visitor) => visitor.VisitSubShaderNode(this);

        public SubShaderNode(List<SLToken> tokens) : base(tokens) { }
    }

    public abstract class ShaderPassNode : ShaderLabSyntaxNode
    {
        protected override IEnumerable<ShaderLabSyntaxNode> GetChildren => Enumerable.Empty<ShaderLabSyntaxNode>();
        public ShaderPassNode(List<SLToken> tokens) : base(tokens) { }
    }

    public class ShaderCodePassNode : ShaderPassNode
    {
        public List<ShaderLabCommandNode> Commands { get; set; }
        public List<HLSLProgramBlock> ProgramBlocks { get; set; }
        public List<HLSLIncludeBlock> IncludeBlocks { get; set; }
        public HLSLProgramBlock? ProgramBlock => ProgramBlocks.Count > 0 ? (HLSLProgramBlock?)ProgramBlocks[0] : null;

        protected override IEnumerable<ShaderLabSyntaxNode> GetChildren => Commands;
        public override void Accept(ShaderLabSyntaxVisitor visitor) => visitor.VisitShaderCodePassNode(this);
        public override T Accept<T>(ShaderLabSyntaxVisitor<T> visitor) => visitor.VisitShaderCodePassNode(this);

        public ShaderCodePassNode(List<SLToken> tokens) : base(tokens) { }
    }

    public class ShaderGrabPassNode : ShaderPassNode
    {
        public string TextureName { get; set; } // Optional
        public List<ShaderLabCommandNode> Commands { get; set; }
        public List<HLSLIncludeBlock> IncludeBlocks { get; set; }

        public bool IsUnnamed => string.IsNullOrEmpty(TextureName);
        protected override IEnumerable<ShaderLabSyntaxNode> GetChildren => Commands;
        public override void Accept(ShaderLabSyntaxVisitor visitor) => visitor.VisitShaderGrabPassNode(this);
        public override T Accept<T>(ShaderLabSyntaxVisitor<T> visitor) => visitor.VisitShaderGrabPassNode(this);

        public ShaderGrabPassNode(List<SLToken> tokens) : base(tokens) { }
    }

    public class ShaderUsePassNode : ShaderPassNode
    {
        public string PassName { get; set; }

        public override void Accept(ShaderLabSyntaxVisitor visitor) => visitor.VisitShaderUsePassNode(this);
        public override T Accept<T>(ShaderLabSyntaxVisitor<T> visitor) => visitor.VisitShaderUsePassNode(this);

        public ShaderUsePassNode(List<SLToken> tokens) : base(tokens) { }
    }

    public abstract class ShaderLabCommandNode : ShaderLabSyntaxNode
    {
        protected override IEnumerable<ShaderLabSyntaxNode> GetChildren => Enumerable.Empty<ShaderLabSyntaxNode>();
        public ShaderLabCommandNode(List<SLToken> tokens) : base(tokens) { }
    }

    public class ShaderLabCommandTagsNode : ShaderLabCommandNode
    {
        public Dictionary<string, string> Tags { get; set; }

        public override void Accept(ShaderLabSyntaxVisitor visitor) => visitor.VisitShaderLabCommandTagsNode(this);
        public override T Accept<T>(ShaderLabSyntaxVisitor<T> visitor) => visitor.VisitShaderLabCommandTagsNode(this);

        public ShaderLabCommandTagsNode(List<SLToken> tokens) : base(tokens) { }
    }

    public class ShaderLabCommandLodNode : ShaderLabCommandNode
    {
        public int LodLevel { get; set; } = 0;

        public override void Accept(ShaderLabSyntaxVisitor visitor) => visitor.VisitShaderLabCommandLodNode(this);
        public override T Accept<T>(ShaderLabSyntaxVisitor<T> visitor) => visitor.VisitShaderLabCommandLodNode(this);

        public ShaderLabCommandLodNode(List<SLToken> tokens) : base(tokens) { }
    }

    public abstract class ShaderLabBasicToggleCommandNode : ShaderLabCommandNode
    {
        public PropertyReferenceOr<bool> Enabled { get; set; }
        public ShaderLabBasicToggleCommandNode(List<SLToken> tokens) : base(tokens) { }
    }

    public class ShaderLabCommandLightingNode : ShaderLabBasicToggleCommandNode
    {
        public override void Accept(ShaderLabSyntaxVisitor visitor) => visitor.VisitShaderLabCommandLightingNode(this);
        public override T Accept<T>(ShaderLabSyntaxVisitor<T> visitor) => visitor.VisitShaderLabCommandLightingNode(this);

        public ShaderLabCommandLightingNode(List<SLToken> tokens) : base(tokens) { }
    }

    public class ShaderLabCommandSeparateSpecularNode : ShaderLabBasicToggleCommandNode
    {
        public override void Accept(ShaderLabSyntaxVisitor visitor) => visitor.VisitShaderLabCommandSeparateSpecularNode(this);
        public override T Accept<T>(ShaderLabSyntaxVisitor<T> visitor) => visitor.VisitShaderLabCommandSeparateSpecularNode(this);

        public ShaderLabCommandSeparateSpecularNode(List<SLToken> tokens) : base(tokens) { }
    }

    public class ShaderLabCommandZWriteNode : ShaderLabBasicToggleCommandNode
    {
        public override void Accept(ShaderLabSyntaxVisitor visitor) => visitor.VisitShaderLabCommandZWriteNode(this);
        public override T Accept<T>(ShaderLabSyntaxVisitor<T> visitor) => visitor.VisitShaderLabCommandZWriteNode(this);

        public ShaderLabCommandZWriteNode(List<SLToken> tokens) : base(tokens) { }
    }

    public class ShaderLabCommandAlphaToMaskNode : ShaderLabBasicToggleCommandNode
    {
        public override void Accept(ShaderLabSyntaxVisitor visitor) => visitor.VisitShaderLabCommandAlphaToMaskNode(this);
        public override T Accept<T>(ShaderLabSyntaxVisitor<T> visitor) => visitor.VisitShaderLabCommandAlphaToMaskNode(this);

        public ShaderLabCommandAlphaToMaskNode(List<SLToken> tokens) : base(tokens) { }
    }

    public class ShaderLabCommandZClipNode : ShaderLabBasicToggleCommandNode
    {
        public override void Accept(ShaderLabSyntaxVisitor visitor) => visitor.VisitShaderLabCommandZClipNode(this);
        public override T Accept<T>(ShaderLabSyntaxVisitor<T> visitor) => visitor.VisitShaderLabCommandZClipNode(this);

        public ShaderLabCommandZClipNode(List<SLToken> tokens) : base(tokens) { }
    }

    public class ShaderLabCommandConservativeNode : ShaderLabBasicToggleCommandNode
    {
        public override void Accept(ShaderLabSyntaxVisitor visitor) => visitor.VisitShaderLabCommandConservativeNode(this);
        public override T Accept<T>(ShaderLabSyntaxVisitor<T> visitor) => visitor.VisitShaderLabCommandConservativeNode(this);

        public ShaderLabCommandConservativeNode(List<SLToken> tokens) : base(tokens) { }
    }

    public class ShaderLabCommandCullNode : ShaderLabCommandNode
    {
        public PropertyReferenceOr<CullMode> Mode { get; set; }

        public override void Accept(ShaderLabSyntaxVisitor visitor) => visitor.VisitShaderLabCommandCullNode(this);
        public override T Accept<T>(ShaderLabSyntaxVisitor<T> visitor) => visitor.VisitShaderLabCommandCullNode(this);

        public ShaderLabCommandCullNode(List<SLToken> tokens) : base(tokens) { }
    }

    public class ShaderLabCommandZTestNode : ShaderLabCommandNode
    {
        public PropertyReferenceOr<ComparisonMode> Mode { get; set; }

        public override void Accept(ShaderLabSyntaxVisitor visitor) => visitor.VisitShaderLabCommandZTestNode(this);
        public override T Accept<T>(ShaderLabSyntaxVisitor<T> visitor) => visitor.VisitShaderLabCommandZTestNode(this);

        public ShaderLabCommandZTestNode(List<SLToken> tokens) : base(tokens) { }
    }

    public class ShaderLabCommandBlendNode : ShaderLabCommandNode
    {
        public int RenderTarget { get; set; } = 0;
        public bool Enabled { get; set; }
        public PropertyReferenceOr<BlendFactor>? SourceFactorRGB { get; set; }
        public PropertyReferenceOr<BlendFactor>? DestinationFactorRGB { get; set; }
        public PropertyReferenceOr<BlendFactor>? SourceFactorAlpha { get; set; }
        public PropertyReferenceOr<BlendFactor>? DestinationFactorAlpha { get; set; }

        public override void Accept(ShaderLabSyntaxVisitor visitor) => visitor.VisitShaderLabCommandBlendNode(this);
        public override T Accept<T>(ShaderLabSyntaxVisitor<T> visitor) => visitor.VisitShaderLabCommandBlendNode(this);

        public ShaderLabCommandBlendNode(List<SLToken> tokens) : base(tokens) { }
    }

    public class ShaderLabCommandOffsetNode : ShaderLabCommandNode
    {
        public PropertyReferenceOr<float> Factor { get; set; }
        public PropertyReferenceOr<float> Units { get; set; }

        public override void Accept(ShaderLabSyntaxVisitor visitor) => visitor.VisitShaderLabCommandOffsetNode(this);
        public override T Accept<T>(ShaderLabSyntaxVisitor<T> visitor) => visitor.VisitShaderLabCommandOffsetNode(this);

        public ShaderLabCommandOffsetNode(List<SLToken> tokens) : base(tokens) { }
    }

    public class ShaderLabCommandColorMaskNode : ShaderLabCommandNode
    {
        public PropertyReferenceOr<string> Mask { get; set; }
        public int RenderTarget { get; set; } = 0;

        public bool IsZeroMask => Mask.Value == "0";

        public override void Accept(ShaderLabSyntaxVisitor visitor) => visitor.VisitShaderLabCommandColorMaskNode(this);
        public override T Accept<T>(ShaderLabSyntaxVisitor<T> visitor) => visitor.VisitShaderLabCommandColorMaskNode(this);

        public ShaderLabCommandColorMaskNode(List<SLToken> tokens) : base(tokens) { }
    }

    public class ShaderLabCommandAlphaTestNode : ShaderLabCommandNode
    {
        public PropertyReferenceOr<ComparisonMode> Mode { get; set; }
        public PropertyReferenceOr<float>? AlphaValue { get; set; } // Optional

        public override void Accept(ShaderLabSyntaxVisitor visitor) => visitor.VisitShaderLabCommandAlphaTestNode(this);
        public override T Accept<T>(ShaderLabSyntaxVisitor<T> visitor) => visitor.VisitShaderLabCommandAlphaTestNode(this);

        public ShaderLabCommandAlphaTestNode(List<SLToken> tokens) : base(tokens) { }
    }

    public class ShaderLabCommandFogNode : ShaderLabCommandNode
    {
        public bool Enabled { get; set; }
        public (float r, float g, float b, float a)? Color { get; set; } // Optional

        public override void Accept(ShaderLabSyntaxVisitor visitor) => visitor.VisitShaderLabCommandFogNode(this);
        public override T Accept<T>(ShaderLabSyntaxVisitor<T> visitor) => visitor.VisitShaderLabCommandFogNode(this);

        public ShaderLabCommandFogNode(List<SLToken> tokens) : base(tokens) { }
    }

    public class ShaderLabCommandNameNode : ShaderLabCommandNode
    {
        public string Name { get; set; }

        public override void Accept(ShaderLabSyntaxVisitor visitor) => visitor.VisitShaderLabCommandNameNode(this);
        public override T Accept<T>(ShaderLabSyntaxVisitor<T> visitor) => visitor.VisitShaderLabCommandNameNode(this);

        public ShaderLabCommandNameNode(List<SLToken> tokens) : base(tokens) { }
    }

    public class ShaderLabCommandBindChannelsNode : ShaderLabCommandNode
    {
        public Dictionary<BindChannel, BindChannel> Bindings { get; set; }

        public override void Accept(ShaderLabSyntaxVisitor visitor) => visitor.VisitShaderLabCommandBindChannelsNode(this);
        public override T Accept<T>(ShaderLabSyntaxVisitor<T> visitor) => visitor.VisitShaderLabCommandBindChannelsNode(this);

        public ShaderLabCommandBindChannelsNode(List<SLToken> tokens) : base(tokens) { }
    }

    public class ShaderLabCommandColorNode : ShaderLabCommandNode
    {
        public bool HasAlphaChannel { get; set; }
        public PropertyReferenceOr<(float r, float g, float b, float a)> Color { get; set; }

        public override void Accept(ShaderLabSyntaxVisitor visitor) => visitor.VisitShaderLabCommandColorNode(this);
        public override T Accept<T>(ShaderLabSyntaxVisitor<T> visitor) => visitor.VisitShaderLabCommandColorNode(this);

        public ShaderLabCommandColorNode(List<SLToken> tokens) : base(tokens) { }
    }

    public class ShaderLabCommandBlendOpNode : ShaderLabCommandNode
    {
        public PropertyReferenceOr<BlendOp> BlendOp { get; set; }
        public PropertyReferenceOr<BlendOp>? BlendOpAlpha { get; set; }

        public override void Accept(ShaderLabSyntaxVisitor visitor) => visitor.VisitShaderLabCommandBlendOpNode(this);
        public override T Accept<T>(ShaderLabSyntaxVisitor<T> visitor) => visitor.VisitShaderLabCommandBlendOpNode(this);

        public ShaderLabCommandBlendOpNode(List<SLToken> tokens) : base(tokens) { }
    }

    public class ShaderLabCommandMaterialNode : ShaderLabCommandNode
    {
        public Dictionary<FixedFunctionMaterialProperty, PropertyReferenceOr<(float r, float g, float b, float a)>> Properties { get; set; }

        public override void Accept(ShaderLabSyntaxVisitor visitor) => visitor.VisitShaderLabCommandMaterialNode(this);
        public override T Accept<T>(ShaderLabSyntaxVisitor<T> visitor) => visitor.VisitShaderLabCommandMaterialNode(this);

        public ShaderLabCommandMaterialNode(List<SLToken> tokens) : base(tokens) { }
    }

    public class ShaderLabCommandSetTextureNode : ShaderLabCommandNode
    {
        // TODO: Not the lazy way
        public string TextureName { get; set; }
        public List<SLToken> Body { get; set; }

        public override void Accept(ShaderLabSyntaxVisitor visitor) => visitor.VisitShaderLabCommandSetTextureNode(this);
        public override T Accept<T>(ShaderLabSyntaxVisitor<T> visitor) => visitor.VisitShaderLabCommandSetTextureNode(this);

        public ShaderLabCommandSetTextureNode(List<SLToken> tokens) : base(tokens) { }
    }

    public class ShaderLabCommandColorMaterialNode : ShaderLabCommandNode
    {
        public bool AmbientAndDiffuse { get; set; }
        public bool Emission => !AmbientAndDiffuse;

        public override void Accept(ShaderLabSyntaxVisitor visitor) => visitor.VisitShaderLabCommandColorMaterialNode(this);
        public override T Accept<T>(ShaderLabSyntaxVisitor<T> visitor) => visitor.VisitShaderLabCommandColorMaterialNode(this);

        public ShaderLabCommandColorMaterialNode(List<SLToken> tokens) : base(tokens) { }
    }

    public class ShaderLabCommandStencilNode : ShaderLabCommandNode
    {
        public PropertyReferenceOr<byte> Ref { get; set; }
        public PropertyReferenceOr<byte> ReadMask { get; set; }
        public PropertyReferenceOr<byte> WriteMask { get; set; }
        public PropertyReferenceOr<ComparisonMode> ComparisonOperationBack { get; set; }
        public PropertyReferenceOr<StencilOp> PassOperationBack { get; set; }
        public PropertyReferenceOr<StencilOp> FailOperationBack { get; set; }
        public PropertyReferenceOr<StencilOp> ZFailOperationBack { get; set; }
        public PropertyReferenceOr<ComparisonMode> ComparisonOperationFront { get; set; }
        public PropertyReferenceOr<StencilOp> PassOperationFront { get; set; }
        public PropertyReferenceOr<StencilOp> FailOperationFront { get; set; }
        public PropertyReferenceOr<StencilOp> ZFailOperationFront { get; set; }
        public PropertyReferenceOr<ComparisonMode> ComparisonOperation => ComparisonOperationFront;
        public PropertyReferenceOr<StencilOp> PassOperation => PassOperationFront;
        public PropertyReferenceOr<StencilOp> FailOperation => FailOperationFront;
        public PropertyReferenceOr<StencilOp> ZFailOperation => ZFailOperationFront;

        public override void Accept(ShaderLabSyntaxVisitor visitor) => visitor.VisitShaderLabCommandStencilNode(this);
        public override T Accept<T>(ShaderLabSyntaxVisitor<T> visitor) => visitor.VisitShaderLabCommandStencilNode(this);

        public ShaderLabCommandStencilNode(List<SLToken> tokens) : base(tokens) { }
    }

    public class ShaderLabCommandPackageRequirementsNode : ShaderLabCommandNode
    {
        // Key: Package name, Value: Package version (optional)
        public Dictionary<string, string> References { get; set; }

        public override void Accept(ShaderLabSyntaxVisitor visitor) => visitor.VisitShaderLabCommandPackageRequirementsNode(this);
        public override T Accept<T>(ShaderLabSyntaxVisitor<T> visitor) => visitor.VisitShaderLabCommandPackageRequirementsNode(this);

        public ShaderLabCommandPackageRequirementsNode(List<SLToken> tokens) : base(tokens) { }
    }
    #endregion
}


// ShaderLab/ShaderLabSyntaxFacts.cs
namespace UnityShaderParser.ShaderLab
{
    public static class ShaderLabSyntaxFacts
    {
        public static bool TryParseShaderLabKeyword(string keyword, out TokenKind token)
        {
            token = default;

            switch (keyword.ToLower())
            {
                case "shader": token = TokenKind.ShaderKeyword; return true;
                case "properties": token = TokenKind.PropertiesKeyword; return true;
                case "range": token = TokenKind.RangeKeyword; return true;
                case "float": token = TokenKind.FloatKeyword; return true;
                case "integer": token = TokenKind.IntegerKeyword; return true;
                case "int": token = TokenKind.IntKeyword; return true;
                case "color": token = TokenKind.ColorKeyword; return true;
                case "vector": token = TokenKind.VectorKeyword; return true;
                case "2d": token = TokenKind._2DKeyword; return true;
                case "3d": token = TokenKind._3DKeyword; return true;
                case "cube": token = TokenKind.CubeKeyword; return true;
                case "2darray": token = TokenKind._2DArrayKeyword; return true;
                case "3darray": token = TokenKind._3DArrayKeyword; return true;
                case "cubearray": token = TokenKind.CubeArrayKeyword; return true;
                case "any": token = TokenKind.AnyKeyword; return true;
                case "rect": token = TokenKind.RectKeyword; return true;
                case "category": token = TokenKind.CategoryKeyword; return true;
                case "subshader": token = TokenKind.SubShaderKeyword; return true;
                case "tags": token = TokenKind.TagsKeyword; return true;
                case "pass": token = TokenKind.PassKeyword; return true;
                case "cgprogram": token = TokenKind.CgProgramKeyword; return true;
                case "cginclude": token = TokenKind.CgIncludeKeyword; return true;
                case "endcg": token = TokenKind.EndCgKeyword; return true;
                case "hlslprogram": token = TokenKind.HlslProgramKeyword; return true;
                case "hlslinclude": token = TokenKind.HlslIncludeKeyword; return true;
                case "endhlsl": token = TokenKind.EndHlslKeyword; return true;
                case "glslprogram": token = TokenKind.GlslProgramKeyword; return true;
                case "glslinclude": token = TokenKind.GlslIncludeKeyword; return true;
                case "endglsl": token = TokenKind.EndGlslKeyword; return true;
                case "fallback": token = TokenKind.FallbackKeyword; return true;
                case "customeditor": token = TokenKind.CustomEditorKeyword; return true;
                case "cull": token = TokenKind.CullKeyword; return true;
                case "zwrite": token = TokenKind.ZWriteKeyword; return true;
                case "ztest": token = TokenKind.ZTestKeyword; return true;
                case "offset": token = TokenKind.OffsetKeyword; return true;
                case "blend": token = TokenKind.BlendKeyword; return true;
                case "blendop": token = TokenKind.BlendOpKeyword; return true;
                case "colormask": token = TokenKind.ColorMaskKeyword; return true;
                case "alphatomask": token = TokenKind.AlphaToMaskKeyword; return true;
                case "zclip": token = TokenKind.ZClipKeyword; return true;
                case "conservative": token = TokenKind.ConservativeKeyword; return true;
                case "lod": token = TokenKind.LodKeyword; return true;
                case "name": token = TokenKind.NameKeyword; return true;
                case "lighting": token = TokenKind.LightingKeyword; return true;
                case "stencil": token = TokenKind.StencilKeyword; return true;
                case "ref": token = TokenKind.RefKeyword; return true;
                case "readmask": token = TokenKind.ReadMaskKeyword; return true;
                case "writemask": token = TokenKind.WriteMaskKeyword; return true;
                case "comp": token = TokenKind.CompKeyword; return true;
                case "compback": token = TokenKind.CompBackKeyword; return true;
                case "compfront": token = TokenKind.CompFrontKeyword; return true;
                case "fail": token = TokenKind.FailKeyword; return true;
                case "zfail": token = TokenKind.ZFailKeyword; return true;
                case "failback": token = TokenKind.FailBackKeyword; return true;
                case "failfront": token = TokenKind.FailFrontKeyword; return true;
                case "zfailback": token = TokenKind.ZFailBackKeyword; return true;
                case "zfailfront": token = TokenKind.ZFailFrontKeyword; return true;
                case "passfront": token = TokenKind.PassFrontKeyword; return true;
                case "passback": token = TokenKind.PassBackKeyword; return true;
                case "usepass": token = TokenKind.UsePassKeyword; return true;
                case "grabpass": token = TokenKind.GrabPassKeyword; return true;
                case "dependency": token = TokenKind.DependencyKeyword; return true;
                case "material": token = TokenKind.MaterialKeyword; return true;
                case "diffuse": token = TokenKind.DiffuseKeyword; return true;
                case "ambient": token = TokenKind.AmbientKeyword; return true;
                case "shininess": token = TokenKind.ShininessKeyword; return true;
                case "specular": token = TokenKind.SpecularKeyword; return true;
                case "emission": token = TokenKind.EmissionKeyword; return true;
                case "ambientanddiffuse": token = TokenKind.AmbientAndDiffuseKeyword; return true;
                case "fog": token = TokenKind.FogKeyword; return true;
                case "mode": token = TokenKind.ModeKeyword; return true;
                case "density": token = TokenKind.DensityKeyword; return true;
                case "separatespecular": token = TokenKind.SeparateSpecularKeyword; return true;
                case "settexture": token = TokenKind.SetTextureKeyword; return true;
                case "combine": token = TokenKind.CombineKeyword; return true;
                case "alpha": token = TokenKind.AlphaKeyword; return true;
                case "lerp": token = TokenKind.LerpKeyword; return true;
                case "double": token = TokenKind.DoubleKeyword; return true;
                case "quad": token = TokenKind.QuadKeyword; return true;
                case "constantcolor": token = TokenKind.ConstantColorKeyword; return true;
                case "matrix": token = TokenKind.MatrixKeyword; return true;
                case "alphatest": token = TokenKind.AlphaTestKeyword; return true;
                case "colormaterial": token = TokenKind.ColorMaterialKeyword; return true;
                case "bindchannels": token = TokenKind.BindChannelsKeyword; return true;
                case "bind": token = TokenKind.BindKeyword; return true;
                case "packagerequirements": token = TokenKind.PackageRequirementsKeyword; return true;
                case "true": token = TokenKind.TrueKeyword; return true;
                case "false": token = TokenKind.FalseKeyword; return true;
                case "off": token = TokenKind.OffKeyword; return true;
                case "on": token = TokenKind.OnKeyword; return true;
                case "front": token = TokenKind.FrontKeyword; return true;
                case "back": token = TokenKind.BackKeyword; return true;
                case "one": token = TokenKind.OneKeyword; return true;
                case "zero": token = TokenKind.ZeroKeyword; return true;
                case "srccolor": token = TokenKind.SrcColorKeyword; return true;
                case "srcalpha": token = TokenKind.SrcAlphaKeyword; return true;
                case "srcalphasaturate": token = TokenKind.SrcAlphaSaturateKeyword; return true;
                case "dstcolor": token = TokenKind.DstColorKeyword; return true;
                case "dstalpha": token = TokenKind.DstAlphaKeyword; return true;
                case "oneminussrccolor": token = TokenKind.OneMinusSrcColorKeyword; return true;
                case "oneminussrcalpha": token = TokenKind.OneMinusSrcAlphaKeyword; return true;
                case "oneminusdstcolor": token = TokenKind.OneMinusDstColorKeyword; return true;
                case "oneminusdstalpha": token = TokenKind.OneMinusDstAlphaKeyword; return true;
                case "global": token = TokenKind.GlobalKeyword; return true;
                case "add": token = TokenKind.AddKeyword; return true;
                case "sub": token = TokenKind.SubKeyword; return true;
                case "revsub": token = TokenKind.RevSubKeyword; return true;
                case "min": token = TokenKind.MinKeyword; return true;
                case "max": token = TokenKind.MaxKeyword; return true;
                case "logicalclear": token = TokenKind.LogicalClearKeyword; return true;
                case "logicalset": token = TokenKind.LogicalSetKeyword; return true;
                case "logicalcopy": token = TokenKind.LogicalCopyKeyword; return true;
                case "logicalcopyinverted": token = TokenKind.LogicalCopyInvertedKeyword; return true;
                case "logicalnoop": token = TokenKind.LogicalNoopKeyword; return true;
                case "logicalinvert": token = TokenKind.LogicalInvertKeyword; return true;
                case "logicaland": token = TokenKind.LogicalAndKeyword; return true;
                case "logicalnand": token = TokenKind.LogicalNandKeyword; return true;
                case "logicalor": token = TokenKind.LogicalOrKeyword; return true;
                case "logicalnor": token = TokenKind.LogicalNorKeyword; return true;
                case "logicalxor": token = TokenKind.LogicalXorKeyword; return true;
                case "logicalequiv": token = TokenKind.LogicalEquivKeyword; return true;
                case "logicalandreverse": token = TokenKind.LogicalAndReverseKeyword; return true;
                case "logicalorreverse": token = TokenKind.LogicalOrReverseKeyword; return true;
                case "logicalorinverted": token = TokenKind.LogicalOrInvertedKeyword; return true;
                case "multiply": token = TokenKind.MultiplyKeyword; return true;
                case "screen": token = TokenKind.ScreenKeyword; return true;
                case "overlay": token = TokenKind.OverlayKeyword; return true;
                case "darken": token = TokenKind.DarkenKeyword; return true;
                case "lighten": token = TokenKind.LightenKeyword; return true;
                case "colordodge": token = TokenKind.ColorDodgeKeyword; return true;
                case "colorburn": token = TokenKind.ColorBurnKeyword; return true;
                case "hardlight": token = TokenKind.HardLightKeyword; return true;
                case "softlight": token = TokenKind.SoftLightKeyword; return true;
                case "difference": token = TokenKind.DifferenceKeyword; return true;
                case "exclusion": token = TokenKind.ExclusionKeyword; return true;
                case "hslhue": token = TokenKind.HSLHueKeyword; return true;
                case "hslsaturation": token = TokenKind.HSLSaturationKeyword; return true;
                case "hslcolor": token = TokenKind.HSLColorKeyword; return true;
                case "hslluminosity": token = TokenKind.HSLLuminosityKeyword; return true;
                default: return false;
            }
        }

        public static bool TryParseBindChannelName(string name, out BindChannel bindChannel)
        {
            bindChannel = default;

            switch (name.ToLower())
            {
                case "vertex": bindChannel = BindChannel.Vertex; return true;
                case "normal": bindChannel = BindChannel.Normal; return true;
                case "tangent": bindChannel = BindChannel.Tangent; return true;
                case "texcoord0": case "texcoord": bindChannel = BindChannel.TexCoord0; return true;
                case "texcoord1": bindChannel = BindChannel.TexCoord1; return true;
                case "texcoord2": bindChannel = BindChannel.TexCoord2; return true;
                case "texcoord3": bindChannel = BindChannel.TexCoord3; return true;
                case "texcoord4": bindChannel = BindChannel.TexCoord4; return true;
                case "texcoord5": bindChannel = BindChannel.TexCoord5; return true;
                case "texcoord6": bindChannel = BindChannel.TexCoord6; return true;
                case "texcoord7": bindChannel = BindChannel.TexCoord7; return true;
                case "color": bindChannel = BindChannel.Color; return true;
                default: return false;
            }
        }

        public static TextureType ShaderPropertyTypeToTextureType(ShaderPropertyKind kind)
        {
            switch (kind)
            {
                case ShaderPropertyKind.Texture2D: return TextureType.Texture2D; 
                case ShaderPropertyKind.Texture3D: return TextureType.Texture3D; 
                case ShaderPropertyKind.TextureCube: return TextureType.TextureCube; 
                case ShaderPropertyKind.TextureAny: return TextureType.TextureAny; 
                case ShaderPropertyKind.Texture2DArray: return TextureType.Texture2DArray; 
                case ShaderPropertyKind.Texture3DArray: return TextureType.Texture3DArray; 
                case ShaderPropertyKind.TextureCubeArray: return TextureType.TextureCubeArray;
                default: return default;
            }
        }

        public static bool TryConvertKeywordToString(TokenKind kind, out string result)
        {
            switch (kind)
            {
                case TokenKind.ShaderKeyword: result = "Shader"; return true;
                case TokenKind.PropertiesKeyword: result = "Properties"; return true;
                case TokenKind.RangeKeyword: result = "Range"; return true;
                case TokenKind.FloatKeyword: result = "Float"; return true;
                case TokenKind.IntegerKeyword: result = "Integer"; return true;
                case TokenKind.IntKeyword: result = "Int"; return true;
                case TokenKind.ColorKeyword: result = "Color"; return true;
                case TokenKind.VectorKeyword: result = "Vector"; return true;
                case TokenKind._2DKeyword: result = "2D"; return true;
                case TokenKind._3DKeyword: result = "3D"; return true;
                case TokenKind.CubeKeyword: result = "Cube"; return true;
                case TokenKind._2DArrayKeyword: result = "2DArray"; return true;
                case TokenKind._3DArrayKeyword: result = "3DArray"; return true;
                case TokenKind.CubeArrayKeyword: result = "CubeArray"; return true;
                case TokenKind.AnyKeyword: result = "Any"; return true;
                case TokenKind.RectKeyword: result = "Rect"; return true;
                case TokenKind.CategoryKeyword: result = "Category"; return true;
                case TokenKind.SubShaderKeyword: result = "SubShader"; return true;
                case TokenKind.TagsKeyword: result = "Tags"; return true;
                case TokenKind.PassKeyword: result = "Pass"; return true;
                case TokenKind.CgProgramKeyword: result = "CGPROGRAM"; return true;
                case TokenKind.CgIncludeKeyword: result = "CGINCLUDE"; return true;
                case TokenKind.EndCgKeyword: result = "ENDCG"; return true;
                case TokenKind.HlslProgramKeyword: result = "HLSLPROGRAM"; return true;
                case TokenKind.HlslIncludeKeyword: result = "HLSLINCLUDE"; return true;
                case TokenKind.EndHlslKeyword: result = "ENDHLSL"; return true;
                case TokenKind.GlslProgramKeyword: result = "GLSLPROGRAM"; return true;
                case TokenKind.GlslIncludeKeyword: result = "GLSLINCLUDE"; return true;
                case TokenKind.EndGlslKeyword: result = "ENDGLSL"; return true;
                case TokenKind.FallbackKeyword: result = "Fallback"; return true;
                case TokenKind.CustomEditorKeyword: result = "CustomEditor"; return true;
                case TokenKind.CullKeyword: result = "Cull"; return true;
                case TokenKind.ZWriteKeyword: result = "ZWrite"; return true;
                case TokenKind.ZTestKeyword: result = "ZTest"; return true;
                case TokenKind.OffsetKeyword: result = "Offset"; return true;
                case TokenKind.BlendKeyword: result = "Blend"; return true;
                case TokenKind.BlendOpKeyword: result = "BlendOp"; return true;
                case TokenKind.ColorMaskKeyword: result = "ColorMask"; return true;
                case TokenKind.AlphaToMaskKeyword: result = "AlphaToMask"; return true;
                case TokenKind.ZClipKeyword: result = "ZClip"; return true;
                case TokenKind.ConservativeKeyword: result = "Conservative"; return true;
                case TokenKind.LodKeyword: result = "LOD"; return true;
                case TokenKind.NameKeyword: result = "Name"; return true;
                case TokenKind.LightingKeyword: result = "Lighting"; return true;
                case TokenKind.StencilKeyword: result = "Stencil"; return true;
                case TokenKind.RefKeyword: result = "Ref"; return true;
                case TokenKind.ReadMaskKeyword: result = "ReadMask"; return true;
                case TokenKind.WriteMaskKeyword: result = "WriteMask"; return true;
                case TokenKind.CompKeyword: result = "Comp"; return true;
                case TokenKind.CompBackKeyword: result = "CompBack"; return true;
                case TokenKind.CompFrontKeyword: result = "CompFront"; return true;
                case TokenKind.FailKeyword: result = "Fail"; return true;
                case TokenKind.ZFailKeyword: result = "ZFail"; return true;
                case TokenKind.FailBackKeyword: result = "FailBack"; return true;
                case TokenKind.FailFrontKeyword: result = "failFront"; return true;
                case TokenKind.ZFailBackKeyword: result = "ZFailBack"; return true;
                case TokenKind.ZFailFrontKeyword: result = "ZFailFront"; return true;
                case TokenKind.PassFrontKeyword: result = "PassFront"; return true;
                case TokenKind.PassBackKeyword: result = "PassBack"; return true;
                case TokenKind.UsePassKeyword: result = "UsePass"; return true;
                case TokenKind.GrabPassKeyword: result = "GrabPass"; return true;
                case TokenKind.DependencyKeyword: result = "Dependency"; return true;
                case TokenKind.MaterialKeyword: result = "Material"; return true;
                case TokenKind.DiffuseKeyword: result = "Diffuse"; return true;
                case TokenKind.AmbientKeyword: result = "Ambient"; return true;
                case TokenKind.ShininessKeyword: result = "Shininess"; return true;
                case TokenKind.SpecularKeyword: result = "Specular"; return true;
                case TokenKind.EmissionKeyword: result = "Emission"; return true;
                case TokenKind.AmbientAndDiffuseKeyword: result = "AmbientAndDiffuse"; return true;
                case TokenKind.FogKeyword: result = "Fog"; return true;
                case TokenKind.ModeKeyword: result = "Mode"; return true;
                case TokenKind.DensityKeyword: result = "Density"; return true;
                case TokenKind.SeparateSpecularKeyword: result = "SeparateSpecular"; return true;
                case TokenKind.SetTextureKeyword: result = "SetTexture"; return true;
                case TokenKind.CombineKeyword: result = "Combine"; return true;
                case TokenKind.AlphaKeyword: result = "Alpha"; return true;
                case TokenKind.LerpKeyword: result = "Lerp"; return true;
                case TokenKind.DoubleKeyword: result = "DOUBLE"; return true;
                case TokenKind.QuadKeyword: result = "Quad"; return true;
                case TokenKind.ConstantColorKeyword: result = "constantColor"; return true;
                case TokenKind.MatrixKeyword: result = "Matrix"; return true;
                case TokenKind.AlphaTestKeyword: result = "AlphaTest"; return true;
                case TokenKind.ColorMaterialKeyword: result = "ColorMaterial"; return true;
                case TokenKind.BindChannelsKeyword: result = "BindChannels"; return true;
                case TokenKind.PackageRequirementsKeyword: result = "PackageRequirements"; return true;
                case TokenKind.BindKeyword: result = "Bind"; return true;
                case TokenKind.TrueKeyword: result = "True"; return true;
                case TokenKind.FalseKeyword: result = "False"; return true;
                case TokenKind.OffKeyword: result = "Off"; return true;
                case TokenKind.OnKeyword: result = "On"; return true;
                case TokenKind.FrontKeyword: result = "Front"; return true;
                case TokenKind.BackKeyword: result = "Back"; return true;
                case TokenKind.OneKeyword: result = "One"; return true;
                case TokenKind.ZeroKeyword: result = "Zero"; return true;
                case TokenKind.SrcColorKeyword: result = "SrcColor"; return true;
                case TokenKind.SrcAlphaKeyword: result = "SrcAlpha"; return true;
                case TokenKind.SrcAlphaSaturateKeyword: result = "SrcAlphaSaturate"; return true;
                case TokenKind.DstColorKeyword: result = "DstColor"; return true;
                case TokenKind.DstAlphaKeyword: result = "DstAlpha"; return true;
                case TokenKind.OneMinusSrcColorKeyword: result = "OneMinusSrcColor"; return true;
                case TokenKind.OneMinusSrcAlphaKeyword: result = "OneMinusSrcAlpha"; return true;
                case TokenKind.OneMinusDstColorKeyword: result = "OneMinusDstColor"; return true;
                case TokenKind.OneMinusDstAlphaKeyword: result = "OneMinusDstAlpha"; return true;
                case TokenKind.GlobalKeyword: result = "Global"; return true;
                case TokenKind.AddKeyword: result = "Add"; return true;
                case TokenKind.SubKeyword: result = "Sub"; return true;
                case TokenKind.RevSubKeyword: result = "RevSub"; return true;
                case TokenKind.MinKeyword: result = "Min"; return true;
                case TokenKind.MaxKeyword: result = "Max"; return true;
                case TokenKind.LogicalClearKeyword: result = "LogicalClear"; return true;
                case TokenKind.LogicalSetKeyword: result = "LogicalSet"; return true;
                case TokenKind.LogicalCopyKeyword: result = "LogicalCopy"; return true;
                case TokenKind.LogicalCopyInvertedKeyword: result = "LogicalCopyInverted"; return true;
                case TokenKind.LogicalNoopKeyword: result = "LogicalNoop"; return true;
                case TokenKind.LogicalInvertKeyword: result = "LogicalInvert"; return true;
                case TokenKind.LogicalAndKeyword: result = "LogicalAnd"; return true;
                case TokenKind.LogicalNandKeyword: result = "LogicalNand"; return true;
                case TokenKind.LogicalOrKeyword: result = "LogicalOr"; return true;
                case TokenKind.LogicalNorKeyword: result = "LogicalNor"; return true;
                case TokenKind.LogicalXorKeyword: result = "LogicalXor"; return true;
                case TokenKind.LogicalEquivKeyword: result = "LogicalEquiv"; return true;
                case TokenKind.LogicalAndReverseKeyword: result = "LogicalAndReverse"; return true;
                case TokenKind.LogicalOrReverseKeyword: result = "LogicalOrReverse"; return true;
                case TokenKind.LogicalOrInvertedKeyword: result = "LogicalOrInverted"; return true;
                case TokenKind.MultiplyKeyword: result = "Multiply"; return true;
                case TokenKind.ScreenKeyword: result = "Screen"; return true;
                case TokenKind.OverlayKeyword: result = "Overlay"; return true;
                case TokenKind.DarkenKeyword: result = "Darken"; return true;
                case TokenKind.LightenKeyword: result = "Lighten"; return true;
                case TokenKind.ColorDodgeKeyword: result = "ColorDodge"; return true;
                case TokenKind.ColorBurnKeyword: result = "ColorBurn"; return true;
                case TokenKind.HardLightKeyword: result = "HardLight"; return true;
                case TokenKind.SoftLightKeyword: result = "SoftLight"; return true;
                case TokenKind.DifferenceKeyword: result = "Difference"; return true;
                case TokenKind.ExclusionKeyword: result = "Exclusion"; return true;
                case TokenKind.HSLHueKeyword: result = "HSLHue"; return true;
                case TokenKind.HSLSaturationKeyword: result = "HSLSaturation"; return true;
                case TokenKind.HSLColorKeyword: result = "HSLColor"; return true;
                case TokenKind.HSLLuminosityKeyword: result = "HSLLuminosity"; return true;
                default: result = string.Empty; return false;
            }
        }

        public static string IdentifierOrKeywordToString(Common.Token<TokenKind> token)
        {
            if (token.Identifier != null)
                return token.Identifier;

            if (TryConvertKeywordToString(token.Kind, out string result))
                return result;

            return "__INVALID";
        }

        public static string TokenToString(Common.Token<TokenKind> token)
        {
            switch (token.Kind)
            {
                case TokenKind.InvalidToken: return "__INVALID";
                case TokenKind.OpenParenToken: return "(";
                case TokenKind.CloseParenToken: return ")";
                case TokenKind.OpenBracketToken: return "[";
                case TokenKind.CloseBracketToken: return "]";
                case TokenKind.OpenBraceToken: return "{";
                case TokenKind.CloseBraceToken: return "}";
                case TokenKind.SemiToken: return ";";
                case TokenKind.CommaToken: return ",";
                case TokenKind.LessThanToken: return "<";
                case TokenKind.LessThanEqualsToken: return "<=";
                case TokenKind.GreaterThanToken: return ">";
                case TokenKind.GreaterThanEqualsToken: return ">=";
                case TokenKind.LessThanLessThanToken: return "<<";
                case TokenKind.GreaterThanGreaterThanToken: return ">>";
                case TokenKind.PlusToken: return "+";
                case TokenKind.PlusPlusToken: return "++";
                case TokenKind.MinusToken: return "-";
                case TokenKind.MinusMinusToken: return "--";
                case TokenKind.AsteriskToken: return "*";
                case TokenKind.SlashToken: return "/";
                case TokenKind.PercentToken: return "%";
                case TokenKind.AmpersandToken: return "&";
                case TokenKind.BarToken: return "|";
                case TokenKind.AmpersandAmpersandToken: return "&&";
                case TokenKind.BarBarToken: return "||";
                case TokenKind.CaretToken: return "^";
                case TokenKind.NotToken: return "!";
                case TokenKind.TildeToken: return "~";
                case TokenKind.QuestionToken: return "?";
                case TokenKind.ColonToken: return ":";
                case TokenKind.ColonColonToken: return "::";
                case TokenKind.EqualsToken: return "=";
                case TokenKind.AsteriskEqualsToken: return "*=";
                case TokenKind.SlashEqualsToken: return "/=";
                case TokenKind.PercentEqualsToken: return "%=";
                case TokenKind.PlusEqualsToken: return "+=";
                case TokenKind.MinusEqualsToken: return "-=";
                case TokenKind.LessThanLessThanEqualsToken: return "<<=";
                case TokenKind.GreaterThanGreaterThanEqualsToken: return ">>=";
                case TokenKind.AmpersandEqualsToken: return "&=";
                case TokenKind.CaretEqualsToken: return "^=";
                case TokenKind.BarEqualsToken: return "|=";
                case TokenKind.EqualsEqualsToken: return "==";
                case TokenKind.ExclamationEqualsToken: return "!=";
                case TokenKind.DotToken: return ".";

                case TokenKind.BracketedStringLiteralToken: return $"[{token.Identifier}]";
                case TokenKind.StringLiteralToken: return $"\"{token.Identifier}\"";

                default: return IdentifierOrKeywordToString(token);
            }
        }

        public static string TokensToString(IEnumerable<Common.Token<TokenKind>> tokens)
        {
            return string.Join(" ", tokens.Select(x => TokenToString(x)));
        }
    }
}


// ShaderLab/ShaderLabSyntaxVisitor.cs
namespace UnityShaderParser.ShaderLab
{
    public abstract class ShaderLabSyntaxVisitor
    {
        protected virtual void DefaultVisit(ShaderLabSyntaxNode node)
        {
            foreach (var child in node.Children)
            {
                child.Accept(this);
            }
        }

        public void VisitMany(IEnumerable<ShaderLabSyntaxNode> nodes)
        {
            foreach (ShaderLabSyntaxNode node in nodes)
            {
                Visit(node);
            }
        }

        public void VisitMany<T>(IList<T> nodes, Action runBetween)
            where T : ShaderLabSyntaxNode
        {
            for (int i = 0; i < nodes.Count; i++)
            {
                Visit(nodes[i]);
                if (i < nodes.Count - 1)
                    runBetween();
            }
        }

        public virtual void Visit(ShaderLabSyntaxNode node) => node?.Accept(this);
        public virtual void VisitShaderNode(ShaderNode node) => DefaultVisit(node);
        public virtual void VisitShaderPropertyNode(ShaderPropertyNode node) => DefaultVisit(node);
        public virtual void VisitShaderPropertyValueFloatNode(ShaderPropertyValueFloatNode node) => DefaultVisit(node);
        public virtual void VisitShaderPropertyValueIntegerNode(ShaderPropertyValueIntegerNode node) => DefaultVisit(node);
        public virtual void VisitShaderPropertyValueVectorNode(ShaderPropertyValueVectorNode node) => DefaultVisit(node);
        public virtual void VisitShaderPropertyValueColorNode(ShaderPropertyValueColorNode node) => DefaultVisit(node);
        public virtual void VisitShaderPropertyValueTextureNode(ShaderPropertyValueTextureNode node) => DefaultVisit(node);
        public virtual void VisitSubShaderNode(SubShaderNode node) => DefaultVisit(node);
        public virtual void VisitShaderCodePassNode(ShaderCodePassNode node) => DefaultVisit(node);
        public virtual void VisitShaderGrabPassNode(ShaderGrabPassNode node) => DefaultVisit(node);
        public virtual void VisitShaderUsePassNode(ShaderUsePassNode node) => DefaultVisit(node);
        public virtual void VisitShaderLabCommandTagsNode(ShaderLabCommandTagsNode node) => DefaultVisit(node);
        public virtual void VisitShaderLabCommandLodNode(ShaderLabCommandLodNode node) => DefaultVisit(node);
        public virtual void VisitShaderLabCommandLightingNode(ShaderLabCommandLightingNode node) => DefaultVisit(node);
        public virtual void VisitShaderLabCommandSeparateSpecularNode(ShaderLabCommandSeparateSpecularNode node) => DefaultVisit(node);
        public virtual void VisitShaderLabCommandZWriteNode(ShaderLabCommandZWriteNode node) => DefaultVisit(node);
        public virtual void VisitShaderLabCommandAlphaToMaskNode(ShaderLabCommandAlphaToMaskNode node) => DefaultVisit(node);
        public virtual void VisitShaderLabCommandZClipNode(ShaderLabCommandZClipNode node) => DefaultVisit(node);
        public virtual void VisitShaderLabCommandConservativeNode(ShaderLabCommandConservativeNode node) => DefaultVisit(node);
        public virtual void VisitShaderLabCommandCullNode(ShaderLabCommandCullNode node) => DefaultVisit(node);
        public virtual void VisitShaderLabCommandZTestNode(ShaderLabCommandZTestNode node) => DefaultVisit(node);
        public virtual void VisitShaderLabCommandBlendNode(ShaderLabCommandBlendNode node) => DefaultVisit(node);
        public virtual void VisitShaderLabCommandOffsetNode(ShaderLabCommandOffsetNode node) => DefaultVisit(node);
        public virtual void VisitShaderLabCommandColorMaskNode(ShaderLabCommandColorMaskNode node) => DefaultVisit(node);
        public virtual void VisitShaderLabCommandAlphaTestNode(ShaderLabCommandAlphaTestNode node) => DefaultVisit(node);
        public virtual void VisitShaderLabCommandFogNode(ShaderLabCommandFogNode node) => DefaultVisit(node);
        public virtual void VisitShaderLabCommandNameNode(ShaderLabCommandNameNode node) => DefaultVisit(node);
        public virtual void VisitShaderLabCommandBindChannelsNode(ShaderLabCommandBindChannelsNode node) => DefaultVisit(node);
        public virtual void VisitShaderLabCommandColorNode(ShaderLabCommandColorNode node) => DefaultVisit(node);
        public virtual void VisitShaderLabCommandBlendOpNode(ShaderLabCommandBlendOpNode node) => DefaultVisit(node);
        public virtual void VisitShaderLabCommandMaterialNode(ShaderLabCommandMaterialNode node) => DefaultVisit(node);
        public virtual void VisitShaderLabCommandSetTextureNode(ShaderLabCommandSetTextureNode node) => DefaultVisit(node);
        public virtual void VisitShaderLabCommandColorMaterialNode(ShaderLabCommandColorMaterialNode node) => DefaultVisit(node);
        public virtual void VisitShaderLabCommandStencilNode(ShaderLabCommandStencilNode node) => DefaultVisit(node);
        public virtual void VisitShaderLabCommandPackageRequirementsNode(ShaderLabCommandPackageRequirementsNode node) => DefaultVisit(node);
    }

    public abstract class ShaderLabSyntaxVisitor<TReturn>
    {
        protected virtual TReturn DefaultVisit(ShaderLabSyntaxNode node)
        {
            foreach (var child in node.Children)
            {
                child.Accept(this);
            }
            return default;
        }

        public List<TReturn> VisitMany(IEnumerable<ShaderLabSyntaxNode> nodes)
        {
            List<TReturn> result = new List<TReturn>();
            foreach (ShaderLabSyntaxNode node in nodes)
            {
                result.Add(Visit(node));
            }
            return result;
        }

        public List<TReturn> VisitMany<T>(IList<T> nodes, Action runBetween)
            where T : ShaderLabSyntaxNode
        {
            List<TReturn> result = new List<TReturn>();
            for (int i = 0; i < nodes.Count; i++)
            {
                result.Add(Visit(nodes[i]));
                if (i < nodes.Count - 1)
                    runBetween();
            }
            return result;
        }

        public virtual TReturn Visit(ShaderLabSyntaxNode node) => node == null ? default : node.Accept(this);
        public virtual TReturn VisitShaderNode(ShaderNode node) => DefaultVisit(node);
        public virtual TReturn VisitShaderPropertyNode(ShaderPropertyNode node) => DefaultVisit(node);
        public virtual TReturn VisitShaderPropertyValueFloatNode(ShaderPropertyValueFloatNode node) => DefaultVisit(node);
        public virtual TReturn VisitShaderPropertyValueIntegerNode(ShaderPropertyValueIntegerNode node) => DefaultVisit(node);
        public virtual TReturn VisitShaderPropertyValueVectorNode(ShaderPropertyValueVectorNode node) => DefaultVisit(node);
        public virtual TReturn VisitShaderPropertyValueColorNode(ShaderPropertyValueColorNode node) => DefaultVisit(node);
        public virtual TReturn VisitShaderPropertyValueTextureNode(ShaderPropertyValueTextureNode node) => DefaultVisit(node);
        public virtual TReturn VisitSubShaderNode(SubShaderNode node) => DefaultVisit(node);
        public virtual TReturn VisitShaderCodePassNode(ShaderCodePassNode node) => DefaultVisit(node);
        public virtual TReturn VisitShaderGrabPassNode(ShaderGrabPassNode node) => DefaultVisit(node);
        public virtual TReturn VisitShaderUsePassNode(ShaderUsePassNode node) => DefaultVisit(node);
        public virtual TReturn VisitShaderLabCommandTagsNode(ShaderLabCommandTagsNode node) => DefaultVisit(node);
        public virtual TReturn VisitShaderLabCommandLodNode(ShaderLabCommandLodNode node) => DefaultVisit(node);
        public virtual TReturn VisitShaderLabCommandLightingNode(ShaderLabCommandLightingNode node) => DefaultVisit(node);
        public virtual TReturn VisitShaderLabCommandSeparateSpecularNode(ShaderLabCommandSeparateSpecularNode node) => DefaultVisit(node);
        public virtual TReturn VisitShaderLabCommandZWriteNode(ShaderLabCommandZWriteNode node) => DefaultVisit(node);
        public virtual TReturn VisitShaderLabCommandAlphaToMaskNode(ShaderLabCommandAlphaToMaskNode node) => DefaultVisit(node);
        public virtual TReturn VisitShaderLabCommandZClipNode(ShaderLabCommandZClipNode node) => DefaultVisit(node);
        public virtual TReturn VisitShaderLabCommandConservativeNode(ShaderLabCommandConservativeNode node) => DefaultVisit(node);
        public virtual TReturn VisitShaderLabCommandCullNode(ShaderLabCommandCullNode node) => DefaultVisit(node);
        public virtual TReturn VisitShaderLabCommandZTestNode(ShaderLabCommandZTestNode node) => DefaultVisit(node);
        public virtual TReturn VisitShaderLabCommandBlendNode(ShaderLabCommandBlendNode node) => DefaultVisit(node);
        public virtual TReturn VisitShaderLabCommandOffsetNode(ShaderLabCommandOffsetNode node) => DefaultVisit(node);
        public virtual TReturn VisitShaderLabCommandColorMaskNode(ShaderLabCommandColorMaskNode node) => DefaultVisit(node);
        public virtual TReturn VisitShaderLabCommandAlphaTestNode(ShaderLabCommandAlphaTestNode node) => DefaultVisit(node);
        public virtual TReturn VisitShaderLabCommandFogNode(ShaderLabCommandFogNode node) => DefaultVisit(node);
        public virtual TReturn VisitShaderLabCommandNameNode(ShaderLabCommandNameNode node) => DefaultVisit(node);
        public virtual TReturn VisitShaderLabCommandBindChannelsNode(ShaderLabCommandBindChannelsNode node) => DefaultVisit(node);
        public virtual TReturn VisitShaderLabCommandColorNode(ShaderLabCommandColorNode node) => DefaultVisit(node);
        public virtual TReturn VisitShaderLabCommandBlendOpNode(ShaderLabCommandBlendOpNode node) => DefaultVisit(node);
        public virtual TReturn VisitShaderLabCommandMaterialNode(ShaderLabCommandMaterialNode node) => DefaultVisit(node);
        public virtual TReturn VisitShaderLabCommandSetTextureNode(ShaderLabCommandSetTextureNode node) => DefaultVisit(node);
        public virtual TReturn VisitShaderLabCommandColorMaterialNode(ShaderLabCommandColorMaterialNode node) => DefaultVisit(node);
        public virtual TReturn VisitShaderLabCommandStencilNode(ShaderLabCommandStencilNode node) => DefaultVisit(node);
        public virtual TReturn VisitShaderLabCommandPackageRequirementsNode(ShaderLabCommandPackageRequirementsNode node) => DefaultVisit(node);
    }
}


// HLSL/PreProcessor/ConstExpressionEvaluator.cs
namespace UnityShaderParser.HLSL.PreProcessor
{
    using HLSLToken = Token<TokenKind>;

    internal class ConstExpressionEvaluator
    {
        public static bool EvaluateConstExprTokens(List<HLSLToken> exprTokens, bool throwExceptionOnError, DiagnosticFlags diagnosticFilter, out List<string> diagnostics)
        {
            HLSLParser localParser = new HLSLParser(exprTokens, throwExceptionOnError, diagnosticFilter);
            var expr = localParser.ParseExpression();

            if (localParser.Diagnostics.Count > 0)
            {
                diagnostics = new List<string>() { "Failed to evaluated const expression in preprocessor directive." };
                return false;
            }

            var self = new ConstExpressionEvaluator();
            bool result = self.EvaluateConstExpr(expr) != 0;
            diagnostics = self.diagnostics;
            return result;
        }

        private List<string> diagnostics = new List<string>();

        private void Error(string err)
        {
            diagnostics.Add(err);
        }

        private static bool ToBool(long i) => i != 0;
        private static long ToNum(bool i) => i ? 1 : 0;

        public long EvaluateConstExpr(ExpressionNode node)
        {
            switch (node)
            {
                case LiteralExpressionNode literalExpr:
                    switch (literalExpr.Kind)
                    {
                        case LiteralKind.Integer:
                            if (literalExpr.Lexeme.StartsWith("0x"))
                            {
                                string lexeme = literalExpr.Lexeme.Substring(2);
                                if (lexeme.EndsWith("u") || lexeme.EndsWith("U"))
                                    lexeme = lexeme.Substring(0, lexeme.Length - 1);
                                return long.Parse(lexeme, System.Globalization.NumberStyles.HexNumber);
                            }
                            return long.Parse(literalExpr.Lexeme);
                        case LiteralKind.Character:
                            return char.Parse(literalExpr.Lexeme);
                        default:
                            Error($"Literals of type '{literalExpr.Kind}' are not supported in constant expressions.");
                            return 0;
                    }
                case BinaryExpressionNode binExpr:
                    long left = EvaluateConstExpr(binExpr.Left);
                    long right = EvaluateConstExpr(binExpr.Right);
                    switch (binExpr.Operator)
                    {
                        case OperatorKind.LogicalOr: return ToNum(ToBool(left) || ToBool(right));
                        case OperatorKind.LogicalAnd: return ToNum(ToBool(left) && ToBool(right));
                        case OperatorKind.BitwiseOr: return left | right;
                        case OperatorKind.BitwiseAnd: return left & right;
                        case OperatorKind.BitwiseXor: return left ^ right;
                        case OperatorKind.Equals: return ToNum(left == right);
                        case OperatorKind.NotEquals: return ToNum(left != right);
                        case OperatorKind.LessThan: return ToNum(left < right);
                        case OperatorKind.LessThanOrEquals: return ToNum(left <= right);
                        case OperatorKind.GreaterThan: return ToNum(left > right);
                        case OperatorKind.GreaterThanOrEquals: return ToNum(left >= right);
                        case OperatorKind.ShiftLeft: return left << (int)right;
                        case OperatorKind.ShiftRight: return left >> (int)right;
                        case OperatorKind.Plus: return left + right;
                        case OperatorKind.Minus: return left - right;
                        case OperatorKind.Mul: return left * right;
                        case OperatorKind.Div: return left / right;
                        case OperatorKind.Mod: return left % right;
                        default:
                            Error($"Binary operators of type '{binExpr.Operator}' are not supported in constant expressions.");
                            return 0;
                    }
                case PrefixUnaryExpressionNode unExpr:
                    long unary = EvaluateConstExpr(unExpr.Expression);
                    switch (unExpr.Operator)
                    {
                        case OperatorKind.Not: return ToNum(!ToBool(unary));
                        case OperatorKind.BitFlip: return ~unary;
                        default:
                            Error($"Unary operators of type '{unExpr.Operator}' are not supported in constant expressions.");
                            return 0;
                    }
                default:
                    Error($"Illegal expression type '{node.GetType().Name}' found in constant expression.");
                    return 0;
            }
        }
    }
}


// HLSL/PreProcessor/HLSLPreProcessor.cs
namespace UnityShaderParser.HLSL.PreProcessor
{
    using HLSLToken = Token<TokenKind>;

    public enum PreProcessorMode
    {
        ExpandAll,
        ExpandIncludesOnly,
        ExpandAllExceptIncludes,
        StripDirectives,
        DoNothing,
        // TODO: Option to embed directives into tokens
    }

    internal struct Macro
    {
        public bool FunctionLike;
        public string Name;
        public List<string> Parameters;
        public List<HLSLToken> Tokens;
    }

    public class HLSLPreProcessor : BaseParser<TokenKind>
    {
        protected override TokenKind StringLiteralTokenKind => TokenKind.StringLiteralToken;
        protected override TokenKind IntegerLiteralTokenKind => TokenKind.IntegerLiteralToken;
        protected override TokenKind FloatLiteralTokenKind => TokenKind.FloatLiteralToken;
        protected override TokenKind IdentifierTokenKind => TokenKind.IdentifierToken;
        protected override TokenKind InvalidTokenKind => TokenKind.InvalidToken;
        protected override ParserStage Stage => ParserStage.HLSLPreProcessing;

        protected string basePath;
        protected string fileName;
        protected IPreProcessorIncludeResolver includeResolver;

        protected int lineOffset = 0;
        internal Dictionary<string, Macro> defines = new Dictionary<string, Macro>();

        protected List<HLSLToken> outputTokens = new List<HLSLToken>();
        protected List<string> outputPragmas = new List<string>();

        protected SourceSpan AddFileContext(SourceSpan span)
        {
            string newBasePath = span.BasePath;
            string newFilePath = span.FileName;
            if (string.IsNullOrEmpty(newBasePath)) newBasePath = basePath;
            if (string.IsNullOrEmpty(newFilePath)) newFilePath = fileName;

            return new SourceSpan(
                newBasePath,
                newFilePath,
                new SourceLocation(span.Start.Line + lineOffset, span.Start.Column, span.Start.Index),
                new SourceLocation(span.End.Line + lineOffset, span.End.Column, span.End.Index));
        }

        protected void Passthrough()
        {
            var token = Advance();
            var newToken = new HLSLToken(token.Kind, token.Identifier, AddFileContext(token.Span), token.OriginalSpan, outputTokens.Count);
            outputTokens.Add(newToken);
        }

        public HLSLPreProcessor(List<HLSLToken> tokens, bool throwExceptionOnError, DiagnosticFlags diagnosticFilter, string basePath, IPreProcessorIncludeResolver includeResolver, Dictionary<string, string> defines)
            : base(tokens, throwExceptionOnError, diagnosticFilter)
        {
            this.basePath = basePath;
            this.includeResolver = includeResolver;

            foreach (var kvp in defines)
            {
                var localTokens = HLSLLexer.Lex(kvp.Value, null, null, false, out var localLexerDiags);
                if (localLexerDiags.Count > 0)
                {
                    Error(DiagnosticFlags.SyntaxError, $"Invalid define '{kvp.Key}' passed.");
                }
                string key = kvp.Key;
                bool functionLike = false;
                var parameters = new List<string>();
                if (kvp.Key.Contains("("))
                {
                    key = kvp.Key.Substring(0, kvp.Key.IndexOf('('));
                    var paramsLexeme = kvp.Key.Substring(kvp.Key.IndexOf('('));
                    paramsLexeme = paramsLexeme.TrimStart('(').TrimEnd(')');
                    parameters = paramsLexeme.Split(',').Select(x => x.Trim()).ToList();
                    functionLike = true;
                }
                this.defines.Add(key, new Macro
                {
                    FunctionLike = functionLike,
                    Name = key,
                    Parameters = parameters,
                    Tokens = localTokens
                });
            }
        }

        public static List<HLSLToken> PreProcess(
            List<HLSLToken> tokens,
            bool throwExceptionOnError,
            DiagnosticFlags diagnosticFilter,
            PreProcessorMode mode,
            string basePath,
            IPreProcessorIncludeResolver includeResolver,
            Dictionary<string, string> defines,
            out List<string> pragmas,
            out List<Diagnostic> diagnostics)
        {
            HLSLPreProcessor preProcessor = new HLSLPreProcessor(tokens, throwExceptionOnError, diagnosticFilter, basePath, includeResolver, defines);
            switch (mode)
            {
                case PreProcessorMode.ExpandAll:
                    preProcessor.ExpandDirectives(true);
                    break;
                case PreProcessorMode.ExpandIncludesOnly:
                    preProcessor.ExpandIncludesOnly();
                    break;
                case PreProcessorMode.ExpandAllExceptIncludes:
                    preProcessor.ExpandDirectives(false);
                    break;
                case PreProcessorMode.StripDirectives:
                    preProcessor.StripDirectives();
                    break;
                case PreProcessorMode.DoNothing:
                    preProcessor.outputTokens = tokens;
                    break;
            }
            pragmas = preProcessor.outputPragmas;
            diagnostics = preProcessor.diagnostics;
            return preProcessor.outputTokens;
        }

        private new string ParseIdentifier()
        {
            if (Match(TokenKind.IdentifierToken))
            {
                return base.ParseIdentifier();
            }
            else
            {
                var identifierToken = Advance();
                if (HLSLSyntaxFacts.TryConvertKeywordToString(identifierToken.Kind, out string result))
                {
                    return result;
                }
                Error("a valid identifier", identifierToken);
                return string.Empty;
            }
        }

        protected struct PreProcessorSnapshot
        {
            public List<HLSLToken> Tokens;
            public int LineOffset;
            public int ExitPosition;
            public SourceSpan IncludeSpan;
        }

        protected Stack<PreProcessorSnapshot> fileSnapshots = new Stack<PreProcessorSnapshot>();

        protected void EnterFile(SourceSpan includeSpan, string newFileName)
        {
            string source = includeResolver.ReadFile(basePath, newFileName);
            var sourceTokens = HLSLLexer.Lex(source, basePath, fileName, throwExceptionOnError, out var diagnosticsToAdd);
            diagnostics.AddRange(diagnosticsToAdd);

            fileSnapshots.Push(new PreProcessorSnapshot
            {
                Tokens = tokens,
                LineOffset = lineOffset,
                ExitPosition = position,
                IncludeSpan = includeSpan,
            });

            position = 0;
            lineOffset = 0;
            tokens = sourceTokens;

            includeResolver.EnterFile(ref basePath, ref fileName, newFileName);
        }

        protected void ExitFile()
        {
            var snapshot = fileSnapshots.Pop();
            tokens = snapshot.Tokens;
            lineOffset = snapshot.LineOffset;
            position = snapshot.ExitPosition;

            includeResolver.ExitFile(ref basePath, ref fileName);
        }

        private void ExpandInclude(bool expandIncludesOnly)
        {
            var keywordTok = Eat(TokenKind.IncludeDirectiveKeyword);
            var pathToken = Eat(TokenKind.SystemIncludeLiteralToken, TokenKind.StringLiteralToken);
            var endTok = Eat(TokenKind.EndDirectiveToken);
            var includeSpan = SourceSpan.Between(keywordTok.Span, endTok.Span);
            string newFileName = pathToken.Identifier ?? string.Empty;

            EnterFile(includeSpan, newFileName);

            if (expandIncludesOnly)
                ExpandIncludesOnly();
            else
                ExpandDirectives();

            ExitFile();
        }

        // Glues tokens together with ##, stringize with #, and evaluates defined(x) between each expansion
        private void ReplaceBetweenExpansions(List<HLSLToken> tokens)
        {
            HLSLToken LocalPeek(int i) => i < tokens.Count ? tokens[i] : InvalidToken;

            List<HLSLToken> result = new List<HLSLToken>();
            for (int i = 0; i < tokens.Count; i++)
            {
                var token = tokens[i];
                if (HLSLSyntaxFacts.TryConvertIdentifierOrKeywordToString(token, out string gluedIdentifier) && LocalPeek(i + 1).Kind == TokenKind.HashHashToken)
                {
                    SourceSpan startSpan = token.Span;
                    SourceSpan startSpanOriginal = token.OriginalSpan;
                    SourceSpan endSpan = token.Span;
                    SourceSpan endSpanOriginal = token.OriginalSpan;
                    int startPosition = token.Position;

                    i++; // identifier
                    while (LocalPeek(i).Kind == TokenKind.HashHashToken &&
                        HLSLSyntaxFacts.TryConvertIdentifierOrKeywordToString(LocalPeek(i + 1), out string nextIdentifier))
                    {
                        i++; // ##
                        var nextToken = LocalPeek(i++); // identifier
                        gluedIdentifier += nextIdentifier;
                        endSpan = nextToken.Span;
                        endSpanOriginal = nextToken.OriginalSpan;
                    }

                    var gluedToken = new HLSLToken(
                        TokenKind.IdentifierToken,
                        gluedIdentifier,
                        SourceSpan.Between(startSpan, endSpan),
                        SourceSpan.Between(startSpanOriginal, endSpanOriginal),
                        startPosition);
                    i--; // For loop continues

                    result.Add(gluedToken);
                }
                else if (token.Kind == TokenKind.IdentifierToken && token.Identifier == "defined")
                {
                    SourceSpan startSpan = token.Span;
                    SourceSpan startSpanOriginal = token.OriginalSpan;
                    int startPosition = token.Position;

                    i++; // defined
                    bool hasParen = LocalPeek(i).Kind == TokenKind.OpenParenToken;
                    if (hasParen) i++;
                    HLSLToken identifier = LocalPeek(i++);
                    SourceSpan endSpan = identifier.Span;
                    SourceSpan endSpanOriginal = identifier.OriginalSpan;
                    if (hasParen)
                    {
                        var closeParen = LocalPeek(i++);
                        endSpan = closeParen.Span;
                        endSpanOriginal = closeParen.OriginalSpan;
                    }

                    var replacedToken = new HLSLToken(
                        TokenKind.IntegerLiteralToken,
                        defines.ContainsKey(HLSLSyntaxFacts.IdentifierOrKeywordToString(identifier)) ? "1" : "0",
                        SourceSpan.Between(startSpan, endSpan),
                        SourceSpan.Between(startSpanOriginal, endSpanOriginal),
                        startPosition);
                    i--; // For loop continues

                    result.Add(replacedToken);
                }
                else if (token.Kind == TokenKind.HashToken && LocalPeek(i + 1).Kind == TokenKind.IdentifierToken)
                {
                    SourceSpan startSpan = token.Span;
                    SourceSpan startSpanOriginal = token.OriginalSpan;
                    int startPosition = token.Position;

                    i++; // Hash
                    HLSLToken identifier = LocalPeek(i++); // Identifier

                    var stringizedToken = new HLSLToken(
                        TokenKind.StringLiteralToken,
                        identifier.Identifier,
                        SourceSpan.Between(startSpan, identifier.Span),
                        SourceSpan.Between(startSpanOriginal, identifier.OriginalSpan),
                        startPosition
                    );
                    i--; // For loop continues
                    result.Add(stringizedToken);
                }
                else
                {
                    result.Add(token);
                }
            }

            tokens.Clear();
            tokens.AddRange(result);
        }

        private bool TryParseFunctionLikeMacroInvocationParameters(List<HLSLToken> tokenStream, ref int streamOffset, out List<List<HLSLToken>> parameters)
        {
            int localOffset = streamOffset + 1;

            // Setup local parser functionality (we want to parse on a secondary token stream)
            bool LocalIsAtEnd() => localOffset >= tokenStream.Count;
            HLSLToken LocalAdvance() => LocalIsAtEnd() ? InvalidToken : tokenStream[localOffset++];
            HLSLToken LocalPeek() => LocalIsAtEnd() ? InvalidToken : tokenStream[localOffset];
            bool LocalMatch(TokenKind kind) => LocalIsAtEnd() ? false : kind == tokenStream[localOffset].Kind;
            HLSLToken LocalEat(TokenKind kind)
            {
                if (!LocalMatch(kind))
                    Error(DiagnosticFlags.PreProcessorError, $"Expected token type '{kind}', got '{LocalPeek().Kind}'.");
                return LocalAdvance();
            }

            parameters = new List<List<HLSLToken>>();

            // Eat arguments if they are available
            if (LocalMatch(TokenKind.OpenParenToken))
            {
                // Always eat open paren
                LocalEat(TokenKind.OpenParenToken);

                // Check for special case of 0 args
                if (LocalMatch(TokenKind.CloseParenToken))
                {
                    LocalEat(TokenKind.CloseParenToken);
                    streamOffset = localOffset - 1;
                    return true;
                }

                parameters.Add(new List<HLSLToken>());

                // Parse until we have match parens, they might be nested
                int numParens = 1;
                while (numParens > 0)
                {
                    var next = LocalAdvance();
                    switch (next.Kind)
                    {
                        case TokenKind.OpenParenToken:
                            numParens++;
                            if (numParens > 1) parameters.Last().Add(next);
                            break;
                        case TokenKind.CloseParenToken:
                            if (numParens > 1) parameters.Last().Add(next);
                            numParens--;
                            break;
                        case TokenKind.CommaToken when numParens == 1:
                            parameters.Add(new List<HLSLToken>());
                            break;
                        default:
                            parameters.Last().Add(next);
                            break;
                    }
                }
                streamOffset = localOffset - 1;
                return true;
            }
            // If no args, it must be a regular identifier
            return false;
        }

        private List<HLSLToken> ApplyMacros()
        {
            // First, get the entire macro identifier
            List<HLSLToken> expanded = new List<HLSLToken>();
            var identifierTok = Eat(TokenKind.IdentifierToken);
            expanded.Add(identifierTok);
            string identifier = identifierTok.Identifier ?? string.Empty;

            // Check if it is a functionlike macro
            bool isFunctionLike = (defines.ContainsKey(identifier) && defines[identifier].FunctionLike) || identifier == "defined";
            if (isFunctionLike)
            {
                // If so, eat arguments if they are available
                if (Match(TokenKind.OpenParenToken))
                {
                    expanded.Add(Eat(TokenKind.OpenParenToken));
                    int numParens = 1;
                    while (numParens > 0) // Might have nested parens
                    {
                        var next = Advance();
                        if (next.Kind == TokenKind.OpenParenToken)
                            numParens++;
                        else if (next.Kind == TokenKind.CloseParenToken)
                            numParens--;
                        expanded.Add(next);
                    }
                }
                // Otherwise, it must be a regular identifier
                else
                {
                    return expanded;
                }
            }

            // Optimization: Only do this if necessary
            bool hasGlueTokenOrDefined = expanded.Any(x => x.Kind == TokenKind.HashHashToken || x.Identifier == "defined");
            if (hasGlueTokenOrDefined)
            {
                ReplaceBetweenExpansions(expanded);
            }
            
            HashSet<string> hideSet = new HashSet<string>();
            
            // Loop until we can't apply macros anymore
            while (true)
            {
                List<HLSLToken> next = new List<HLSLToken>();
                HashSet<string> nextHideSet = new HashSet<string>();

                // Go over each token and try to apply, adding to the hideset as we go
                bool anyThingApplied = false;
                for (int i = 0; i < expanded.Count; i++)
                {
                    HLSLToken token = expanded[i];

                    string lexeme = HLSLSyntaxFacts.IdentifierOrKeywordToString(token);
                    // If the macro matches
                    if (!hideSet.Contains(lexeme) && !HLSLSyntaxFacts.IsStringLikeLiteral(token.Kind) && defines.TryGetValue(lexeme, out Macro macro))
                    {
                        // Add it to the hideset
                        if (!nextHideSet.Contains(lexeme))
                        {
                            nextHideSet.Add(lexeme);
                        }

                        anyThingApplied = true;

                        // We need to replace tokens.
                        // First, check if we have a functionlike macro
                        if (macro.FunctionLike)
                        {
                            // Try to parse parameters.
                            if (!TryParseFunctionLikeMacroInvocationParameters(expanded, ref i, out var parameters))
                            {
                                // If they aren't present, it might be a deferred function-like macro.
                                // Eat more tokens to get the parameters and retry.
                                if (Match(TokenKind.OpenParenToken))
                                {
                                    expanded.Add(Eat(TokenKind.OpenParenToken));
                                    int numParens = 1;
                                    while (numParens > 0) // Might have nested parens
                                    {
                                        var nextTok = Advance();
                                        if (nextTok.Kind == TokenKind.OpenParenToken)
                                            numParens++;
                                        else if (nextTok.Kind == TokenKind.CloseParenToken)
                                            numParens--;
                                        expanded.Add(nextTok);
                                    }
                                    if (!TryParseFunctionLikeMacroInvocationParameters(expanded, ref i, out parameters))
                                        next.Add(token); // Still no luck, must be a regular identifier.
                                }
                                // Otherwise, must be a regular identifier.
                                else
                                {
                                    next.Add(token);
                                }
                            }

                            if (parameters.Count != macro.Parameters.Count)
                                Error(DiagnosticFlags.PreProcessorError, $"Incorrect number of arguments passed to macro '{macro.Name}', expected {macro.Parameters.Count}, got {parameters.Count}.");

                            // If they are there, substitute them
                            foreach (var macroToken in macro.Tokens)
                            {
                                string macroTokenLexeme = HLSLSyntaxFacts.IdentifierOrKeywordToString(macroToken);
                                int paramIndex = macro.Parameters.IndexOf(macroTokenLexeme);
                                if (paramIndex >= 0 && paramIndex < parameters.Count)
                                {
                                    var parameter = parameters[paramIndex];
                                    foreach (var parameterToken in parameter)
                                    {
                                        next.Add(new HLSLToken(parameterToken.Kind, parameterToken.Identifier, macroToken.Span, parameterToken.Span, parameterToken.Position));
                                    }
                                }
                                else
                                {
                                    next.Add(macroToken);
                                }
                            }
                        }
                        // If not, we can just substitute tokens directly
                        else
                        {
                            next.AddRange(macro.Tokens);
                        }
                    }
                    // Otherwise just pass the token through
                    else
                    {
                        next.Add(token);
                    }
                }

                // Optimization: Check if anything changed - costly to replace
                if (anyThingApplied)
                {
                    ReplaceBetweenExpansions(next);
                }

                hideSet = nextHideSet;
                expanded = next;

                // If nothing was applied, stop
                if (!anyThingApplied)
                {
                    break;
                }
            }

            return expanded;
        }

        private static void ShiftPositionsToStartFrom(int start, List<HLSLToken> tokens)
        {
            for (int i = 0; i < tokens.Count; i++)
            {
                var token = tokens[i];
                var newToken = new HLSLToken(token.Kind, token.Identifier, token.Span, token.OriginalSpan, start + i);
                tokens[i] = newToken;
            }
        }

        private List<HLSLToken> SkipUntilEndOfConditional()
        {
            List<HLSLToken> skipped = new List<HLSLToken>();
            int depth = 0;
            while (true)
            {
                if (!LoopShouldContinue())
                {
                    Error(DiagnosticFlags.PreProcessorError, "Unterminated conditional directive.");
                    break;
                }

                switch (Peek().Kind)
                {
                    case TokenKind.IfdefDirectiveKeyword:
                    case TokenKind.IfndefDirectiveKeyword:
                    case TokenKind.IfDirectiveKeyword:
                        depth++;
                        skipped.Add(Advance());
                        break;

                    case TokenKind.ElseDirectiveKeyword:
                    case TokenKind.ElifDirectiveKeyword:
                        if (depth == 0)
                        {
                            return skipped;
                        }
                        else
                        {
                            skipped.Add(Advance());
                        }
                        break;

                    case TokenKind.EndifDirectiveKeyword:
                        if (depth == 0)
                        {
                            return skipped;
                        }
                        else
                        {
                            depth--;
                            skipped.Add(Advance());
                        }
                        break;

                    default:
                        skipped.Add(Advance());
                        break;
                }
            }
            return skipped;
        }

        private bool EvaluateConstExpr(List<HLSLToken> exprTokens)
        {
            bool result = ConstExpressionEvaluator.EvaluateConstExprTokens(exprTokens, throwExceptionOnError, diagnosticFilter, out var evalDiags);
            if (evalDiags.Count > 0)
            {
                foreach (var diag in evalDiags)
                {
                    Error(DiagnosticFlags.PreProcessorError, diag);
                }
                return false;
            }
            return result;
        }

        private bool EvaluateCondition(bool continued)
        {
            HLSLToken conditional = Advance();
            switch (conditional.Kind)
            {
                case TokenKind.IfdefDirectiveKeyword:
                    string ifdefName = ParseIdentifier();
                    Eat(TokenKind.EndDirectiveToken);
                    return defines.ContainsKey(ifdefName);

                case TokenKind.IfndefDirectiveKeyword:
                    string ifndefName = ParseIdentifier();
                    Eat(TokenKind.EndDirectiveToken);
                    return !defines.ContainsKey(ifndefName);

                case TokenKind.ElseDirectiveKeyword:
                    Eat(TokenKind.EndDirectiveToken);
                    if (!continued)
                    {
                        Error(DiagnosticFlags.PreProcessorError, "Unexpected #else directive - there is no conditional directive preceding it.");
                    }
                    return true;

                case TokenKind.IfDirectiveKeyword:
                case TokenKind.ElifDirectiveKeyword:
                    if (!continued && conditional.Kind == TokenKind.ElifDirectiveKeyword)
                    {
                        Error(DiagnosticFlags.PreProcessorError, "Unexpected #elif directive - there is no conditional directive preceding it.");
                    }
                    // Get the expanded tokens for the condition expression
                    List<HLSLToken> expandedConditionTokens = new List<HLSLToken>();
                    while (LoopShouldContinue() && !Match(TokenKind.EndDirectiveToken))
                    {
                        // If we find an identifier, eagerly expand (https://www.math.utah.edu/docs/info/cpp_1.html)
                        var next = Peek();
                        if (next.Kind == TokenKind.IdentifierToken)
                        {
                            expandedConditionTokens.AddRange(ApplyMacros());
                        }
                        else
                        {
                            expandedConditionTokens.Add(Advance());
                        }
                    }
                    // The C spec says we should replace any identifiers remaining after expansion with the literal 0
                    for (int i = 0; i < expandedConditionTokens.Count; i++)
                    {
                        var token = expandedConditionTokens[i];
                        if (token.Kind == TokenKind.IdentifierToken)
                        {
                            var newToken = new HLSLToken(TokenKind.IntegerLiteralToken, "0", token.Span, token.OriginalSpan, token.Position);
                            expandedConditionTokens[i] = newToken;
                        }
                    }
                    Eat(TokenKind.EndDirectiveToken);
                    // Finally evaluate the expression
                    ShiftPositionsToStartFrom(0, expandedConditionTokens);
                    return EvaluateConstExpr(expandedConditionTokens);
                default:
                    Error(DiagnosticFlags.PreProcessorError, $"Unexpected token '{conditional.Kind}', expected preprocessor directive.");
                    return false;
            }
        }

        private void ExpandConditional()
        {
            int startPosition = position;
            List<HLSLToken> takenTokens = new List<HLSLToken>();
            bool branchTaken = false;

            bool condEvaluation = EvaluateCondition(false);

            while (true)
            {
                if (!LoopShouldContinue())
                {
                    Error(DiagnosticFlags.PreProcessorError, "Unterminated conditional directive.");
                    break;
                }

                // Eat the body
                var skipped = SkipUntilEndOfConditional();

                // If we haven't already taken a branch, and this one is true, take it
                if (!branchTaken && condEvaluation)
                {
                    branchTaken = true;
                    takenTokens = skipped;
                }

                // If we have reached the end, stop
                if (Match(TokenKind.EndifDirectiveKeyword))
                {
                    Eat(TokenKind.EndifDirectiveKeyword);
                    Eat(TokenKind.EndDirectiveToken);
                    break;
                }

                condEvaluation = EvaluateCondition(true);
            }

            // Substitution. First take away the tokens we just evaluated, then insert the substitution,
            // and rewind to the start of it
            int numTokensInDirective = position - startPosition;
            position = startPosition;
            tokens.RemoveRange(position, numTokensInDirective);
            tokens.InsertRange(position, takenTokens);
        }

        private void GlueStringLiteralsPass()
        {
            position = 0;
            lineOffset = 0;
            tokens = new List<HLSLToken>(outputTokens);
            outputTokens.Clear();
            while (LoopShouldContinue())
            {
                if (Match(TokenKind.StringLiteralToken))
                {
                    var strTok = Eat(TokenKind.StringLiteralToken);
                    string glued = strTok.Identifier ?? string.Empty;
                    SourceSpan spanStart = strTok.Span;
                    SourceSpan spanStartOriginal = strTok.OriginalSpan;
                    SourceSpan spanEnd = strTok.Span;
                    SourceSpan spanEndOriginal = strTok.OriginalSpan;
                    while (Match(TokenKind.StringLiteralToken))
                    {
                        var nextStrTok = Eat(TokenKind.StringLiteralToken);
                        glued += nextStrTok.Identifier ?? string.Empty;
                        spanEnd = nextStrTok.Span;
                        spanEndOriginal = nextStrTok.OriginalSpan;
                    }
                    var gluedSpan = SourceSpan.Between(spanStart, spanEnd);
                    var gluedSpanOriginal = SourceSpan.Between(spanStartOriginal, spanEndOriginal);
                    var gluedToken = new HLSLToken(TokenKind.StringLiteralToken, glued, gluedSpan, gluedSpanOriginal, outputTokens.Count);
                    outputTokens.Add(gluedToken);
                }
                else
                {
                    Passthrough();
                }
            }
        }

        public void ExpandDirectives(bool expandIncludes = true)
        {
            while (LoopShouldContinue())
            {
                HLSLToken next = Peek();
                switch (next.Kind)
                {
                    case TokenKind.IncludeDirectiveKeyword:
                        if (expandIncludes)
                        {
                            ExpandInclude(false);
                        }
                        else
                        {
                            // Skip the include
                            Eat(TokenKind.IncludeDirectiveKeyword);
                            var pathToken = Eat(TokenKind.SystemIncludeLiteralToken, TokenKind.StringLiteralToken);
                            Eat(TokenKind.EndDirectiveToken);
                        }
                        break;

                    case TokenKind.LineDirectiveKeyword:
                        int tokenLine = next.Span.Start.Line; // where we actually are
                        Eat(TokenKind.LineDirectiveKeyword);
                        int targetLine = ParseIntegerLiteral(); // where we want to be
                        lineOffset = targetLine - tokenLine - 1; // calculate the offset
                        if (Match(TokenKind.StringLiteralToken))
                        {
                            Advance();
                        }
                        Eat(TokenKind.EndDirectiveToken);
                        break;

                    case TokenKind.DefineDirectiveKeyword:
                        Eat(TokenKind.DefineDirectiveKeyword);
                        string from = ParseIdentifier();
                        List<string> args = new List<string>();
                        bool functionLike = false;
                        if (Match(TokenKind.OpenFunctionLikeMacroParenToken))
                        {
                            functionLike = true;
                            Eat(TokenKind.OpenFunctionLikeMacroParenToken);
                            args = ParseSeparatedList0(TokenKind.CloseParenToken, TokenKind.CommaToken, ParseIdentifier);
                            Eat(TokenKind.CloseParenToken);
                        }
                        List<HLSLToken> toks = ParseMany0(() => !Match(TokenKind.EndDirectiveToken), () => Advance());
                        Eat(TokenKind.EndDirectiveToken);
                        defines[from] = new Macro
                        {
                            Name = from,
                            FunctionLike = functionLike,
                            Parameters = args,
                            Tokens = toks
                        };
                        break;

                    case TokenKind.UndefDirectiveKeyword:
                        Eat(TokenKind.UndefDirectiveKeyword);
                        string undef = ParseIdentifier();
                        Eat(TokenKind.EndDirectiveToken);
                        defines.Remove(undef);
                        break;

                    case TokenKind.ErrorDirectiveKeyword:
                        Eat(TokenKind.ErrorDirectiveKeyword);
                        var errorToks = ParseMany0(() => !Match(TokenKind.EndDirectiveToken), () => Advance())
                            .Select(x => HLSLSyntaxFacts.TokenToString(x));
                        Eat(TokenKind.EndDirectiveToken);
                        string error = string.Join(" ", errorToks);
                        Error(DiagnosticFlags.PreProcessorError, error);
                        break;

                    case TokenKind.PragmaDirectiveKeyword:
                        Eat(TokenKind.PragmaDirectiveKeyword);
                        var pragmaToks = ParseMany0(() => !Match(TokenKind.EndDirectiveToken), () => Advance())
                            .Select(x => HLSLSyntaxFacts.TokenToString(x));
                        Eat(TokenKind.EndDirectiveToken);
                        string pragma = string.Join(" ", pragmaToks);
                        outputPragmas.Add(pragma);
                        break;

                    case TokenKind.IfdefDirectiveKeyword:
                    case TokenKind.IfndefDirectiveKeyword:
                    case TokenKind.IfDirectiveKeyword:
                    case TokenKind.ElifDirectiveKeyword:
                    case TokenKind.ElseDirectiveKeyword:
                    case TokenKind.EndifDirectiveKeyword:
                        ExpandConditional();
                        break;

                    case TokenKind.IdentifierToken:
                        var startSpan = Peek().Span;
                        var expanded = ApplyMacros();
                        var endSpan = Previous().Span;
                        var newSpan = SourceSpan.Between(startSpan, endSpan);
                        foreach (var token in expanded)
                        {
                            var newToken = new HLSLToken(token.Kind, token.Identifier, AddFileContext(newSpan), token.Span, outputTokens.Count);
                            outputTokens.Add(newToken);
                        }
                        break;

                    default:
                        Passthrough();
                        break;
                }
            }

            if (fileSnapshots.Count == 0)
            {
                // C spec says we need to glue adjacent string literals
                GlueStringLiteralsPass();
            }
        }

        public void ExpandIncludesOnly()
        {
            while (LoopShouldContinue())
            {
                HLSLToken next = Peek();
                if (next.Kind == TokenKind.IncludeDirectiveKeyword)
                {
                    ExpandInclude(true);
                }
                else
                {
                    Passthrough();
                }
            }
        }

        public void StripDirectives(bool expandIncludes = true)
        {
            while (LoopShouldContinue())
            {
                HLSLToken next = Peek();
                switch (next.Kind)
                {
                    case TokenKind.IncludeDirectiveKeyword:
                    case TokenKind.LineDirectiveKeyword:
                    case TokenKind.DefineDirectiveKeyword:
                    case TokenKind.UndefDirectiveKeyword:
                    case TokenKind.ErrorDirectiveKeyword:
                    case TokenKind.PragmaDirectiveKeyword:
                    case TokenKind.IfdefDirectiveKeyword:
                    case TokenKind.IfndefDirectiveKeyword:
                    case TokenKind.IfDirectiveKeyword:
                    case TokenKind.ElifDirectiveKeyword:
                    case TokenKind.ElseDirectiveKeyword:
                    case TokenKind.EndifDirectiveKeyword:
                        while (LoopShouldContinue() && !Match(TokenKind.EndDirectiveToken))
                        {
                            Advance();
                        }
                        if (Match(TokenKind.EndDirectiveToken))
                        {
                            Advance();
                        }
                        break;

                    default:
                        Passthrough();
                        break;
                }
            }

            // C spec says we need to glue adjacent string literals
            GlueStringLiteralsPass();
        }
    }
}


// HLSL/PreProcessor/IPreProcessorIncludeResolver.cs
namespace UnityShaderParser.HLSL.PreProcessor
{
    public interface IPreProcessorIncludeResolver
    {
        // Called when an include is found, updates the current base path and file path/name.
        void EnterFile(ref string basePath, ref string filePath, string includePath);

        // Called when an include is done being processed, updates the current base path and file path/name.
        void ExitFile(ref string basePath, ref string filePath);

        // Called when an include is found, reads the file and returns its content
        string ReadFile(string basePath, string includePath);

    }

    public sealed class DefaultPreProcessorIncludeResolver : IPreProcessorIncludeResolver
    {
        private List<string> includePaths = new List<string>();

        private struct FileState
        {
            public string basePath;
            public string filePath;
        }
        private Stack<FileState> fileStates = new Stack<FileState>();

        public DefaultPreProcessorIncludeResolver() { }

        public DefaultPreProcessorIncludeResolver(List<string> includePaths)
        {
            foreach (var includePath in includePaths)
            {
                if (!Directory.Exists(includePath))
                {
                    this.includePaths.Add(Path.GetFullPath(includePath));
                }
                else
                {
                    this.includePaths.Add(includePath);
                }
            }
        }

        public void EnterFile(ref string basePath, ref string filePath, string includePath)
        {
            fileStates.Push(new FileState
            {
                basePath = basePath,
                filePath = filePath
            });

            string[] pathParts = includePath.Split('/', '\\');
            if (pathParts.Length > 1)
            {
                basePath = Path.Combine(basePath, string.Join("/", pathParts.Take(pathParts.Length - 1)));
            }
            filePath = pathParts.LastOrDefault();
        }

        public void ExitFile(ref string basePath, ref string filePath)
        {
            var state = fileStates.Pop();
            basePath = state.basePath;
            filePath = state.filePath;
        }

        public string ReadFile(string basePath, string filePath)
        {
            // Fix windows-specific include paths
            filePath = filePath.Replace("\\", "/");

            string path = string.IsNullOrEmpty(basePath)
                ? filePath
                : Path.Combine(basePath, filePath);

            // Try include paths instead
            if (!File.Exists(path))
            {
                foreach (string includePath in includePaths)
                {
                    string combinedPath = Path.Combine(includePath, filePath);
                    if (File.Exists(combinedPath))
                        return File.ReadAllText(combinedPath);
                    combinedPath = Path.Combine(basePath, includePath, filePath);
                    if (File.Exists(combinedPath))
                        return File.ReadAllText(combinedPath);
                }
            }

            // Still not found, so try current directory instead
            if (!File.Exists(path))
            {
                string lastFolder = Path.GetFileName(basePath);
                if (!string.IsNullOrEmpty(lastFolder) && filePath.StartsWith(lastFolder))
                {
                    path = Path.Combine($"{basePath}/..", filePath);
                }
            }

            return File.ReadAllText(path);
        }
    }
}

