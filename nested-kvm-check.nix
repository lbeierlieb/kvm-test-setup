{
  runNixOSTest,
  nixosSystem,
  stdenv,
}:
let
  nested-guest = nixosSystem {
    inherit (stdenv.hostPlatform) system;
    modules = [
      ({ config, ... }: {
        networking.hostName = "nested-guest";
        system.stateVersion = config.system.nixos.release;
        virtualisation.vmVariant.virtualisation = {
          graphics = false;
          forwardPorts = [
            {
              from = "host";
              host.port = 2222;
              guest.port = 22;
            }
          ];
        };
        services.openssh = {
          enable = true;
          settings = {
            PermitRootLogin = "yes";
            PermitEmptyPasswords = "yes";
          };
        };
        users.users.root.password = "";
        security.pam.services.sshd.allowNullPassword = true;
      })
    ];
  };
in
runNixOSTest {
  name = "nested-kvm";
  nodes.machine = {
    systemd.services.nested-guest = {
      wantedBy = [ "multi-user.target" ];
      serviceConfig.ExecStart = ''
        ${nested-guest.config.system.build.vm}/bin/run-nested-guest-vm
      '';
    };
    virtualisation = {
      cores = 4;
      memorySize = 4096;
    };
  };

  testScript = ''
    machine.wait_for_unit("nested-guest.service")
  '';
}
