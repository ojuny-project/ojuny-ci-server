/* @menu
   displayname = "Network";
   icon = "network-wired-symbolic";
   order = 20;
   description = "Server addressing and interface";
*/

{ config, lib, ... }:

{
  options.ci.network = {
    mode = lib.mkOption {
      type = lib.types.enum [
        "dhcp"
        "static"
      ];
      default = "dhcp";
      description = "Addressing mode.";
    };

    interface = lib.mkOption {
      type = lib.types.str;
      default = "eth0";
      description = "Primary network interface name.";
    };

    address = lib.mkOption {
      type = lib.types.str;
      default = "192.168.1.10";
      description = "Static IPv4 address.";
    };

    prefixLength = lib.mkOption {
      type = lib.types.int;
      default = 24;
      description = "Static IPv4 prefix length.";
    };

    gateway = lib.mkOption {
      type = lib.types.str;
      default = "192.168.1.1";
      description = "Static default gateway.";
    };

    dns = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [
        "1.1.1.1"
        "8.8.8.8"
      ];
      description = "Static DNS servers.";
    };
  };

  config = {
    /* @option widget = "dropdown"; choices = [ "dhcp" "static" ]; label = "Addressing"; group = "Addressing"; */
    ci.network.mode = "dhcp";

    /* @option widget = "text"; label = "Interface"; group = "Addressing"; */
    ci.network.interface = "eth0";

    /* @option widget = "text"; label = "IPv4 address"; group = "Static"; visibleWhen.path = "ci.network.mode"; visibleWhen.equals = "static"; */
    ci.network.address = "192.168.1.10";

    /* @option widget = "spin"; label = "Prefix length"; group = "Static"; min = 1; max = 32; visibleWhen.path = "ci.network.mode"; visibleWhen.equals = "static"; */
    ci.network.prefixLength = 24;

    /* @option widget = "text"; label = "Gateway"; group = "Static"; visibleWhen.path = "ci.network.mode"; visibleWhen.equals = "static"; */
    ci.network.gateway = "192.168.1.1";

    /* @option widget = "list"; label = "DNS servers"; itemLabel = "Server"; addLabel = "Add server"; group = "Static"; visibleWhen.path = "ci.network.mode"; visibleWhen.equals = "static"; */
    ci.network.dns = [
      "1.1.1.1"
      "8.8.8.8"
    ];

    networking.useDHCP = config.ci.network.mode == "dhcp";

    networking.interfaces.${config.ci.network.interface} = lib.mkIf (config.ci.network.mode == "static") {
      ipv4.addresses = [
        {
          address = config.ci.network.address;
          prefixLength = config.ci.network.prefixLength;
        }
      ];
    };

    networking.defaultGateway = lib.mkIf (config.ci.network.mode == "static") config.ci.network.gateway;
    networking.nameservers = lib.mkIf (config.ci.network.mode == "static") config.ci.network.dns;

    networking.firewall.interfaces.${config.ci.network.interface}.allowedTCPPorts = [
      config.ci.hydra.port
      config.ci.cache.port
    ];
  };
}
