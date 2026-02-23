using System.Collections.Generic;
using UnityEngine;
using UnityShaderParser.HLSL;

namespace ORL.ShaderGenerator.Tools.SurfaceShaders
{
    public class PassVisitor : HLSLSyntaxVisitor
    {
        public FunctionDefinitionNode surfaceFunction;
        public FunctionDefinitionNode vertexFunction;
        public StructTypeNode surfaceInputStruct;
        public StructTypeNode vertexInputStruct;
        public string surfaceInputName;
        public List<VariableDeclarationStatementNode> textures = new();
        public List<VariableDeclarationStatementNode> variables = new();
        public List<IncludeDirectiveNode> includes = new();
        public List<string> defines = new();
        public List<VariableDeclarationStatementNode> uniforms = new();
        public List<StructTypeNode> structs = new();
        public List<FunctionDefinitionNode> functions = new();

        private List<string> _properties;
        private SurfaceShaderConverter.PragmaInfo _pragmaInfo;

        public PassVisitor(List<string> properties, SurfaceShaderConverter.PragmaInfo pragmaInfo)
        {
            _properties = properties;
            _pragmaInfo = pragmaInfo;
        }

        public override void VisitStructTypeNode(StructTypeNode node)
        {
            structs.Add(node);
            base.VisitStructTypeNode(node);
        }

        public override void VisitFunctionDefinitionNode(FunctionDefinitionNode node)
        {
            if (node.Name.GetName() == _pragmaInfo.SurfaceFnName)
            {
                surfaceFunction = node;
            }

            if (node.Name.GetName() == _pragmaInfo.VertexFnName)
            {
                vertexFunction = node;
            }

            functions.Add(node);
            base.VisitFunctionDefinitionNode(node);
        }

        public override void VisitIncludeDirectiveNode(IncludeDirectiveNode node)
        {
            includes.Add(node);
            base.VisitIncludeDirectiveNode(node);
        }

        public override void VisitFunctionLikeMacroNode(FunctionLikeMacroNode node)
        {
            var macro = node.GetPrettyPrintedCode().Trim();
            if (macro.StartsWith("#define"))
            {
                defines.Add(macro);
            }
            base.VisitFunctionLikeMacroNode(node);
        }

        public override void VisitVariableDeclarationStatementNode(VariableDeclarationStatementNode node)
        {
            if (node.Parent is StructTypeNode)
            {
                base.VisitVariableDeclarationStatementNode(node);
                return;
            }

            if (!_properties.Contains(node.Declarators[0].Name))
            {
                base.VisitVariableDeclarationStatementNode(node);
                return;
            }

            if (node.Kind is PredefinedObjectTypeNode nodeKind)
            {
                if (nodeKind.Kind is PredefinedObjectType.Sampler2D)
                {
                    textures.Add(node);
                }
            }
            else
            {
                variables.Add(node);
            }

            uniforms.Add(node);

            base.VisitVariableDeclarationStatementNode(node);
        }
    }
}