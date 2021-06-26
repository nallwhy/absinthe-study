let
  nixpkgs = import ./nixpkgs.nix;
  platform = if nixpkgs.stdenv.isDarwin then [
    nixpkgs.darwin.apple_sdk.frameworks.CoreServices
    nixpkgs.darwin.apple_sdk.frameworks.Foundation
  ] else if nixpkgs.stdenv.isLinux then
    [ nixpkgs.inotify-tools ]
  else
    [ ];
in [ ] ++ platform
