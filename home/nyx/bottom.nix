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

  home = {
    stateVersion = "24.05";
    # Packages that should be installed to the user profile.
    packages = with pkgs; [
      # here is some command line tools I use frequently
      # feel free to add your own or remove some of them

      nnn # terminal file manager

      # archives
      zip
      xz
      unzip
      #p7zip

      # utils
      #ripgrep # recursively searches directories for a regex pattern
      #jq # A lightweight and flexible command-line JSON processor
      #yq-go # yaml processor https://github.com/mikefarah/yq
      #eza # A modern replacement for ‘ls’
      fzf # A command-line fuzzy finder

      # networking tools
      #mtr # A network diagnostic tool
      #iperf3
      #dnsutils  # `dig` + `nslookup`
      #ldns # replacement of `dig`, it provide the command `drill`
      #aria2 # A lightweight multi-protocol & multi-source command-line download utility
      #socat # replacement of openbsd-netcat
      nmap # A utility for network discovery and security auditing
      #ipcalc  # it is a calculator for the IPv4/v6 addresses

      # misc
      #cowsay
      #file
      #which
      tree
      #gnused
      #gnutar
      #gawk
      #zstd
      #gnupg

      # nix related
      #
      # it provides the command `nom` works just like `nix`
      # with more details log output
      # productivity

      #hugo # static site generator
      #glow # markdown previewer in terminal

      # keyboard tools
      zmkBATx

      # desktop notifications
      libnotify
      mako

      btop # replacement of htop/nmon
      iotop # io monitoring
      iftop # network monitoring
      nvtopPackages.full # gpu monitoring
      bottom # cpu monitoring
      vulkan-tools
      wayland-utils
      corectrl
      pavucontrol

      # system call monitoring
      strace # system call monitoring
      ltrace # library call monitoring
      #lsof # list open files

      # system tools
      sysstat
      #lm_sensors # for `sensors` command
      ethtool
      #pciutils # lspci
      #usbutils # lsusb
    ];
  };
  programs.alacritty = {
    enable = true;
    # custom settings
    settings = {
      env.TERM = "xterm-256color";
      font = {
        size = 12;
      };
      scrolling.multiplier = 5;
      selection.save_to_clipboard = true;
    };
  };

  programs.git = {
    enable = true;
    userName = "Nyxerproject";
    userEmail = "nxyerproject@gmail.com";
  };
}
