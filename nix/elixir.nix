let
  # Because this files is hashed into CI cache,
  # it should fetch nixpkgs by its own even if it's same version with nixpkgs.nix.
  nixpkgs = import (fetchTarball {
    url =
      "https://github.com/trevorite/nixpkgs/archive/v1.12.1-setup-hook.tar.gz";
    sha256 = "sha256:1h15r1wps8bqz9a2b3mxiyyj60cdjkvsvy9pw1adfx77d6dvghly";
  }) { };
in [ nixpkgs.elixir nixpkgs.erlang ]
