# flake-nc_py_api

Standalone flake packaging [nc_py_api](https://github.com/cloud-py-api/nc_py_api)
— the Nextcloud Python Framework — version `0.31.0`.

The package used to live in a personal nixpkgs fork; this flake makes it
usable on top of an unmodified `nixpkgs` from nixos-unstable.

## Usage

Build the package:

```console
nix build .#nc_py_api
```

Use it in a dev shell:

```console
nix develop
```

Or consume it from another flake by adding this flake as an input and
overlaying it:

```nix
{
  inputs.nc-py-api.url = "github:it-zone/flake-nc_py_api";

  outputs = { self, nixpkgs, nc-py-api }:
    let
      pkgs = import nixpkgs {
        system = "x86_64-linux";
        overlays = [ nc-py-api.overlays.default ];
      };
    in
    {
      # ...
    };
}
```

## What the overlay provides

`pkgs.python3Packages.nc_py_api` plus the dependency versions it pins, which
nixpkgs does not (yet) ship:

| Package              | Version | Reason                                                    |
| -------------------- | ------- | --------------------------------------------------------- |
| `nc_py_api`          | 0.31.0  | the package itself                                         |
| `filelock`           | 4.2.10  | `nc_py_api` requires `filelock>=4.2.10,<5`                 |
| `python-sbom`        | 0.1.2   | build backend requirement of `filelock` 4.2.10             |
| `zipremove`          | 0.10.0  | runtime dependency of `python-sbom`                        |
| `installer`          | 1.1.0   | `python-sbom` requires `installer>=1.1`                    |
| `hatchling`          | 1.33.0  | `python-sbom` requires `hatchling>=1.32.4`                 |
| `hatch-vcs`          | 0.5.0   | build backend requirement of `python-sbom`                 |
| `hatch-fancy-pypi-readme` | 25.1.0 | build backend requirement of `python-sbom`             |

The `hatch-vcs` and `hatch-fancy-pypi-readme` packages are rebuilt against
our `hatchling`, because both propagate `hatchling` into the build
environment where it would otherwise shadow the newer version.

The overlay also overrides `pypaInstallHook`, because nixpkgs hardcodes the
`installer` version it ships (1.0.1) into that hook, which shadows
`installer` 1.1.0 and breaks `python-sbom`.

## Tests

The upstream test suite is split in two:

- `tests/` — integration tests, they need a live Nextcloud instance
  (`tests/conftest.py` connects to `nextcloud.local` at import time).
- `tests_unit/` — offline unit tests.

Only `tests_unit` is run during the build (`enabledTestPaths`).

## Layout

```
flake.nix          flake outputs (packages, checks, devShell, overlay)
overlay.nix        nixpkgs overlay adding python3Packages.nc_py_api
packages/          the individual package expressions
```
