{
  nested-nixos-test,
}:
nested-nixos-test {
  name = "nested-nixos-test smoke-test";
  nested-machine = {
    virtualisation.vmVariant.virtualisation.qemu.forceAccel = true;
  };
  test-script = ''
    (status, out) = nested_guest_execute("uname -a")
    print(out)
    nested_guest_succeed("whoami | grep root")
  '';
}
