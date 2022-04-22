#!/usr/bin/perl -w

# Collect MRCI and CASSCF results from a curve calculation with Columbus.
# Usage collect-disp-dft.pl <eref> <TYPE> <ENTER>
# eref = energy base (au) to compute DE in eV
# TYPE = mcscf or mrci

use POSIX qw(ceil floor);

open(FO,">collect-disp-columbus.dat") or die ":( collect-disp-columbus.dat";

$au2ev=27.21138386;

$WDIR="DISPLACEMENT";
$disp="displfl";

$eref=0;
if (defined($ARGV[0])){
  $eref = $ARGV[0];
  print "Reference energy: $eref\n";
}

if (defined($ARGV[1])){
  $type = $ARGV[1];
}else{
  die "\n\nType (mrci or mcscf) not found.\n Usage: collect-disp-dft.pl <eref> <TYPE> <ENTER> \n\n";
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
  $add="";
  if (-s "$WDIR/CALC.c$c.d$i"."au"){
    $add="au";
  }
  if (-s "$WDIR/CALC.c$c.d$i"."Ang"){
    $add="Ang";
  }
  chdir("$WDIR/CALC.c$c.d$i$add");
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
  if ($type eq "mcscf"){
    $logf = "LISTINGS/mcscfsm.sp";
    if (!-s $logf){
      $logf = "LISTINGS/mcscfsm.all";
    }
    open(TM,$logf) or warn ":( CALC.c$c.d$i$add/$logf";
    while(<TM>){
       if (/Individual total energies for all states:/){
          while(<TM>){           
            chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//; 
            if (!/-----/){ 
              (@g)=split(/\s+/,$_);
              $escf=$g[9];
              if ($escf =~ /,/){
                chop($escf);
              }
              $eng[$k]=$eng[$k].sprintf("%12.3f",($escf-$eref)*$au2ev);
            }else{
              last;
            }
          }
       }  
    } 
    close(TM);
  }elsif($type eq "mrci"){
    $logf = "LISTINGS/ciudgsm.sp";
    if (!-s $logf){
      $logf = "LISTINGS/ciudgsm.all";
    }
    open(TM,$logf) or warn ":( CALC.c$c.d$i$add/$logf";
    while(<TM>){
       if (/number of reference/){
          while(<TM>){
            if (/eci       =/){
              chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
              (@g)=split(/\s+/,$_);
              $escf=$g[2];
              $eng[$k]=$eng[$k].sprintf("%12.3f",($escf-$eref)*$au2ev);
            }
          }
       }
    }
    close(TM);
  }

}

