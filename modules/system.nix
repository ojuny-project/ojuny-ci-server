{
  config,
  lib,
  pkgs,
  ...
}:

{
  networking.hostName = config.ci.hostName;
  networking.domain = config.ci.domain;
  time.timeZone = config.ci.timeZone;
  i18n.defaultLocale = config.ci.locale;
  system.stateVersion = "26.11";

  users.mutableUsers = false;
  users.users.${config.ci.adminUser} = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    hashedPassword = config.ci.adminHashedPassword;
    openssh.authorizedKeys.keys = config.ci.ssh.authorizedKeys;
  };

  services.openssh = {
    enable = true;
    ports = [ config.ci.ssh.port ];
    settings.PermitRootLogin = "no";
  };

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ config.ci.ssh.port ];
  };

  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    trusted-users = [
      "root"
      config.ci.adminUser
    ];
  };

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  nix.optimise.automatic = true;

  environment.systemPackages = with pkgs; [
    curl
    git
    htop
    jq
    tmux
  ];

  security.sudo.wheelNeedsPassword = false;
}
