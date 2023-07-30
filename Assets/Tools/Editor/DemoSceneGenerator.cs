using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Threading.Tasks;
using UnityEditor;
using UnityEditor.PackageManager.UI;
using UnityEditor.SceneManagement;
using UnityEngine;
using UnityEngine.Rendering.PostProcessing;
using UnityEngine.SceneManagement;
using Object = UnityEngine.Object;

namespace ORL.Tools {
    public class DemoSceneGenerator
    {
        private static List<Action> _mainThreadActions = new List<Action>();
        
        [MenuItem("Tools/orels1/Generate Development Scene")]
        public static async Task CreateDemoScene()
        {
            try
            {
                _mainThreadActions.Clear();
                EditorApplication.update += MainThreadDispatcher;

                // Scaffold Directories
                Directory.CreateDirectory("Assets/Develop/All");
                Directory.CreateDirectory("Assets/Develop/Common");
                if (Directory.Exists("Assets/Develop/All/All"))
                {
                    Directory.Delete("Assets/Develop/All/All", true);
                }

                var dRef = EditorUtility.DisplayDialogComplex(
                    "Save Scenes?",
                    "This will generate a new development scene and open it, is recommended to save all currently open scenes beforehand" +
                    "This will also remove the existing generated assets" +
                    "Save Scenes?",
                    "Save",
                    "Cancel",
                    "Don's Save"
                );

                switch (dRef)
                {
                    case 0:
                        EditorSceneManager.SaveOpenScenes();
                        break;
                    case 1:
                        return;
                }
                
                EditorUtility.DisplayProgressBar("Generating Development Samples", "Prepping...", 0f);

                EditorSceneManager.NewScene(NewSceneSetup.EmptyScene, NewSceneMode.Single);

                AssetDatabase.DeleteAsset("Assets/Develop/All/All.unity");

                var scene = EditorSceneManager.NewScene(NewSceneSetup.DefaultGameObjects, NewSceneMode.Single);
                EditorSceneManager.SaveScene(scene, "Assets/Develop/All/All.unity");

                EditorUtility.DisplayProgressBar("Generating Development Samples", "Setting up lighting...", 0.05f);
                SetupLighting();
                
                EditorUtility.DisplayProgressBar("Generating Development Samples", "Setting up post processing...", 0.1f);
                SetUpPostProcessing();

                EditorUtility.DisplayProgressBar("Generating Development Samples", "Getting a list of shaders...", 0f);
                var orlShaders = await GetORLShaders();
                Debug.Log($"Loaded shaders list\n{string.Join("\n", orlShaders.Select(s => s.name).ToArray())}");
                EditorUtility.DisplayProgressBar("Generating Development Samples", "Creating samples...", 0.2f);
                var spawnedMats = CreateSamples(orlShaders);

                AssetDatabase.Refresh();
                EditorSceneManager.SaveScene(scene);

                await Task.Delay(2000).ConfigureAwait(true);
                
                EditorUtility.DisplayProgressBar("Generating Development Samples", "Initializing samples...", 0.7f);

                var i = 0;
                foreach (var mat in spawnedMats)
                {
                    Selection.activeObject = mat;
                    EditorUtility.DisplayProgressBar("Generating Development Samples", $"Initializing samples {i+1} / {spawnedMats.Count}..", 0.7f + 0.2f * ((i+1) /(float) spawnedMats.Count));
                    i++;
                    await Task.Delay(500);
                }

                await Task.Delay(2000).ConfigureAwait(true);
                
                EditorUtility.DisplayProgressBar("Generating Development Samples", "Baking...", 0.95f);

                Debug.Log("Setting up baking task");
                var bakeTask = new TaskCompletionSource<bool>();
                var started = Lightmapping.BakeAsync();
                if (started)
                {
                    Debug.Log("Baking Started");
                }
                else
                {
                    Debug.LogError("Baking failed to start");
                    bakeTask.SetResult(false);
                }

                Lightmapping.bakeCompleted += () => { bakeTask.SetResult(true); };

                await bakeTask.Task.ConfigureAwait(true);
                EditorSceneManager.SaveScene(scene);

                EditorUtility.DisplayProgressBar("Generating Development Samples", "Done!", 1f);
                EditorApplication.update -= MainThreadDispatcher;
            }
            finally
            {
                EditorUtility.ClearProgressBar();
            }
        }

