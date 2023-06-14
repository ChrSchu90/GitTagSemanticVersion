#!/usr/bin/env pwsh

function WriteVariable {
    Param([string]$name, [string]$value)
    Write-Host "[info] $name = $value"
    echo "$name=$value" >> $env:GITHUB_OUTPUT
}

#$tag = git describe --tags --abbrev=0
$tag = $args[0]
Write-Host "[info] Tag = $tag"

$semVer2Regex = [Regex] '(?<versiontag>(V|v)(?<version>(?<major>0|[1-9]\d*)\.(?<minor>0|[1-9]\d*)\.(?<patch>0|[1-9]\d*))(?:-(?<prerelease>(?:0|[1-9]\d*|\d*[a-zA-Z-][0-9a-zA-Z-]*)(?:\.(?:0|[1-9]\d*|\d*[a-zA-Z-][0-9a-zA-Z-]*))*))?(?:\+(?<buildmetadata>[0-9a-zA-Z-]+(?:\.[0-9a-zA-Z-]+)*))?)$'

$isValid = $semVer2Regex.IsMatch($tag)
WriteVariable -name "is_valid" -value "$isValid"
if (-not $isValid) {
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

WriteVariable -name "is_prerelease" -value "$isPrerelease"
WriteVariable -name "version_tag" -value $versionTag
WriteVariable -name "version" -value $version
WriteVariable -name "major" -value $major
WriteVariable -name "minor" -value $minor
WriteVariable -name "patch" -value $patch
WriteVariable -name "suffix" -value $versionSuffix
WriteVariable -name "metadata" -value $versionMetadata
WriteVariable -name "package" -value $packageVersion
