#if UNITY_2019_4
using System;
using System.Collections.Generic;
using System.IO;
using System.IO.Compression;
using System.Linq;
using System.Net.Http;
using System.Threading.Tasks;
using Newtonsoft.Json;
using ORL.Drawers;
using UnityEditor;
using UnityEditor.PackageManager.Requests;
using UnityEngine;
using UnityEngine.UIElements;

namespace ORL.ShaderInspector.MaterialLibraries
{
    public class AmbientCGBrowser: PopupWindowContent
    {
        private readonly Action _onClose;
        private readonly Material _targetMaterial;
        public override Vector2 GetWindowSize()
        {
            return new Vector2(440, 500);
        }

        public override void OnGUI(Rect rect)
        {
            // do stuff here
        }

        public AmbientCGBrowser(Action onClose, Material targetMaterial): base()
        {
            _onClose = onClose;
            _targetMaterial = targetMaterial;
        }

        private class AmbientCGResult
        {
            public SearchQuery searchQuery { get; set; }
            public List<AmbientCGMaterial> foundAssets { get; set; }
        }
        
        private class SearchQuery
        {
            public bool forceSpecificAssetId { get; set; }
            public List<string> category { get; set; }
            public List<string> assetId { get; set; }
            public string absoluteDate { get; set; }
            public List<string> dataType { get; set; }
            public List<string> creationMethod { get; set; }
            public string queryString { get; set; }
            public string sort { get; set; }
            public string createdUsingAssetId { get; set; }
            public string basedOnAssetId { get; set; }
            public string variationsOfAssetId { get; set; }
            public string limit { get; set; }
            public string offset { get; set; }
            public Include include { get; set; }

            public struct Include
            {
                public bool statisticsData { get; set; }
                public bool tagData { get; set; }
                public bool displayData { get; set; }
                public bool dimensionsData { get; set; }
                public bool relationshipData { get; set; }
                public bool neighbourData { get; set; }
                public bool variationsData { get; set; }
                public bool downloadData { get; set; }
                public bool previewData { get; set; }
                public bool mapData { get; set; }
                public bool usdData { get; set; }
                public bool imageData { get; set; }
            }
        }

        public class AmbientCGMaterial
        {
            public string assetId { get; set; }
            public string releaseDate { get; set; }
            public string earlyReleaseDate { get; set; }
            public string dataType { get; set; }
            public string creationMethod { get; set; }
            public string category { get; set; }
            public string dataTypeName { get; set; }
            public string dataTypeDescription { get; set; }
            public string creationMethodName { get; set; }
            public string creationMethodDescription { get; set; }
            public string displayName { get; set; }
            public string customDisplayName { get; set; }
            public string description { get; set; }
            public string displayCategory { get; set; }
            public string shortLink { get; set; }
            public PreviewImage previewImage { get; set; }
            public DownloadFolders downloadFolders { get; set; }
            
            public class PreviewImage
            {
                [JsonProperty("256-PNG")]
                public string png256 { get; set; }
            }

            public class DownloadFolders
            {
                [JsonProperty("default")]
                public DownloadFolder defaultFolder { get; set; }

                public class DownloadFolder
                {
                    public string title { get; set; }
                    public DownloadFiletypeCategories downloadFiletypeCategories { get; set; }

                    public class DownloadFiletypeCategories
                    {
                        public DownloadFolderCategory zip { get; set; }
                        
                        public class DownloadFolderCategory
                        {
                            public string title { get; set; }
                            public List<Download> downloads { get; set; }

                            public class Download
                            {
                                public string fullDownloadPath { get; set; }
                                public string downloadLink { get; set; }
                                public string fileName { get; set; }
                                public long size { get; set; }
                                public string filetype { get; set; }
                                public string attribute { get; set; }
                                public List<string> zipContent { get; set; }
                            }
                        }
                    }

                }
            }
        }

        private string _searchTerm;

