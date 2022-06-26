using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;
using UnityEditor;
using UnityEditor.Experimental.AssetImporters;
using UnityEngine;
using ORL.ModularShaderSystem;

namespace ORL
{
  #region Importer
  [ScriptedImporter(1, "orlshader")]
  public class ORLShaderDefinitionImporter : ScriptedImporter
  {
    
    // We collect .orlshader dependencies here to make sure they get processed beforehand
    static string[] GatherDependenciesFromSourceFile(string path)
    {
      var depPaths = new List<string>();
      using (var sr = new StringReader(File.ReadAllText(path)))
      {
        var builder = new StringBuilder();
        string line;
        var name = "";
        var deleteEmptyLine = false;
        var type = "";
        while ((line = sr.ReadLine()) != null)
        {
          // skip commented out code
          if (line.Trim().StartsWith("//"))
          {
            continue;
          }
          if (line.Contains("#T#") || line.Contains("#S#"))
          {
            if (builder.Length > 0 && !string.IsNullOrWhiteSpace(name) && type == "includes")
            {
              PreProcessIncludes(builder, ref depPaths, path);
            }
    
            if (line.Contains("#T#"))
            {
              type = "template";
            }
            else
            {
              switch (line)
              {
                case "#S#Settings": type = "settings"; break;
                case "#S#Includes": type = "includes"; break;
                case "#S#Properties": type = "properties"; break;
                case "#S#FragmentVariables": type = "fragVars"; break;
                case "#S#VertexVariables": type = "vertVars"; break;
                case "#S#ColorVariables": type = "colorVars"; break;
                case "#S#ShadowVariables": type = "shadowVars"; break;
              }
            }
    
            builder = new StringBuilder();
            name = line.Replace("#T#", "").Trim();
            continue;
          }
    
          if (string.IsNullOrEmpty(line))
          {
            if (deleteEmptyLine)
              continue;
            deleteEmptyLine = true;
          }
          else
          {
            deleteEmptyLine = false;
          }
    
          if (!string.IsNullOrWhiteSpace(name))
          {
            builder.AppendLine(line);
          }
        }

        // make sure that the last section is processed correctly before returning
        if (builder.Length > 0 && !string.IsNullOrWhiteSpace(name))
        {
          PreProcessIncludes(builder, ref depPaths, path);
        }
      }
      
      return depPaths.ToArray();
    }

    private static void PreProcessIncludes(StringBuilder builder, ref List<string> finalPaths, string assetPath)
    {
      var includeLines = builder.ToString().Split(new[] { Environment.NewLine }, StringSplitOptions.RemoveEmptyEntries);
      var includes = new List<string>();
      foreach (var line in includeLines)
      {
        if (line.Contains("#S#")) continue;
        var cleaned = line.Trim().Replace("\"", "");
        includes.Add(cleaned);
      }

      foreach (var include in includes)
      {
        if (!include.Contains(".orlshader")) continue;
        finalPaths.Add(ResolveRequiredPath(include, assetPath));
      }
    }
    
