# OVERVIEW

dale's own compilation process is compatible with standard `dub`. We wrap some common workflows with `build` tasks for convenience.

# BUILDTIME REQUIREMENTS

* [D](https://dlang.org/) 2+
* [dub](https://code.dlang.org/)
* [D-Scanner](https://github.com/dlang-community/D-Scanner)
* [coreutils](https://www.gnu.org/software/coreutils/coreutils.html)

# INSTALL PACKAGE FROM LOCAL SOURCE FILES

```console
$ ./build install
```

# UNINSTALL PACKAGE

```console
$ ./build uninstall
```

# BUILD: LINT, COMPILE, and TEST

```console
$ ./build [build]
```

# PUBLISH

(Tag a new VCS release.)

# CLEAN

```console
$ ./build clean
```
