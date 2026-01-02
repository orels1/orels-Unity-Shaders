#r "nuget: CommandLineParser, 2.9.1"
#r "nuget: SemanticVersioning, 3.0.0-beta2"

using CommandLine;
using SemanticVersioning;
using System.Text.Json;
using System.Text.Json.Nodes;

public enum TargetPackages
{
    All,
    Shaders,
    Generator,
    Inspector
}

public class Options
{
    [Option("package", SetName = "target")]
    public string PackageName { get; set; }

    [Option("major", HelpText = "Increments the major version")]
    public bool Major { get; set; }

    [Option("minor", HelpText = "Increments the minor version")]
    public bool Minor { get; set; }

    [Option("patch", HelpText = "Increments the patch version")]
    public bool Patch { get; set; }

    [Option("beta", HelpText = "Increments the pre-release version")]
    public bool Beta { get; set; }

    [Option("set-beta", HelpText = "Adds the provided name as a pre-release identifier")]
    public string NewBetaVersion { get; set; }

    [Value(0)]
    public string Version { get; set; }
    [Option("deps", HelpText = "Updates dependencies to use the new version (lockstep release)")]
    public bool UpdateDependencies { get; set; }
}

Dictionary<TargetPackages, string> PackageIds = new() {
    {TargetPackages.All, ""},
    {TargetPackages.Shaders, "sh.orels.shaders"},
    {TargetPackages.Generator, "sh.orels.shaders.generator"},
    {TargetPackages.Inspector, "sh.orels.shaders.inspector"}
};

Parser.Default.ParseArguments<Options>(Args)
    .WithParsed<Options>(o =>
    {
        TargetPackages targetPackages;
        if (string.IsNullOrWhiteSpace(o.PackageName))
        {
            targetPackages = TargetPackages.All;
        }
        else
        {
            switch (o.PackageName)
            {
                case "shaders":
                    targetPackages = TargetPackages.Shaders;
                    break;
                case "generator":
                    targetPackages = TargetPackages.Generator;
                    break;
                case "inspector":
                    targetPackages = TargetPackages.Inspector;
                    break;
                default:
                    throw new Exception($"Unknown package name: {o.PackageName}");
            }
        }
        Console.WriteLine($"Target Package: {targetPackages} ({PackageIds[targetPackages]})");
        var settingExactVersion = false;
        if (!string.IsNullOrWhiteSpace(o.Version))
        {
            settingExactVersion = true;
            Console.WriteLine($"Planning to set to version: {o.Version}\n");
        }

        var targetJSONs = new List<string>();
        if (targetPackages == TargetPackages.All || targetPackages == TargetPackages.Shaders)
        {
            targetJSONs.Add("../Packages/sh.orels.shaders/package.json");
        }
        if (targetPackages == TargetPackages.All || targetPackages == TargetPackages.Generator)
        {
            targetJSONs.Add("../Packages/sh.orels.shaders.generator/package.json");
        }
        if (targetPackages == TargetPackages.All || targetPackages == TargetPackages.Inspector)
        {
            targetJSONs.Add("../Packages/sh.orels.shaders.inspector/package.json");
        }

        Console.WriteLine("Processing target packages:\n");
        foreach (var packagePath in targetJSONs)
        {
            var packageJSONtext = File.ReadAllText(packagePath);
            var packageJSON = JsonNode.Parse(packageJSONtext);
            var displayName = packageJSON!["displayName"]!;
            var version = packageJSON!["version"]!;
            Console.Write($"{displayName} | {version}");
            if (settingExactVersion)
            {
                Console.WriteLine($" -> {o.Version}");
                packageJSON["version"] = o.Version;

                // Update lockstep deps
                if (o.UpdateDependencies && packageJSON!["name"]!.ToString() == "sh.orels.shaders")
                {
                    Console.WriteLine($"Updating dependencies to {o.Version} as well");
                    packageJSON["vpmDependencies"]["sh.orels.shaders.generator"] = $"^{o.Version}";
                    packageJSON["vpmDependencies"]["sh.orels.shaders.inspector"] = $"^{o.Version}";
                }
            }
            else if (!string.IsNullOrWhiteSpace(o.NewBetaVersion))
            {
                var newVersion = $"{version}-{o.NewBetaVersion}.1";
                Console.WriteLine($" -> {newVersion}");
                packageJSON["version"] = newVersion;

                if (o.UpdateDependencies && packageJSON!["name"]!.ToString() == "sh.orels.shaders")
                {
                    Console.WriteLine($"Updating dependencies to {newVersion} as well");
                    packageJSON["vpmDependencies"]["sh.orels.shaders.generator"] = $"^{newVersion}";
                    packageJSON["vpmDependencies"]["sh.orels.shaders.inspector"] = $"^{newVersion}";
                }
            }
            else if (o.Beta)
            {
                var parsed = new Version(version.ToString());
                if (!parsed.IsPreRelease)
                {
                    Console.WriteLine($"\nVersion {version} is not a pre-release, cannot bump");
                    return;
                }
                var preReleaseSplit = parsed.PreRelease.Split('.');
                var newVersion = $"{parsed.Major}.{parsed.Minor}.{parsed.Patch}-{preReleaseSplit[0]}.{int.Parse(preReleaseSplit[1]) + 1}";
                packageJSON["version"] = newVersion;
                Console.WriteLine($" -> {newVersion}");

                if (o.UpdateDependencies && packageJSON!["name"]!.ToString() == "sh.orels.shaders")
                {
                    Console.WriteLine($"Updating dependencies to {newVersion} as well");
                    packageJSON["vpmDependencies"]["sh.orels.shaders.generator"] = $"^{newVersion}";
                    packageJSON["vpmDependencies"]["sh.orels.shaders.inspector"] = $"^{newVersion}";
                }
            }
            else if (o.Minor)
            {
                var parsed = new Version(version.ToString());
                if (parsed.IsPreRelease)
                {
                    Console.WriteLine($"\nVersion {version} is a pre-release, cannot bump minor version");
                    return;
                }
                var newVersion = $"{parsed.Major}.{parsed.Minor + 1}.{parsed.Patch}";
                packageJSON["version"] = newVersion;
                Console.WriteLine($" -> {newVersion}");

                if (o.UpdateDependencies && packageJSON!["name"]!.ToString() == "sh.orels.shaders")
                {
                    Console.WriteLine($"Updating dependencies to {newVersion} as well");
                    packageJSON["vpmDependencies"]["sh.orels.shaders.generator"] = $"^{newVersion}";
                    packageJSON["vpmDependencies"]["sh.orels.shaders.inspector"] = $"^{newVersion}";
                }
            }
            File.WriteAllText(packagePath, packageJSON!.ToJsonString(new JsonSerializerOptions { WriteIndented = true }));
        }

        Console.WriteLine("\nDone!");
    });
