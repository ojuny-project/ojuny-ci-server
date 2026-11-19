{
  config,
  lib,
  ...
}:

let
  splitCommas = value: lib.filter (item: item != "") (lib.splitString "," value);
  splitSpaces = value: lib.filter (item: item != "") (lib.splitString " " value);
in
{
  nix.buildMachines = map (builder: {
    hostName = builder.hostName;
    systems = splitCommas builder.systems;
    sshUser = builder.sshUser;
    sshKey = if builder.sshKey == "" then null else builder.sshKey;
    maxJobs = builder.maxJobs;
    speedFactor = builder.speedFactor;
    supportedFeatures = splitSpaces builder.supportedFeatures;
    publicHostKey = if builder.publicHostKey == "" then null else builder.publicHostKey;
  }) config.ci.builders;

  nix.distributedBuilds = config.ci.builders != [ ];
  nix.settings.builders-use-substitutes = lib.mkIf (config.ci.builders != [ ]) true;
}
