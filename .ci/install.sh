#!/bin/bash

set -ex

command_prefix=()

# Install pre-requisites
if [ "${TRAVIS_OS_NAME}" = "osx" ];
then
    brew update || brew update
    brew install cmake || :;
elif [ ! "${TRAVIS_OS_NAME}" = "windows" ];
then
    docker pull ${DOCKER_IMAGE}
    docker run -v ${PWD}:${PWD} -w ${PWD}  \
               -u root \
               --name "${RUNNER}" \
               --rm -t -d ${DOCKER_IMAGE}
    command_prefix=(docker exec ${RUNNER})
fi

# Install Conan
if [ "${TRAVIS_OS_NAME}" = "windows" ];
then
    choco install conan || :;
    export PATH="${PATH}:/c/Program Files/Conan/conan";
else
    ${command_prefix[@]} pip install conan --upgrade;
fi

# Install dependencies using Conan
conan=(${command_prefix[@]} conan)
${conan[@]} remote add -f bincrafters https://api.bintray.com/conan/bincrafters/public-conan
${conan[@]} profile new default --detect  # Generates default profile detecting GCC and sets old ABI

if [ "${TRAVIS_OS_NAME}" = "osx" ];
then
    ${conan[@]} profile update settings.compiler.libcxx=libc++ default
elif [ "${TRAVIS_OS_NAME}" = "windows" ];
then
    ${conan[@]} profile update settings.compiler="Visual Studio" default
    ${conan[@]} profile update settings.compiler.version=15 default
    ${conan[@]} profile update settings.compiler.libcxx=libstdc++11 default
else
    # Sets libcxx to C++11 ABI
    ${conan[@]} profile update settings.compiler.libcxx=libstdc++11 default
fi

${conan[@]} install . --build missing