        private static void MainThreadDispatcher()
        {
            var actionsToDispatch = _mainThreadActions.ToArray();
            foreach (var action in actionsToDispatch)
            {
                action();
                _mainThreadActions.Remove(action);
            }
        }

        private static void SetupLighting()
        {
            var skyMat = new Material(Shader.Find("Skybox/Procedural"));
            AssetDatabase.DeleteAsset("Assets/Develop/Common/Sky.mat");
            AssetDatabase.CreateAsset(skyMat, "Assets/Develop/Common/Sky.mat");
            RenderSettings.skybox = AssetDatabase.LoadAssetAtPath<Material>("Assets/Develop/Common/Sky.mat");
            var mainLight = GameObject.Find("Directional Light").GetComponent<Light>();
            Undo.RecordObject(mainLight, "set light params");
            mainLight.lightmapBakeType = LightmapBakeType.Baked;
            mainLight.shadowAngle = 8f;
            RenderSettings.sun = mainLight;
        }

        private static void SetUpPostProcessing()
        {
            var profile = ScriptableObject.CreateInstance<PostProcessProfile>();
            var bloom = profile.AddSettings<Bloom>();
            bloom.threshold.Override(0.75f);
            bloom.intensity.Override(0.3f);
            bloom.diffusion.Override(9f);
            bloom.softKnee.Override(1f);

            var colorGrading = profile.AddSettings<ColorGrading>();
            colorGrading.tonemapper.Override(Tonemapper.Neutral);
            colorGrading.contrast.Override(20f);
            colorGrading.saturation.Override(20f);
            AssetDatabase.DeleteAsset("Assets/Develop/Common/Main PP Profile.asset");
            AssetDatabase.SaveAssets();
            AssetDatabase.CreateAsset(profile, "Assets/Develop/Common/Main PP Profile.asset");

            var tM = new SerializedObject(AssetDatabase.LoadAssetAtPath<Object>("ProjectSettings/TagManager.asset"));
            tM.FindProperty("layers").GetArrayElementAtIndex(30).stringValue = "Post Processing";
            tM.ApplyModifiedProperties();

            var cam = GameObject.FindWithTag("MainCamera");
            var ppLayer = cam.AddComponent<PostProcessLayer>();
            ppLayer.volumeLayer = LayerMask.GetMask("Post Processing");
            ppLayer.volumeTrigger = cam.transform;

            var volume = new GameObject("Post Processing Volume");
            volume.layer = LayerMask.NameToLayer("Post Processing");
            var ppVolume = volume.AddComponent<PostProcessVolume>();
            ppVolume.isGlobal = true;
            ppVolume.profile = profile;

            AssetDatabase.SaveAssets();

            // var resources = ScriptableObject.CreateInstance<PostProcessResources>();
            // ppLayer.Init(resources);
            EditorSceneManager.SaveOpenScenes();
        }

        private static async Task<List<Shader>> GetORLShaders()
        {
            var results = new List<Shader>();
            try
            {
                var packagesRequest = UnityEditor.PackageManager.Client.List();
                await Task.Run(async () =>
                {
                    var completed = false;
                    while (!completed)
                    {
                        _mainThreadActions.Add(() =>
                        {
                            completed = packagesRequest.IsCompleted;
                        });
                        await Task.Delay(250);
                    }
                });

                var packages = packagesRequest.Result;
                var shadersPackagePath =
                    packages.Where(p => p.name == "sh.orels.shaders").Select(p => p.assetPath).First();
                Debug.Log($"Found ORL Shaders path, {shadersPackagePath}");
                foreach (var filePath in Directory.EnumerateFiles(shadersPackagePath, "*.orlshader",
                             SearchOption.AllDirectories))
                {
                    var loadedShader = AssetDatabase.LoadAssetAtPath<Shader>(filePath);
                    if (loadedShader != null)
                    {
                        results.Add(loadedShader);
                    }
                }
            }
            catch (Exception e)
            {
                Debug.LogException(e);
            }

            return results;
        }

