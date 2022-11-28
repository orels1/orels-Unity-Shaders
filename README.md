# VPM Package Template

Starter for making Packages, including automation for building and publishing them.

Once you're all set up, you'll be able to push changes to this repository and have .zip and .unitypackage versions automatically generated, and a listing made which works in the VPM for delivering updates for this package. 
Multi-package repo support is yet to come.

## ▶ Getting Started

* Press [![Use This Template](https://user-images.githubusercontent.com/737888/185467681-e5fdb099-d99f-454b-8d9e-0760e5a6e588.png)](https://github.com/vrchat-community/template-package/generate)
to start a new GitHub project based on this template, and follow the directions there. 
* Clone this repository locally using git.
* Open the folder as a Unity Project.
* Wait while the VPM resolver is downloaded and added to your project. This gives you access to the VPM Package Maker and Package Resolver tools.

## 🚇 Migrating Assets Package
* Full details at [Converting Assets to a VPM Package](https://vcc.docs.vrchat.com/guides/convert-unitypackage)

## Working on Your Package

You can delete the "Packages/com.vrchat.demo-template" directory or reuse it for your own package.
Update the `.gitignore` file in the "Packages" directory to include your package. It has an example of including the demo package which you can easily change out for your own package name.

You can open the Unity project and work on your package's files in your favorite Code Editor. Then commit and push your changes. Once you've set up the automation as described below, you can easily publish new versions.

## Setting up the Automation

You'll need to make a few changes in [release.yml](.github/workflows/release.yml):
* Changed the `paths` property on line 7 to point to the directory where your Package's source files are. Leave the `/**` at the end so GitHub knows to run this action whenever any file in that directory is changed. In the example, this property reads: `paths: Packages/com.vrchat.demo-template/**`
* Change the `packageName` property on line 10 to include the name of your package, like `packageName: "com.vrchat.demo-template"`
* We highly recommend you keep the existing folder structure where the root of the project is a Unity Repo, and your packages are in the "Packages" directory, If you change this, you'll need to update the paths that assume your package is in the "Packages" directory, on lines 24, 38, 41 and 57.

That's it. If you want to store and generate your web files in a folder other than "Website" in the root, you can change the `listPublicDirectory` item [here in build-listing.yml](.github/workflows/build-listing.yml#L17).

## 🎉 Publishing a Release

A release will be automatically built whenever you push changes to your main branch which update files in the package folder you specified in `release.yml`. The version specified in your `package.json` file will be used to define the version of the release.

## 📃 Rebuilding the Listing

Whenever you make a change to a release - automatically publishing it, or manually creating, editing or deleting one, the [Build Repo Listing](.github/workflows/build-listing.yml) action will make a new index of all the releases available, and publish them as a website hosted fore free on [GitHub Pages](https://pages.github.com/). This listing can be used by the VPM to keep your package up to date, and the generated index page can serve as a simple landing page with info for your package. The URL for your package will be in the format `https://username.github.io/repo-name`.

## 🏠 Customizing the Landing Page

The action which rebuilds the listing also publishes a landing page. The source for this page is in `Website/index.html`. The automation system uses [Scriban](https://github.com/scriban/scriban) to fill in the objects like `{{ this }}` with information from the latest release's manifest, so it will stay up-to-date with the name, id and description that you provide there. You are welcome to modify this page however you want - just use the existing `{{ template.objects }}` to fill in that info wherever you like. The entire contents of your "Website" folder are published to your GitHub Page each time.

## Technical Stuff

You are welcome to make your own changes to the automation process to make it fit your needs, and you can create Pull Requests if you have some changes you think we should adopt. Here's some more info on the included automation:

### Build Release Action
[release.yml](/.github/workflows/release.yml)

This is a composite action combining a variety of existing GitHub Actions and some shell commands to create both a .zip of your Package and a .unitypackage. It creates a release which is named for the `version` in the `package.json` file found in your target Package, and publishes the zip, the unitypackage and the package.json file to this release.

### Build Repo Listing
[build-listing.yml](.github/workflows/build-listing.yml)

This is a composite action which builds a vpm-compatible [Repo Listing](https://vcc.docs.vrchat.com/vpm/repos) based on the releases you've created. In order to find all your releases and combine them into a listing, it checks out [another repository](https://github.com/vrchat-community/package-list-action) which has a [Nuke](https://nuke.build/) project which includes the VPM core lib to have access to its types and methods. This project will be expanded to include more functionality in the future - for now, the action just calls its `BuildRepoListing` target, which calls `RebuildHomePage` when it completes. If you wanted to make an action that just rebuilds the home page, you could call that directly instead - just copy the existing call and replace the target names.

## Status
![GitHub deployments](https://img.shields.io/github/deployments/momo-the-monster/template-package/github-pages?label=Generate%20Listing)
