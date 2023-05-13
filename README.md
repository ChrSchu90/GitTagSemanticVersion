# Git Tag Semantic Version
GitHub action to get version information from the Git tag.

The tag reqires a "v" as prefix followed by a [Semantic Version 2.0.0](https://semver.org/). You can [test your tag](https://regex101.com/r/rEi5ZC/2) for validation.
## Formats:
- *v[Major].[Minor].[Patch]
- *v[Major].[Minor].[Patch]-[pre-release]
- *v[Major].[Minor].[Patch]+[buildmetadata]
- *v[Major].[Minor].[Patch]-[pre-release]+[buildmetadata]

## Example
```yml
name: Example

on:
  push:
    tags:
      - 'v*'

jobs:
  build:
    name: Build
    runs-on: ubuntu-latest
    steps:
    - name: Checkout
      uses: actions/checkout@v3
    - name: Setup .NET
      uses: actions/setup-dotnet@v3
      with:
        dotnet-version: 6.0.x
    - name: Restore
      run: dotnet restore
    - name: Build
      run: dotnet build --no-restore
    - name: Test
      run: dotnet test --no-restore --no-build
    - name: Get Version from Tag
      if: startsWith(github.event.ref, 'refs/tags/v')
      id: tagver      
      uses: ChrSchu90/GitTagSemanticVersion@main
    - name: Pack Release NuGets      
      if: steps.tagver.outputs.is_prerelease == 'False'
      run: dotnet pack --no-restore --output ${{ github.workspace }}/packages /p:Version=${{ steps.tagver.outputs.version }}
    - name: Pack Prerelease NuGets
      if: steps.tagver.outputs.is_prerelease == 'True'
      run: dotnet pack --no-restore --output ${{ github.workspace }}/packages /p:VersionPrefix=${{ steps.tagver.outputs.version }} --version-suffix ${{ steps.tagver.outputs.suffix }}
    - name: Push NuGets
      if: steps.tagver.outcome == 'success'
      run: dotnet nuget push ${{ github.workspace }}/packages/*.nupkg --source ${{ secrets.NUGET_FEED }} --skip-duplicate --api-key ${{ secrets.NUGET_API_KEY }}
```

## Inputs

The following outputs can be accessed via `${{ steps.<step-id>.outputs }}` from this action

| Name         | Type   | Description                                                                         |
| ------------ | ------ | ----------------------------------------------------------------------------------- |
| `tag`        | String | [optional] Tag where the version info gets extracted from. Default is `github.ref`  |

## Outputs

The following outputs can be accessed via `${{ steps.<step-id>.outputs }}` from this action

| Name            | Type   | Description                                                                |
| --------------- | ------ | -------------------------------------------------------------------------- |
| `version_tag`   | String | The clean version tag e.g. v1.2.3-beta+asvdd without the git ref prefix    |
| `version`       | String | Version without pre-release or build metadata (Major.Minor.Patch)          |
| `major`         | String | Major version number                                                       |
| `minor`         | String | Minor version number                                                       |
| `patch`         | String | Patch version number                                                       |
| `suffix`        | String | Pre-release tag without `-` (e.g. beta, beta3, alpha, alpha5)              |
| `metadata`      | String | Metadata tag without `+` (e.g. asf343o23432o4432o4n2)                      |
| `package`       | String | Package version for NuGet (major.minor.patch-suffix)                       |
| `is_prerelease` | String | `True` if the version is a pre-release (suffix defined), otherwise `False` |

## Notes
- This action requires `pwsh` to actually be available and on PATH of the runner - which
  is the case for all GitHub-provided runner VMs; for your own runners you need to take care of that yourself.
- This action is a [`composite` action](https://docs.github.com/en/actions/creating-actions/creating-a-composite-run-steps-action).

## License
This action is licensed under [MIT license](LICENSE).
