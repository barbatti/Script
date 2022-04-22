#!/usr/bin/perl -w

# Collect ADC(2) Turbomole results from a curve calculation.
# Usage collect-disp-adc2.pl <file> <eref> <otyp> <ENTER>
# file is the name of the adc(2) output file.
# eref = MP2 energy base (au) to compute DE in eV
# otyp = 1 (length); 2 (velocity); 3(mixed) oscillator strength gauge.

use POSIX qw(ceil floor);

open(FO,">collect-disp-adc2-e.dat") or die ":( collect-disp-adc2-e.dat";
open(FS,">collect-disp-adc2-f.dat") or die ":( collect-disp-adc2-f.dat";
open(RF,">command_line") or die ":( command_line";

$au2ev=27.21138386;

$WDIR="DISPLACEMENT";
$disp="displfl";

$logf="mrci.last";

$logf="ricc2.out";
if (defined($ARGV[0])){
  $logf = $ARGV[0];
}

$eref=0;
if (defined($ARGV[1])){
  $eref = $ARGV[1];
}

$otyp=1;
if (defined($ARGV[2])){
  $otyp = $ARGV[2];
}
if ($otyp == 1){
  $gauge="length";
}elsif($otyp == 2){
  $gauge="velocity";
}elsif($otyp == 3){
  $gauge="mixed";
}

print RF "colect-disp-adc2.pl was run with the following options:\n";
print RF "$logf $eref $otyp\n";

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
  if (!defined($osc[$k])){
    $osc[$k]="";
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
   print FS "$dist[$k]  $osc[$k]\n";
}


# .............................

sub find_energy{

  open(TM,$logf) or warn ":( CALC.c$c.d$i/$logf";
  while(<TM>){
     if (/Final MP2/){
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
     if (/oscillator strength \($gauge/){
        chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//; 
        (@g)=split(/\s+/,$_);
         $osc[$k]=$osc[$k].sprintf("%12.4f",$g[5]);
     }  
  } 
  close(TM);

}

