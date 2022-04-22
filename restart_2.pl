#!/usr/bin/perl -w

@list=(2,3,4,7,8,9,11,12);
$tmax = 200;

foreach(@list){
  $i=$_;
  print "TRAJ$i \n";
  open(T,"TRAJ$i/INFO_RESTART/control.dyn") or warn ":( $i";
  open(TA,">control.dyn.aux");
  while(<T>){
     if (/tmax/i){
       print TA "  tmax = $tmax \n";
     }else{
       print TA $_;
     }
  }
  close(T);
  close(TA);
  system("mv control.dyn.aux TRAJ$i/control.dyn");
}
