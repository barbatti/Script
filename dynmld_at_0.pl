#!/usr/bin/perl -w
#
use lib join('/',$ENV{"NX"},"CPAN") ;
use colib_perl;
$au2ang=units("au2ang");

$traj_i=1;
$traj_f=35;
$nat=15;

open (OUT,">dyn-0.mld")or die" Failed to open file: dyn-0.mld\n";
for ($i=$traj_i;$i<=$traj_f;$i++){
  $file="TRAJ$i/RESULTS/dyn.out";
  open(FL,$file) or warn ":( $file\n";
  while(<FL>){
    if (/Initial geometry:/){
       for ($n=1;$n<=$nat;$n++){
          $_=<FL>;
          chomp; s/^ *//;
          ($symbol[$n],$charge[$n],$x[$n],$y[$n],$z[$n],$am[$n])=split(/\s+/,$_);
       }
    }
  }
  close(FL);
  print_at();
}
close(OUT);

sub print_at{
    print {OUT}" $nat\n\n";
    for ($k=1; $k<=$nat; $k++)
    {
      $x[$k]=$x[$k]*$au2ang;
      $y[$k]=$y[$k]*$au2ang;
      $z[$k]=$z[$k]*$au2ang;
      printf {OUT}("%7s  %15.6f  %15.6f   %15.6f\n", $symbol[$k],$x[$k],$y[$k],$z[$k]);
    }
}
