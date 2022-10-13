{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    bionix.url = "github:papenfusslab/bionix";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    self,
    nixpkgs,
    bionix,
    flake-utils,
  }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = import nixpkgs {
        inherit system;
        config.rPackageOverrides = self:
          with self; {
            edgeR = (import nixpkgs {inherit system;}).rPackages.edgeR.overrideAttrs (attrs: {
              buildInputs = attrs.buildInputs ++ lib.optional stdenv.isDarwin libiconv;
            });
          };
      };
      bionix' = import bionix {nixpkgs = pkgs;};
    in {
      defaultPackage = bionix'.callBionix ./. {};
      packages.solution = bionix'.callBionix ./solution.nix {};
    });
}
