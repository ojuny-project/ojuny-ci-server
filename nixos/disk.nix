/* @menu
   displayname = "Disk";
   icon = "drive-harddisk-system-symbolic";
   order = 40;
   description = "Target disk and swap";
*/

{ lib, ... }:

{
  options.ci.disk = {
    device = lib.mkOption {
      type = lib.types.str;
      default = "/dev/vda";
      description = "Target disk for the disko layout.";
    };

    swapSize = lib.mkOption {
      type = lib.types.str;
      default = "0";
      description = "Swap partition size, or 0 for no swap.";
    };
  };

  config = {
    /* @option widget = "text"; label = "Target disk"; group = "Disk"; */
    ci.disk.device = "/dev/vda";

    /* @option widget = "text"; label = "Swap size"; group = "Disk"; description = "Use 0 to disable swap."; */
    ci.disk.swapSize = "0";
  };
}
