using System;
using System.Collections.Generic;
using UnityEditor;

namespace ORL.Drawers
{
    public interface IDrawer
    {
        // These are arbitrary drawer matchers
        // These can be combined with other drawers but the order of execution is not guaranteed
        // If you want to add a new %DrawerFunction() you should use IDrawerFunc instead
        bool MatchDrawer(MaterialProperty property);
        
        bool OnGUI(
            MaterialEditor editor,
            MaterialProperty[] properties,
            MaterialProperty property,
            int index,
            Dictionary<string, object> uiState,
            Func<bool> next
        );
        
    }
}