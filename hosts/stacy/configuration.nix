{inputs, pkgs, config, ...}: {
  imports = [
    ./hardware-configuration.nix
    ../../users/taylor.nix
    #../common/services
    #../common/zram.nix
    #../common/services/server_stuff.nix
    ../common
  ];

  # networking
  networking = {
    hostName = "stacy";
    networkmanager.enable = true;
    firewall = {
      enable = true;
      allowedTCPPorts = [];
      allowedUDPPorts = [];
    };
  };

  #drives
  fileSystems."/drives/wolfy" = {
    device = "/dev/md0";
    fsType = "ext4";
    options = [
      # boot options for fstab
      "users" # Allows any user to mount and unmount
      "nofail" # Prevent system from failing if this drive doesn't mount 
    ];
  };

  # filesystems, disks, and bootloading
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
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
    users.taylor = import ../../home/taylor/stacy;
  };

  environment = {
    sessionVariables = {
      FLAKE = "/home/taylor/nyx-config";
    };
  };

  system.stateVersion = "23.11";
environment.systemPackages = [
  pkgs.neofetch
  pkgs.mdadm
  pkgs.btop
  pkgs.static-web-server
  pkgs.wget
  # minecraft 
  pkgs.jdk21_headless
  pkgs.minecraft-server
  # jellyfin
  pkgs.jellyfin
  pkgs.jellyfin-web
  pkgs.jellyfin-ffmpeg
];
services.openssh = {
  enable = true;
  settings.PasswordAuthentication = false;
  settings.KbdInteractiveAuthentication = false;
  openFirewall = true;
};

services.grafana = {
  enable = true;
  settings = {
    server = {
      # Listening Address
      http_addr = "100.93.121.109";
      # and Port
      http_port = 80;
      # Grafana needs to know on which domain and URL it's running
      domain = "stacy.baameows.gay";
      root_url = "http://stacy.baameows.gay/grafana/"; # Not needed if it is `https://your.domain/`
      serve_from_sub_path = true;
    };
  };
};

# hosts/chrysalis/configuration.nix
services.prometheus = {
  enable = true;
  port = 9090;
  exporters = {
    node = {
      enable = true;
      enabledCollectors = [ "systemd" ];
      port = 9091;
    };
    smartctl = { 
      enable = true; 
      port = 9092;
    };
  };
  scrapeConfigs = [
    {
      job_name = "stacy";
      static_configs = [{
        targets = [ "127.0.0.1:9091" "127.0.0.1:9092" ];
      }];
    }
  ];
};

# loki: port 3030 (8030)
services.loki = {
  enable = true;
  configuration = {
    server.http_listen_port = 3030;
    auth_enabled = false;

    ingester = {
      lifecycler = {
        address = "127.0.0.1";
        ring = {
          kvstore = {
            store = "inmemory";
          };
          replication_factor = 1;
        };
      };
      chunk_idle_period = "1h";
      max_chunk_age = "1h";
      chunk_target_size = 999999;
      chunk_retain_period = "30s";
      max_transfer_retries = 0;
    };

    schema_config = {
      configs = [{
        from = "2022-06-06";
        store = "boltdb-shipper";
        object_store = "filesystem";
        schema = "v11";
        index = {
          prefix = "index_";
          period = "24h";
        };
      }];
    };

    storage_config = {
      boltdb_shipper = {
        active_index_directory = "/var/lib/loki/boltdb-shipper-active";
        cache_location = "/var/lib/loki/boltdb-shipper-cache";
        cache_ttl = "24h";
        shared_store = "filesystem";
      };

      filesystem = {
        directory = "/var/lib/loki/chunks";
      };
    };

    limits_config = {
      reject_old_samples = true;
      reject_old_samples_max_age = "168h";
    };

    chunk_store_config = {
      max_look_back_period = "0s";
    };

    table_manager = {
      retention_deletes_enabled = false;
      retention_period = "0s";
    };

    compactor = {
      working_directory = "/var/lib/loki";
      shared_store = "filesystem";
      compactor_ring = {
        kvstore = {
          store = "inmemory";
        };
      };
    };
  };
  # user, group, dataDir, extraFlags, (configFile)
};

