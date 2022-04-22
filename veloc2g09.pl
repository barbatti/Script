#!/usr/bin/perl -w

$au2s=2.4188843265E-17;

$v_in="veloc";
$v_out="veloc_g";

open(IN,$v_in) or die "Cannot open $v_in";
open(OUT,">$v_out") or die "Cannot open $v_out";
while(<IN>){
  chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
  ($vx,$vy,$vz)=split(/\s+/,$_);
  $vx=$vx/$au2s;
  $vy=$vy/$au2s;
  $vz=$vz/$au2s;
  printf OUT " %14.8E   %14.8E   %14.8E\n",$vx,$vy,$vz;
}
close(OUT);
close(IN);
