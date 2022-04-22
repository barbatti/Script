#!/usr/bin/perl -w

# Collect CC2 Turbomole results from a curve calculation
# Usage collect-disp-cc2.pl <file> <eref> <ENTER>
# file is the name of the cc2 output file.
# eref = CC2 energy base (au) to compute DE in eV
use POSIX qw(ceil floor);

open(FO,">collect-disp-cc2.dat") or die ":( collect-disp-cc2.dat";

$au2ev=27.21138386;

$WDIR="DISPLACEMENT";
$disp="displfl";

$logf="mrci.last";

$logf="ricc2.log";
if (defined($ARGV[0])){
  $logf = $ARGV[0];
}

$eref=0;
if (defined($ARGV[1])){
  $eref = $ARGV[1];
}

open(DP,"$WDIR/$disp") or die ":( $WDIR/$disp";
$_=<DP>;
$_=<DP>;
$_=<DP>;
$k=0;
while(<DP>){ 
  chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//; 
  ($c,$i)=split(/\s+/,$_);
  print "Collecting $c  $i \n";
  chdir("$WDIR/CALC.c$c.d$i");
  if (!defined($eng[$k])){
    $eng[$k]="";
  }
  find_energy();
  chdir("../../");
  $k++;
}
close(DP);
$kmax=$k;

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
  close(DMF);
}else{
  for ($k=0;$k<=$kmax-1;$k++){
    $dist[$k]=sprintf("%8d",$k);
  }
}

for ($k=0;$k<=$kmax-1;$k++){
   print FO "$dist[$k]  $eng[$k]\n";
}


# .............................

sub find_energy{

  open(TM,$logf) or warn ":( CALC.c$c.d$i/$logf";
  while(<TM>){
     if (/Final CC2/){
        chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//; 
        (@g)=split(/\s+/,$_);
         $ecc20=$g[5]; 
         $eng[$k]=$eng[$k].sprintf("%12.3f",($ecc20-$eref)*$au2ev);
     }
     if (/Energy:/){
        chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//; 
        (@g)=split(/\s+/,$_);
         $escf=$g[1];
         $eng[$k]=$eng[$k].sprintf("%12.3f",($escf+$ecc20-$eref)*$au2ev);
     }  
  } 
  close(TM);

}

