using System;
using System.Collections.Generic;
using ORL.ShaderInspector;
using UnityEditor;

namespace ORL.Drawers
{
    public interface IDrawerFunc
    {
        // All the functions use the same syntax %FnName()
        // Functions can be combined with other drawers
        string FunctionName { get; }

        bool OnGUI(MaterialEditor editor,
            MaterialProperty[] properties,
            MaterialProperty property,
            int index,
            ref Dictionary<string, object> uiState,
            Func<bool> next
        )
        {
            return OnGUI(editor, properties, property, index, ref uiState, next, new Dictionary<string, LocalizationData.LocalizedPropData>());
        }
        
        bool OnGUI(
            MaterialEditor editor,
            MaterialProperty[] properties,
            MaterialProperty property,
            int index,
            ref Dictionary<string, object> uiState,
            Func<bool> next,
            Dictionary<string, LocalizationData.LocalizedPropData> localizationData
        )
        {
            return OnGUI(editor, properties, property, index, ref uiState, next);
        }

        // You can define an array of string key prefixes to be put into the `uiState` that you want to be persisted on the material
        // This is useful for things like foldouts, toggles, etc.
        // It is recommended to prefix your keys with the name of your drawer to avoid collisions
        // Currently only values of the following types are persisted: int, float, bool, string, and Gradient
        string[] PersistentKeys { get; }
    }
}