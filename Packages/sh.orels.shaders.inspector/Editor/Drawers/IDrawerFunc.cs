using System;
using System.Collections.Generic;
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
        Dictionary<string, object> uiState,
        Func<bool> next);
    }
}