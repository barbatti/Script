#!/usr/bin/perl -w

$WDIR="DISPLACEMENT";
$disp="displfl";

if (!-s $WDIR){
  print "This script should submit the jobs inside the $WDIR/CALC* directories.\n";
  print "However, it cannot find the $WDIR directory or it is empty.\n";
  die;
}

#print "Submission script file: ";
#$_=<STDIN>;
#chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
#$psub = $_;

print "Submission command: ";
$_=<STDIN>;
chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
$psub = $_;

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

#system("qstat");

#======================================================================================

sub change_dir{
  $add="";
  if (-s "$WDIR/CALC.c$c.d$i"."au"){
    $add="au";
  }
  if (-s "$WDIR/CALC.c$c.d$i"."Ang"){
    $add="Ang";
  }
  if (-s "$WDIR/CALC.c$c.d$i"."Deg"){
    $add="Deg";
  }
  if (!-s "$WDIR/CALC.c$c.d$i$add"){
    die "$WDIR/CALC.c$c.d$i$add does not exist!";
  }else{
    chdir("$WDIR/CALC.c$c.d$i$add");
    if (!-s "geom"){
      #die "geom does not exist or is empty!";
    }
    #system("qsub $psub");
    system("$psub");
    if (-s "WORK"){
      system("rm -rf WORK");
    }
    chdir("../../");
  }
}

