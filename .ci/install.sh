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
fi

pip install conan --upgrade
conan remote add -f bincrafters https://api.bintray.com/conan/bincrafters/public-conan
conan profile new default --detect  # Generates default profile detecting GCC and sets old ABI

# Sets libcxx to C++11 ABI
echo "CLANG_VERSIONS=${CLANG_VERSIONS:-}"
if [ ! -z "${CLANG_VERSIONS:-}" ] || [[ "$(uname -s)" == 'Darwin' ]];
then
    conan profile update settings.compiler.libcxx=libstdc++ default
else
    conan profile update settings.compiler.libcxx=libstdc++11 default
fi
conan install .