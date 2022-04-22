#!/usr/bin/perl -w

# Collect MOLCAS results from a curve calculation
# Usage collect-molcas.pl eref erefmix <ENTER>
# eref = energy base (au) to compute DE in eV
# erefmix = mixed-state energy base (au) to compute DE in eV
use POSIX qw(ceil floor);

open(OUT,">collect-molcas.dat") or die ":( collect-molcas.dat";
open(MIX,">collect-molcas-mix.dat") or die ":( collect-molcas-mix.dat";

$au2ev=27.211396;

$WDIR="DISPLACEMENT";
$disp="displfl";

$eref=0;
$erefmix=0;
if ($ARGV[0] != 0){
  $eref = $ARGV[0];
}
if ($ARGV[1] != 0){
  $erefmix = $ARGV[1];
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
  collect_emix();
}

# ..............................

sub collect_emix{
  $ncol=5;
  open(ML,"$WDIR/CALC.c$c.d$i/molcas.log") or die ":( $WDIR/CALC.c$c.d$i/molcas.log";
  while(<ML>){
    if (/Number of CI roots used/){
       @g=split(/\s+/,$_);
       $nstmix=$g[6];
       print STDOUT "\nNumber of mixed states: $nstmix \n"; 
       $q=$nstmix/$ncol;
       $nl=ceil($q);
       print STDOUT "Number of lines to be read: $nl\n";
    }
  }
  close(ML);
  open(ML,"$WDIR/CALC.c$c.d$i/molcas.log") or die ":( $WDIR/CALC.c$c.d$i/molcas.log";
  while(<ML>){
    if (/Energies and eigenvectors:/){
       $_=<ML>;
       $nmax=-1;
       if ($nl > 1){
          for ($il=1;$il<=$nl-1;$il++){
             $i0=($il-1)*$ncol;
             $_=<ML>;
             chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
             @g=split(/\s+/,$_);
             for ($k=0;$k<=$ncol-1;$k++){
                $emix[$i0+$k]=$g[$k];
                $emixev[$i0+$k]=-($erefmix-$emix[$i0+$k])*$au2ev;
                $nmax=$i0+$k;
                print  "$i  $k  $i0  $nmax   $emix[$i0+$k] \n";
             }
             for ($k=1;$k<=$nstmix+2;$k++){
                $_=<ML>;
             }
          }
       }
       $_=<ML>;
       chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
       @g=split(/\s+/,$_);
       $rem=$nstmix-$ncol*($nl-1);
       for ($k=1;$k<=$rem;$k++){
          $emix[$nmax+$k]=$g[$k-1];
          $emixev[$nmax+$k]=-($erefmix-$emix[$nmax+$k])*$au2ev;
          print  "$i  $k   $nmax   $emix[$nmax+$k] \n";
       }
    }
  }
  close(ML);
  print MIX "$i   @emix    @emixev\n";
}

# ..............................

