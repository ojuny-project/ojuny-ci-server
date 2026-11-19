{ ... }:

{
  flake.modules.nixos.system-configuration =
    { config, lib, ... }:
    {
      options.ojuny.repoPath = lib.mkOption {
        type = lib.types.str;
        default = "repos/nix-flake";
        description = "Path to the installed flake, relative to the primary user's home or absolute.";
      };

      config = {
        networking.hostName = lib.mkDefault config.ci.hostName;
        networking.domain = lib.mkDefault config.ci.domain;
        time.timeZone = lib.mkDefault config.ci.timeZone;
        i18n.defaultLocale = lib.mkDefault config.ci.locale;
        console.keyMap = lib.mkDefault "us";
        system.stateVersion = "26.11";
        ojuny.repoPath = lib.mkDefault "repos/nix-flake";
      };
    };
}
