using System;
using System.Collections.Generic;
using System.IO;
using System.Reflection;
using ORL.OdinSerializer;
using UnityEditor;
using UnityEditor.ProjectWindowCallback;
using UnityEngine;
using ORL.ModularShaderSystem;
using Object = UnityEngine.Object;

namespace ORL
{
  public class ORLShaderDefinition : SerializedScriptableObject, ITemplateCollection
  {
    public string ShaderName;
    public string AuthorName;
    public string Version;
    public string Template;
    public string ShaderTags;
    public string PassTags;
    public string CustomEditor;
    public List<string> Includes;
    public List<ShaderProp> Props;
    public List<ShaderVariable> FragmentVariables;
    public string FragmentFunction;
    public int FragmentQueue;
    public List<ShaderVariable> VertexVariables;
    public string VertexFunction;
    public int VertexQueue;
    public List<ShaderVariable> ColorVariables;
    public string ColorFunction;
    public int ColorQueue;
    public List<ShaderVariable> ShadowVariables;
    public string ShadowFunction;
    public int ShadowQueue;

    // this mimics TemplateAssetCollection, as we essentially build on top of it
    public List<TemplateAsset> Templates;
    public List<TemplateAsset> TemplatesList
    {
      get => Templates;
      set => Templates = value;
    }

    public ShaderModule GeneratedModule;
    public ModularShader GeneratedShader;

    public ORLShaderDefinition()
    {
      ShaderName = "New Shader";
      AuthorName = "";
      Version = "1.0";
      ShaderTags = "";
      PassTags = "";
      CustomEditor = "";
      Includes = new List<string>();
      Props = new List<ShaderProp>();
      FragmentVariables = new List<ShaderVariable>();
      FragmentFunction = "";
      FragmentQueue = 0;
      VertexVariables = new List<ShaderVariable>();
      VertexFunction = "";
      VertexQueue = 0;
      ColorVariables = new List<ShaderVariable>();
      ColorFunction = "";
      ColorQueue = 0;
      ShadowVariables = new List<ShaderVariable>();
      ShadowFunction = "";
      ShadowQueue = 0;
      Templates = new List<TemplateAsset>();
    }

    [MenuItem("Assets/Create/Shader/ORL/PBR Shader", priority = 9)]
    private static void CreatePBRTemplateShader()
    {
      CreateTemplate("ORLPBRShaderTemplateMarkdown");
    }
    
    [MenuItem("Assets/Create/Shader/ORL/PBR Shader [No Editor]", priority = 9)]
    private static void CreatePBRTemplateShaderPure()
    {
      CreateTemplate("ORLPBRShaderTemplate");
    }
    
    [MenuItem("Assets/Create/Shader/ORL/VFX Shader", priority = 9)]
    private static void CreateVFXTemplateShader()
    {
      CreateTemplate("ORLVFXShaderTemplateMarkdown");
    }
    
    [MenuItem("Assets/Create/Shader/ORL/VFX Shader [No Editor]", priority = 9)]
    private static void CreateVFXTemplateShaderPure()
    {
      CreateTemplate("ORLVFXShaderTemplate");
    }
    
    private static void CreateTemplate(string templateName)
    {
      Type projectWindowUtilType = typeof(ProjectWindowUtil);
      MethodInfo getActiveFolderPath = projectWindowUtilType.GetMethod("GetActiveFolderPath", BindingFlags.Static | BindingFlags.NonPublic);
      object obj = getActiveFolderPath.Invoke(null, new object[0]);
      string pathToCurrentFolder = obj.ToString();
      string uniquePath = AssetDatabase.GenerateUniqueAssetPath($"{pathToCurrentFolder}/New Shader.orlshader");

      ProjectWindowUtil.StartNameEditingIfProjectWindowExists(0, ScriptableObject.CreateInstance<DoCreateNewAsset>(), uniquePath, null, (string) templateName);
    }

    private static Dictionary<string, string> PBRTemplateMapping = new Dictionary<string, string>
    {
      {"TEMPLATE", "ORL PBR Template.stemplate"},
      {"UTILITIES", "ORL Utility Functions.asset"},
      {"BASE_MODULE", "ORL PBR Module.asset"}
    };
    
    private static Dictionary<string, string> VFXemplateMapping = new Dictionary<string, string>
    {
      {"TEMPLATE", "ORL VFX Template.stemplate"},
      {"UTILITIES", "ORL Utility Functions.asset"},
      {"BASE_MODULE", "ORL VFX Module.asset"}
    };

    private static Dictionary<string, Dictionary<string, string>> templateMappings =
      new Dictionary<string, Dictionary<string, string>>
      {
        {"ORLPBRShaderTemplate", PBRTemplateMapping},
        {"ORLPBRShaderTemplateMarkdown", PBRTemplateMapping},
        {"ORLVFXShaderTemplate", VFXemplateMapping},
        {"ORLVFXShaderTemplateMarkdown", VFXemplateMapping}
      };

    internal class DoCreateNewAsset : EndNameEditAction
    {
      public override void Action(int instanceId, string pathName, string resourceFile)
      {
        var template = Resources.Load<TextAsset>(resourceFile);
        // add modules with correct paths
        var shaderContent = template.text;
        var name = pathName.Substring(pathName.LastIndexOf("/") + 1).Replace(".orlshader", "");
        shaderContent = shaderContent.Replace("SHADER_NAME", name);
        var mappings = templateMappings[resourceFile];
        foreach (var mapping in mappings)
        {
          shaderContent = shaderContent.Replace(mapping.Key, mapping.Value);
        }
        File.WriteAllText(pathName, shaderContent);
        AssetDatabase.Refresh();
        Object o = AssetDatabase.LoadAssetAtPath<Object>(pathName);
        Selection.activeObject = o;
      }