    public override void OnImportAsset(AssetImportContext ctx)
    {
      var subAsset = ScriptableObject.CreateInstance<ORLShaderDefinition>();

      using (var sr = new StringReader(File.ReadAllText(ctx.assetPath)))
      {
        var builder = new StringBuilder();
        string line;
        var name = "";
        var deleteEmptyLine = false;
        var type = "";
        while ((line = sr.ReadLine()) != null)
        {
          // skip commented out code
          if (line.Trim().StartsWith("//"))
          {
            continue;
          }
          if (line.Contains("#T#") || line.Contains("#S#"))
          {
            if (builder.Length > 0 && !string.IsNullOrWhiteSpace(name))
            {
              SaveAssetForType(type, ctx, subAsset, builder, name);
            }

            if (line.Contains("#T#"))
            {
              type = "template";
            }
            else
            {
              switch (line)
              {
                case "#S#Settings": type = "settings"; break;
                case "#S#Includes": type = "includes"; break;
                case "#S#Properties": type = "properties"; break;
                case "#S#FragmentVariables": type = "fragVars"; break;
                case "#S#VertexVariables": type = "vertVars"; break;
                case "#S#ColorVariables": type = "colorVars"; break;
                case "#S#ShadowVariables": type = "shadowVars"; break;
                case "#S#TessFactorsVariables": type = "tessFactorsVars"; break;
              }
            }

            builder = new StringBuilder();
            name = line.Replace("#T#", "").Trim();
            continue;
          }

          if (string.IsNullOrEmpty(line))
          {
            if (deleteEmptyLine)
              continue;
            deleteEmptyLine = true;
          }
          else
          {
            deleteEmptyLine = false;
          }

          if (!string.IsNullOrWhiteSpace(name))
          {
            builder.AppendLine(line);
          }
        }

        if (builder.Length > 0 && !string.IsNullOrWhiteSpace(name))
          SaveAssetForType(type, ctx, subAsset, builder, name);
      }

      // create a module
      var module = ScriptableObject.CreateInstance<ShaderModule>();
      module.Id = subAsset.ShaderName.Replace("/", ".").Replace(" ", "_");
      module.Name = subAsset.ShaderName;
      module.Author = subAsset.AuthorName;
      module.Properties = subAsset.Props.Select(prop => new Property
      {
        Attributes = prop.Attributes.ToList(),
        DefaultValue = prop.DefaultValue,
        DisplayName = prop.Description,
        Name = prop.Name,
        DefaultTextureAsset = null,
        Type = prop.Type
      }).ToList();
      module.Functions = new List<ShaderFunction>();
      module.Templates = new List<ModuleTemplate>();

      SaveOptionalTemplate(ref module, ref subAsset, "ShaderFeatures", "SHADER_FEATURES");
      SaveOptionalTemplate(ref module, ref subAsset, "ShaderDefines", "SHADER_DEFINES");
      SaveOptionalTemplate(ref module, ref subAsset, "LibraryFunctions", "LIBRARY_FUNCTIONS");
      SaveOptionalTemplate(ref module, ref subAsset, "ShaderTags", "SHADER_TAGS");
      SaveOptionalTemplate(ref module, ref subAsset, "PassTags", "PASS_TAGS");
      SaveOptionalTemplate(ref module, ref subAsset, "PassModifiers", "PASS_MODS");
      SaveOptionalTemplate(ref module, ref subAsset, "TessFactorsFunction", "TESS_FACTORS_FUNCTION");

      SaveModuleFunction(
        ref module, ref subAsset, 
        "FRAGMENT_FUNCTION",
        "FRAGMENT",
        "Fragment",
        ref subAsset.FragmentVariables,
        subAsset.FragmentFunction, subAsset.FragmentQueue
      );

      SaveModuleFunction(
        ref module, ref subAsset, 
        "VERTEX_FUNCTION",
        "VERTEX",
        "Vertex",
        ref subAsset.VertexVariables,
        subAsset.VertexFunction, subAsset.VertexQueue
      );

      SaveModuleFunction(
        ref module, ref subAsset, 
        "FINAL_COLOR_MOD",
        "COLOR",
        "Color",
        ref subAsset.ColorVariables,
        subAsset.ColorFunction, subAsset.ColorQueue
      );

      SaveModuleFunction(
        ref module, ref subAsset, 
        "SHADOW_FUNCTION",
        "SHADOW",
        "Shadow",
        ref subAsset.ShadowVariables,
        subAsset.ShadowFunction, subAsset.ShadowQueue
      );
      
      SaveModuleFunction(
        ref module, ref subAsset, 
        "NOT_INCLUDED", // we inject the template directly instead of using function chaining
        "NOT_INCLUDED",
        "TessFactors",
        ref subAsset.TessFactorsVariables,
        subAsset.TessFactorsFunction, 0
      );

      var shader = ScriptableObject.CreateInstance<ModularShader>();

      shader.Name = subAsset.ShaderName;
      shader.Id = subAsset.ShaderName.Replace("/", ".");
      shader.Author = subAsset.AuthorName;
      shader.ShaderPath = subAsset.ShaderName;
      shader.Version = subAsset.Version;
      shader.CustomEditor = subAsset.CustomEditor;
      // in case of pure modules - the template might not be defined
      if (!string.IsNullOrEmpty(subAsset.Template))
      {
        shader.ShaderTemplate = ResolveBaseTemplate(subAsset.Template, assetPath);
      }
      shader.BaseModules = new List<ShaderModule>();
      var selfIncluded = false;
      foreach (var include in subAsset.Includes)
      {
        if (include == "self")
        {
          shader.BaseModules.Add(module);
          selfIncluded = true;
          continue;
        }
        shader.BaseModules.Add(ResolveModuleInclude(include, assetPath));
      }

      if (!selfIncluded)
      {
        shader.BaseModules.Add(module);
      }


      module.name = "ShaderModule";
      ctx.AddObjectToAsset("ShaderModule", module);
      shader.name = "Shader";
      ctx.AddObjectToAsset("Shader", shader);
      subAsset.GeneratedModule = module;
      subAsset.GeneratedShader = shader;

      ctx.AddObjectToAsset("Collection", subAsset);
      ctx.SetMainObject(subAsset);
    }

