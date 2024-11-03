{
  services.tailscale = {
    enable = true;
    interfaceName = "tailnet";
    #useRoutingFeatures = "client";
    #extraUpFlags = ["--exit-node=100.70.74.122"];
  };
}
