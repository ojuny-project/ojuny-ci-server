{
  config,
  lib,
  ...
}:

let
  networkFilesystems = [
    "nfs"
    "nfs4"
    "cifs"
    "smb3"
    "glusterfs"
    "ceph"
    "9p"
  ];

  reservedPaths = [
    "/nix"
    "/var/lib/postgresql"
    "/var/lib/hydra"
  ];

  mountOptions =
    mount:
    lib.filter (value: value != "") (lib.splitString " " mount.options);
in
{
  fileSystems = lib.mkMerge (
    map (
      mount:
      lib.mkIf mount.enable {
        ${mount.path} = {
          device = mount.device;
          fsType = mount.fsType;
          options = mountOptions mount;
        };
      }
    ) config.ci.storage.mounts
  );

  systemd.tmpfiles.rules = [
    "d ${config.ci.storage.artifactsPath} 0755 ${config.ci.adminUser} ${config.ci.adminUser} -"
  ];

  assertions = map (mount: {
    assertion = !(
      mount.enable
      && builtins.elem mount.path reservedPaths
      && builtins.elem mount.fsType networkFilesystems
    );
    message = "${mount.path} must stay on local block storage. Network filesystems are not supported for ${mount.path}.";
  }) config.ci.storage.mounts;
}