    private static string ResolveRequiredPath(string name, string assetPath)
    {
      // absolute paths
      var path = name.StartsWith("Assets/") ? name : Path.Combine(Path.GetDirectoryName(assetPath), name);
      // first - try to find asset in the main directory
      var folderRef = Resources.Load<TextAsset>("ORLLocator");
      var templatesPath = AssetDatabase.GetAssetPath(folderRef);
      templatesPath = templatesPath.Substring(0, templatesPath.LastIndexOf("/"));
      // templatesPath = templatesPath.Replace("Assets/", "/");
      templatesPath = templatesPath.Replace("/Resources", "/Sources/Editor/");

      var potentialAsset = AssetDatabase.LoadAssetAtPath<UnityEngine.Object>(templatesPath + name);
      if (potentialAsset != null)
      {
        return templatesPath + name;
      }

      return path;
    }

    private static TemplateAsset ResolveBaseTemplate(string name, string assetPath)
    {
      var finalPath = ResolveRequiredPath(name, assetPath);
      return AssetDatabase.LoadAssetAtPath<TemplateAsset>(finalPath);
    }

    private static ShaderModule ResolveModuleInclude(string name, string assetPath = "")
    {
      var finalPath = ResolveRequiredPath(name, assetPath);
      
      // handle .orlshader includes
      if (name.Contains(".orlshader"))
      {
        var asset = AssetDatabase.LoadAssetAtPath<ORLShaderDefinition>(finalPath);
        return asset.GeneratedModule;
      }

      return AssetDatabase.LoadAssetAtPath<ShaderModule>(finalPath);
    }

    private static void SaveAssetForType(string type, AssetImportContext ctx, ORLShaderDefinition asset, StringBuilder builder, string name)
    {
      switch (type)
      {
        case "template":
          SaveTemplateAsset(ctx, asset, builder, name);
          break;
        case "settings":
          SaveSettings(asset, builder);
          break;
        case "includes":
          SaveIncludes(asset, builder);
          break;
        case "properties":
          SaveProperties(asset, builder);
          break;
        case "fragVars":
          SaveFragVars(asset, builder);
          break;
        case "vertVars":
          SaveVertVars(asset, builder);
          break;
        case "colorVars":
          SaveColorVars(asset, builder);
          break;
        case "shadowVars":
          SaveShadowVars(asset, builder);
          break;
        case "tessFactorsVars":
          SaveTessFactorsVars(asset, builder);
          break;
      }
    }

