using UnityEngine;
using UnityEditor;
using System;
using System.Collections.Generic;

namespace ORL.Shaders.UpgradePlans
{
    public class UpgradePlanBase
    {
        protected string _oldVersion;
        public string OldVersion => _oldVersion;
        protected string _newVersion;
        public string NewVersion => _newVersion;

        public virtual bool Upgrade(IList<Material> materials, bool dryRun = false)
        {
            Debug.Log("Upgrading materials to " + NewVersion);
            return true;
        }
    }
}