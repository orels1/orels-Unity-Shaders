using UnityEngine;
using UnityEditor;
using System;
using orels1;

public class ORS1MaterialEditor : ShaderGUI {
  private Texture headerImage;
  private bool headerFailed;
  private string helpLink;
  private bool noHelpLink;
  
  public override void OnGUI(MaterialEditor materialEditor, MaterialProperty[] properties) {
    try {
      if (!headerFailed && !noHelpLink) {
        if (headerImage == null || helpLink == null) {
          var shaderName = (materialEditor.target as Material).shader.name;
          if (shaderName.StartsWith("orels1") || shaderName.StartsWith("ors1")) {
            headerImage = ORS1ShaderMap.GetShaderHeaderTexture(shaderName);
            helpLink = ORS1ShaderMap.GetShaderHelpLink(shaderName);
            if (headerImage == null) {
              headerFailed = true;
            }

            if (helpLink == null) {
              noHelpLink = true;
            }
          }
          else {
            headerFailed = true;
            noHelpLink = true;
          }
        }

        // we check here too for the case when it was failed during loading
        if (!headerFailed) {
          var rect = EditorGUILayout.GetControlRect(GUILayout.Height(64));
          GUI.DrawTexture(rect, headerImage, ScaleMode.ScaleToFit);
        }

        if (!noHelpLink) {
          if (GUILayout.Button(new GUIContent("Check out the docs"), GUILayout.Height(15))) {
            Application.OpenURL(helpLink);
          }
          EditorGUILayout.Space();
        }
      }
    }
    catch {
      headerFailed = true;
      noHelpLink = true;
    }
    EditorGUI.BeginChangeCheck();
    base.OnGUI(materialEditor, properties);

    Material mat = materialEditor.target as Material;
    
    materialEditor.LightmapEmissionProperty();
    if(EditorGUI.EndChangeCheck() )
    {

      string isEmissive = mat.GetTag( "IsEmissive", false, "false" );
      if( isEmissive.Equals( "true" ) )
      {
        mat.globalIlluminationFlags &= (MaterialGlobalIlluminationFlags)3;
      }
      else
      {
        mat.globalIlluminationFlags |= MaterialGlobalIlluminationFlags.EmissiveIsBlack;
      }
    }
    
  }
}