    private static void SaveSettings(ORLShaderDefinition asset, StringBuilder builder)
    {
      var settingLines = builder.ToString().Split(new[] { Environment.NewLine }, StringSplitOptions.RemoveEmptyEntries);
      foreach (var line in settingLines)
      {
        if (line.Contains("#S#")) continue;
        var valueMatch = Regex.Match(line, "(?<=\")([\\d\\w\\s\\D\\W\\S/.]+)(?=\")");
        if (!valueMatch.Success) continue;
        if (line.StartsWith("Name"))
        {
          asset.ShaderName = valueMatch.Value;
          continue;
        }
        if (line.StartsWith("Author"))
        {
          asset.AuthorName = valueMatch.Value;
          continue;
        }
        if (line.StartsWith("Version"))
        {
          asset.Version = valueMatch.Value;
          continue;
        }
        if (line.StartsWith("Template"))
        {
          asset.Template = valueMatch.Value;
          continue;
        }
        if (line.StartsWith("CustomEditor"))
        {
          asset.CustomEditor = valueMatch.Value;
          continue;
        }
        if (line.StartsWith("FragmentQueue"))
        {
          asset.FragmentQueue = int.Parse(valueMatch.Value);
          continue;
        }
        if (line.StartsWith("VertexQueue"))
        {
          asset.VertexQueue = int.Parse(valueMatch.Value);
          continue;
        }
      }
    }

    private static void SaveIncludes(ORLShaderDefinition asset, StringBuilder builder)
    {
      var includeLines = builder.ToString().Split(new[] { Environment.NewLine }, StringSplitOptions.RemoveEmptyEntries);
      var includes = new List<string>();
      foreach (var line in includeLines)
      {
        if (line.Contains("#S#")) continue;
        var cleaned = line.Trim().Replace("\"", "");
        includes.Add(cleaned);
      }

      asset.Includes = includes;
    }

    private static void SaveProperties(ORLShaderDefinition asset, StringBuilder builder)
    {
      var propsLines = builder.ToString().Split(new[] { Environment.NewLine }, StringSplitOptions.RemoveEmptyEntries);
      var props = new List<ShaderProp>();
      foreach (var line in propsLines)
      {
        if (line.Contains("#S#")) continue;
        var prop = new ShaderProp();
        // Name
        var nameMatch = Regex.Match(line, "(?<!\\[)([\\w\\d_\\s]+)(?=\\(\")");
        if (nameMatch.Success)
        {
          prop.Name = nameMatch.Value.Trim();
        }
        // Attributes
        var attrMatches = Regex.Matches(line, "(?<=\\[)([\\w(),.\\s]+)(?=\\])");
        if (attrMatches.Count > 0)
        {
          prop.Attributes = new string[attrMatches.Count];
        }
        for (int i = 0; i < attrMatches.Count; i++)
        {
          prop.Attributes[i] = attrMatches[i].Value;
        }
        // Description
        var descMatch = Regex.Match(line, "(?<=\\(\")([\\w\\d\\s\\W\\D\\S]+?)(?=\")");
        if (descMatch.Success)
        {
          prop.Description = descMatch.Value;
        }
        // Type
        var typeMatch = Regex.Match(line, "(?<=\",)(?:\\s*)([\\w\\d\\s(),\\-\\.]+)(?=\\))");
        if (typeMatch.Success)
        {
          var formatted = typeMatch.Value.Trim();
          if (formatted == "CUBE")
          {
            formatted = "Cube";
          }
          prop.Type = formatted;
        }
        // Default Value
        var defaultMatch = Regex.Match(line, "(?<==)(?:\\s*)([\\w\\d\\(\\)\\-,.\"{}\\s]+)(?:\\s*)$");
        if (defaultMatch.Success)
        {
          prop.DefaultValue = defaultMatch.Value;
        }
        props.Add(prop);
      }

      asset.Props = props;
    }

    private static void SaveVarsForStage(ref List<ShaderVariable> target,
      StringBuilder builder)
    {
      var varLines = builder.ToString().Split(new[] { Environment.NewLine }, StringSplitOptions.RemoveEmptyEntries);
      var vars = new List<ShaderVariable>();
      foreach (var line in varLines)
      {
        if (line.Contains("#S#")) continue;
        var variable = new ShaderVariable();
        if (line.Contains("TEXTURE") || line.Contains("SAMPLER"))
        {
          variable.Name = line.Trim().Replace(";", "");
          variable.Type = "custom";
          vars.Add(variable);
          continue;
        }
        var typeMatch = Regex.Match(line, "([\\w\\d]+)(?=\\s)");
        if (typeMatch.Success)
        {
          variable.Type = typeMatch.Value.Trim();
        }

        var nameMatch = Regex.Match(line, "(?<=\\s)([\\w\\d]+)(?=;)");
        if (nameMatch.Success)
        {
          variable.Name = nameMatch.Value.Trim();
        }
        vars.Add(variable);
      }

      target = vars;
    }

