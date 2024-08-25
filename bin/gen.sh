#!/bin/bash

#rm -rf /Volumes/mac-J/larpoux/.cargo/registry
#cd rust
#cargo clean
#cd ..

cargo install 'flutter_rust_bridge_codegen'
#cp    flutter_rust_bridge/frb_example/integrate_third_party/rust/src/api/override_web_audio_api.rs tau_rust/rust/src/api
#cp -a flutter_rust_bridge/frb_example/integrate_third_party/rust/src/third_party/* tau_rust/rust/src/third_party

rm -r lib/public/rust/api/*
rm -r lib/public/rust/frb_*
rm rust/src/frb_*

flutter clean
flutter pub get

cd example
flutter pub get
cd ..

echo '-----> flutter_rust_bridge_codegen generate'
flutter_rust_bridge_codegen generate
#cargo run --manifest-path ../flutter_rust_bridge/frb_codegen/Cargo.toml -- generate


if [ $? -ne 0 ]; then
    echo "Error: flutter_rust_bridge_codegen generate"
    exit -1
fi


cd rust

#cargo clean
#if [ $? -ne 0 ]; then
#    echo "Error: cargo clean"
#    exit -1
#fi


#rm Cargo.lock
#echo '-----> cargo clippy'
#cargo clippy --fix --allow-dirty --allow-staged --allow-no-vcs -- -D warnings
#if [ $? -ne 0 ]; then
#    echo "Error: ~/bin/generate.sh"
#    exit -1
#fi

#echo '-----> cargo fmt'
#cargo +nightly fmt --check
#if [ $? -ne 0 ]; then
#    echo "Error: ~/bin/generate.sh"
#    exit -1
#fi

echo '-----> cargo build'
cargo build
if [ $? -ne 0 ]; then
    echo "Error: cargo build"
    exit -1
fi

echo '-----> cargo build release'
cargo build --release
if [ $? -ne 0 ]; then
    echo "Error: cargo build"
    exit -1
fi

cd .. # back into tau/tau_rust
cd .. # back into tau/
