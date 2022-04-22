#!/usr/bin/perl -w

# Collect G09 TDDFT results from a curve calculation
# Usage collect-disp-gaussian.pl <logfile> <eref> <ENTER>
# logfile - log file name
# eref = DFT energy base (au) to compute DE in eV
use POSIX qw(ceil floor);

open(FO,">collect-disp-gaussian.dat") or die ":( collect-gaussian.dat";

$au2ev=27.211396;

$WDIR="DISPLACEMENT";
$disp="displfl";

$logf="gaussian.log";
if (defined($ARGV[0])){
  $logf = $ARGV[0];
}

$eref=0;
if (defined($ARGV[1])){
  $eref = $ARGV[1];
}

$dmf="distance-mw.dat";
if (-s $dmf){
  $k=0;
  open(DMF,$dmf) or warn ":( $dmf\n";
  while(<DMF>){
    chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
    $dist[$k]=$_;
    $dist[$k]=sprintf("%8.2f",$_);
    $k++;
  }
  $kmax=$k;
  close(DMF);
}else{
  for ($k=0;$k<=$kmax-1;$k++){
    $dist[$k]=sprintf("%8d",$k);
  }
}

$k=0;
open(DP,"$WDIR/$disp") or die ":( $WDIR/$disp";
$_=<DP>;
$_=<DP>;
$_=<DP>;
while(<DP>){ 
  $eng="";
  chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//; 
  ($c,$i)=split(/\s+/,$_);
  print "Collecting $c  $i \n";
  chdir("$WDIR/CALC.c$c.d$i");
  find_energy();
  print FO "$eng\n";
  chdir("../../");
  $k++;
}
close(DP);

# .............................

sub find_energy{

  if (-s "g$i-$logf"){
    $log_f="g$i-$logf";
  }else{
    $log_f=$logf;
  }
  open(TM,$log_f) or warn ":( CALC.c$c.d$i/$log_f";
  while(<TM>){
     if (/SCF Done:/){
        chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//; 
        (@g)=split(/\s+/,$_);
         $escf=$g[4];
     }  
  } 
  close(TM);
  $eng=$eng.sprintf("%12.3f    %12.3f",$dist[$k],($escf-$eref)*$au2ev);

  system("collect-gaussian.pl $log_f");
  open(CG,"collect-gaussian.dat");
  while(<CG>){
    chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//; 
    (@g)=split(/\s+/,$_);
    $eng=$eng.sprintf("%12.3f",(($g[1]/$au2ev)+$escf-$eref)*$au2ev);
  }
  close(CG);
}

