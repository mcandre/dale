# dale: a paranoid D task runner

![pocket sand](https://raw.githubusercontent.com/mcandre/dale/master/dale.gif)

# EXAMPLE

```console
$ cd example

$ dale
...
(Currently broken!)

$ dale -h
Usage: dale [options]

Options:
    -l, --list          list available tasks
    -h, --help          print usage info
    -v, --version       print version info
```

# ABOUT

dale is a task runner for D projects, a more portable alternative to makefiles. dale wraps common D tools like dub, allowing you to declare your own build workflows.

# DUB

https://code.dlang.org/packages/dale

# RUNTIME REQUIREMENTS

* [D](https://dlang.org) 2+

# SETUP

## dale.d

Write some tasks in a `dale.d` build configuration script at the top-level directory of your D project:

```d
import dale;

immutable PROJECT = "arithmancy";
immutable VERSION = "0.0.1";

void banner() {
    writefln("%s %s", PROJECT, VERSION);
}

void test() {
    exec("dub", ["test"]);
}

void build() {
    deps(test);
    exec("dub", ["build"]);
}

void publish() {
    exec("dub", ["publish"]);
}

void clean() {
    exec("dub", ["clean"]);
}

void main(string[] args) {
    phony(clean);
    loadTasks(build, [banner, test, publish, clean]);
}
```

## dub.json

Now, wire up the dale command line interface by configuring your top-level `dub.json` or `dub.dsl`:

```json
{
    "name": "arithmancy",
    "description": "an *advanced* mathematical compilation",
    "version": "0.0.1",
    "configurations": [
        {
            "name": "shi_sha",
            "targetType": "executable",
            "libs": ["dale"]
        }
    ]
}
```

Launch a terminal session in your project directory. Install and run the dale tool:

```console
$ dub fetch dale
$ dub run dale
```

Watch how he behaves... I hope dale is practicing good manners :P

What happens when you run:

* `dub run dale -- banner`?
* `dub run dale --  test`?
* `dub run dale --  clean`?
* `dub run dale --  build`?
* `dub run dale --  -h`?
* `dub run dale --  --list`?
* `VERBOSE=1 dub run dale -- build`?
* `VERBOSE=1 dub run dale -- build build build`?

# DEBRIEFING

Let's break down the code so far:

* `void name() { ... }` declares a task named `name`.
* `deps(requirement)` caches a dependency on task `requirement`.
* `exec(...)` spawns raw shell command processes.
* `VERBOSE=1` enables command string emission during processing.
* `phony(...)` disables dependency caching for some tasks.
* `load(default, [...])` exposes a `default` task and some other tasks to the dale command line.
* `shi_sha` is a feature gate, so that neither the dale package, nor your project's dale binary escape with your D package when you `dale publish`.

# DoN't UsE sHelL cOmMaNdS!1

Just because the dale library offers several *supremely convenient* macros for executing shell commands doesn't mean that you should always shell out. No way, man!

Whenever possible, use regular D code, as in the `banner()` example. There's like a ba-jillion [packages](https://code.dlang.org) of prewritten D code, so you might as well use it!

# CONTRIBUTING

For more details on developing dale itself, see [DEVELOPMENT.md](DEVELOPMENT.md).

# SEE ALSO

* Inspired by the excellent [mage](https://magefile.org/) build system for Go projects
* Thank you [Kenji](https://forum.dlang.org/post/mailman.2348.1382205515.1719.digitalmars-d@puremagic.com) for sharing reflection snippets!
* [tinyrick](https://github.com/mcandre/tinyrick) for Rust projects

# EVEN MORE EXAMPLES

* The included [example](example) project provides a fully qualified demonstration of how to build projects with dale.
* For a more practical example, see [ios7crypt-d](https://github.com/mcandre/ios7crypt-d), a little *modulino* library + command line tool for *deliciously dumb* password encryption.
* [dale_extras](https://github.com/mcandre/dale_extras) defines some common workflow tasks as plain old D functions, that you can sprinkle onto your dale just like any other Dub package.
