{
  pkgs,
  config,
  inputs,
  ...
}: {
  # nix.settings = {
  #   # add binary caches
  #   trusted-public-keys = [
  #     "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
  #     "nixpkgs-wayland.cachix.org-1:3lwxaILxMRkVhehr5StQprHdEo4IrE8sRho9R9HOLYA="
  #   ];
  #   substituters = [
  #     "https://cache.nixos.org"
  #     "https://nixpkgs-wayland.cachix.org"
  #   ];
  # };

  # use it as an overlay
  # nixpkgs.overlays = [inputs.nixpkgs-wayland.overlay];

  programs.sway = {
    enable = true;
  };
}