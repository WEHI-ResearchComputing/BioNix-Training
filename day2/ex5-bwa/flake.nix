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
      pkgs = import nixpkgs {inherit system;};
      bionix' = import bionix {nixpkgs = pkgs;};
    in {
      defaultPackage = bionix'.callBionix ./. {};
    });
}
