{
  nested-nixos-test,
}:
nested-nixos-test {
  name = "nested-kvm";
  test-script = ''
    (status, out) = nested_guest_execute("uname -a")
    print(out)
    nested_guest_succeed("uname -a | grep 6.18.54")
    nested_guest_succeed("whoami | grep root")
  '';
}
