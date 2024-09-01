using System;
using System.Collections.Generic;
using System.Text.RegularExpressions;
using ORL.ShaderInspector;
using UnityEditor;
using UnityEngine;
#if BAKERY_INCLUDED

namespace ORL.Drawers
{
    public class BakeryVolumeAssignerDrawer : IDrawerFunc
    {
        public string FunctionName => "BakeryVolumeAssigner";

        public string[] PersistentKeys => Array.Empty<string>();

        public bool OnGUI(MaterialEditor editor, MaterialProperty[] properties, MaterialProperty property, int index, ref Dictionary<string, object> uiState, Func<bool> next)
        {
            if (EditorGUI.indentLevel == -1) return true;

            var currentMaterial = editor.target as Material;

            var hasVolume = currentMaterial.GetTexture("_Volume0") != null;
            var newVolume = EditorGUILayout.ObjectField(hasVolume ? "Assign New Volume" : "Assign Volume", null, typeof(BakeryVolume), true) as BakeryVolume;

            if (newVolume != null)
            {
                currentMaterial.SetTexture("_Volume0", newVolume.bakedTexture0);
                currentMaterial.SetTexture("_Volume1", newVolume.bakedTexture1);
                currentMaterial.SetTexture("_Volume2", newVolume.bakedTexture2);
                currentMaterial.SetTexture("_VolumeMask", newVolume.bakedMask);
                if (newVolume.bakedTexture3 != null)
                {
                    currentMaterial.SetTexture("_Volume3", newVolume.bakedTexture3);
                }
                var bounds = newVolume.bounds;
                currentMaterial.SetVector("_VolumeMin", bounds.min);
                currentMaterial.SetVector("_VolumeInvSize", new Vector3(1.0f / bounds.size.x, 1.0f / bounds.size.y, 1.0f / bounds.size.z));
            }

            if (hasVolume)
            {
                if (GUILayout.Button("Unset Volume"))
                {
                    currentMaterial.SetTexture("_Volume0", null);
                    currentMaterial.SetTexture("_Volume1", null);
                    currentMaterial.SetTexture("_Volume2", null);
                    currentMaterial.SetTexture("_Volume3", null);
                    currentMaterial.SetTexture("_VolumeMask", null);
                    currentMaterial.SetVector("_VolumeMin", Vector3.zero);
                    currentMaterial.SetVector("_VolumeInvSize", Vector3.one * 1000001);
                }
            }

            return true;
        }
    }
}
#endif