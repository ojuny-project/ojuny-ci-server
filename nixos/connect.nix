/* @menu
   displayname = "Nix-connect";
   icon = "network-wired-symbolic";
   order = 55;
   description = "LAN device management and trust";
*/

{ config, lib, ... }:

{
  options.ci.connect = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Run the nix-connect daemon on this host.";
    };

    infoPort = lib.mkOption {
      type = lib.types.port;
      default = 5060;
      description = "Public, signed device information port.";
    };

    controlPort = lib.mkOption {
      type = lib.types.port;
      default = 5061;
      description = "mTLS control port for paired devices.";
    };

    openFirewall = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Open the information and control ports on the LAN.";
    };

    discovery = {
      auto = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Use the connected subnet for discovery.";
      };

      ranges = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
        description = "Explicit discovery ranges when automatic mode is off.";
      };

      interval = lib.mkOption {
        type = lib.types.ints.positive;
        default = 60;
        description = "Seconds between discovery scans.";
      };
    };
  };

  config = {
    /* @option widget = "switch"; label = "Enable nix-connect"; group = "Nix-connect"; */
    ci.connect.enable = true;

    /* @option widget = "spin"; label = "Information port"; group = "Nix-connect"; min = 1; max = 65535; visibleWhen.path = "ci.connect.enable"; visibleWhen.equals = true; */
    ci.connect.infoPort = 5060;

    /* @option widget = "spin"; label = "Control port"; group = "Nix-connect"; min = 1; max = 65535; visibleWhen.path = "ci.connect.enable"; visibleWhen.equals = true; */
    ci.connect.controlPort = 5061;

    /* @option widget = "switch"; label = "Open firewall"; group = "Nix-connect"; visibleWhen.path = "ci.connect.enable"; visibleWhen.equals = true; */
    ci.connect.openFirewall = true;

    /* @option widget = "switch"; label = "Automatic discovery"; group = "Discovery"; visibleWhen.path = "ci.connect.enable"; visibleWhen.equals = true; */
    ci.connect.discovery.auto = true;

    /* @option widget = "list"; label = "Discovery ranges"; itemLabel = "CIDR"; addLabel = "Add range"; group = "Discovery"; visibleWhen.path = "ci.connect.discovery.auto"; visibleWhen.equals = false; */
    ci.connect.discovery.ranges = [ ];

    /* @option widget = "spin"; label = "Discovery interval"; group = "Discovery"; min = 1; max = 3600; unit = "s"; visibleWhen.path = "ci.connect.enable"; visibleWhen.equals = true; */
    ci.connect.discovery.interval = 60;

    services.nix-connect = {
      enable = config.ci.connect.enable;
      initialAccount = config.ci.adminUser;
      infoPort = config.ci.connect.infoPort;
      controlPort = config.ci.connect.controlPort;
      openFirewall = config.ci.connect.openFirewall;
      discovery = {
        auto = config.ci.connect.discovery.auto;
        ranges = config.ci.connect.discovery.ranges;
        interval = config.ci.connect.discovery.interval;
      };
    };
  };
}
