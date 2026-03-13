# Swift IHO S-100 portrayal

## Introduction

This Swift Package uses [swift-s101](https://github.com/ElectronicChartCentre/swift-s101) to parse IHO S-101 files.

## Use

Take a look at the tests for examples on how to use.

## Performance tips

* Cache S-101 DataSetFile.
* Cache Lua DrawingCommands.

## Status

* Artifacts from the latest Github Action build for macOS and Linux has images of several IHO S-164 test data sets.
* Only S-101 for now.
* Works on iOS, macOS and Linux. However, non-Apple platforms are missing text now.
* CoreGraphicsRenderer for PNG is the best Renderer now. The VectorTileRenderer is not usable yet.
* LLXY and WebMercator projection, but easy to implement Projection protocol.
* Early phase, so not complete and API will change.

## License

Apache 2.0
