{
  description = "Reimagined language server for Elixir";

  inputs.nixpkgs.url = "flake:nixpkgs";
  inputs.flake-parts.url = "github:hercules-ci/flake-parts";
  inputs.systems.url = "github:nix-systems/default";

  outputs = {
    self,
    systems,
    ...
  } @ inputs:
    inputs.flake-parts.lib.mkFlake {inherit inputs;} {
      flake = {
        lib = {
          mkExpert = {erlang}: erlang.callPackage ./nix/expert.nix {};
        };
      };

      systems = import systems;

      perSystem = {pkgs, ...}: let
        erlang = pkgs.beam.packages.erlang_25;
        expert = self.lib.mkExpert {inherit erlang;};
      in {
        formatter = pkgs.alejandra;

        apps.update-hash = let
          script = pkgs.writeShellApplication {
            name = "update-hash";

            runtimeInputs = [pkgs.nixFlakes pkgs.gawk];

            text = ''
              nix --extra-experimental-features 'nix-command flakes' \
                build --no-link "${self}#__fodHashGen" 2>&1 | gawk '/got:/ { print $2 }' || true
            '';
          };
        in {
          type = "app";
          program = "${script}/bin/update-hash";
        };

        packages = {
          inherit expert;
          default = expert;

          __fodHashGen = expert.mixFodDeps.overrideAttrs (final: curr: {
            outputHash = pkgs.lib.fakeSha256;
          });
        };

        devShells.default = pkgs.mkShell {
          packages = let
            beamPackages = pkgs.beam.packages;
          in
            [
              beamPackages.erlang_27.erlang
              beamPackages.erlang_27.elixir_1_17
            ]
            ++ pkgs.lib.optionals pkgs.stdenv.isDarwin [
              pkgs.darwin.apple_sdk.frameworks.CoreFoundation
              pkgs.darwin.apple_sdk.frameworks.CoreServices
            ];
        };
      };
    };
}
