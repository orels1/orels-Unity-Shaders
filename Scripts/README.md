# Scripts

To use the provided scripts - you must install the `dotnet-script` global tool

```
dotnet tool install -g dotnet-script
```

afterwards you'll be able to run the included `*.csx` scripts via a simple `dotnet-script <filename>` command

## Available Scripts

- `SetVersion.csx <version>`
  - Sets the version of the package to a desired value
  - `--package <PackageName>` Sets the version of a specific package. If not provided - all packages are bumped
  - `--major` Increments the major version
  - `--minor` Increments the minor version
  - `--patch` Increments the patch version
  - `--beta` Increments the currently set beta version
  - `--set-beta <name>` Adds the provided name as a pre-release identifier