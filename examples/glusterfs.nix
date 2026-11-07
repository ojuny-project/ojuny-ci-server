# GlusterFS artifacts
#
# GlusterFS is for artifacts, release staging and archival. It is not used for
# /nix, PostgreSQL or the Hydra database.
{ ... }:

{
  ci.storage.mounts = [
    {
      path = "/var/lib/ojuny-ci/artifacts";
      device = "gluster1:/ojuny-artifacts";
      fsType = "glusterfs";
      options = "defaults,_netdev";
      enable = true;
    }
  ];
}
