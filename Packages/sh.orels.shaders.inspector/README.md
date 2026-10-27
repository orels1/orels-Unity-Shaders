# ORL Shader Inspector

A property-based shader inspector system for Unity shaders.

## Features

- H1 and H2 headers
- Headers acting as foldouts with default expanded states
- Min/Max Sliders
- Gradients generator
- Texture-based keywords
- ShowIf conditions for property visibility control
- Property combining for rendering multiple properties on a single line
- Texture Packing
- Keyword debugging
- Localization

Check out the main [ORL Shaders](https://github.com/orels1/orels-Unity-Shaders/tree/main/Packages/sh.orels.shaders) package to see it in action.

[Full documentation is available here](https://shaders.orels.sh/docs/inspector/overview)

## Localization

Property names and tooltips can be localized via `.orlloc` files. They are imported into `LocalizationData` assets and picked up by the inspector automatically.

A localization file named after a shader module (e.g. `Snow.orlloc` for `Snow.orlsource`) takes priority over the shared pool for the shaders that include that module. Use `module = <name>` in the file to bind it to a module explicitly.

### File format

The recommended format uses one block per property:

```
# comments start with a hash

[_SnowLevel]
name.en = Snow Level
name.ja = 雪の量
tooltip.en = Controls the level of snow coverage
tooltip.ja = 雪の量を制御します
```

- `name` / `tooltip` with a language suffix per language (`en`, `ja`, ...), english by default
- No escaping needed - values may contain any characters except a newline
- `module = <name>` (optional) binds the file to a module, defaults to the file name. For modules in subfolders (e.g. `Modules/Toon/Main`) use the source path relative to the generator sources (`module = Modules/Toon/Main`), as the file name alone is ambiguous between folders
- `@[Prop]` references copy the same field of another property in the same language (falling back to english), e.g. `name.en = @[_OtherProp]` - useful for repeated property sets like material layers. Cycles and dangling targets are dropped with an import warning

### Tools

- `Tools > orels1 > Localization Helpers` - copies property names / a ready-to-fill localization template from a source file
- `Tools > orels1 > Export Localization Docs` - exports all localization data into per-module markdown files

## Installation

### Unity Package Manager

You can add this package to any unity project if you have git installed by simply using the following git url in the package manager:

```
https://github.com/orels1/orels-Unity-Shaders.git#packages?path=Packages/sh.orels.shaders.inspector
```

### Unity Package

You can download the latest version of the inspector [as a unitypackage here](https://github.com/orels1/orels-Unity-Shaders/releases)

### VRChat Creator Companion

Add this repo listing to your VCC

```
https://orels1.github.io/orels-Unity-Shaders/index.json
```

Afterwards - add ORL Shader Inspector package to your project

Having issues? [Hop by the discord](https://discord.orels.one)
