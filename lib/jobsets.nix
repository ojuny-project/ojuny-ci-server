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

  groupNames = lib.attrNames groups;

  repoGroups =
    repo:
    lib.filter (group: group != "") (lib.splitString " " repo.groups);

  repoFlake =
    repo:
    if repo.ref == "" then
      repo.url
    else if
      lib.hasPrefix "github:" repo.url
      || lib.hasPrefix "gitlab:" repo.url
      || lib.hasPrefix "sourcehut:" repo.url
    then
      "${repo.url}/${repo.ref}"
    else
      "${repo.url}?ref=${repo.ref}";

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

  mkExtraJobset =
    repo:
    {
      enabled = 1;
      type = 1;
      flake = repoFlake repo;
      description = "Ojuny CI for ${repo.name}";
      checkinterval = 300;
      schedulingshares = 100;
      emailoverride = "";
      keepnr = 3;
    };

  enabledGroups = lib.filter (group: ci.jobs.${group}.enable) groupNames;

  standardJobs = lib.concatMap (
    group:
    map (repo: {
      name = "${group}-${repo}";
      value = mkJobset repo;
    }) groups.${group}
  ) enabledGroups;

  extraRepositories = ci.jobs.extraRepositories or [ ];

  extraJobs = lib.concatMap (
    repo:
    map (group: {
      name = "${group}-${repo.name}";
      value = mkExtraJobset repo;
    }) (repoGroups repo)
  ) extraRepositories;

  allJobs = standardJobs ++ extraJobs;

  extraComplete = lib.all (
    repo: repo.name != "" && repo.url != "" && repoGroups repo != [ ]
  ) extraRepositories;

  extraGroupsKnown = lib.all (
    repo: lib.all (group: lib.elem group groupNames) (repoGroups repo)
  ) extraRepositories;

  extraNamesUnique = lib.length (lib.attrNames (lib.listToAttrs allJobs)) == lib.length allJobs;
in
assert lib.assertMsg extraComplete
  "ci.jobs.extraRepositories needs a name, a url and at least one group on every entry";
assert lib.assertMsg extraGroupsKnown
  "ci.jobs.extraRepositories groups must be one of: ${lib.concatStringsSep ", " groupNames}";
assert lib.assertMsg extraNamesUnique
  "ci.jobs.extraRepositories entries collide with another jobset name";
lib.listToAttrs allJobs
