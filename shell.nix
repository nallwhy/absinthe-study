let nixpkgs = import ./nix/nixpkgs.nix;
in nixpkgs.mkShell { buildInputs = import ./nix/default.nix; }
