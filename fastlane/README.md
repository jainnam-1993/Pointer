fastlane documentation
----

# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```sh
xcode-select --install
```

For _fastlane_ installation instructions, see [Installing _fastlane_](https://docs.fastlane.tools/#installing-fastlane)

# Available Actions

## Android

### android internal

```sh
[bundle exec] fastlane android internal
```

Upload AAB to Play Store internal testing track

### android metadata

```sh
[bundle exec] fastlane android metadata
```

Upload metadata (screenshots, descriptions) to Play Store

### android production

```sh
[bundle exec] fastlane android production
```

Upload AAB to Play Store production track

### android deploy_internal

```sh
[bundle exec] fastlane android deploy_internal
```

Upload everything (AAB + metadata) to internal track

### android validate

```sh
[bundle exec] fastlane android validate
```

Validate service account credentials

----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.

More information about _fastlane_ can be found on [fastlane.tools](https://fastlane.tools).

The documentation of _fastlane_ can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
