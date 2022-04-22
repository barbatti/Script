#!/usr/bin/perl -w
#

$it=1;
$ft=46;

for ($i=$it;$i<=$ft;$i++){
  open(DO,"TRAJ$i/RESULTS/dyn.out");
  open(AUX,">TRAJ$i/RESULTS/dyn-aux");
  while(<DO>){
    if (/Molecular dynamics on state1/){
      $_=~s/Molecular dynamics on state1/Molecular dynamics on state 1/;
    }
    if (/Wave function state1/){
      $_=~s/Wave function state1/Wave function state 1/;
    }
    print AUX "$_";
  }
  close(DO);
  close(AUX);
  system("mv -f TRAJ$i/RESULTS/dyn.out TRAJ$i/RESULTS/dyn.org");
  system("gzip TRAJ$i/RESULTS/dyn.org");
  system("mv -f TRAJ$i/RESULTS/dyn-aux TRAJ$i/RESULTS/dyn.out");
}
