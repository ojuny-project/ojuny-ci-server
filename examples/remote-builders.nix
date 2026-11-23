# Remote builder host
#
# Run this on the builder machine. The CI server exposes the queue runner gRPC
# endpoint; point queueRunnerAddr at it. A non-local endpoint needs mTLS or an
# authorization file listed in the server's tokenPaths.
{ ... }:

{
  services.hydra-builder = {
    enable = true;
    queueRunnerAddr = "http://ci.lan:50051";

    settings = {
      buildCores = 0;
      maxJobs = 4;
    };
  };
}