        public override async void OnOpen()
        {
            base.OnOpen();
            var visualTreeAsset = Resources.Load<VisualTreeAsset>("AmbientCGBrowserLayout");
            visualTreeAsset.CloneTree(editorWindow.rootVisualElement);
            var styleSheet = Resources.Load<StyleSheet>("AmbientCGBrowserStyles");
            editorWindow.rootVisualElement.styleSheets.Add(styleSheet);
            var loadMoreButton = editorWindow.rootVisualElement.Q<Button>("load-more");
            var nameField = editorWindow.rootVisualElement.Q<TextField>("search-term");
            _loadingBlock = editorWindow.rootVisualElement.Q("loading");
            _scrollView = editorWindow.rootVisualElement.Q("scroll-view");
            nameField.RegisterValueChangedCallback(evt =>
            {
                _searchTerm = evt.newValue;
            });
            var button = editorWindow.rootVisualElement.Q<Button>("search-now");
            button.clicked += () => Search();
            
            loadMoreButton.clicked += () =>
            {
                if (_loading) return;
                if (loadMoreButton.ClassListContains("d-none")) return;
                var count = editorWindow.rootVisualElement.Query<Button>(null, "preview").ToList().Count;
                Search(count);
            };
            
            Search();
        }

        private string _lastSearchTerm = null;
        private bool _loading;
        private VisualElement _loadingBlock;
        private bool _downloading;
        private VisualElement _scrollView;
        private async void Search(int offset = 0)
        {
            _loading = true;
            var container = editorWindow.rootVisualElement.Q("container");
            var loadMoreButton = editorWindow.rootVisualElement.Q<Button>("load-more");
            loadMoreButton.AddToClassList("d-none");
            _loadingBlock.RemoveFromClassList("d-none");

            var requestParams = new Dictionary<string, string>
            {
                {"type", "Material"},
                {"sort", "Popular"},
                {"limit", "21"},
                {"offset", offset.ToString()},
                {"include", "displayData,previewData,downloadData,imageData"}
            };
            if (_lastSearchTerm != _searchTerm)
            {
                container.Clear();
            }
            if (!string.IsNullOrWhiteSpace(_searchTerm))
            {
                requestParams.Add("q", _searchTerm);
                _lastSearchTerm = _searchTerm;
            }
            else
            {
                _lastSearchTerm = null;
            }
            var list = await Requests.Request<AmbientCGResult>("https://ambientCG.com/api/v2/full_json",
                HttpMethod.Get, requestParams);
            loadMoreButton.EnableInClassList( "d-none", list.foundAssets.Count == 0);
            var cacheFile = Resources.Load<TextAsset>("AmbientCGCache");
            AmbientCGCache cache = null;
            if (cacheFile != null)
            {
                cache = JsonConvert.DeserializeObject<AmbientCGCache>(cacheFile.text);
            }

            var previewImages = new List<Button>();
            foreach (var asset in list.foundAssets)
            {
                var previewContainer = new VisualElement();
                previewContainer.AddToClassList("flex-col");
                previewContainer.AddToClassList("items-center");
                // previewContainer.AddToClassList("mr-1");
                previewContainer.AddToClassList("mb-1");
                var preview = new Button();
                preview.AddToClassList("preview");
                previewContainer.Add(preview);
                container.Add(previewContainer);
                previewImages.Add(preview);
            }

            var index = 0;
            foreach (var asset in list.foundAssets)
            {
                var preview = previewImages[index++];
                if (cache == null)
                {
                    cache = new AmbientCGCache();
                    var image = await Requests.GetImage(asset.previewImage.png256);
                    var guid = GUID.Generate().ToString();
                    Directory.CreateDirectory(
                        "Packages/sh.orels.shaders.inspector/Editor/MaterialLibraries/Resources/Previews");
                    File.WriteAllBytes($"Packages/sh.orels.shaders.inspector/Editor/MaterialLibraries/Resources/Previews/{guid}.png", image.EncodeToPNG());
                    cache.cache.Add(asset.assetId, guid);
                    preview.style.backgroundImage = image;
                }
                else
                {
                    if (cache.cache.TryGetValue(asset.assetId, out var previewGuid))
                    {
                        var image = AssetDatabase.LoadAssetAtPath<Texture2D>($"Packages/sh.orels.shaders.inspector/Editor/MaterialLibraries/Resources/Previews/{previewGuid}.png");
                        if (image != null)
                        {
                            preview.style.backgroundImage = image;
                        }
                        else
                        {
                            image = await Requests.GetImage(asset.previewImage.png256);
                            var guid = GUID.Generate().ToString();
                            Directory.CreateDirectory(
                                "Packages/sh.orels.shaders.inspector/Editor/MaterialLibraries/Resources/Previews");
                            File.WriteAllBytes($"Packages/sh.orels.shaders.inspector/Editor/MaterialLibraries/Resources/Previews/{guid}.png", image.EncodeToPNG());
                            cache.cache.Add(asset.assetId, guid);
                            preview.style.backgroundImage = image;
                        }
                    }
                    else
                    {
                        var image = await Requests.GetImage(asset.previewImage.png256);
                        var guid = GUID.Generate().ToString();
                        Directory.CreateDirectory(
                            "Packages/sh.orels.shaders.inspector/Editor/MaterialLibraries/Resources/Previews");
                        File.WriteAllBytes($"Packages/sh.orels.shaders.inspector/Editor/MaterialLibraries/Resources/Previews/{guid}.png", image.EncodeToPNG());
                        cache.cache.Add(asset.assetId, guid);
                        preview.style.backgroundImage = image;
                    }
                }
                preview.clicked += async () =>
                {
                    if (_downloading) return;
                    _downloading = true;
                    await DownloadMaterial(asset, status =>
                    {
                        preview.text = status;
                    });
                    _downloading = false;
                };
            }
            _loadingBlock.AddToClassList("d-none");
            _loading = false;

            File.WriteAllText("Packages/sh.orels.shaders.inspector/Editor/MaterialLibraries/Resources/AmbientCGCache.json", JsonConvert.SerializeObject(cache));
            Debug.Log("Got list");
        }
        
