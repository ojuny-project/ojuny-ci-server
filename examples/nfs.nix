# NFS artifacts
{ ... }:

{
  ci.storage.mounts = [
    {
      path = "/var/lib/ojuny-ci/artifacts";
      device = "nas.lan:/export/ojuny-artifacts";
      fsType = "nfs4";
      options = "defaults,_netdev,soft,timeo=100";
      enable = true;
    }
  ];
}