# promtail: port 3031 (8031)
services.promtail = {
  enable = true;
  configuration = {
    server = {
      http_listen_port = 3031;
      grpc_listen_port = 0;
    };
    positions = {
      filename = "/tmp/positions.yaml";
    };
    clients = [{
      url = "http://127.0.0.1:${toString config.services.loki.configuration.server.http_listen_port}/loki/api/v1/push";
    }];
    scrape_configs = [{
      job_name = "journal";
      journal = {
        max_age = "12h";
        labels = {
          job = "systemd-journal";
          host = "pihole";
        };
      };
      relabel_configs = [{
        source_labels = [ "__journal__systemd_unit" ];
        target_label = "unit";
      }];
    }];
  };
  # extraFlags
};

# static web server for filedrop
services.static-web-server = {
  enable = true;
  listen = "[::]:420";
  root = "/drives/wolfy/filedrop";
  configuration = {
    general = { directory-listing = true; };
  };
};

# jellyfin
services.jellyfin = {
    enable = true;
    openFirewall = true;
};

# minecraft
systemd.services.baacraft = {
   description = "Minecraft Server :3";
   serviceConfig = {   ExecStart = "java /home/taylor/minecraft/user_jvm_args.txt /home/taylor/minecraft/libraries/net/neoforged/forge/1.20.1-47.1.106/unix_args.txt";   };
   wantedBy = ["multi-user.target"];
};
systemd.services.baacraft.enable = false;

# slslk
#services.slskd.enable = true;
#services.slskd.nginx.enable = true;
#security.acme.acceptTerms = true; # i should krill myself
#services.slskd.nginx.domainName = "slskd";
#services.slskd.settings.web.port = 512;

# samba
services.samba = {
  enable = true;
  securityType = "user";
  openFirewall = true;
  settings = ''
    guest account = guest
    map to guest = bad user
    server string = stacy
    netbios name = stacy
    workgroup = WORKGROUP
  '';
  shares = {
    filedrop = {
      path = "/drives/wolfy/filedrop/filedrop";
      browseable = "yes";
      "guest ok" = "yes";
      "read only" = "no";
      "create mask" = "0644";
      "directory mask" = "0755";
    };
    public = {
      path = "/drives/wolfy/public";
      browseable = "yes";
      "guest ok" = "yes";
      "read only" = "yes";
    };
    stacy = {
      path = "/";
      browsable = "yes";
      "guest ok" = "no";
      "read only" = "no";
      "valid users" = "taylor";
    };
    wolfy = {
      path = "/drives/wolfy/";
      browsable = "yes";
      "guest ok" = "no";
      "read only" = "no";
      "valid users" = "taylor";
    };
  };
};
services.samba-wsdd = {
  enable = true;
  openFirewall = true;
};

#so smart !!!
services.smartd = {
  enable = true;
  devices = [{device = "/dev/disk/by-id/wwn-0x5000c5007445717f";}];
};

# pog :3
systemd.services.assemble_raid = {
    wantedBy=["multi-user.target"];
    after=["dev-mqueue.mount"];
    description="assembles the RAID1 array :3";
    unitConfig.ConditionPathExists="!/dev/md0"; # only run if the array isn't already assembled
    serviceConfig = {
        Type="oneshot";
        User="root";
        ExecStart="/run/current-system/sw/bin/mdadm --assemble --force /dev/md0 /dev/disk/by-id/wwn-0x5000c5007445717f";
    };
};

programs.bash.loginShellInit = ''
  clear
  neofetch --source /home/taylor/ascii 
'';

programs.bash.shellAliases = { 
  neofetch = "neofetch --source /home/taylor/ascii";
  config = "sudo nvim /etc/nixos/configuration.nix";
  rebuild = "nh os switch";
};
}
