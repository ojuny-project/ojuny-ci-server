# Remote builders
{ ... }:

{
  ci.builders = [
    {
      hostName = "builder.lan";
      systems = "x86_64-linux,aarch64-linux";
      sshUser = "root";
      sshKey = "/var/lib/ojuny-ci/builder-key";
      maxJobs = 8;
      speedFactor = 2;
      supportedFeatures = "kvm nixos-test big-parallel benchmark";
      publicHostKey = "ssh-ed25519 AAAA... builder";
    }
  ];
}
