{
  config,
  pkgs,
  ...
}: {
  imports = [
    ./global
    ./features/games/gaming.nix
    ./features/vr
  ];
  programs.alacritty.enable = true;
}
