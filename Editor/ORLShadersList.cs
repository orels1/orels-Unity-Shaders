#if UNITY_EDITOR
using System.Collections.Generic;
using System.IO;
using Sirenix.OdinInspector;
using UnityEditor;
using UnityEngine;

namespace orels1.Shaders {
  [CreateAssetMenu(fileName = "ORLShadersList", menuName = "orels1/Internal/Shaders List", order = 1)]
  public class ORLShadersList : SerializedScriptableObject {
    public List<Shader> shadersToBuild;
    public List<TextAsset> dependencies;
    public Dictionary<string, Texture> nonModifiableTextures;

    [FolderPath]
    public string sourcePath = "Assets/Shaders/Develop";
    [FolderPath]
    public string buildPath = "Assets/Shaders/Release/orels1/ORL/";

    [FolderPath(ParentFolder = "@sourcePath")] public string extraAssetsToInclude = "Assets/";

    public bool includeSource = true;
    [ShowIf("includeSource")][FilePath]
    public List<string> extraSources;
    public bool createUnityPackage;
    [ShowIf("createUnityPackage")][FolderPath]
    public string packageExportPath = "Assets/Shaders/Release/";
    [ShowIf("createUnityPackage")]
    public string packageFileName = "ORLStandardShaders";

    public bool debugBuild;

    [Button("Build Shader Release")]
    public void BuildShaderList() {
      ORLShaderBuilder.BuildShaderRelease(shadersToBuild, dependencies, nonModifiableTextures, sourcePath, buildPath, includeSource, extraSources, extraAssetsToInclude, debugBuild);
      if (createUnityPackage) {
        var createPath = $"Assets/../{packageFileName}.unitypackage";
        var exportPath = packageExportPath + packageFileName + ".unitypackage";
        if (File.Exists(createPath)) {
          File.Delete(createPath);
        }
        AssetDatabase.ExportPackage(buildPath.Substring(0, buildPath.LastIndexOf("/")), packageFileName + ".unitypackage", ExportPackageOptions.Recurse);
        if (File.Exists(exportPath)) {
          File.Delete(exportPath);
        }
        File.Move(createPath, exportPath);
        AssetDatabase.Refresh();
      }
    }
  }
}
#endif
