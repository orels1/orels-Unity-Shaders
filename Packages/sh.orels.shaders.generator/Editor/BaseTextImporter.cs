using System.IO;
using UnityEditor.Experimental.AssetImporters;
using UnityEngine;

namespace ORL.ShaderGenerator
{
    public class BaseTextImporter : ScriptedImporter
    {
        public override void OnImportAsset(AssetImportContext ctx)
        {
            var textContent = File.ReadAllText(ctx.assetPath);
            var textAsset = new TextAsset(textContent);
            textAsset.name = "Content";
            ctx.AddObjectToAsset("Collection", textAsset);
            ctx.SetMainObject(textAsset);
        }
    }
}