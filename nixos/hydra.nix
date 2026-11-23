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
      type = lib.types.ints.unsigned;
      default = 0;
      description = "Optional cap on concurrent builder jobs. 0 uses dynamic PSI scheduling with no cap.";
    };

    maxOutputSize = lib.mkOption {
      type = lib.types.ints.unsigned;
      default = 0;
      description = "Per-output NAR size limit in bytes. 0 disables the cap.";
    };

    minimumDiskFree = lib.mkOption {
      type = lib.types.ints.unsigned;
      default = 20;
      description = "Stop the queue runner when /nix/store free space drops below this many GiB.";
    };

    minimumDiskFreeEvaluator = lib.mkOption {
      type = lib.types.ints.unsigned;
      default = 10;
      description = "Stop the evaluator when /nix/store free space drops below this many GiB.";
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

    /* @option widget = "spin"; label = "Max jobs"; group = "Queue"; min = 0; max = 1024; description = "0 uses dynamic PSI scheduling."; */
    ci.hydra.maxJobs = 0;

    /* @option widget = "spin"; label = "Max output size"; group = "Queue"; min = 0; unit = "bytes"; description = "0 disables the per-output cap."; */
    ci.hydra.maxOutputSize = 0;

    /* @option widget = "spin"; label = "Minimum disk free"; group = "Queue"; min = 0; unit = "GiB"; */
    ci.hydra.minimumDiskFree = 20;

    /* @option widget = "spin"; label = "Minimum disk free, evaluator"; group = "Queue"; min = 0; unit = "GiB"; */
    ci.hydra.minimumDiskFreeEvaluator = 10;

    /* @option widget = "switch"; label = "Use substitutes"; group = "Queue"; */
    ci.hydra.useSubstitutes = true;

    services.hydra = {
      enable = config.ci.hydra.enable;
      hydraURL = "http://${config.ci.hostName}:${toString config.ci.hydra.port}";
      notificationSender = "hydra@${config.ci.hostName}";
      port = config.ci.hydra.port;
      listenHost = config.ci.hydra.bindAddress;
      useSubstitutes = config.ci.hydra.useSubstitutes;
      minimumDiskFree = config.ci.hydra.minimumDiskFree;
      minimumDiskFreeEvaluator = config.ci.hydra.minimumDiskFreeEvaluator;

      queueRunner.settings = {
        maxOutputSize = config.ci.hydra.maxOutputSize;
        machineFreeFn = if config.ci.hydra.maxJobs > 0 then "DynamicWithMaxJobLimit" else "Dynamic";
      };
    };

    services.postgresql.enable = config.ci.hydra.enable;
  };
}
