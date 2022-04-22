#!/usr/bin/perl -w

# Input
$Nat = 15; # Number of atoms
$dt  = 0.5; # time step

# list of trajectories:
#@list=(1,3,22,28,32,36,38,44,57,60,61,65,72,79,83,89,94);
@list=(4,5,10,11,12,14,15,16,19,20,21,23,24,26,27,29,33,35,37,39,40,42,45,47,50,51,52,53,54,56,62,64,66,67,70,75,76,81,88,95,96,97);

foreach(@list){
  $nt=$_;
  system("cp -f dyn$nt.mld dyn.mld");
  nl();
  $final_step=sprintf("%u",$lines/($Nat+2));
  open(INP,">inp") or die ":( inp";
  print INP "$final_step\n$dt\n";
  close(INP);
  system("./cp-traj.pl < inp");
  system("mv -f cp.log cp$nt.log");
  system("mv -f t-cp.dat t-cp$nt.dat");
  system("rm -f temp*");
}
#system("./reorder-theta-phi.pl");

sub nl{
  $filename="dyn.mld";
  $lines=0;
  open(FN,$filename) or die ":( $filename";
  while(<FN>){
    $lines++;
  }
  close(FN);
}

