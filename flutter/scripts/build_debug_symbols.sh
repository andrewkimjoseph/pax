#! /bin/bash

cd build/app/intermediates/merged_native_libs/release/mergeReleaseNativeLibs/out/lib/
zip -r symbols.zip arm64-v8a armeabi-v7a x86 x86_64 -x "*.DS_Store"
cd ../../../../../../../../