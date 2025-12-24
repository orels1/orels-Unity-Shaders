using UnityEngine;
using UnityEditor;
using System;
using System.Collections.Generic;

namespace ORL.Shaders.UpgradePlans
{
    public class UpgradeV6toV7 : UpgradePlanBase
    {
        public UpgradeV6toV7()
        {
            _oldVersion = "6.x.x";
            _newVersion = "7.0.0";
        }

        public override bool Upgrade(IList<Material> materials, bool dryRun = false)
        {
            EditorUtility.DisplayProgressBar("Upgrading Materials", "Please wait...", 0);
            var groupId = Undo.GetCurrentGroup();
            Undo.SetCurrentGroupName("Upgraded to " + NewVersion);
            var i = 0f;
            var success = true;

            try
            {
                foreach (var mat in materials)
                {
                    var materialShaderVersion = 0;
                    if (mat.HasProperty("INTERNAL_MaterialShaderVersion"))
                    {
                        materialShaderVersion = mat.GetInt("INTERNAL_MaterialShaderVersion");
                    }

                    EditorUtility.DisplayProgressBar("Upgrading Materials", $"Upgrading {mat.name}",
                        i / materials.Count);
                    // Upgrade emission
                    if (!dryRun)
                    {
                        Undo.RecordObject(mat, "Upgraded to " + NewVersion);
                    }

                    if (mat.HasProperty("_EmissionColor"))
                    {
                        var currentColor = mat.GetColor("_EmissionColor");
                        currentColor.r = Mathf.Pow(currentColor.r, 1.0f / 2.2f);
                        currentColor.g = Mathf.Pow(currentColor.g, 1.0f / 2.2f);
                        currentColor.b = Mathf.Pow(currentColor.b, 1.0f / 2.2f);
                        if (dryRun)
                        {
                            Debug.Log("Would have upgraded emission color for " + mat.name + " from " +
                                      mat.GetColor("_EmissionColor") + " to " + currentColor);
                        }
                        else
                        {
                            mat.SetColor("_EmissionColor", currentColor);
                        }
                    }

                    // Upgrade Specular Occlusion
                    if (mat.HasProperty("_SpecOcclusion"))
                    {
                        var currValue = mat.GetFloat("_SpecOcclusion");

                        // If default value, then upgrade to new default
                        if (Mathf.Abs(0.075f - currValue) < 0.001f)
                        {
                            if (dryRun)
                            {
                                Debug.Log("Would have upgraded specular occlusion for " + mat.name + " from " +
                                          currValue + " to " + 0.25f);
                            }
                            else
                            {
                                mat.SetFloat("_SpecOcclusion", 0.25f);
                            }
                        }
                        else // If the value was modified - clone it to the new property
                        {
                            if (dryRun)
                            {
                                Debug.Log("Would have upgraded specular occlusion for " + mat.name + " from " +
                                          currValue + " to " + 0.25f);
                            }
                            else
                            {
                                // This is the reflection probe occlusiomn
                                // Leaving it untouched might be too dark, so we'll set it to 0.25 unless it was modified below that (usually 0)
                                mat.SetFloat("_SpecOcclusion", currValue < 0.25f ? currValue : 0.25f);

                                // this is the new lightmap occlusion property
                                // We can clone here as-is
                                mat.SetFloat("_BakedSpecularOcclusion", currValue);
                            }
                        }
                    }

                    // Enable GSAA normal map contribution
                    if (materialShaderVersion < 700)
                    {
                        if (mat.HasProperty("_GSAAIncludeNormalMaps"))
                        {
                            if (dryRun)
                            {
                                Debug.Log("Would have enabled GSAA normal map contribution for " + mat.name);
                            }
                            else
                            {
                                mat.SetInt("_GSAAIncludeNormalMaps", 1);
                            }
                        }
                    }

                    // Migrate old parallax offsets to new
                    if (mat.HasProperty("_HeightRefPlane"))
                    {
                        var currValue = mat.GetFloat("_HeightRefPlane");
                        if (dryRun)
                        {
                            Debug.Log("Would have migrated parallax offset for " + mat.name + " from " + currValue +
                                      " to " + Mathf.Clamp(currValue - 0.5f, -1, 1));
                        }
                        else
                        {
                            mat.SetFloat("_HeightRefPlane", Mathf.Clamp(currValue - 0.5f, -1, 1));
                        }
                    }

                    if (mat.HasProperty("INTERNAL_MaterialShaderVersion"))
                    {
                        if (dryRun)
                        {
                            Debug.Log("Would have upgraded shader version for " + mat.name + " from " +
                                      mat.GetInt("INTERNAL_MaterialShaderVersion") + " to " + 700);
                        }
                        else
                        {
                            mat.SetInt("INTERNAL_MaterialShaderVersion", 700);
                        }
                    }

                    if (mat.HasProperty("_DFG"))
                    {
                        if (dryRun)
                        {
                            Debug.Log("Would have assigned DFG texture for " + mat.name);
                        }
                        else
                        {
                            var dfgTex = AssetDatabase.LoadAssetAtPath<Texture2D>(
                                "Packages/sh.orels.shaders.generator/Runtime/Assets/dfg-multiscatter.exr");
                            mat.SetTexture("_DFG", dfgTex);
                        }
                    }

                    i++;
                }
            }
            catch (Exception e)
            {
                Debug.LogException(e);
                success = false;
            }
            finally
            {
                EditorUtility.ClearProgressBar();
            }

            Undo.CollapseUndoOperations(groupId);
            return success;
        }
    }
}