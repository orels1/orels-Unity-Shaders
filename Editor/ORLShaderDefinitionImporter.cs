using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Reflection;
using System.Text;
using System.Text.RegularExpressions;
using ORL.OdinSerializer.Utilities;
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
    public override void OnImportAsset(AssetImportContext ctx)
    {
      var subAsset = ScriptableObject.CreateInstance<ORLShaderDefinition>();

      //string text = File.ReadAllText(ctx.assetPath);


      using (var sr = new StringReader(File.ReadAllText(ctx.assetPath)))
      {
        var builder = new StringBuilder();
        string line;
        string name = "";
        bool deleteEmptyLine = false;
        string type = "";
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
      module.Author = "orels1";
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

      var shaderFeatures = subAsset.Templates.Find(t => t.name == "ShaderFeatures");
      if (shaderFeatures != null)
      {
        module.Templates.Add(new ModuleTemplate()
        {
          Queue = 0,
          Template = shaderFeatures,
          Keywords = new List<string>() {
            "SHADER_FEATURES"
          }
        });
      }

      var shaderDefines = subAsset.Templates.Find(t => t.name == "ShaderDefines");
      if (shaderDefines != null)
      {
        module.Templates.Add(new ModuleTemplate()
        {
          Queue = 0,
          Template = shaderDefines,
          Keywords = new List<string>() {
            "SHADER_DEFINES"
          }
        });
      }

      var libraryFunctions = subAsset.Templates.Find(t => t.name == "LibraryFunctions");
      if (libraryFunctions != null)
      {
        module.Templates.Add(new ModuleTemplate()
        {
          Queue = 0,
          Template = libraryFunctions,
          Keywords = new List<string>() {
            "LIBRARY_FUNCTIONS"
          }
        });
      }

      var shaderTags = subAsset.Templates.Find(t => t.name == "ShaderTags");
      if (shaderTags != null)
      {
        module.Templates.Add(new ModuleTemplate()
        {
          Queue = 0,
          Template = shaderTags,
          Keywords = new List<string>() {
            "SHADER_TAGS"
          }
        });
        subAsset.ShaderTags = shaderTags.Template;
      }

      var passTags = subAsset.Templates.Find(t => t.name == "PassTags");
      if (passTags != null)
      {
        module.Templates.Add(new ModuleTemplate()
        {
          Queue = 0,
          Template = passTags,
          Keywords = new List<string>() {
            "PASS_TAGS"
          }
        });
        subAsset.PassTags = passTags.Template;
      }

      var passModifiers = subAsset.Templates.Find(t => t.name == "PassModifiers");
      if (passModifiers != null)
      {
        module.Templates.Add(new ModuleTemplate()
        {
          Queue = 0,
          Template = passModifiers,
          Keywords = new List<string>() {
            "PASS_MODS"
          }
        });
      }

      if (!string.IsNullOrEmpty(subAsset.FragmentFunction))
      {
        module.Functions.Add(new ShaderFunction
        {
          AppendAfter = "#K#FRAGMENT_FUNCTION",
          CodeKeywords = new List<string>() { "FRAGMENT_CODE" },
          Name = subAsset.FragmentFunction,
          Queue = (short)subAsset.FragmentQueue,
          ShaderFunctionCode = subAsset.Templates.Find(template => template.name == "FragmentFunction"),
          UsedVariables = subAsset.FragmentVariables.Select(variable =>
          {
            var converted = new Variable()
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

      if (!string.IsNullOrEmpty(subAsset.VertexFunction))
      {
        module.Functions.Add(new ShaderFunction
        {
          AppendAfter = "#K#VERTEX_FUNCTION",
          CodeKeywords = new List<string>() { "VERTEX_CODE" },
          Name = subAsset.VertexFunction,
          Queue = (short)subAsset.VertexQueue,
          ShaderFunctionCode = subAsset.Templates.Find(template => template.name == "VertexFunction"),
          UsedVariables = subAsset.VertexVariables.Select(variable =>
          {
            var converted = new Variable()
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

      if (!string.IsNullOrEmpty(subAsset.ColorFunction))
      {
        module.Functions.Add(new ShaderFunction
        {
          AppendAfter = "#K#FINAL_COLOR_MOD",
          CodeKeywords = new List<string>() { "COLOR_CODE" },
          Name = subAsset.ColorFunction,
          Queue = (short)subAsset.ColorQueue,
          ShaderFunctionCode = subAsset.Templates.Find(template => template.name == "ColorFunction"),
          UsedVariables = subAsset.ColorVariables.Select(variable =>
          {
            var converted = new Variable()
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

      var shader = ScriptableObject.CreateInstance<ModularShader>();

      shader.Name = subAsset.ShaderName;
      shader.Id = subAsset.ShaderName.Replace("/", ".");
      shader.Author = subAsset.AuthorName;
      shader.ShaderPath = subAsset.ShaderName;
      shader.Version = subAsset.Version;
      shader.CustomEditor = subAsset.CustomEditor;
      shader.ShaderTemplate =
        AssetDatabase.LoadAssetAtPath<TemplateAsset>(Path.Combine(Path.GetDirectoryName(assetPath), subAsset.Template));
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
        // if we're trying to reference a subshader - extract its module
        if (include.Contains(".orlshader"))
        {
          var subshader =
          AssetDatabase.LoadAssetAtPath<ORLShaderDefinition>(Path.Combine(Path.GetDirectoryName(assetPath), include));
          shader.BaseModules.Add(subshader.GeneratedModule);
          continue;
        }
        var resolved =
          AssetDatabase.LoadAssetAtPath<ShaderModule>(Path.Combine(Path.GetDirectoryName(assetPath), include));
        shader.BaseModules.Add(resolved);
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
      }
    }

    private static void SaveSettings(ORLShaderDefinition asset, StringBuilder builder)
    {
      var settingLines = builder.ToString().Split(new[] { Environment.NewLine }, StringSplitOptions.RemoveEmptyEntries);
      foreach (var line in settingLines)
      {
        if (line.Contains("#S#")) continue;
        var valueMatch = Regex.Match(line, "(?<=\")([\\d\\w\\s\\D\\W\\S/.]+)(?=\")");
        if (valueMatch.Success)
        {
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
        var typeMatch = Regex.Match(line, "(?<=\",)(?:\\s*)([\\w\\d\\s(),\\.]+)(?=\\))");
        if (typeMatch.Success)
        {
          prop.Type = typeMatch.Value.Trim();
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

    private static void SaveFragVars(ORLShaderDefinition asset, StringBuilder builder)
    {
      var varLines = builder.ToString().Split(new[] { Environment.NewLine }, StringSplitOptions.RemoveEmptyEntries);
      var vars = new List<ShaderVariable>();
      foreach (var line in varLines)
      {
        if (line.Contains("#S#")) continue;
        var variable = new ShaderVariable();
        if (line.Contains("TEXTURE") || line.Contains("SAMPLER"))
        {
          variable.Name = line.Trim();
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

      asset.FragmentVariables = vars;
    }

    private static void SaveVertVars(ORLShaderDefinition asset, StringBuilder builder)
    {
      var varLines = builder.ToString().Split(new[] { Environment.NewLine }, StringSplitOptions.RemoveEmptyEntries);
      var vars = new List<ShaderVariable>();
      foreach (var line in varLines)
      {
        if (line.Contains("#S#")) continue;
        var variable = new ShaderVariable();
        if (line.Contains("TEXTURE") || line.Contains("SAMPLER"))
        {
          variable.Name = line.Trim();
          variable.Name = variable.Name.Replace(";", "");
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

      asset.VertexVariables = vars;
    }

    private static void SaveColorVars(ORLShaderDefinition asset, StringBuilder builder)
    {
      var varLines = builder.ToString().Split(new[] { Environment.NewLine }, StringSplitOptions.RemoveEmptyEntries);
      var vars = new List<ShaderVariable>();
      foreach (var line in varLines)
      {
        if (line.Contains("#S#")) continue;
        var variable = new ShaderVariable();
        if (line.Contains("TEXTURE") || line.Contains("SAMPLER"))
        {
          variable.Name = line.Trim();
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

      asset.ColorVariables = vars;
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
        var nameMatch = Regex.Match(lines[0], "(?<=\\s)([\\w\\d]+)(?=\\(\\))");
        if (nameMatch.Success)
        {
          if (name == "FragmentFunction")
          {
            asset.FragmentFunction = nameMatch.Value;
          }

          if (name == "VertexFunction")
          {
            asset.VertexFunction = nameMatch.Value;
          }

          if (name == "ColorFunction")
          {
            asset.ColorFunction = nameMatch.Value;
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
        var issues = ShaderGenerator.CheckShaderIssues(t.GeneratedShader);
        if (issues.Count > 0)
        {
          EditorUtility.DisplayDialog("Error", $"The modular shader has issues that must be resolved before generating the shader:\n  {string.Join("\n  ", issues)}", "Ok");
          return;
        }

        string path = EditorUtility.OpenFolderPanel("Select folder", "Assets", "");
        if (path.Length == 0)
          return;

        string localPath = Environment.CurrentDirectory;
        localPath = localPath.Replace('\\', '/');
        path = path.Replace(localPath + "/", "");
        ShaderGenerator.GenerateShader(path, t.GeneratedShader);
      }
    }
  }
  #endregion
}
