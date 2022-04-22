#!/usr/bin/perl -w
#
for ($i=1;$i<=500;$i++){
  print "$i\n";
  system("mkdir TRAJ$i");
  system("cp -rf ../../../ADJ_GRD/TRAJECTORIES/TRAJ$i/RESULTS TRAJ$i/.");
  system("rm -f TRAJ$i/RESULTS/dyn.xyz");
}
