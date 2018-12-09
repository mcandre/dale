import arithmancy;
import dl;

import std.file;
import std.stdio;

// Generate documentation
void doc() {
    exec("doxygen");
}

// Run D-Scanner
void dscanner() {
    exec("dub", ["run", "dscanner", "--", "--styleCheck"]);
}

// Static code validation
void lint() {
    deps(&doc);
    deps(&dscanner);
}

// Lint, and then install artifacts
void install() {
    exec("dub", ["install"]);
}

// Uninstall artifacts
void uninstall() {
    exec("dub", ["remove", "arithmancy"]);
}

// Lint, and then run unit tests
void unitTest() {
    // deps(&lint);
    exec("dub", ["test"]);
}

// Lint, and then run integration tests
void integrationTest() {
    deps(&install);

    assert(execOutput("add_two", ["-n", "2"]) == "4");
    assert(execStatus("add_two") != 0);
}

// Lint, and then run tests
void test() {
    deps(&unitTest);
    deps(&integrationTest);
}

// Lint, unittest, and build debug binaries
void buildDebug() {
    deps(&unitTest);
    exec("dub", ["build"]);
}

// Lint, unittest, and build release binaries
void buildRelease() {
    deps(&unitTest);
    exec("dub", ["build", "-b", "release"]);
}

// Lint, unittest, and build debug and release binaries
void build() {
    deps(&buildDebug);
    deps(&buildRelease);
}

// Show banner
void banner() {
    writefln("%s %s", "arithmancy", ARITHMANCY_VERSION);
}

// Publish to crate repository
void publish() {
    exec("dub", ["publish"]);
}

// Run dub clean
void cleanDub() {
    exec("dub", ["clean"]);
}

// Remove .dub/ cache
void cleanDotDub() {
    if (exists(".dub")) {
        rmdirRecurse(".dub");
    }
}

// Remove static libraries
void cleanStaticLibraries() {
    auto cwd = getcwd();

    foreach(library; dirEntries(cwd, "*.a", SpanMode.shallow)) {
        remove(library);
    }

    foreach(library; dirEntries(cwd, "*.lib", SpanMode.shallow)) {
        remove(library);
    }
}

// Remove test binaries
void cleanTests() {
    auto cwd = getcwd();

    foreach(binary; dirEntries(cwd, "*-test-*", SpanMode.shallow)) {
        remove(binary);
    }
}

// Clean workspaces
void clean() {
    deps(&cleanDub);
    deps(&cleanDotDub);
    deps(&cleanStaticLibraries);
    deps(&cleanTests);
}

// CLI entrypoint
version(unittest) {} else
void main(string[] args) {
    phony([
        &uninstall,
        &cleanDub,
        &clean
    ]);

    mixin(yyyup!("args", "build"));
}

void unused() {}