        private static List<Material> CreateSamples(List<Shader> shaders)
        {
            if (Directory.Exists("Assets/Develop/All/Materials"))
            {
                Directory.Delete("Assets/Develop/All/Materials", true);
            }
            AssetDatabase.Refresh();
            Directory.CreateDirectory("Assets/Develop/All/Materials");
            
            AssetDatabase.StartAssetEditing();

            var results = new List<Material>();

            try
            {
                var planeMat = new Material(Shader.Find("Standard"));
                planeMat.SetColor("_Color", Color.gray);
                AssetDatabase.CreateAsset(planeMat, "Assets/Develop/All/Materials/Plane.mat");
                var spawnSpot = Vector3.zero;

                var samplesToCreate = shaders.Count(s => !s.name.Contains("/UI/"));
                var index = 0;
                foreach (var shader in shaders)
                {
                    if (shader.name.Contains("/UI/")) continue;
                    EditorUtility.DisplayProgressBar("Generating Development Samples", $"Creating samples {index+1} / {samplesToCreate}...", 0.2f + ((index + 1) / (float)samplesToCreate) * 0.5f);
                    var material = new Material(shader)
                    {
                        name = shader.name.Substring(shader.name.LastIndexOf("/", StringComparison.Ordinal) + 1)
                    };
                    AssetDatabase.CreateAsset(material, $"Assets/Develop/All/Materials/{material.name}");
                    var sphereObj = GameObject.CreatePrimitive(PrimitiveType.Sphere);
                    sphereObj.name = $"Preview [{material.name}]";
                    var sphereMeshRenderer = sphereObj.GetComponent<MeshRenderer>();
                    sphereMeshRenderer.receiveGI = ReceiveGI.LightProbes;
                    sphereMeshRenderer.sharedMaterial = material;
                    sphereObj.transform.position = spawnSpot + Vector3.up * 1f;
                    sphereObj.isStatic = true;

                    var bottomPlane = GameObject.CreatePrimitive(PrimitiveType.Plane);
                    bottomPlane.name = "Floor";
                    var bottomPlaneMeshRenderer = bottomPlane.GetComponent<MeshRenderer>();
                    bottomPlaneMeshRenderer.sharedMaterial = planeMat;
                    bottomPlane.isStatic = true;
                    bottomPlane.transform.position = spawnSpot;
                    bottomPlane.transform.localScale *= 0.3f;
                    bottomPlane.transform.SetParent(sphereObj.transform, true);

                    var lpgObj = new GameObject("LPG");
                    lpgObj.transform.position = spawnSpot + Vector3.up * 1.1f;
                    lpgObj.AddComponent<LightProbeGroup>();
                    lpgObj.transform.SetParent(sphereObj.transform, true);

                    var reflProbeObj = new GameObject("Refl Probe");
                    var reflProbe = reflProbeObj.AddComponent<ReflectionProbe>();
                    reflProbe.boxProjection = true;
                    reflProbe.size = Vector3.one * 3f;
                    reflProbe.center = new Vector3(0f, 0.5f, 0f);
                    reflProbe.resolution = 64;
                    reflProbeObj.transform.position = spawnSpot + Vector3.up;
                    reflProbeObj.transform.SetParent(sphereObj.transform, true);

                    spawnSpot += Vector3.forward * 5f;
                    
                    results.Add(material);
                    index++;
                }

            }
            catch (Exception e)
            {
                Debug.LogException(e);
            }
            finally
            {
                AssetDatabase.StopAssetEditing();
            }
            return results;
        }
    }
}
