# APTOS Project

## Dependencies

```bash
# Install this before
$ brew install swift-protobuf
$ cargo install cargo-lipo
```

## Core

```bash
# Build the core
$ cd core && make ios
```

## App

```bash
# Generate proto
$ cd app && make protos
```

```bash
# Launch Xcode
$ cd app && make xcode
```
