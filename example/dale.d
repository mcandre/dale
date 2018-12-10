import arithmancy;
import dl;

import std.file;
import std.stdio;
import std.string;

// Generate documentation
@(TASK)
void doc() {
    exec("doxygen");
}

// Run D-Scanner
@(TASK)
void dscanner() {
    exec("dub", ["run", "dscanner", "--", "--styleCheck"]);
}

// Static code validation
@(TASK)
void lint() {
    // deps(&doc);
    // deps(&dscanner);
}

// Lint, and then install artifacts
@(TASK)
void install() {
    auto cwd = getcwd();
    exec("dub", ["add-local", cwd]);
}

// Uninstall artifacts
@(TASK)
void uninstall() {
    auto cwd = getcwd();
    exec("dub", ["remove-local", cwd]);
}

// Lint, and then run unit tests
@(TASK)
void unitTest() {
    deps(&lint);
    exec("dub", ["test"]);
}

// Lint, and then run integration tests
@(TASK)
void integrationTest() {
    deps(&install);

    assert(chomp(execStdoutUTF8("dub", ["run", "--verror", "--config", "add_two", "--", "-n", "2"])) == "4");
    assert(execStatus("dub", ["run", "--verror", "--config", "add_two"]) != 0);
}

// Lint, and then run tests
@(TASK)
void test() {
    deps(&unitTest);
    deps(&integrationTest);
}

// Lint, unittest, and build debug binaries
@(TASK)
void buildDebug() {
    deps(&unitTest);
    exec("dub", ["build"]);
    exec("dub", ["build", "--config", "add_two"]);
}

// Lint, unittest, and build release binaries
@(TASK)
void buildRelease() {
    deps(&unitTest);
    exec("dub", ["build", "-b", "release"]);
    exec("dub", ["build", "-b", "release", "--config", "add_two"]);
}

// Lint, unittest, and build (release) binaries
@(TASK)
void build() {
    deps(&buildRelease);
}

// Show banner
@(TASK)
void banner() {
    writefln("%s %s", "arithmancy", ARITHMANCY_VERSION);
}

// Publish to crate repository
@(TASK)
void publish() {
    exec("dub", ["publish"]);
}

// Run dub clean
@(TASK)
void cleanDub() {
    exec("dub", ["clean"]);
}

// Clean workspaces
@(TASK)
void clean() {
    deps(&cleanDub);
}

// CLI entrypoint
version(unittest) {} else
void main(string[] args) {
    phony([
        &uninstall,
        &cleanDub,
        &clean
    ]);

    mixin(yyyup!(__MODULE__, "args", "build"));
}
