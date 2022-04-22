#!/usr/bin/perl -w

@neworder=(1,3,9,2,8,4,10,5,11,6,12,7,13);

$D="DISPLACEMENT";
open(DP,"$D/displfl") or die "Cannot read $D/displfl";

$_=<DP>;
$_=<DP>;
$_=<DP>;
while(<DP>){
  chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
  ($i,$j)=split(/\s+/,$_); 
  chdir("$D/CALC.c$i.d$j");
  open(OG,"geom") or die ":( geom";
  $k=0;
  while(<OG>){
    $g[$k]=$_;
    $k++;
  }
  close(OG);
  open(NG,">aux") or die ":( aux";
  foreach(@neworder){
    $k=$_-1;
    print NG $g[$k];
  }
  close(NG);
  system("mv geom geom.old; mv aux geom");
  chdir("../../");
}
