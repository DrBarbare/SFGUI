#!/bin/bash

set -ex

if [[ "$(uname -s)" == 'Darwin' ]];
then
    brew update || brew update
    brew install cmake || true

    command_prefix=""
else
    docker pull ${DOCKER_IMAGE}
    docker run -v ${PWD}:${PWD} -w ${PWD}  \
               -u root \
               --name "${RUNNER}" \
               --rm -t -d ${DOCKER_IMAGE}
    command_prefix=(docker exec ${RUNNER})
fi

${command_prefix[@]} pip install conan --upgrade

conan=(${command_prefix[@]} conan)
${conan[@]} remote add -f bincrafters https://api.bintray.com/conan/bincrafters/public-conan
${conan[@]} profile new default --detect  # Generates default profile detecting GCC and sets old ABI


if [[ "$(uname -s)" == 'Darwin' ]];
then
    ${conan[@]} profile update settings.compiler.libcxx=libc++ default
    ${conan[@]} install . --build missing
else
    # Sets libcxx to C++11 ABI
    ${conan[@]} profile update settings.compiler.libcxx=libstdc++11 default
    ${conan[@]} install . || ${conan[@]} install . --build sfml
fi