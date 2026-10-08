{
  description = "nested-nixos-test: A helper function to build nested nixos integration tests";

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
      packages = forAllSystems (pkgs: {
        linux-vmi = pkgs.callPackage ./custom-kernel.nix {
          linux = pkgs.linuxKernel.kernels.linux_7_2;
        };
        nested-nixos-test = pkgs.callPackage ./nested-nixos-test.nix {
          inherit (pkgs.testers) runNixOSTest;
          inherit (nixpkgs.lib) nixosSystem;
        };
      });
      checks = forAllSystems (
        pkgs:
        let
          inherit (pkgs.stdenv.hostPlatform) system;
        in
        {
          smoke-test = pkgs.callPackage ./smoke-test.nix {
            nested-nixos-test = self.packages.${system}.nested-nixos-test;
          };
        }
      );
    };
}
