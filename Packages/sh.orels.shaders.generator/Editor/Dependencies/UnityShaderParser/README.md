# UnityShaderParser
A library for parsing Unity shaders. Consists of a few distinct components:
- A parser for ShaderLab, Unity's own Shader DSL.
- A parser for HLSL, the shading language embedded in ShaderLab.
- A preprocessor for dealing with macros before parsing.
- A framework for analyzing syntax trees using the visitor pattern, and for making edits to the corresponding source code.

Check [the tests](https://github.com/pema99/UnityShaderParser/tree/master/UnityShaderParser.Tests) for some examples.

# Acknowledgements
- http://code.google.com/p/fxdis-d3d1x/ for test data
- https://github.com/James-Jones/HLSLCrossCompiler for test data
- http://developer.download.nvidia.com/shaderlibrary/webpages/shader_library.html for test data
- https://github.com/pema99/UnityShaderParser/tree/master/UnityShaderParser.Tests/TestShaders/Sdk for test data
- https://github.com/microsoft/DirectX-Graphics-Samples/ for test data
- Unity Builtin Shaders used as ShaderLab test data, available on the Unity download page
- https://github.com/tgjones/HlslTools was used as inspiration and reference for some of the HLSL parsing techniques
