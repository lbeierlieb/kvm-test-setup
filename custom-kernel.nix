{
  linux,
  fetchFromGitHub,
}:
linux.override (old: {
  argsOverride = {
    version = "7.0.13";
    modDirVersion = "7.0.13";
    src = fetchFromGitHub {
      owner = "vmi-rs";
      repo = "linux";
      rev = "510a3b5a45632630e80df142220954353b2fe59a";
      hash = "sha256-+Z1T9Cpv8dpsWLyCNbT9kIpu4gZPvJpMIk++xmAe/tY=";
    };
  };
})
