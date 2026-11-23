{ config, lib, ... }:

{
  services.hydra-builder = {
    enable = config.ci.hydra.enable;
    queueRunnerAddr = "http://[::1]:${toString config.services.hydra.queueRunner.grpc.port}";

    settings = {
      buildCores = 0;
      maxJobs = lib.mkIf (config.ci.hydra.maxJobs > 0) config.ci.hydra.maxJobs;
    };
  };
}
