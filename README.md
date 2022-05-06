# Aptos Hackathon

Aptos API spec => **https://fullnode.devnet.aptoslabs.com/spec.html**

## Dependencies

```bash
# Install Cocoapods to manage swift dependencies
$ brew install cocoapods

# Install Rust (if not already done) => https://www.rust-lang.org/tools/install
$ curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

# Install Swift Protobuf to generate swift implem of our .proto
$ brew install swift-protobuf

# Cargo Lipo is used to generate a static library for iOS
$ cargo install cargo-lipo
```

## Core

Inside the core folder:

```bash
# Install iOS targets for rust (if not already done)
$ make init_ios

# Generate the static library for iOS
$ make ios
```

## App

Inside the app folder:

```bash
# Will generate swift protos via the protoc compiler
$ make protos

# Install Cocoapods dependencies
$ pod install

# Launch Xcode, for convenience
$ make xcode
```
