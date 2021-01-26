using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

namespace orels1 {
  public class ORS1ShaderMap {
    private static Dictionary<string, string> shaderMap = new Dictionary<string, string> {
      {"ProgramWaveNoise", "ProgramWave"},
      {"ProgramWaveSimple", "ProgramWave"},
      {"SimpleIce", "SimpleIce"},
      {"CeilingLights", "CeilingLights"}
    };
    
    private static Dictionary<string, string> docsMap = new Dictionary<string, string> {
      {"ProgramWaveNoise", "https://shaders.orels.sh/shaders/program-wave"},
      {"ProgramWaveSimple", "https://shaders.orels.sh/shaders/program-wave"},
      {"SimpleIce", "https://shaders.orels.sh/shaders/simple-ice"},
      {"CeilingLights", "https://shaders.orels.sh/shaders/ceiling-lights"}
    };

    public static Texture GetShaderHeaderTexture(string shaderName) {
      var texName = shaderName.Substring(shaderName.IndexOf("/") + 1);
      texName = texName.Replace(" ", "");
      if (shaderMap.ContainsKey(texName)) {
       return AssetDatabase.LoadAssetAtPath<Texture>($"Assets/Shaders/orels1/Resources/ors1_{shaderMap[texName]}.png"); 
      }
      return null;
    }

    public static string GetShaderHelpLink(string shaderName) {
      var linkKey = shaderName.Substring(shaderName.IndexOf("/") + 1);
      linkKey = linkKey.Replace(" ", "");
      if (docsMap.ContainsKey(linkKey)) {
        return docsMap[linkKey];
      }
      return null;
    }
  }
}
