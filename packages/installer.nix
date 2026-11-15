{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  flit-core,
}:

buildPythonPackage rec {
  pname = "installer";
  version = "1.1.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "pypa";
    repo = "installer";
    rev = version;
    hash = "sha256-l2jxC2UJOmWGpCOUWU/2x2QSuYo7GjGxj9Yeu6V2uh0=";
  };

  patches = [
    # Add --executable flag to installer to correctly support cross
    # https://github.com/pypa/installer/pull/258
    ./cross.patch
  ];

  nativeBuildInputs = [ flit-core ];

  # This package is part of the bootstrap chain and its test dependencies
  # cannot be built yet when this is being built.
  doCheck = false;

  meta = {
    description = "Low-level library for installing a Python package from a wheel distribution";
    homepage = "https://github.com/pypa/installer";
    changelog = "https://github.com/pypa/installer/blob/${src.rev}/docs/changelog.md";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.cpcloud ];
    teams = [ lib.teams.python ];
  };
}
