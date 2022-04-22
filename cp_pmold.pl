#!/usr/bin/perl -w
# ------ USER INPUT -----
$imin=1;
$imax=20;
$name="ura";
# -----------------------

for ($i=$imin;$i<=$imax;$i++){
  change_name();
}

sub change_name{
  $batch="#\$ -N";
  open(PM,"pmold") or die ":( pmold";
  open(PA,">pmold.aux") or die ":( pmold.aux";
  while(<PM>){
    if (/-N/){
      print PA "$batch $name.$i\n";
    }else{
      print PA $_;
    }
  }
  close(PM);
  close(PA);
  system("mv pmold.aux TRAJ$i/pmold");
}

