{
  pkgs,
  configuration,
  jobsetsJson,
}:

{
  settings-eval = pkgs.runCommand "check-settings" { } ''
    test -n "${configuration.ci.git.username}"
    test -n "${configuration.ci.hostName}"
    test -n "${configuration.ci.adminUser}"
    touch $out
  '';

  jobsets-schema = pkgs.runCommand "check-jobsets-schema" {
    nativeBuildInputs = [ pkgs.python3 ];
  } ''
    python3 ${./jobsets_schema.py} ${jobsetsJson}
    touch $out
  '';

  storage-assertions = pkgs.runCommand "check-storage-assertions" {
    nativeBuildInputs = [ pkgs.python3 ];
  } ''
    python3 ${./storage_assertions.py} ${
      pkgs.writeText "mounts.json" (builtins.toJSON configuration.ci.storage.mounts)
    }
    touch $out
  '';

  options-coverage = pkgs.runCommand "check-options-coverage" {
    nativeBuildInputs = [ pkgs.python3 ];
  } ''
    python3 ${./options_coverage.py} ${../modules}
    touch $out
  '';
}
