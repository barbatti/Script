#!/usr/bin/perl -w

# Collect Turbomole TDDFT results from a curve calculation
# Usage collect-disp-tm-tddft.pl eref <ENTER>
# eref = DFT energy base (au) to compute DE in eV
use POSIX qw(ceil floor);

open(FO,">collect-disp-tm-tddft.dat") or die ":( collect-disp-tm-tddft.dat";

$au2ev=27.211396;

$WDIR="DISPLACEMENT";
$disp="displfl";

$eref=0;
if (defined($ARGV[0])){
  $eref = $ARGV[0];
}

$distf="distance-mw.dat";
if (-s $distf){
  open(DT,$distf) or die ":( $distf";
}else{
  $d_ind=0;
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
  if (-s $distf){
    $dist=<DT>;
    chomp($dist);$dist =~ s/^\s*//;$dist =~ s/\s*$//;
  }else{
    print "no\n";
    $dist=$d_ind;
    $d_ind++;
  }
  chdir("$WDIR/CALC.c$c.d$i");
  find_energy();
  print FO "\n";
  chdir("../../");
}
close(DP);
if (-s $distf){
  close(DT);
}

# .............................

sub find_energy{

$tmf="escf.out";
if (!-s $tmf){
  $tmf="tddft.out";
}

open(TM,$tmf) or die ":( $tmf";
while(<TM>){
   if (/IRREP/){
      while(<TM>){
         if (/Ground state/){
           while(<TM>){
              if (/Total energy:/){
                  chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
                  ($g,$g,$energ)=split(/\s+/,$_);
                  $energ=($energ-$eref)*$au2ev;
                  printf FO "%9.3f   %9.3f ",$dist,$energ;
                  last;
              }
           }
         }
         if (/excitation/){
            chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
            ($g,$g,$g)=split(/\s+/,$_);
             while(<TM>){
                 if (/Total energy:/){
                    chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
                   ($g,$g,$energ)=split(/\s+/,$_);
                    $energ=($energ-$eref)*$au2ev;
                    while(<TM>){
                       if (/Oscillator strength:/){
                          $_=<TM>;
                          $_=<TM>;
                          $_=<TM>;
                          $_=<TM>;
                          chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
                          #($g,$g,$oos)=split(/\s+/,$_);   
                          #printf FO "%9.3f %8.4f ",$energ,$oos;
                          printf FO "%9.3f ",$energ;
                          last;
                       } # end if Oscillator
                    } # end while
                    last;
                 } # end if Total energy:
             } # end while
         }  # end if excitation
      } # end while
   }  # end if IRREP 
} # end while

close(TM);

}

