#!/bin/bash
set -eEuo pipefail

PACKAGE='dale'
VERSION='0.0.1'
ARCHIVE="${PACKAGE}-${VERSION}.zip"

doc() {
    doxygen
}

dscanner() {
    dub run dscanner -- --styleCheck
}

lint() {
    true # doc
    true # dscanner
}

unit_test() {
    lint
    dub test
}

integration_test() {
    install

    trap 'popd' ERR INT KILL
    pushd example

    dub run dale -- -l
    dub run dale -- -v
    dub run dale -- -h
    dub run dale

    # doc \
    # dscanner \
    VERBOSE=1 dub run dale -- \
        lint \
        test \
        build \
        install \
        unitTest \
        integrationTest \
        test \
        banner \
        uninstall \
        cleanDub \
        clean

    popd
}

test() {
    unit_test
    integration_test
}

install_binaries() {
    dub add-local .
}

install() {
    install_binaries
}

uninstall() {
    dub remove-local .
}

build_debug() {
    unit_test
    dub build
}

build_release() {
    unit_test
    dub build -b release
}

build() {
    build_release
}

publish() {
    dub publish
}

clean_example() {
    trap 'popd' ERR INT KILL
    pushd example

    dub clean

    popd
}

clean_dub() {
    dub clean
}

clean_static_libraries() {
    rm *.a *.lib || true
}

clean_tests() {
    rm *-test-* || true
}

clean() {
    clean_example
    clean_dub
}

if [ -z "$1" ]; then
    build
fi

for task in "$@"; do
    "$task"
done
