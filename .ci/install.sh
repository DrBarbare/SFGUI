#!/bin/bash

set -eux

if [[ "$(uname -s)" == 'Darwin' ]];
then
    brew update || brew update
    brew outdated pyenv || brew upgrade pyenv
    brew install pyenv-virtualenv
    brew install cmake || true

    if which pyenv > /dev/null;
    then
        eval "$(pyenv init -)"
    fi

    pyenv install 2.7.10
    pyenv virtualenv 2.7.10 conan
    pyenv rehash
    pyenv activate conan
    command_prefix=""
else
    docker pull ${DOCKER_IMAGE}
    docker run -v ${PWD}:${PWD} -w ${PWD}  \
               -u root \
               --name "${RUNNER}" \
               --rm -t -d ${DOCKER_IMAGE}
    command_prefix=(docker run ${RUNNER})
fi

${command_prefix[@]} pip install conan --upgrade

conan=(${command_prefix[@]} conan)
${conan[@]} remote add -f bincrafters https://api.bintray.com/conan/bincrafters/public-conan
${conan[@]} profile new default --detect  # Generates default profile detecting GCC and sets old ABI

# Sets libcxx to C++11 ABI
${conan[@]} profile update settings.compiler.libcxx=libstdc++11 default
${conan[@]} install . || "${conan[@]}" install . --build sfml