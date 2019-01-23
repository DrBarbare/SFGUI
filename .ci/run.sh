#!/bin/bash

set -eux

if [[ "$(uname -s)" == 'Darwin' ]];
then
    generator="-GXcode"
    cmake=("cmake")
    need_stop=false
else
    generator="-GNinja"
    cmake=(docker run ${RUNNER} cmake)
    need_stop=true
fi

build_dir="$(pwd)/build"
${cmake[@]} -H"$(pwd)" -B"${build_dir}" "${generator}" -DCMAKE_BUILD_TYPE=Release
${cmake[@]} --build "${build_dir}" --config Release

if ${need_stop};
then
     docker stop "${RUNNER}"
fi