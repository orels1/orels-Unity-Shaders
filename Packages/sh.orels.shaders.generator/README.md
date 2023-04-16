# ORL Shader Generator

A Unity shader generator framework with a collection of templates and modules for Unity Built-In Render Pipeline.

## Features

This generation framework allows you to do the following

- Generate shaders from modules and templates for any pipeline and shader application. Although this generator was built with a focus on Built-In Render Pipeline and VRChat shaders
- Split up your shaders in modules with nested dependencies
- Colocate properties and variables relevant to a particular module
- Deduplicate variables and properties if they are declared in multiple modules
- Order your modules and templates in a way that makes sense to you, with potential for overriding the order of function calls
- Auto-reload shaders on any module change
- Export shaders as singular .shader files for ease of distribution

Check out the main [ORL Shaders](https://github.com/orels1/orels-Unity-Shaders/tree/main/Packages/sh.orels.shaders) package to see it in action.

[Full documentation is available here](https://shaders.orels.sh/docs/generator/development-basics)

## Installation

### Unity Package Manager

You can add this package to any unity project if you have git installed by simply using the following git url in the package manager:

```
https://github.com/orels1/orels-Unity-Shaders.git#packages?path=Packages/sh.orels.shaders.generator
```

### Unity Package

You can download the latest version of the generator [as a unitypackage here](https://github.com/orels1/orels-Unity-Shaders/releases)

### VRChat Creator Companion

Add this repo listing to your VCC

```
https://orels1.github.io/orels-Unity-Shaders/index.json
```

Afterwards - add ORL Shader Generator package to your project

Having issues? [Hop by the discord](https://discord.gg/orels1)