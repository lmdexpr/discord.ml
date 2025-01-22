{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs = { flake-utils, nixpkgs, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

        ocamlPackages = pkgs.ocaml-ng.ocamlPackages_5_3;

        dependencies = with ocamlPackages; [
          yojson
          ppx_yojson_conv
          logs
          hex
        ];

        localPackages = rec {
          sodium = ocamlPackages.buildDunePackage {
            pname = "sodium";
            version = "dev";
            src = pkgs.fetchFromGitHub {
              owner  = "ahrefs";
              repo   = "ocaml-sodium";
              rev    = "734eccbb47e7545a459a504188f1da8dc0bd018e";
              sha256 = "sha256-anm9sM7xeRdxdwPDpHsKb93Bck6qUWNrw9yEnIPH1n0=";
            };
            buildInputs = [
              pkgs.libsodium
              ocamlPackages.dune-configurator
            ];
            nativeBuildInputs = [ 
              pkgs.pkg-config
            ];
            propagatedBuildInputs = with ocamlPackages; [
              base
              ctypes
            ];
          };

          discord = ocamlPackages.buildDunePackage {
            pname = "discord";
            version = "0.1.0";
            src = ./.;
            buildInputs = [ sodium ] ++ dependencies;
          };
        };

        devPackages = with pkgs.ocamlPackages; [
          ocaml-lsp
          ocamlformat
        ];
      in
      {
        legacyPackages = localPackages;
        packages = {
          default = localPackages.discord;
        };

        devShells.default =
          pkgs.mkShell {
            inputsFrom  = builtins.attrValues localPackages;
            buildInputs = with pkgs; [ 
              nil nixpkgs-fmt 
            ] ++ devPackages
              ++ builtins.attrValues localPackages;
          };
      });
}