        private async Task DownloadMaterial(AmbientCGMaterial material, Action<string> onProgress = null)
        {
            var downloadInfo =
                material.downloadFolders.defaultFolder.downloadFiletypeCategories.zip.downloads.FirstOrDefault(
                    download => download.attribute == "2K-PNG");
            if (downloadInfo == null)
            {
                Debug.LogError("Unable to find a 2k PNG download");
                return;
            }
            var basePath = $"Assets/Develop/AmbientCG/Downloads/{material.assetId}";
            
            // check if the material is already there
            if (Directory.Exists(basePath))
            {
                if (Directory.GetFiles(basePath).Length > 0)
                {
                    Debug.Log("Material Already Exists");
                    onProgress?.Invoke("Converting...");
                    ConvertAndApply(material, basePath, _targetMaterial);
                    onProgress?.Invoke("");
                    return;
                }
            }
            
            onProgress?.Invoke("Downloading...");
            Debug.Log("Downloading Archive");
            
            var archive = await Requests.Request<byte[]>(downloadInfo.fullDownloadPath, HttpMethod.Get);
            var archivePath = Path.GetTempFileName();
            onProgress?.Invoke("Unpacking...");
            Debug.Log("Unpacking Archive");
            File.WriteAllBytes(archivePath, archive);
            AssetDatabase.StartAssetEditing();
            Directory.CreateDirectory(basePath);
            try
            {
                using (var zip = new ZipArchive(File.OpenRead(archivePath), ZipArchiveMode.Read))
                {
                    foreach (var zipEntry in zip.Entries)
                    {
                        if (Path.GetExtension(zipEntry.FullName) != ".png") continue;
                        // only use GL normal
                        if (zipEntry.FullName.Contains("NormalDX")) continue;
                        using (var fileStream = File.OpenWrite(basePath + "/" + zipEntry.FullName))
                        {
                            using (var zipStream = zipEntry.Open())
                            {
                                await zipStream.CopyToAsync(fileStream);
                            }
                        }
                        Debug.Log($"Extracted {zipEntry.FullName} to {basePath}");
                    }
                }
            } catch (Exception e)
            {
                Debug.LogError(e);
            }
            finally
            {
                File.Delete(archivePath);
            }
            Debug.Log("Finished extraction");
            AssetDatabase.StopAssetEditing();
            AssetDatabase.Refresh();
            onProgress?.Invoke("Converting...");
            ConvertAndApply(material, basePath, _targetMaterial);
            onProgress?.Invoke("");
        }

