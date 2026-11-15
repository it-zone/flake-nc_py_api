{
  lib,
  buildPythonPackage,
  fetchPypi,

  # runtime
  editables,
  packaging,
  pathspec,
  pluggy,
  tomlkit,
  trove-classifiers,
}:

buildPythonPackage (finalAttrs: {
  pname = "hatchling";
  version = "1.33.0";
  pyproject = true;

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-TEIr1NVU/P9d5bc+lZb4XkHp+X9+VT2PdZXssxpie+8=";
  };

  # listed in backend/pyproject.toml
  dependencies = [
    editables
    packaging
    pathspec
    pluggy
    tomlkit
    trove-classifiers
  ];

  pythonImportsCheck = [
    "hatchling"
    "hatchling.build"
  ];

  # tries to fetch packages from the internet
  doCheck = false;

  meta = {
    description = "Modern, extensible Python build backend";
    mainProgram = "hatchling";
    homepage = "https://github.com/pypa/hatch/releases/tag/hatchling-v${finalAttrs.version}";
    changelog = "https://github.com/pypa/hatch/releases/tag/hatchling-v${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [
      hexa
      ofek
    ];
  };
})