    private static void SaveFragVars(ORLShaderDefinition asset, StringBuilder builder)
    {
      SaveVarsForStage(ref asset.FragmentVariables, builder);
    }

    private static void SaveVertVars(ORLShaderDefinition asset, StringBuilder builder)
    {
      SaveVarsForStage(ref asset.VertexVariables, builder);
    }

    private static void SaveColorVars(ORLShaderDefinition asset, StringBuilder builder)
    {
      SaveVarsForStage(ref asset.ColorVariables, builder);
    }

    private static void SaveShadowVars(ORLShaderDefinition asset, StringBuilder builder)
    {
      SaveVarsForStage(ref asset.ShadowVariables, builder);
    }
    
    private static void SaveTessFactorsVars(ORLShaderDefinition asset, StringBuilder builder)
    {
      SaveVarsForStage(ref asset.TessFactorsVariables, builder);
    }

    private static void SaveTemplateAsset(AssetImportContext ctx, ORLShaderDefinition asset, StringBuilder builder,
      string name)
    {
      var templateAsset = ScriptableObject.CreateInstance<TemplateAsset>();
      templateAsset.Template = builder.ToString();
      templateAsset.name = name;

      var lines = templateAsset.Template.Split(new[] { Environment.NewLine }, StringSplitOptions.RemoveEmptyEntries);
      if (lines.Length > 0)
      {
        var nameMatch = Regex.Match(lines[0], "(?<=\\s)([\\w\\d]+)(?=\\(.*\\))");
        if (nameMatch.Success)
        {
          switch (name)
          {
            case "FragmentFunction":
              asset.FragmentFunction = nameMatch.Value;
              break;
            case "VertexFunction":
              asset.VertexFunction = nameMatch.Value;
              break;
            case "ColorFunction":
              asset.ColorFunction = nameMatch.Value;
              break;
            case "ShadowFunction":
              asset.ShadowFunction = nameMatch.Value;
              break;
            case "TessFactorsFunction":
              asset.TessFactorsFunction = nameMatch.Value;
              break;
          }
        }
      }

      MatchCollection mk = Regex.Matches(templateAsset.Template, @"#K#\w*", RegexOptions.Multiline);
      MatchCollection mki = Regex.Matches(templateAsset.Template, @"#KI#\w*", RegexOptions.Multiline);

      var mkr = new string[mk.Count + mki.Count];
      for (var i = 0; i < mk.Count; i++)
        mkr[i] = mk[i].Value;
      for (var i = 0; i < mki.Count; i++)
        mkr[mk.Count + i] = mki[i].Value;

      templateAsset.Keywords = mkr.Distinct().ToArray();

      ctx.AddObjectToAsset(name, templateAsset);
      asset.Templates.Add(templateAsset);
    }

