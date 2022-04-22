#!/usr/bin/perl -w

# This script will copy all trajectories with normal termination into a new directory (COPIED_TRAJS)
# with new sequntial numbering.

print " Max trajectory number: ";
$_=<STDIN>;
chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
$max_trj=$_;

$CT="COPIED_TRAJS";
if (!-s "$CT"){
  system("mkdir $CT");
}

$j=0;
for ($i=1;$i<=$max_trj;$i++){
  $grep=qx(grep -c ends TRAJ$i/moldyn.log);
  chomp($grep);
  print "$grep\n";
  if ($grep == 1){
    $j++;
    system("cp -rf TRAJ$i $CT/TRAJ$j");
  }
}
