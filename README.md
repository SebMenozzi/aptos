# APTOS Project

## Dependencies

```bash
# Install Swift Protobuf to generate swift implem of our .proto
$ brew install swift-protobuf
# Cargo Lipo is used to generate a static library for iOS
$ cargo install cargo-lipo
```

## Core

Inside the core folder:

```bash
# Has to be done once, it will install iOS targets for rust
$ make init_ios
# Generate the static library for iOS
$ make ios
```

## App

Inside the app folder:

```bash
# Will generate swift protos via the protoc compiler
$ make protos
```

```bash
# Launch Xcode for convinience
$ make xcode
```
