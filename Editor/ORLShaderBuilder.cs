#if UNITY_EDITOR
using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using System.Linq;
using JBooth.BetterShaders;
using UnityEditor;
using UnityEngine;
using Debug = UnityEngine.Debug;

namespace orels1.Shaders {
  public class ORLShaderBuilder {
    public static void BuildShaderRelease(List<Shader> shaders, List<TextAsset> dependencies,
      Dictionary<string, Texture> nonModifiable, string sourcePath, string targetPath, bool includeSource, List<string> extraSources, string extraAssetsToInclude, bool debugBuild) {
      if (shaders == null) return;
      var sw = new Stopwatch();
      sw.Start();
      var assets = new List<string>();
      if (debugBuild) {
        Log($"Queing: {string.Join(",", shaders.Select(s => s.name).ToArray())}");
      }

      EditorUtility.DisplayProgressBar("Cleaning Up", "", 0.5f);
      CleanUp(targetPath);
      if (debugBuild) {
        Log("Cleaned target folder");
      }


      foreach (var dep in dependencies) {
        EditorUtility.DisplayProgressBar("Copying", dep.name, 0.5f);
        var path = AssetDatabase.GetAssetPath(dep);
        var newPath = targetPath + path.Substring(path.LastIndexOf("/") + 1);
        File.Copy(path, newPath);
        if (debugBuild) {
          Log($"Copied {path} to {newPath}");
        }
      }

      var nonModTextures = new List<Texture>();

      foreach (var texture in nonModifiable) {
        EditorUtility.DisplayProgressBar("Copying", texture.Value.name, 0.5f);
        var path = AssetDatabase.GetAssetPath(texture.Value);
        var original = AssetImporter.GetAtPath(path) as TextureImporter;
        var newPath = targetPath + path.Substring(path.LastIndexOf("/") + 1);
        File.Copy(path, newPath);
        AssetDatabase.Refresh();
        nonModTextures.Add(AssetDatabase.LoadAssetAtPath<Texture>(newPath));
        var copy = AssetImporter.GetAtPath(newPath) as TextureImporter;
        var settings = new TextureImporterSettings();
        original.ReadTextureSettings(settings);
        copy.SetTextureSettings(settings);
        copy.SetPlatformTextureSettings(original.GetDefaultPlatformTextureSettings());
        copy.SaveAndReimport();
        if (debugBuild) {
          Log($"Copied {path} to {newPath}");
        }
      }

      var finalShaders = new List<string>();
      // build the files
      var i = 1.0f;
      foreach (var shader in shaders) {
        EditorUtility.DisplayProgressBar("Building", shader.name, i / shaders.Count);
        var opts = new OptionOverrides {
          shaderName = shader.name.Replace("/Develop", "")
        };
        var path = AssetDatabase.GetAssetPath(shader);
        var built = BetterShaderImporterEditor.BuildExportShader(ShaderBuilder.RenderPipeline.Standard, opts, path);

        // add the NonModifiable tag to the props
        foreach (var nonModProp in nonModifiable) {
          built = built.Replace($"{nonModProp.Key}(\"", $"[NonModifiableTextureData]{nonModProp.Key}(\"");
          Log($"Marked {nonModProp.Key} as NonModifiable on {shader.name}");
        }

        var exportPath = targetPath + path.Substring(path.LastIndexOf("/") + 1).Replace(".surfshader", ".shader");
        File.WriteAllText(exportPath, built);
        finalShaders.Add(exportPath);
        if (debugBuild) {
          Log($"Built {shader.name} at {exportPath}");
        }
        i++;
      }

      AssetDatabase.Refresh();

      // Assign the texture
      foreach (var builtShader in finalShaders) {
        var shader = ShaderImporter.GetAtPath(builtShader) as ShaderImporter;
        if (shader == null) continue;
        EditorUtility.DisplayProgressBar("Assigning NonModMaps", $"{shader.GetShader().name}", i / nonModifiable.Count);
        var nonModNames = nonModifiable.Keys.ToArray();
        var nonModValues = nonModTextures.ToArray();
        shader.SetNonModifiableTextures(nonModNames, nonModValues);
        shader.SaveAndReimport();
        if (debugBuild) {
          Log($"Assigned nonModMaps: {string.Join(", ", nonModNames)} to {builtShader}");
        }
      }

      if (Directory.Exists(sourcePath + extraAssetsToInclude)) {
        CopyDirectory(sourcePath + extraAssetsToInclude, targetPath, true);
      }

      // Copy the source files
      if (includeSource) {
        var publishedSourcesPath = targetPath + "Sources";
        if (!Directory.Exists(publishedSourcesPath)) {
          Directory.CreateDirectory(publishedSourcesPath);
          if (debugBuild) {
            Log($"Created a source dir {publishedSourcesPath}");
          }
        }

        var uniqSources = new List<string>();
        // build a list of unique dependencies
        i = 1.0f;
        foreach (var shader in shaders) {
          EditorUtility.DisplayProgressBar("Collecting Sources", shader.name, i / shaders.Count);
          var lines = File.ReadAllLines(AssetDatabase.GetAssetPath(shader));
          foreach (var line in lines) {
            // skip the line if its not a dep
            if (!line.Contains(".surfshader")) continue;
            // we don't collect sources from subfolders
            if (line.Contains("/")) continue;
            if (!uniqSources.Contains(line.Trim().Replace("\"", ""))) {
              uniqSources.Add(line.Trim().Replace("\"", ""));
            }

            if (line.Contains("END_SUBSHADERS")) break;
          }
        }

        foreach (var extraSource in extraSources) {
          if (!uniqSources.Contains(extraSource.Substring(extraSource.LastIndexOf("/") + 1))) {
            uniqSources.Add(extraSource.Substring(extraSource.LastIndexOf("/") + 1));
          }
        }

        if (debugBuild) {
          Log($"Collected sources {string.Join(", ", uniqSources)}");
        }

          i = 1.0f;
        foreach (var source in uniqSources) {
          EditorUtility.DisplayProgressBar("Copying Sources", source, i / uniqSources.Count);
          var path = AssetDatabase.GetAssetPath(shaders[0]);
          path = path.Substring(0, path.LastIndexOf("/") + 1);
          path += source;
          var text = File.ReadAllText(path);
          text = text.Replace("orels1/Internal", "orels1/Source");
          File.WriteAllText(targetPath + "/Sources/" + source, text);
          if (debugBuild) {
            Log($"Copied source {source} to {path}");
          }
        }
      }

      AssetDatabase.Refresh();
      EditorUtility.ClearProgressBar();
      sw.Stop();
      if (debugBuild) {
        Log($"Build Finished in {sw.ElapsedMilliseconds}ms");
      }
    }
    
