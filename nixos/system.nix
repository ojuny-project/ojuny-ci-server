{
  config,
  lib,
  pkgs,
  ...
}:

{
  environment.etc."ojuny/flake-path".text = config.ojuny.repoPath;

  users.mutableUsers = false;
  users.groups.networkmanager = { };
  environment.shells = [
    pkgs.zsh
    pkgs.fish
  ];

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
