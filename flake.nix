{
  description = "Expert LSP for Elixir";

  inputs = {
    beam-flakes = {
      url = "github:mhanberg/nix-beam-flakes";
      inputs.flake-parts.follows = "flake-parts";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  outputs = inputs @ {
    beam-flakes,
    flake-parts,
    ...
  }:
    flake-parts.lib.mkFlake {inherit inputs;} {
      imports = [beam-flakes.flakeModule];

      systems = ["aarch64-darwin" "x86_64-darwin" "x86_64-linux"];

      perSystem = {pkgs, ...}: let
        alias_7zz = pkgs.symlinkJoin {
          name = "7zz-aliased";
          paths = [pkgs._7zz];
          postBuild = ''
            ln -s ${pkgs._7zz}/bin/7zz $out/bin/7z
          '';
        };
      in {
        beamWorkspace = {
          enable = true;
          devShell = {
            packages = with pkgs; [
              zig
              alias_7zz
              just
            ];
            languageServers.elixir = false;
            languageServers.erlang = false;
          };
          versions = {fromToolVersions = ./.tool-versions;};
        };
      };
    };
}
