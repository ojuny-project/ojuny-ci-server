/* @menu
   displayname = "Hydra";
   icon = "applications-development-symbolic";
   order = 60;
   description = "Hydra server and queue";
*/

{ config, lib, ... }:

{
  options.ci.hydra = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Run Hydra on this host.";
    };

    port = lib.mkOption {
      type = lib.types.port;
      default = 3000;
      description = "Hydra web port.";
    };

    bindAddress = lib.mkOption {
      type = lib.types.str;
      default = "0.0.0.0";
      description = "Address Hydra listens on.";
    };

    adminPasswordHash = lib.mkOption {
      type = lib.types.str;
      default = "!";
      description = "Argon2id password hash for the Hydra administrator. A locked value is the default.";
    };

    maxJobs = lib.mkOption {
      type = lib.types.int;
      default = 4;
      description = "Maximum concurrent Hydra build jobs.";
    };

    maxOutputSize = lib.mkOption {
      type = lib.types.int;
      default = 10737418240;
      description = "Maximum output size in bytes.";
    };

    useSubstitutes = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Allow Hydra to use substitutes.";
    };
  };

  config = {
    /* @option widget = "switch"; label = "Enable Hydra"; group = "Hydra"; */
    ci.hydra.enable = true;

    /* @option widget = "spin"; label = "Port"; group = "Hydra"; min = 1; max = 65535; */
    ci.hydra.port = 3000;

    /* @option widget = "text"; label = "Bind address"; group = "Hydra"; advanced = true; */
    ci.hydra.bindAddress = "0.0.0.0";

    /* @option widget = "text"; label = "Admin password hash"; group = "Hydra"; advanced = true; description = "Argon2id hash. Use hydra-create-user to generate one."; */
    ci.hydra.adminPasswordHash = "!";

    /* @option widget = "spin"; label = "Max jobs"; group = "Queue"; min = 1; max = 256; */
    ci.hydra.maxJobs = 4;

    /* @option widget = "spin"; label = "Max output size"; group = "Queue"; min = 1048576; unit = "bytes"; */
    ci.hydra.maxOutputSize = 10737418240;

    /* @option widget = "switch"; label = "Use substitutes"; group = "Queue"; */
    ci.hydra.useSubstitutes = true;

    services.hydra = {
      enable = config.ci.hydra.enable;
      hydraURL = "http://${config.ci.hostName}:${toString config.ci.hydra.port}";
      notificationSender = "hydra@${config.ci.hostName}";
      port = config.ci.hydra.port;
      listenHost = config.ci.hydra.bindAddress;
      useSubstitutes = config.ci.hydra.useSubstitutes;
      extraConfig = ''
        max_output_size = ${toString config.ci.hydra.maxOutputSize}
        max_workers = ${toString config.ci.hydra.maxJobs}
      '';
    };

    services.postgresql.enable = config.ci.hydra.enable;
  };
}
