{
  imports = [
    ../../users/taylor.nix
    ../common
  ];

  # networking
  networking = {
    hostName = "strange";
    networkmanager.enable = true;
    # firewall.enable = true;
    dhcpcd.enable = false;
  };

  # services and background things
  services = {
    xserver = {
      enable = false;
    };
  };

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.taylor = import ../../home/taylor/strange;
  };

  environment = {
    sessionVariables = {
      FLAKE = "/home/taylor/nyx-config";
    };
  };

  system.stateVersion = "24.05";
}
