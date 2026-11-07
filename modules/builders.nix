/* @menu
   displayname = "Builders";
   icon = "cpu-symbolic";
   order = 80;
   description = "Optional remote builders";
*/

{ lib, ... }:

{
  options.ci.builders = lib.mkOption {
    type = lib.types.listOf (
      lib.types.submodule {
        options = {
          hostName = lib.mkOption {
            type = lib.types.str;
            description = "Builder hostname.";
          };
          systems = lib.mkOption {
            type = lib.types.str;
            default = "x86_64-linux";
            description = "Comma-separated systems.";
          };
          sshUser = lib.mkOption {
            type = lib.types.str;
            default = "root";
            description = "SSH user.";
          };
          sshKey = lib.mkOption {
            type = lib.types.str;
            default = "";
            description = "SSH private key path, or empty.";
          };
          maxJobs = lib.mkOption {
            type = lib.types.int;
            default = 1;
            description = "Maximum concurrent jobs.";
          };
          speedFactor = lib.mkOption {
            type = lib.types.int;
            default = 1;
            description = "Relative speed.";
          };
          supportedFeatures = lib.mkOption {
            type = lib.types.str;
            default = "kvm nixos-test big-parallel benchmark";
            description = "Space-separated supported features.";
          };
          publicHostKey = lib.mkOption {
            type = lib.types.str;
            default = "";
            description = "Public host key, or empty.";
          };
        };
      }
    );
    default = [ ];
    description = "Remote builders. Empty keeps the server as the only builder.";
  };

  config = {
    /* @option widget = "table-list"; label = "Remote builders"; columns = [ "hostName" "systems" "sshUser" "sshKey" "maxJobs" "speedFactor" "supportedFeatures" "publicHostKey" ]; columnTypes = [ "str" "str" "str" "str" "int" "int" "str" "str" ]; addLabel = "Add builder"; group = "Builders"; */
    ci.builders = [ ];
  };
}
