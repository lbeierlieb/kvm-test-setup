{
  description = "Example how to test KVM inside a NixOS integration test";

  inputs = {
    nixpkgs.url = "https://channels.nixos.org/nixpkgs-unstable/nixexprs.tar.zst";
  };

  outputs =
    {
      self,
      nixpkgs,
      ...
    }:
    let
      systems = nixpkgs.lib.systems.flakeExposed;
      forAllSystems =
        function: nixpkgs.lib.genAttrs systems (system: function nixpkgs.legacyPackages.${system});
    in
    {
      checks = forAllSystems (pkgs: {
        nested-kvm = pkgs.callPackage ./nested-kvm-check.nix {
          inherit (pkgs.testers) runNixOSTest;
          inherit (nixpkgs.lib) nixosSystem;
        };
      });
    };
}