        private void ConvertAndApply(AmbientCGMaterial material, string basePath, Material targetMaterial)
        {
            var files = Directory.GetFiles(basePath);
            var hasMetallic = false;
            var hasRoughness = false;
            var hasAO = false;
            var hasDisplacement = false;
            
            foreach (var filePath in files)
            {
                var fileName = Path.GetFileName(filePath);
                if (fileName.Contains("Metalness")) hasMetallic = true;
                if (fileName.Contains("Roughness")) hasRoughness = true;
                if (fileName.Contains("AmbientOcclusion")) hasAO = true;
                if (fileName.Contains("Displacement")) hasDisplacement = true;
                var asset = AssetDatabase.LoadAssetAtPath<Texture2D>(filePath);
                var importer = AssetImporter.GetAtPath(filePath) as TextureImporter;
                if (importer == null) continue;
                if (fileName.Contains("NormalGL"))
                {
                    importer.textureType = TextureImporterType.NormalMap;
                    importer.SaveAndReimport();
                }

                if (fileName.Contains("Displacement") || fileName.Contains("Roughness") || fileName.Contains("Metalness"))
                {
                    importer.sRGBTexture = false;
                    importer.SaveAndReimport();
                }
            }

            var metallicTex = hasMetallic
                ? AssetDatabase.LoadAssetAtPath<Texture2D>(Path.Combine(basePath,
                    $"{material.assetId}_2K_Metalness.png"))
                : null;
            var roughnessTex = hasRoughness
                ? AssetDatabase.LoadAssetAtPath<Texture2D>(Path.Combine(basePath,
                    $"{material.assetId}_2K_Roughness.png"))
                : null;
            var aoTex = hasAO
                ? AssetDatabase.LoadAssetAtPath<Texture2D>(Path.Combine(basePath,
                    $"{material.assetId}_2K_AmbientOcclusion.png"))
                : null;
            var heightTex = hasDisplacement
                ? AssetDatabase.LoadAssetAtPath<Texture2D>(Path.Combine(basePath,
                    $"{material.assetId}_2K_Displacement.png"))
                : null;

            var repacked = TexturePacker.PackTexture(
                new Texture2D[] { metallicTex, aoTex, null, roughnessTex },
                new [] { 0,0,0,0 },
                new [] { 0f,1f,1f,1f },
                new [] { false, false, false, true }, 
                true,
                2048,
                basePath + $"/{material.assetId}_2K_Mask.png");

            if (_targetMaterial != null)
            {
                _targetMaterial.SetTexture("_MainTex", AssetDatabase.LoadAssetAtPath<Texture2D>(Path.Combine(basePath, $"{material.assetId}_2K_Color.png")));
                _targetMaterial.SetTexture("_BumpMap", AssetDatabase.LoadAssetAtPath<Texture2D>(Path.Combine(basePath, $"{material.assetId}_2K_NormalGL.png")));
                _targetMaterial.SetTexture("_MaskMap", repacked);
                if (hasDisplacement)
                {
                    _targetMaterial.SetInt("UI_ParallaxHeader", 1);
                    _targetMaterial.EnableKeyword("PARALLAX");
                    _targetMaterial.SetInt("_EnableParallax", 1);
                    _targetMaterial.SetTexture("_Height", AssetDatabase.LoadAssetAtPath<Texture2D>(Path.Combine(basePath, $"{material.assetId}_2K_Displacement.png")));
                }
            }
        }

        public override void OnClose()
        {
            base.OnClose();
            _onClose();
        }
    }
}
#endif