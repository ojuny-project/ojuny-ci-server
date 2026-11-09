{
  lib,
  ci,
}:

let
  repoName =
    standard:
    (ci.git.repositories.${standard}.name or standard);

  repoUrl =
    standard:
    if ci.git.protocol == "ssh" then
      "git+ssh://git@${ci.git.host}/${ci.git.username}/${repoName standard}"
    else
      "git+https://${ci.git.host}/${ci.git.username}/${repoName standard}";

  mkJobset =
    standard:
    {
      enabled = 1;
      type = 1;
      flake = repoUrl standard;
      description = "Ojuny CI for ${repoName standard}";
      checkinterval = 300;
      schedulingshares = 100;
      emailoverride = "";
      keepnr = 3;
    };

  groups = {
    checks = [
      "ojuny-ci-workflows"
      "ojuny-template"
      "ojuny-installer"
      "ojuny-cli"
      "ojuny-desktop"
      "ojuny-manual"
      "ojuny-site"
      "ojuny-patches"
      "ojuny-test-flakes"
      "nix-cache-discovery"
      "nix-cleaner"
      "nix-settings-gui"
      "ojuny-welcome"
      "nix-regedit"
      "nix-shell-gui"
      "simple-nix-update-gui"
      "ojuny-ci-server"
    ];
    vmTests = [
      "nix-cache-discovery"
      "ojuny-installer"
    ];
    isos = [ "ojuny-installer" ];
    persistentImage = [ "ojuny-installer" ];
    reproducibility = [ "ojuny-installer" ];
    acceptance = [ "ojuny-installer" ];
    installReport = [ "ojuny-installer" ];
  };

  enabledGroups = lib.filter (group: ci.jobs.${group}.enable) (lib.attrNames groups);
in
lib.listToAttrs (
  lib.concatMap (
    group:
    map (repo: {
      name = "${group}-${repo}";
      value = mkJobset repo;
    }) groups.${group}
  ) enabledGroups
)
