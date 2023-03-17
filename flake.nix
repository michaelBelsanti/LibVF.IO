{
  description = "libvfio flake";

  inputs = {
    nvidia-vgpu.url = "github:danielfullmer/nixos-nvidia-vgpu";
    nimble.url = "github:nix-community/flake-nimble";
    flake-parts.url = "github:hercules-ci/flake-parts";
    nimble2nix.url = "github:bandithedoge/nimble2nix";
  };

  outputs = inputs@{flake-parts, nixpkgs, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "x86_64-linux"
      ];
      perSystem = { config, self', inputs', pkgs, system, ... }: {
        _module.args.pkgs = import nixpkgs {
          inherit system;
          overlays = [inputs.nimble2nix.overlay];
        };
        packages.default = pkgs.buildNimblePackage {
          pname = "arcd";
          version = "0.1";
          src = ./.;
        };
      };
    };
}