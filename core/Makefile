.PHONY: init_ios init_android macos ios check clean prettier

init_ios:
	rustup target add aarch64-apple-ios x86_64-apple-ios;

init_android:
	rustup target add aarch64-linux-android armv7-linux-androideabi i686-linux-android;

macos:
	cargo build;
	cp target/debug/libcore.a ../app/Frameworks/libcore-macos.a;

ios:
	cargo lipo;
	cp target/universal/debug/libcore.a ../app/Frameworks/libcore-ios.a;

check:
	cargo check;

clean:
	cargo clean;

prettier:
	rustfmt src/*.rs;