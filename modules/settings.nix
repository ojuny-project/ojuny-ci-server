/* @menu
   displayname = "CI identity";
   icon = "preferences-system-network-symbolic";
   order = 10;
   description = "Git identity, host and administrator";
*/

{ lib, ... }:

{
  options.ci = {
    git = {
      username = lib.mkOption {
        type = lib.types.str;
        default = "ojuny-project";
        description = "Git host username or organization that owns the Ojuny repositories.";
      };

      host = lib.mkOption {
        type = lib.types.str;
        default = "github.com";
        description = "Git host used to build repository URLs.";
      };

      protocol = lib.mkOption {
        type = lib.types.enum [
          "https"
          "ssh"
        ];
        default = "https";
        description = "Protocol used to build repository URLs.";
      };

      tokenFile = lib.mkOption {
        type = lib.types.nullOr lib.types.path;
        default = null;
        description = "Optional file containing a Git token for private repositories.";
      };

      repositories = lib.mkOption {
        type = lib.types.attrsOf (
          lib.types.submodule {
            options.name = lib.mkOption {
              type = lib.types.str;
              description = "Actual repository name under the configured username.";
            };
          }
        );
        default = { };
        description = "Optional per-repository name overrides keyed by the standard Ojuny repository name.";
      };
    };

    hostName = lib.mkOption {
      type = lib.types.str;
      default = "ojuny-ci";
      description = "Server hostname.";
    };

    domain = lib.mkOption {
      type = lib.types.str;
      default = "lan";
      description = "Server DNS domain.";
    };

    timeZone = lib.mkOption {
      type = lib.types.str;
      default = "UTC";
      description = "System time zone.";
    };

    locale = lib.mkOption {
      type = lib.types.str;
      default = "en_US.UTF-8";
      description = "System locale.";
    };

    adminUser = lib.mkOption {
      type = lib.types.str;
      default = "admin";
      description = "Primary system administrator and Hydra administrator account name.";
    };

    adminHashedPassword = lib.mkOption {
      type = lib.types.str;
      default = "!";
      description = "Hashed password for the system administrator. A locked value is the default; use SSH keys or set a hash.";
    };

    ssh = {
      port = lib.mkOption {
        type = lib.types.port;
        default = 22;
        description = "OpenSSH port.";
      };

      authorizedKeys = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ "# replace with your SSH public key" ];
        description = "SSH public keys for the administrator.";
      };
    };
  };

  config = {
    /* @option widget = "text"; label = "Git username"; group = "Git"; description = "The Git host user or organization that owns the repositories."; */
    ci.git.username = "ojuny-project";

    /* @option widget = "text"; label = "Git host"; group = "Git"; */
    ci.git.host = "github.com";

    /* @option widget = "dropdown"; choices = [ "https" "ssh" ]; label = "Git protocol"; group = "Git"; */
    ci.git.protocol = "https";

    /* @option widget = "path"; label = "Git token file"; group = "Git"; advanced = true; nullable = true; */
    ci.git.tokenFile = null;

    /* @option widget = "table-attrset"; label = "Repository overrides"; columns = [ "name" ]; group = "Git"; description = "Key each row by the standard Ojuny repository name and set the actual name."; */
    ci.git.repositories = { };

    /* @option widget = "text"; label = "Hostname"; group = "Host"; */
    ci.hostName = "ojuny-ci";

    /* @option widget = "text"; label = "Domain"; group = "Host"; */
    ci.domain = "lan";

    /* @option widget = "text"; label = "Timezone"; group = "Host"; */
    ci.timeZone = "UTC";

    /* @option widget = "text"; label = "Locale"; group = "Host"; */
    ci.locale = "en_US.UTF-8";

    /* @option widget = "text"; label = "Admin user"; group = "Administrator"; */
    ci.adminUser = "admin";

    /* @option widget = "text"; label = "Admin password hash"; group = "Administrator"; advanced = true; */
    ci.adminHashedPassword = "!";

    /* @option widget = "spin"; label = "SSH port"; group = "Administrator"; min = 1; max = 65535; */
    ci.ssh.port = 22;

    /* @option widget = "list"; label = "SSH keys"; itemLabel = "Key"; addLabel = "Add key"; group = "Administrator"; */
    ci.ssh.authorizedKeys = [ "# replace with your SSH public key" ];
  };
}
