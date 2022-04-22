#!/usr/bin/perl -w

$WDIR="DISPLACEMENT";
$disp="displfl";

print " Coordinate number [default = 1]:";
$_=<STDIN>;
chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;         # remove trailing blanks
if ($_ eq ""){
  $c = 1;
}else{
  $c=$_;
}

open(DP,"GS/$WDIR/$disp") or die ":( $WDIR/$disp";
$_=<DP>;
$_=<DP>;
$_=<DP>;
while(<DP>){
  chomp;
  $_ =~ s/^\s*//;         # remove leading blanks
  $_ =~ s/\s*$//;         # remove trailing blanks
  ($c,$i)=split(/\s+/,$_);
  print " ..... JOB $i ....";
  run_cube();
}
close(DP);

sub run_cube{
  chdir("GS/$WDIR/CALC.c$c.d$i");
  print " GS ....";
#  system("g09 < g$i-gaussian.com > g$i-gaussian.log");
  system("cp -f gs.cube ../../../.");
  chdir("../../../");
  chdir("ES/$WDIR/CALC.c$c.d$i");
  print " ES ....\n";
#  system("g09 < g$i-gaussian.com > g$i-gaussian.log");
  system("cp -f ex.cube ../../../.");
  chdir("../../../");
  system("\$g09root/g09/cubman < inp");
  system("mv diff.cube diff-$i.cube");
  system("rm -f ex.cube gs.cube");
}

