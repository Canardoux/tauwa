#!/bin/bash

cd ~/projmac/flutter_rust_bridge.git
git pull
git pull https://github.com/fzyzcjy/flutter_rust_bridge refs/pull/2045/head
cd frb_codegen
cargo build
if [ $? -ne 0 ]; then
    echo "Error: cargo build"
    exit -1
fi

cd ..

cd frb_example/integrate_third_party
~/projmac/flutter_rust_bridge/target/debug/flutter_rust_bridge_codegen generate
if [ $? -ne 0 ]; then
    echo "Error: cargo build"
    exit -1
fi
~/projmac/flutter_rust_bridge/target/debug/flutter_rust_bridge_codegen generate
cd ../..
