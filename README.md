# dale: a paranoid D task runner

![pocket sand](https://raw.githubusercontent.com/mcandre/dale/master/dale.gif)

# EXAMPLE

```console
$ cd example

$ dub run dale
Running .dub/build/test/arithmancy-test-unittest

$ dub run dale -- -h
Usage: ../.dub/build/bin/dale [OPTIONS]
-l    --list
-v --version
-h    --help This help information.
```

# ABOUT

dale is a task runner for D projects, a more portable alternative to makefiles. dale wraps common dub workflows, providing a convenient way to kick off your various build commands.

# DUB

https://code.dlang.org/packages/dale

# LICENSE

BSD-2-Clause

# RUNTIME REQUIREMENTS

* [D](https://dlang.org) 2+

# INSTALL

```console
$ dub fetch dale
```

# SETUP

## dale.d

Write some tasks in a `dale.d` build configuration script at the top-level directory of your D project:

```d
import dl;

immutable VERSION = "0.0.1";

@(TASK)
void banner() {
    writefln("arithmancy %s", VERSION);
}

@(TASK)
void test() {
    exec("dub", ["test"]);
}

@(TASK)
void build() {
    deps(test);
    exec("dub", ["build"]);
}

@(TASK)
void clean() {
    exec("dub", ["clean"]);
}

@(TASK)
void main(string[] args) {
    phony([&clean]);
    mixin(yyyup!("args", "build"));
}
```

## dub.sdl / dub.json

Now, wire up the dale command line interface by configuring your top-level `dub.sdl` or `dub.json`:

```sdlang
configuration "shi_sha" {
    targetName "dale"
    targetType "executable"
    targetPath ".dub/build/shi_sha"
    mainSourceFile "dale.d"
    dependency "dale" version="0.0.1"
}
```

```json
{
    "configurations": [
        {
            "name": "shi_sha",
            "targetName": "dale",
            "targetType": "executable",
            "targetPath": ".dub/build/shi_sha",
            "mainSourceFile": "dale.d",
            "dependencies": {
                "dale": "0.0.1"
            }
        }
    ]
}
```

Watch how he behaves... I hope dale is practicing good manners :P

What happens when you run:

* `dub run dale -- banner`?
* `dub run dale -- test`?
* `dub run dale -- clean`?
* `dub run dale -- build`?
* `dub run dale -- -h`?
* `dub run dale -- --list`?
* `VERBOSE=1 dub run dale -- build`?
* `VERBOSE=1 dub run dale -- build build build`?

# DEBRIEFING

Let's break down the code so far:

* `@(TASK) void name() { ... }` declares a task named `name`.
* `deps(&requirement)` caches a dependency on task `requirement`.
* `exec(...)` spawns raw shell command processes.
* `VERBOSE=1` enables command string emission during processing.
* `phony(...)` disables dependency caching for some tasks.
* `mixin(yyyup!("args", "build"))` registers a `default` task and wires up any other `TASK`-annotated functions to the dale command line interface.
* `shi_sha` is a feature gate, so that neither the dale package, nor your project's dale binary escape with your D package when you publish your project.

# DoN't UsE sHelL cOmMaNdS!1

Just because the dale library offers several *supremely convenient* macros for executing shell commands doesn't mean that you should always shell out. No way, man!

Whenever possible, use regular D code, as in the `banner()` example. There's like a ba-jillion [packages](https://code.dlang.org) of prewritten D code, so you might as well use it! Dale uses no DSL's, just plain old D code, so it's easy to integrate with other D libraries.

# CONTRIBUTING

For more details on developing dale itself, see [DEVELOPMENT.md](DEVELOPMENT.md).

# SEE ALSO

* Inspired by the excellent [mage](https://magefile.org/) build system for Go projects
* Thank you [Kenji](https://forum.dlang.org/post/mailman.2348.1382205515.1719.digitalmars-d@puremagic.com) for sharing reflection snippets!
* [cmake](https://cmake.org/), a build system for C/C++ projects
* [GNU autotools](https://www.gnu.org/software/automake/manual/html_node/Autotools-Introduction.html), a build system for Linux C/C++ projects
* [Gradle](https://gradle.org/), a build system for JVM projects
* [lake](https://luarocks.org/modules/steved/lake), a Lua task runner
* [Mage](https://magefile.org/), a task runner for Go projects
* [npm](https://www.npmjs.com/), [Grunt](https://gruntjs.com/), Node.js task runners
* [POSIX make](https://pubs.opengroup.org/onlinepubs/009695299/utilities/make.html), a task runner standard for C/C++ and various other software projects
* [Rake](https://ruby.github.io/rake/), a task runner for Ruby projects
* [rdmd](https://dlang.org/rdmd.html), a fast-compiling interpreter for D
* [Shake](https://shakebuild.com/), a task runner for Haskell projects
* [tinyrick](https://github.com/mcandre/tinyrick) for Rust projects

# EVEN MORE EXAMPLES

* The included [example](example) project provides a fully qualified demonstration of how to build projects with dale.
