#!/usr/bin/perl -w

# This program goes over each state:
#                         1 singlet a' excitation
#
#
# Total energy:                           -897.1355192598562
#
# Excitation energy:                      0.1607626555437578
#
# Excitation energy / eV:                  4.374576309342439
#
# Excitation energy / nm:                  283.4200051366915
#
# Excitation energy / cm^(-1):             35283.32445581754
#
#
# Oscillator strength:
#
#    velocity representation:             0.6364661348009015E-03
#
#    length representation:               0.7066497945553742E-03
#
#    mixed representation:                0.6706394125182397E-03
#
#
# Rotatory strength:
#
#    velocity representation:              0.000000000000000
#
#    velocity rep. / 10^(-40)erg*cm^3:     0.000000000000000
#
#    length representation:                0.000000000000000
#
#    length rep. / 10^(-40)erg*cm^3:       0.000000000000000
#
#
# Dominant contributions:
#
#    occ. orbital  energy / eV   virt. orbital  energy / eV   |coeff.|^2*100
#      31 a'         -9.07          33 a'         -2.88           28.0
#      32 a'         -8.59          33 a'         -2.88           27.4
#      24 a"         -8.76          26 a"         -2.37           23.1
#
# And writes  Table:
# 1 a' 4.374576309342439 0.7066497945553742E-03 31a'-33a' 28.0  32a'33a' 24.4  24a''-26a''23.1
#

$tmf="escf.out";
if (!-s $tmf){
  $tmf="tddft.out";
}

$fout=">collect-turbomole.dat";

open(TM,$tmf) or die ":( $tmf";
open(FO,$fout) or die ":( $fout";
while(<TM>){
   if (/IRREP/){
      while(<TM>){
         if (/excitation/){
            chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
            ($ns,$g,$sym)=split(/\s+/,$_);
             while(<TM>){
                 if (/eV:/){
                    chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
                   ($g,$g,$g,$g,$energ)=split(/\s+/,$_);
                    while(<TM>){
                       if (/Oscillator strength:/){
                          $_=<TM>;
                          $_=<TM>;
                          $_=<TM>;
                          $_=<TM>;
                          chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
                          ($g,$g,$oos)=split(/\s+/,$_);   
                          while(<TM>){
                             if (/occ. orbital/){
                                $string="";
                                for ($ind=1;$ind<=3;$ind++){
                                   $_=<TM>;
                                   chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
                                   if ($_ eq ""){
                                      last;
                                   }else{
                                      $opshell="y";
                                      if ((/alpha/) or (/beta/)){
                                         $opshell="n";
                                      }
                                      if ($opshell eq "y"){
                                        ($ni,$symi,$g,$nf,$symf,$g,$c2)=split(/\s+/,$_);
                                         $string=$string."    ".$ni.$symi."-".$nf.$symf." ".$c2;
                                      }else{
                                        ($ni,$symi,$spi,$g,$nf,$symf,$spf,$g,$c2)=split(/\s+/,$_);
                                         $spi=sprintf("%5s",$spi);
                                         $spf=sprintf("%5s",$spf);
                                         $string=$string."    ".$ni.$symi." $spi"."-".$nf.$symf." $spf"." ".$c2;
                                      }
                                   } # end if $_
                                } # end for ind
                                printf FO "%3d %4s %9.3f %8.4f %s \n",$ns,$sym,$energ,$oos,$string;
                                last;
                             } # end if occ
                          } # end while
                          last;
                       } # end if Oscillator
                    } # end while
                    last;
                 } # end if eV:
             } # end while
         }  # end if excitation
      } # end while
   }  # end if IRREP 
} # end while

close(TM);
close(FO);


