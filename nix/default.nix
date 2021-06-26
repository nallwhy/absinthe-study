let
  elixir = import ./elixir.nix;
  other = import ./other.nix;
in elixir ++ other
