#!/usr/bin/perl -w

$WDIR="DISPLACEMENT";
$disp="displfl";

if (!-s $WDIR){
  print "This script should submit the jobs inside the $WDIR/CALC* directories.\n";
  print "However, it cannot find the $WDIR directory or it is empty.\n";
  die;
}

system("qstat -g c");

print "\n Which queue? ";
$_=<STDIN>;
chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
$queue=$_;

print "\n Gaussian input file? (def = gaussian.com) ";
$_=<STDIN>;
chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
$gauss=$_;
if ($gauss eq ""){
  $gauss="gaussian.com";
}

$psub = "q_g09bk";

open(DP,"$WDIR/$disp") or die ":( $WDIR/$disp";
$_=<DP>;
$_=<DP>;
$_=<DP>;
$ind=0;
while(<DP>){
  chomp;
  $_ =~ s/^\s*//;         # remove leading blanks
  $_ =~ s/\s*$//;         # remove trailing blanks
  ($c,$i)=split(/\s+/,$_);
  change_dir();
  $ind++;
}
close(DP);

system("qstat");

#======================================================================================

sub change_dir{
  if (!-s "$WDIR/CALC.c$c.d$i"){
    die "$WDIR/CALC.c$c.d$i does not exist!";
  }else{
    chdir("$WDIR/CALC.c$c.d$i");
    if (-s "g$i-$gauss"){
      $auxf="aux-sub";
      open(AU,">$auxf") or die ":( $auxf";
      print AU "$queue\n\n";
      close(AU);
      system("$psub g$i-$gauss < $auxf");
      system("rm -f $auxf");
      system("sleep 2");
    }
    chdir("../../");
  }
}

