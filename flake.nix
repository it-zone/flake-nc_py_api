{
  description = "nc_py_api — Nextcloud Python Framework, packaged as a standalone flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs =
    { self, nixpkgs }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];

      forAllSystems = nixpkgs.lib.genAttrs systems;

      pkgsFor =
        system:
        import nixpkgs {
          inherit system;
          overlays = [ self.overlays.default ];
        };
    in
    {
      # Overlay adding `pkgs.python3Packages.nc_py_api` (and the pinned
      # dependencies it needs) to any nixpkgs instance.
      overlays.default = import ./overlay.nix;

      packages = forAllSystems (
        system:
        let
          pkgs = pkgsFor system;
        in
        {
          inherit (pkgs.python3Packages) nc_py_api;

          default = pkgs.python3Packages.nc_py_api;
        }
      );

      # Full package set with the overlay applied.
      legacyPackages = forAllSystems (system: pkgsFor system);

      checks = forAllSystems (
        system:
        let
          pkgs = pkgsFor system;
        in
        {
          nc_py_api = pkgs.python3Packages.nc_py_api;
        }
      );

      devShells = forAllSystems (
        system:
        let
          pkgs = pkgsFor system;
        in
        {
          default = pkgs.mkShell {
            packages = [ pkgs.python3Packages.nc_py_api ];
          };
        }
      );

      formatter = forAllSystems (system: (pkgsFor system).nixpkgs-fmt);
    };
}
