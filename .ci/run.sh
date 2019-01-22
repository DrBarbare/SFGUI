#!/bin/bash

set -eux

if [[ "$(uname -s)" == 'Darwin' ]];
then
    generator="-GXcode"
else
    generator="-GNinja"
fi

build_dir="$(pwd)/build"
cmake -H"$(pwd)" -B"${build_dir}" "${generator}" -DCMAKE_BUILD_TYPE=Release
cmake --build "${build_dir}" --config Release