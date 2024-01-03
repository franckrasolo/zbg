{
  description = "Nix flake for zbg";

  inputs = {
    opam-repository = {
      url = "github:ocaml/opam-repository";
      flake = false;
    };

    opam-nix = {
      url = "github:tweag/opam-nix";
      inputs.opam-repository.follows = "opam-repository";
    };

    flake-utils.url = "github:numtide/flake-utils";
    # nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs.follows = "opam-nix/nixpkgs";
  };

  outputs = { self, nixpkgs, flake-utils, opam-nix, opam-repository }@inputs:
    let
      package = "zbg";
    in
      flake-utils.lib.eachDefaultSystem (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          on = opam-nix.lib.${system};

          devPackagesQuery = {
            # development packages added her will be automatically added to devShell

            # ocaml-lsp-server = "*";
            # ocamlformat = "*";
            # ocp-indent = "*";
            # merlin = "*";
          };

          query = devPackagesQuery // {
            ocaml-base-compiler = "*";
          };

          scope = on.buildDuneProject { } package ./. query;
          overlay = final: prev: {
            # opam = prev.opam.overrideAttrs (_: { withFakeOpam = false; });

            ${package} = prev.${package}.overrideAttrs (_: {
              # prevent ocaml dependencies from leaking into dependent environments
              doNixSupport = false;
              withFakeOpam = false;
            });
          };

          scope' = scope.overrideScope' overlay;

          # main package containing the executable
          main = scope'.${package};

          # packages from devPackagesQuery
          devPackages = builtins.attrValues
            (pkgs.lib.getAttrs (builtins.attrNames devPackagesQuery) scope');
        in {
          legacyPackages = scope';
 
          packages.default = main;

          devShells.default = pkgs.mkShell rec {
            inputsFrom = [ main ];

            buildInputs = devPackages ++ [
              # additional packages from nixpkgs
            ];
          };
        }
      );
}
