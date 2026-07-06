using System;
using System.Collections.Generic;
using System.Text.RegularExpressions;
using UnityEditor;
using UnityEngine;

namespace ORL.Drawers
{
    /// This simply stores the priority number used by the parser during deduplication, higher priority will be kept
    public class PriorityDrawer : IDrawerFunc
    {
        public string FunctionName => "Priority";

        // Matches %Priority(Value)
        private Regex _matcher = new Regex(@"%Priority\((?<priority>[\d]+)+\)");

        public string[] PersistentKeys => Array.Empty<string>();

        public bool OnGUI(MaterialEditor editor, MaterialProperty[] properties, MaterialProperty property, int index, ref Dictionary<string, object> uiState, Func<bool> next)
        {
            return next();
        }
    }
}
