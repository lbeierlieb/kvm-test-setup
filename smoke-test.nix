{
  nested-nixos-test,
}:
nested-nixos-test {
  name = "nested-nixos-test smoke-test";
  test-script = ''
    (status, out) = nested_guest_execute("uname -a")
    print(out)
    nested_guest_succeed("whoami | grep root")
  '';
}
