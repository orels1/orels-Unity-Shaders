using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

namespace orels1 {
  public class ORS1ShaderMap {
    private static Dictionary<string, string> shaderMap = new Dictionary<string, string> {
      {"ProgramWaveNoise", "ProgramWave"},
      {"ProgramWaveSimple", "ProgramWave"}
    };

    public static Texture GetShaderHeaderTexture(string shaderName) {
      var texName = shaderName.Substring(shaderName.IndexOf("/") + 1);
      texName = texName.Replace(" ", "");
      if (shaderMap.ContainsKey(texName)) {
       return AssetDatabase.LoadAssetAtPath<Texture>($"Assets/Shaders/orels1/Resources/ors1_{shaderMap[texName]}.png"); 
      }
      return null;
    }
  }
}
