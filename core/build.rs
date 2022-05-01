extern crate cbindgen;

use std::env;

fn main() -> Result<(), Box<dyn std::error::Error>> {
    let crate_dir = env::var("CARGO_MANIFEST_DIR").unwrap();

    cbindgen::Builder::new()
        .with_crate(&crate_dir)
        .with_language(cbindgen::Language::C)
        .generate()
        .expect("Unable to generate bindings")
        .write_to_file("bindings.h");

    let files = &["core.proto"];
    let dirs = &["../protos"];

    prost_build::compile_protos(files, dirs)
        .unwrap_or_else(|e| panic!("protobuf compilation failed: {}", e));

    Ok(())
}