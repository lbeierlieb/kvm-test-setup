{
  runNixOSTest,
  nixosSystem,
  stdenv,
}:
{
  name,
  machine ? { },
  nested-machine ? { },
  test-script ? "",
}:
let
  nested-guest = nixosSystem {
    inherit (stdenv.hostPlatform) system;
    modules = [
      nested-machine
      ({ config, ... }: {
        networking.hostName = "nested-machine";
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
  inherit name;
  nodes.machine = {
    imports = [ machine ];

    systemd.services.nested-guest = {
      wantedBy = [ "multi-user.target" ];
      serviceConfig.ExecStart = ''
        ${nested-guest.config.system.build.vm}/bin/run-nested-machine-vm
      '';
    };
    virtualisation = {
      cores = 4;
      memorySize = 4096;
    };
  };
  testScript = ''
    import datetime

    def nested_guest_execute(command):
       return machine.execute( "ssh -q -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no root@localhost -p 2222 '" + command + "'")

    def nested_guest_succeed(command):
       return machine.succeed( "ssh -q -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no root@localhost -p 2222 '" + command + "'", timeout=datetime.timedelta(seconds = 30))

    def wait_for_nested_guest(timeout_sec):
      start_time = datetime.datetime.now()
      print("Waiting for nested SSH port to become available")
      while True:
        (status, out) = machine.execute( "ssh -q -o ConnectTimeout=1 -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no root@localhost -p 2222 'echo hi'")
        if status == 0:
          return
        if (datetime.datetime.now() - start_time).total_seconds() > timeout_sec:
          raise Exception(f"timeout: nested-SSH port did not open after {timeout_sec} seconds")

    machine.wait_for_unit("nested-guest.service")
    wait_for_nested_guest(60)

    ${test-script}
  '';
}
