/* @menu
   displayname = "Storage";
   icon = "drive-harddisk-symbolic";
   order = 30;
   description = "Artifacts and optional filesystems";
*/

{ lib, ... }:

{
  options.ci.storage = {
    artifactsPath = lib.mkOption {
      type = lib.types.str;
      default = "/var/lib/ojuny-ci/artifacts";
      description = "Directory used for Hydra artifacts, release staging and archival.";
    };

    mounts = lib.mkOption {
      type = lib.types.listOf (
        lib.types.submodule {
          options = {
            path = lib.mkOption {
              type = lib.types.str;
              description = "Mount point.";
            };
            device = lib.mkOption {
              type = lib.types.str;
              description = "Device or remote export.";
            };
            fsType = lib.mkOption {
              type = lib.types.str;
              description = "Filesystem type.";
            };
            options = lib.mkOption {
              type = lib.types.str;
              default = "";
              description = "Space-separated mount options.";
            };
            enable = lib.mkOption {
              type = lib.types.bool;
              default = true;
              description = "Mount this filesystem.";
            };
          };
        }
      );
      default = [ ];
      description = "Optional extra filesystems.";
    };
  };

  config = {
    /* @option widget = "path"; label = "Artifacts path"; group = "Artifacts"; */
    ci.storage.artifactsPath = "/var/lib/ojuny-ci/artifacts";

    /* @option widget = "table-list"; label = "Extra mounts"; columns = [ "path" "device" "fsType" "options" "enable" ]; columnTypes = [ "str" "str" "str" "str" "bool" ]; addLabel = "Add mount"; group = "Mounts"; */
    ci.storage.mounts = [ ];
  };
}
