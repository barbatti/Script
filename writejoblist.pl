#!/usr/bin/perl -w

#$p1="/home/barbatti/DYNAMICS/CNH4/CIOVERLAP/CAS12.8/DYN_CONVENTIONAL_MODEL0/TRAJECTORIES/TRAJ";
#$p2="/home/barbatti/DYNAMICS/CNH4/CIOVERLAP/CAS12.8/DYN_CONVENTIONAL_MODEL2/TRAJECTORIES/TRAJ";
#$p2="/home/barbatti/DYNAMICS/CNH4/CIOVERLAP/CAS12.8/DYN_CONVENTIONAL_MODEL-NC/TRAJECTORIES/TRAJ";
#$p1="/home/barbatti/DYNAMICS/CNH4/CIOVERLAP/MRCI44-CAS12.8/DYN_CONVENTIONAL/TRAJECTORIES/TRAJ";
#$p2="/home/barbatti/DYNAMICS/CNH4/CIOVERLAP/MRCI44-CAS12.8/DYN_CIOVERLAP/TRAJECTORIES/TRAJ";
$p2="/home/barbatti/DYNAMICS/CYTOSINE/ERWIN/TRAJ";

$ini=165;
$fin=194;

open(FL,">list");
for ($i=$ini;$i<=$fin;$i++){
#  print FL " $p1$i pmold w\n";
  print FL " $p2$i pmold w\n";
}