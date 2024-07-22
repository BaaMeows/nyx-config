{
  lib,
  pkgs,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    ./disko-config.nix
    ../common/desktop/niri
    ../common/desktop
    ../common
  ];

  # networking
  networking = {
    hostName = "muon";
    networkmanager.enable = true;
    firewall.enable = true;
  };

  # filesystems, disks, and bootloading
  boot.loader.grub = {
    enable = true;
    efiSupport = true;
    efiInstallAsRemovable = true;
  };

  # services and background things
  services = {
    # needed for wayland
    xserver = {
      enable = true;
    };
    displayManager = {
      autoLogin.enable = false;
      autoLogin.user = "nyx"; # login things
      sddm = {
        enable = true;
        wayland.enable = true;
        sugarCandyNix = {
          enable = true; # set SDDM's theme to "sddm-sugar-candy-nix".
          settings = {
            Background = lib.cleanSource ../common/theme/backgrounds/background.png;
            ScreenWidth = 1920;
            ScreenHeight = 1080;
            FormPosition = "left";
            HaveFormBackground = true;
            PartialBlur = true;
          };
        };
      };
    };

    # sound stuff
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = true;
    };
  };

  # TODO move to seporate nix file (module?)
  users.users.nyx = {
    isNormalUser = true;
    extraGroups = ["networkmanager" "wheel"];
    hashedPassword = "$y$j9T$d2moNWhXMPaPXQQlBS9J7/$uQKwf.Y0xRKzbaOZCFybnrUeqB3HAnUiuzL17wA7/P3";
  };

  environment = {
    systemPackages = with pkgs; [
      rio
      fuzzel
    ];
    sessionVariables = {
      FLAKE = "/home/nyx/nyx-config";
    };
  };

  system.stateVersion = "24.05";
}
