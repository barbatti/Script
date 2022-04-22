#!/usr/bin/perl -w

# Collect MRCI/DFT results from a curve calculation
# Usage collect-disp-dft.pl <eref> <ENTER>
# eref = DFT/MRCI energy base (au) to compute DE in eV
use POSIX qw(ceil floor);

open(FO,">collect-disp-dftci.dat") or die ":( collect-dftci.dat";

$au2ev=27.21138386;

$WDIR="DISPLACEMENT";
$disp="displfl";

$logf="mrci.last";
#$logf="mrci.2.log";

$eref=0;
if (defined($ARGV[0])){
  $eref = $ARGV[0];
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
     if (/          DFTCI/){
        chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//; 
        (@g)=split(/\s+/,$_);
         $escf=$g[4];
         $eng[$k]=$eng[$k].sprintf("%12.3f",($escf-$eref)*$au2ev);
     }  
  } 
  close(TM);

}