      public override void Cancelled(int instanceId, string pathName, string resourceFile) => Selection.activeObject = (Object)null;
    }
  }

  public class ShaderProp
  {
    public string Name = "";
    public string Description = "";
    public string Type = "";
    public string[] Attributes = Array.Empty<string>();
    public string DefaultValue = "";
  }

  public class ShaderVariable
  {
    public string Name;
    public string Type;
  }

  // since we're using serializer but not the Inspector - we need to draw everything ourselves
  [CustomEditor(typeof(ORLShaderDefinition))]
  public class ORLShaderDefinitionEditor : Editor
  {
    private byte[] result;
    private List<Object> referencedUnityObjects;
    private bool propsOpen = false;
    private bool vertexVarsOpen = false;
    private bool fragVarsOpen = false;
    private bool colorVarsOpen = false;
    private bool shadowVarsOpen = false;
    public override void OnInspectorGUI()
    {
      var t = target as ORLShaderDefinition;
      if (t == null) return;

      var box = new GUIStyle("helpBox");
      EditorGUILayout.LabelField("Settings", EditorStyles.largeLabel);
      EditorGUILayout.TextField("Shader Name", t.ShaderName);
      EditorGUILayout.TextField("Author", t.AuthorName);
      EditorGUILayout.TextField("Version", t.Version);
      EditorGUILayout.TextField("CustomEditor", t.CustomEditor);
      EditorGUILayout.TextField("Template", t.Template);
      EditorGUILayout.TextField("Shader Tags", t.ShaderTags);
      EditorGUILayout.TextField("Pass Tags", t.PassTags);
      EditorGUILayout.LabelField("Shader tags apply to the whole shader, while Pass Tags are injected into individual passes Tags block", EditorStyles.helpBox);
      EditorGUILayout.Space();

      propsOpen = EditorGUILayout.Foldout(propsOpen, "Properties");
      if (propsOpen)
      {
        foreach (var prop in t.Props)
        {
          using (var h = new EditorGUILayout.HorizontalScope(box))
          {
            EditorGUILayout.LabelField(prop.Name, prop.Type);
          }
        }
      }
      // there is no editing of the fields, so no change checks are needed

      EditorGUILayout.Space();
      EditorGUILayout.LabelField("Vertex Stage", EditorStyles.largeLabel);
      EditorGUILayout.TextField("Vertex Function:", t.VertexFunction);
      EditorGUILayout.IntField("Vertex Function Queue", t.VertexQueue);

      vertexVarsOpen = EditorGUILayout.Foldout(vertexVarsOpen, "Vertex Function Variables");
      if (vertexVarsOpen)
      {
        foreach (var prop in t.VertexVariables)
        {
          using (var h = new EditorGUILayout.HorizontalScope(box))
          {
            EditorGUILayout.LabelField(prop.Name, prop.Type);
          }
        }
      }

      EditorGUILayout.Space();
      EditorGUILayout.LabelField("Fragment Stage", EditorStyles.largeLabel);
      EditorGUILayout.TextField("Fragment Function:", t.FragmentFunction);
      EditorGUILayout.IntField("Fragment Function Queue", t.FragmentQueue);

      fragVarsOpen = EditorGUILayout.Foldout(fragVarsOpen, "Fragment Function Variables");
      if (fragVarsOpen)
      {
        foreach (var prop in t.FragmentVariables)
        {
          using (var h = new EditorGUILayout.HorizontalScope(box))
          {
            EditorGUILayout.LabelField(prop.Name, prop.Type);
          }
        }
      }

      EditorGUILayout.Space();
      EditorGUILayout.LabelField("Final Color Mods", EditorStyles.largeLabel);
      EditorGUILayout.TextField("Color Mod Function:", t.ColorFunction);
      EditorGUILayout.IntField("Color Mod Function Queue", t.ColorQueue);

      colorVarsOpen = EditorGUILayout.Foldout(colorVarsOpen, "Color Mod Function Variables");
      if (colorVarsOpen)
      {
        foreach (var prop in t.ColorVariables)
        {
          using (var h = new EditorGUILayout.HorizontalScope(box))
          {
            EditorGUILayout.LabelField(prop.Name, prop.Type);
          }
        }
      }

      EditorGUILayout.Space();
      EditorGUILayout.LabelField("Shadowcaster Mods", EditorStyles.largeLabel);
      EditorGUILayout.TextField("Shadowcaster Mod Function:", t.ShadowFunction);
      EditorGUILayout.IntField("Shadowcaster Mod Function Queue", t.ShadowQueue);

      shadowVarsOpen = EditorGUILayout.Foldout(shadowVarsOpen, "Shadowcaster Mod Function Variables");
      if (shadowVarsOpen)
      {
        foreach (var prop in t.ShadowVariables)
        {
          using (var h = new EditorGUILayout.HorizontalScope(box))
          {
            EditorGUILayout.LabelField(prop.Name, prop.Type);
          }
        }
      }
    }
  }
}
