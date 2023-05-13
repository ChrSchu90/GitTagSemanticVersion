#!/usr/bin/env pwsh

#$tag = git describe --tags --abbrev=0
$tag = $args[0]
Write-Host "[info] Tag = $tag"

$semVer2Regex = [Regex] '(?<versiontag>(V|v)(?<version>(?<major>0|[1-9]\d*)\.(?<minor>0|[1-9]\d*)\.(?<patch>0|[1-9]\d*))(?:-(?<prerelease>(?:0|[1-9]\d*|\d*[a-zA-Z-][0-9a-zA-Z-]*)(?:\.(?:0|[1-9]\d*|\d*[a-zA-Z-][0-9a-zA-Z-]*))*))?(?:\+(?<buildmetadata>[0-9a-zA-Z-]+(?:\.[0-9a-zA-Z-]+)*))?)$'
if (-not $semVer2Regex.IsMatch($tag)) {
    throw "Invalid version tag format! See: https://semver.org/"
}

$matches = $semVer2Regex.Matches($tag)[0]
$versionTag = $matches.Groups['versiontag'].Value
$version = $matches.Groups['version'].Value
$major = $matches.Groups['major'].Value
$minor = $matches.Groups['minor'].Value
$patch = $matches.Groups['patch'].Value
$packageVersion = $version
$versionSuffix = ""
$versionMetadata = ""

$prerelease = $matches.Groups['prerelease']
$isPrerelease = $prerelease.Success;
if($isPrerelease) {
    $versionSuffix = $prerelease.Value
    $packageVersion = "$version-$versionSuffix"
}

$metadata = $matches.Groups['buildmetadata']
if($metadata.Success) {
    $versionMetadata = $metadata.Value
}

Write-Host "[info] version_tag = $versionTag"
echo "version_tag=$versionTag" >> $env:GITHUB_OUTPUT
Write-Host "[info] is_prerelease = $isPrerelease"
echo "is_prerelease=$isPrerelease" >> $env:GITHUB_OUTPUT
Write-Host "[info] version = $version"
echo "version=$version" >> $env:GITHUB_OUTPUT
Write-Host "[info] major = $major"
echo "major=$major" >> $env:GITHUB_OUTPUT
Write-Host "[info] minor = $minor"
echo "minor=$minor" >> $env:GITHUB_OUTPUT
Write-Host "[info] patch = $patch"
echo "patch=$patch" >> $env:GITHUB_OUTPUT
Write-Host "[info] suffix = $versionSuffix"
echo "suffix=$versionSuffix" >> $env:GITHUB_OUTPUT
Write-Host "[info] metadata = $versionMetadata"
echo "metadata=$versionMetadata" >> $env:GITHUB_OUTPUT
Write-Host "[info] package = $packageVersion"
echo "package=$packageVersion" >> $env:GITHUB_OUTPUT