    // Copied from https://docs.microsoft.com/en-us/dotnet/standard/io/how-to-copy-directories
    private static void CopyDirectory(string sourceDir, string destinationDir, bool recursive)
    {
      // Get information about the source directory
      var dir = new DirectoryInfo(sourceDir);

      // Check if the source directory exists
      if (!dir.Exists)
        throw new DirectoryNotFoundException($"Source directory not found: {dir.FullName}");

      // Cache directories before we start copying
      DirectoryInfo[] dirs = dir.GetDirectories();

      // Create the destination directory
      Directory.CreateDirectory(destinationDir);

      // Get the files in the source directory and copy to the destination directory
      foreach (FileInfo file in dir.GetFiles())
      {
        string targetFilePath = Path.Combine(destinationDir, file.Name);
        file.CopyTo(targetFilePath);
      }

      // If recursive and copying subdirectories, recursively call this method
      if (recursive)
      {
        foreach (DirectoryInfo subDir in dirs)
        {
          string newDestinationDir = Path.Combine(destinationDir, subDir.Name);
          CopyDirectory(subDir.FullName, newDestinationDir, true);
        }
      }
    }

    // nuke everything in the target folder
    private static void CleanUp(string path) {
      if (Directory.Exists(path)) {
        Directory.Delete(path, true);
        Directory.CreateDirectory(path);
        AssetDatabase.Refresh();
      }
    }

    private static void Log(string text) {
      Debug.Log($"<color=#AB9DF2>[SHADER BUILDER]</color> {text}");
    }

    [MenuItem("Tools/Clear Progress Bar")]
    public static void ClearProgressBar() {
      EditorUtility.ClearProgressBar();
    }
  }
}
#endif
