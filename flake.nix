{
  description = "libvfio flake";

  inputs = {
    utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
  };

  outputs = inputs@{ self, nixpkgs, utils, ... }:
    let
      # put devShell and any other required packages into local overlay
      localOverlay = import ./nix/overlay.nix;

      # if you have additional overlays from other flakes, you may add them here
      allOverlays = [
        localOverlay # this should expose devShell
      ];

      pkgsForSystem = system: import nixpkgs {
        overlays = allOverlays;
        inherit system;
      };
    # https://github.com/numtide/flake-utils#usage for more examples
    in utils.lib.eachSystem [ "x86_64-linux" ] (system: rec {
      legacyPackages = pkgsForSystem system;
      packages = utils.lib.flattenTree {
        inherit (legacyPackages) devShell libvfio;
      };
      defaultPackage = packages.libvf.io;
      apps.libvf.io = utils.lib.mkApp { drv = packages.libvf.io; };  # use as `nix run .#libvf.io`
      hydraJobs = { inherit (legacyPackages) libvfio; };
      checks = { inherit (legacyPackages) libvfio; };              # items to be ran as part of `nix flake check`
  }) // {
    # non-system suffixed items should go here
    overlays = {
      default = localOverlay;
    };
    nixosModules.default = import ./nix/module.nix inputs; # attr set or list
    nixosConfigurations.hostname = { config, pkgs, ... }: {};
  };
}