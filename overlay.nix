# Overlay that adds `nc_py_api` (Nextcloud Python Framework) on top of a
# stock nixpkgs, together with the dependency versions it pins.
#
# The packages below are the ones that nixpkgs does not (yet) ship in the
# required versions:
#
#   * `filelock` 4.2.10 — nc_py_api requires `filelock>=4.2.10,<5`.
#   * `python-sbom` 0.1.2 — build backend requirement of filelock 4.2.10.
#   * `zipremove` 0.10.0 — runtime dependency of python-sbom.
#   * `installer` 1.1.0 — python-sbom requires `installer>=1.1`.
#   * `hatchling` 1.33.0 — python-sbom requires `hatchling>=1.32.4`.
#   * `packageurl-python` 0.17.6 — the sdist is used instead of the git
#     checkout, because the purl specification test data only lives in a git
#     submodule and is not shipped in the sdist.
#
# The overridden packages are passed explicitly, because the `callPackage`
# scope of the Python package set is bound to the unpatched nixpkgs set.
_final: prev:
let
  callPackage = prev.python3Packages.callPackage;

  installer = callPackage ./packages/installer.nix { };

  hatchling = callPackage ./packages/hatchling.nix { };

  # `hatch-vcs` and `hatch-fancy-pypi-readme` propagate `hatchling`, so they
  # have to be rebuilt against our `hatchling`, otherwise the nixpkgs version
  # (1.32.0) shadows it in the build environment.
  hatch-vcs = callPackage ./packages/hatch-vcs.nix { inherit hatchling; };

  hatch-fancy-pypi-readme = callPackage ./packages/hatch-fancy-pypi-readme.nix { inherit hatchling; };

  packageurl-python = callPackage ./packages/packageurl-python.nix { };

  zipremove = callPackage ./packages/zipremove.nix { };

  # nixpkgs' `pypaInstallHook` installs wheels with the `installer` package.
  # It pins the version that nixpkgs ships (1.0.1), which shadows our
  # `installer` 1.1.0 in the build environment and breaks packages that
  # require `installer>=1.1` (python-sbom).
  pypaInstallHook = prev.python3Packages.pypaInstallHook.override { inherit installer; };

  buildPythonPackage = prev.python3Packages.buildPythonPackage.override { inherit pypaInstallHook; };

  python-sbom = callPackage ./packages/python-sbom.nix {
    inherit
      buildPythonPackage
      hatch-fancy-pypi-readme
      hatch-vcs
      hatchling
      installer
      packageurl-python
      zipremove
      ;
  };

  filelock = callPackage ./packages/filelock.nix {
    inherit
      buildPythonPackage
      hatch-fancy-pypi-readme
      hatch-vcs
      hatchling
      python-sbom
      ;
  };

  nc_py_api = callPackage ./packages/nc-py-api.nix {
    inherit
      buildPythonPackage
      hatchling
      filelock
      ;
  };
in
{
  python3Packages = prev.python3Packages // {
    inherit
      buildPythonPackage
      pypaInstallHook
      installer
      hatchling
      hatch-vcs
      hatch-fancy-pypi-readme
      packageurl-python
      zipremove
      python-sbom
      filelock
      nc_py_api
      ;
  };
}
