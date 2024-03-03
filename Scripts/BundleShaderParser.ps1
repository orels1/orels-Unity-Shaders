dotnet-combine single-file ..\UnityShaderParser\UnityShaderParser --output ./Packages/sh.orels.shaders.generator/Editor/Dependencies/UnityShaderParser/UnityShaderParser.cs --overwrite

Copy-Item ..\UnityShaderParser\LICENSE ./Packages/sh.orels.shaders.generator/Editor/Dependencies/UnityShaderParser/LICENSE.txt
Copy-Item ..\UnityShaderParser\README.md ./Packages/sh.orels.shaders.generator/Editor/Dependencies/UnityShaderParser/README.md