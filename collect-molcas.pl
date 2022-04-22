#!/usr/bin/perl -w

# Collect MOLCAS results from a curve calculation
# Usage collect-molcas.pl eref <ENTER>
# eref = energy base to compute in eV

open(OUT,">collect-molcas.dat") or die ":( collect-molcas.dat";

$au2ev=27.211396;

$WDIR="DISPLACEMENT";
$disp="displfl";

$eref=0;
if (@ARGV != 0){
  $eref = $ARGV[0];
}

open(DP,"$WDIR/$disp") or die ":( $WDIR/$disp";
$_=<DP>;
$_=<DP>;
$_=<DP>;
while(<DP>){ 
  chomp;
  $_ =~ s/^\s*//;         # remove leading blanks
  $_ =~ s/\s*$//;         # remove trailing blanks
  ($c,$i)=split(/\s+/,$_);
  find_energy();
}
close(DP);

# .............................

sub find_energy{
  open(ML,"$WDIR/CALC.c$c.d$i/molcas.log") or die ":( $WDIR/CALC.c$c.d$i/molcas.log";
  $k=0;
  $all_e="";
  $all_ev="";
  while(<ML>){
    if (/Total energy:/){
      chomp;
      $_ =~ s/^\s*//;         # remove leading blanks
      $_ =~ s/\s*$//;         # remove trailing blanks
      ($grb,$grb,$e[$k])=split(/\s+/,$_);
      print STDOUT " >>>>>>>>>>>>>>>>>>>>>>>>>>>     $k   $e[$k] \n";
      $grb=$grb;
      $all_e=$all_e."   $e[$k]";
      $k++;
    }
  }
  close(ML);
  for ($n=0;$n<$k;$n++){
    $ev=($e[$n]-$eref)*$au2ev;
    $all_ev=$all_ev."   $ev";
  }
  print OUT "$i  $all_e   $all_ev\n";
}
