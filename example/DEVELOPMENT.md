# OVERVIEW

arithmancy's own compilation process is compatible with standard `dub`. We wrap some common workflows with `dale` tasks for convenience.

# BUILDTIME REQUIREMENTS

* [D](https://dlang.org/) 2+
* [dub](https://code.dlang.org/)
* [dale](https://github.com/mcandre/dale)
* [D-Scanner](https://github.com/dlang-community/D-Scanner)

# INSTALL PACKAGE FROM LOCAL SOURCE FILES

```console
$ dub run dale -- install
```

# UNINSTALL PACKAGE

```console
$ dub run dale -- uninstall
```

# BUILD: LINT, COMPILE, and TEST

```console
$ dub run dale [-- build]
```

# PUBLISH

(Tag a new VCS release.)

# CLEAN

```console
$ dub run dale -- clean
```
