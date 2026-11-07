/* @menu
   displayname = "Cache";
   icon = "folder-download-symbolic";
   order = 50;
   description = "LAN binary cache and peer discovery";
*/

{ config, lib, ... }:

{
  options.ci.cache = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Run nix-cache-discovery on this host.";
    };

    port = lib.mkOption {
      type = lib.types.port;
      default = 5055;
      description = "Cache and discovery port.";
    };

    openFirewall = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Open the cache port to the discovered or configured private ranges.";
    };

    discovery = {
      auto = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Use the connected subnet for discovery and the client allowlist.";
      };

      ranges = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
        description = "Explicit discovery ranges when auto mode is off.";
      };

      interval = lib.mkOption {
        type = lib.types.ints.positive;
        default = 60;
        description = "Seconds between discovery scans.";
      };
    };
  };

  config = {
    /* @option widget = "switch"; label = "Enable cache"; group = "Cache"; */
    ci.cache.enable = true;

    /* @option widget = "spin"; label = "Port"; group = "Cache"; min = 1; max = 65535; */
    ci.cache.port = 5055;

    /* @option widget = "switch"; label = "Open firewall"; group = "Cache"; */
    ci.cache.openFirewall = true;

    /* @option widget = "switch"; label = "Automatic discovery"; group = "Discovery"; */
    ci.cache.discovery.auto = true;

    /* @option widget = "list"; label = "Discovery ranges"; itemLabel = "CIDR"; addLabel = "Add range"; group = "Discovery"; visibleWhen.path = "ci.cache.discovery.auto"; visibleWhen.equals = false; */
    ci.cache.discovery.ranges = [ ];

    /* @option widget = "spin"; label = "Discovery interval"; group = "Discovery"; min = 1; max = 3600; unit = "s"; */
    ci.cache.discovery.interval = 60;

    services.nix-cache-discovery = {
      enable = config.ci.cache.enable;
      port = config.ci.cache.port;
      openFirewall = config.ci.cache.openFirewall;
      exclusive = true;
      priority = 30;
      fallbackSubstituters = [ "https://cache.nixos.org" ];
      verifyFallbackSignatures = true;
      discovery = {
        auto = config.ci.cache.discovery.auto;
        ranges = config.ci.cache.discovery.ranges;
        interval = config.ci.cache.discovery.interval;
      };
    };
  };
}
