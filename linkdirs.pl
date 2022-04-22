#!/usr/bin/perl -w
# This script links trajectories from separated directories into a single dir with
# sequential numbering. MB 2015
#
# ================== User Input ===============================
$dir="/fsnfs/users/barbatti/PYRROLE/DZ/DYNAMICS/WIG-SAMPLING"; # Orginal dynamics
$alltj="ALL_TRAJS";                                            # New Dir
$ntraj[0]=19;                                                  # Number of trajs
$ntraj[1]=30;
$ntraj[2]=36;
$ntraj[3]=15;
$dyn[0]="S3";                                                  # Dir name
$dyn[1]="S4";
$dyn[2]="S5";
$dyn[3]="S6";
# =============================================================
$nbase=0;
if (!-s $alltj){
  system("mkdir $alltj");
}else{
  die "Directory $alltj already exists!";
}
for ($k=0;$k<=3;$k++){
  for ($i=1;$i<=$ntraj[$k];$i++){
    $j=$i+$nbase;
    system("ln -s $dir/$dyn[$k]/TRAJECTORIES/TRAJ$i ALL_TRAJS/TRAJ$j");
    print "Mapping $dyn[$k]/TRAJECTORIES/TRAJ$i into $alltj/TRAJ$j\n";
  }
  $nbase=$nbase+$ntraj[$k];
}
