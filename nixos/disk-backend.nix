{
  config,
  lib,
  ...
}:

{
  disko.devices.disk.main = {
    device = config.ci.disk.device;
    type = "disk";
    content = {
      type = "gpt";
      partitions = {
        ESP = {
          size = "1G";
          type = "EF00";
          priority = 1;
          content = {
            type = "filesystem";
            format = "vfat";
            mountpoint = "/boot";
          };
        };
        root = {
          size = "100%";
          priority = 3;
          content = {
            type = "filesystem";
            format = "ext4";
            mountpoint = "/";
          };
        };
      }
      // lib.optionalAttrs (config.ci.disk.swapSize != "0") {
        swap = {
          size = config.ci.disk.swapSize;
          priority = 2;
          content = {
            type = "swap";
          };
        };
      };
    };
  };

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
}
