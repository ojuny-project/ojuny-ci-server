{ config, lib, ... }:

let
  user = config.ci.adminUser;
in
{
  users.users.${user} = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];

    hashedPassword = lib.mkIf (config.ci.adminHashedPassword != "!") (
      lib.mkForce config.ci.adminHashedPassword
    );

    openssh.authorizedKeys.keys = config.ci.ssh.authorizedKeys;
  };
}