    private static void SaveModuleFunction(ref ShaderModule module, ref ORLShaderDefinition subAsset, string keywordPrefix, string codePrefix, string functionName, ref List<ShaderVariable> vars,
      string name, int queue)
    {
      if (string.IsNullOrEmpty(name)) return;
      module.Functions.Add(new ShaderFunction
        {
          AppendAfter = $"#K#{keywordPrefix}",
          CodeKeywords = new List<string> { $"{codePrefix}_CODE" },
          Name = name,
          Queue = (short)queue,
          ShaderFunctionCode = subAsset.Templates.Find(template => template.name == $"{functionName}Function"),
          UsedVariables = vars.Select(variable =>
          {
            var converted = new Variable
            {
              Name = variable.Name
            };
            if (variable.Type == "Int")
            {
              converted.Type = VariableType.Custom;
              converted.CustomType = variable.Type;
            }
            else
            {
              switch (variable.Type)
              {
                case "half":
                  converted.Type = VariableType.Half;
                  break;
                case "half2":
                  converted.Type = VariableType.Half2;
                  break;
                case "half3":
                  converted.Type = VariableType.Half3;
                  break;
                case "half4":
                  converted.Type = VariableType.Half4;
                  break;
                case "float":
                  converted.Type = VariableType.Float;
                  break;
                case "float2":
                  converted.Type = VariableType.Float2;
                  break;
                case "float3":
                  converted.Type = VariableType.Float3;
                  break;
                case "float4":
                  converted.Type = VariableType.Float4;
                  break;
                case "custom":
                  converted.Type = VariableType.Custom;
                  break;
                default:
                  converted.Type = VariableType.Custom;
                  converted.CustomType = variable.Type;
                  break;
              }
            }

            return converted;
          }).ToList()
        });
    }

    private static void SaveOptionalTemplate(ref ShaderModule module, ref ORLShaderDefinition subAsset, string name, string keyword)
    {
      var foundTemplate = subAsset.Templates.Find(t => t.name == name);
      if (foundTemplate != null)
      {
        module.Templates.Add(new ModuleTemplate()
        {
          Queue = 0,
          Template = foundTemplate,
          Keywords = new List<string> {
            keyword
          }
        });
      }
    }
    
    public override bool SupportsRemappedAssetType(Type type)
    {
      return type.IsAssignableFrom(typeof(ORLShaderDefinition));
    }
  }
  #endregion

  #region UI

  [CustomEditor(typeof(ORLShaderDefinitionImporter))]
  public class ORLShaderDefinitionImporterEditor : ScriptedImporterEditor
  {
    public override void OnInspectorGUI()
    {
      base.OnInspectorGUI();

      var t = Selection.activeObject as ORLShaderDefinition;
      if (t == null) return;
      if (GUILayout.Button("Generate Shader"))
      {
        if (t.GeneratedShader == null)
        {
          Debug.LogError("No Modular Shader found, make sure your Shader Definition is valid");
          return;
        }
        var _issues = ShaderGenerator.CheckShaderIssues(t.GeneratedShader);
        if (_issues.Count > 0)
        {
          EditorUtility.DisplayDialog("Error", $"The modular shader has issues that must be resolved before generating the shader:\n  {string.Join("\n  ", _issues)}", "Ok");
          return;
        }

        var path = "";
        if (t.GeneratedShader.LastGeneratedShaders != null &&t.GeneratedShader.LastGeneratedShaders.Count > 0 && t.GeneratedShader.LastGeneratedShaders[0] != null)
        {
          path = Path.GetDirectoryName(AssetDatabase.GetAssetPath(t.GeneratedShader.LastGeneratedShaders[0]));
        }

        if (string.IsNullOrWhiteSpace(path))
        {

          path = EditorUtility.OpenFolderPanel("Select folder", "Assets", "");
          if (string.IsNullOrWhiteSpace(path))
            return;

        }
        var localPath = Environment.CurrentDirectory;
        localPath = localPath.Replace('\\', '/');
        path = path.Replace(localPath + "/", "");
        var filename = AssetDatabase.GetAssetPath(t);
        filename = filename.Replace('\\', '/');
        filename = filename.Substring(filename.LastIndexOf("/") + 1);
        filename = filename.Replace(".orlshader", "");
        ShaderGenerator.GenerateShader(path, t.GeneratedShader, filename);
        var shaderList = Resources.Load<ORLShaderList>("ORLShaderList");
        if (shaderList == null) return;
        var fullPath = AssetDatabase.GetAssetPath(t);
        EditorUtility.SetDirty(shaderList);
        path = path.Replace('\\', '/');
        if (shaderList.shadersList.ContainsKey(fullPath))
        {
          shaderList.shadersList[fullPath] = path;
        }
        else
        {
          shaderList.shadersList.Add(fullPath,path);
        }
        AssetDatabase.SaveAssets();
        AssetDatabase.Refresh();
      }
    }
  }
  #endregion
}
