# UnityShaderParser
A library for parsing Unity shaders. Consists of a few distinct components:
- A parser for ShaderLab, Unity's own Shader DSL.
- A parser for HLSL, the shading language embedded in ShaderLab.
- A preprocessor for dealing with macros before parsing.
- A framework for analyzing syntax trees using the visitor pattern, and for making edits to the corresponding source code.

Example usages:
- Used in [Slang shading language plugin](https://github.com/pema99/slangunityplugin) for Unity, [here](https://github.com/pema99/SlangUnityPlugin/blob/master/Editor/Scripts/SlangShaderImporter.cs#L39-L537).
- Used in [Orels' Unity shaders](https://github.com/orels1/orels-Unity-Shaders), in a few places ([example 1](https://github.com/orels1/orels-Unity-Shaders/blob/3ee6a786af8720c6e5f62383a34433844f6f7ac5/Packages/sh.orels.shaders.generator/Editor/ShaderAnalyzers.cs), [example 2](https://github.com/orels1/orels-Unity-Shaders/blob/3ee6a786af8720c6e5f62383a34433844f6f7ac5/Packages/sh.orels.shaders.generator/Editor/ShaderBlockValidations.cs)).
- Another small example in [this issue](https://github.com/pema99/UnityShaderParser/issues/3#issuecomment-2305855379).
- [The tests](https://github.com/pema99/UnityShaderParser/tree/master/UnityShaderParser.Tests) contain many small examples.

# Acknowledgements
- http://code.google.com/p/fxdis-d3d1x/ for test data
- https://github.com/James-Jones/HLSLCrossCompiler for test data
- http://developer.download.nvidia.com/shaderlibrary/webpages/shader_library.html for test data
- https://github.com/pema99/UnityShaderParser/tree/master/UnityShaderParser.Tests/TestShaders/Sdk for test data
- https://github.com/microsoft/DirectX-Graphics-Samples/ for test data
- Unity Builtin Shaders used as ShaderLab test data, available on the Unity download page
- https://github.com/tgjones/HlslTools was used as inspiration and reference for some of the HLSL parsing techniques
