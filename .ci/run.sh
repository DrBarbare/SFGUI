#!/bin/bash

set -ex

cmake=("cmake")
if [ "${TRAVIS_OS_NAME}" = "osx" ];
then
    generator="-GXcode"
    CORES=4 # Apple toolchain can't figure out the number of cores...
    need_stop=false
elif [ "${TRAVIS_OS_NAME}" = "windows" ];
then
    generator=("-GVisual Studio 15 2017 Win64")
    need_stop=false
else
    generator="-GNinja"
    cmake=(docker exec ${RUNNER} cmake)
    need_stop=true
fi

build_dir="$(pwd)/build"
${cmake[@]} -H"$(pwd)" -B"${build_dir}" "${generator}" -DCMAKE_BUILD_TYPE=Release
${cmake[@]} --build "${build_dir}" --config Release -j ${CORES:-}

if ${need_stop};
then
     docker stop "${RUNNER}"
fi