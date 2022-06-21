# forem-vala

Unofficial [Forem](https://forem.com) API client library for Vala. Still a work in progress.

## Compilation

I recommend including `forem-vala` as a git submodule and adding `forem-vala/src/Forem.vala` to your sources list. This will avoid packaging conflicts and remote build system issues until I learn a better way to suggest this.

### Requirements

```
meson
ninja-build
valac
```

### Building

```bash
meson build
cd build
meson configure -Denable_examples=true
ninja
./examples/hello-forem
```

Examples require update to username and password, don't check this in

```
string user = "username";
string password = "password";
```

# Quick Start

TBD
