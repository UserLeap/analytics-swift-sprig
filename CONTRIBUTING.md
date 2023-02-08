## Release process
### Updating dependencies
Daily a workflow is run to update segment and sprig dependencies automatically. It will open a PR assigned to the SDK team

### Tag & Release
After the dependency PR is merged, in order to release update the version in Sources/SegmentSprig/Version.swift. When a change to this is pushed it will create the tag and the corresponding release.