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
    doc
    dscanner
}

unittest() {
    # lint
    dub test
}

integration_test() {
    install
    sh -c 'cd example && VERBOSE=1 dub run dale -- -l'
    sh -c 'cd example && VERBOSE=1 dub run dale -- -v'
    sh -c 'cd example && VERBOSE=1 dub run dale -- -h'
    sh -c 'cd example && VERBOSE=1 dub run dale'
    sh -c 'cd example && VERBOSE=1 dub run dale -- \
        test \
        dscanner \
        lint \
        build \
        doc \
        install \
        unittest \
        integration_test \
        test \
        banner \
        uninstall \
        clean_dub \
        clean'
}

test() {
    unittest
    integration_test
}

install_binaries() {
    dub add-local .
}

install() {
    install_binaries
}

uninstall() {
    dub remove dale
}

build_debug() {
    unittest
    dub build
}

build_release() {
    unittest
    dub build -b release
}

build() {
    build_debug
    build_release
}

publish() {
    dub publish
}

clean_example() {
    rm -rf example/bin;
    sh -c 'cd example && dub clean';
}

clean_dub() {
    dub clean
}

clean_dotdub() {
    rm -rf .dub || true
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
    clean_dotdub
    clean_static_libraries
    clean_tests
}

if [ -z "$1" ]; then
    build
fi

for task in "$@"; do
    "$task"
done
