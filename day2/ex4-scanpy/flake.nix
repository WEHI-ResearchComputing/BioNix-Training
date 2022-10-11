{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/release-21.11";
    bionix.url = "github:papenfusslab/bionix";
    flake-utils.url = "github:numtide/flake-utils";

    mach-nix = {
      url = "mach-nix/3.5.0";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-utils.follows = "flake-utils";
        pypi-deps-db.follows = "pypi-deps-db";
      };
    };

    pypi-deps-db = {
      url = "github:DavHau/pypi-deps-db";
      flake = false;
    };
  };

  outputs = {
    self,
    nixpkgs,
    bionix,
    flake-utils,
    mach-nix,
    ...
  }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = import nixpkgs {
        inherit system;
      };
      bionix' = import bionix {nixpkgs = pkgs;};
    in {
      defaultPackage = bionix'.callBionix ./. {mach-nix = mach-nix.lib."${system}";};
      packages.solution = bionix'.callBionix ./solution.nix {mach-nix = mach-nix.lib."${system}";};
    });
}
