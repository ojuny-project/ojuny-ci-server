{ config, ... }:

{
  users.users.${config.ci.adminUser} = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    hashedPassword = config.ci.adminHashedPassword;
    openssh.authorizedKeys.keys = config.ci.ssh.authorizedKeys;
  };
}
