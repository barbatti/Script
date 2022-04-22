#!/usr/bin/perl -w

# This program goes over each state, reads:
#       Energy:     0.2220223 H      6.04154 eV    48728.254 cm-1
#
#     +=======================================================================+
#     | type: RE0                    symmetry: a'              state:    5    |
#     +-----------------------+-----------------------+-----------------------+
#     | occ. orb.  index spin | vir. orb.  index spin |  coeff/|amp|     %    |
#     +=======================+=======================+=======================+
#     |   32 a'      38       |   34 a'      59       |   0.57258      32.8   |
#     |   25 a"      57       |   26 a"     204       |   0.57007      32.5   |
#     |   20 a"      52       |   26 a"     204       |   0.30002       9.0   |
# ...
#       oscillator strength (length gauge)   :      0.13174591
# And writes:
# 5 a' 6.04154 0.13174591 32a'-34a' 32.0  25a"26a" 32.5  20a"-26a" 9.0
#

$tmf="ricc2.out";
$fout=">collect-turbomole-cc2.dat";

$i=0;
open(TM,$tmf) or die ":( $tmf";
open(FO,$fout) or die ":( $fout";
while(<TM>){
   if (/oscillator strength \(l/){
      chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
      @g=split(/\s+/,$_);
      $oos[$i]=$g[5];
      $i++;
   }
}
close(TM);

$i=0;
open(TM,$tmf) or die ":( $tmf";
while(<TM>){
   if (/Energy:/){
      chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
      @g=split(/\s+/,$_);
      $energ=$g[3];
      $_=<TM>;$_=<TM>;$_=<TM>;
      chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
      @g=split(/\s+/,$_);
      $sym=$g[4];
      $ns=$g[6]; 
      $_=<TM>;$_=<TM>;$_=<TM>;
      $string="";
      for ($ind=1;$ind<=3;$ind++){
         $_=<TM>;
         chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
         if ($_=~/\=/){
             last;
         }else{
             ($g,$ni,$symi,$g,$g,$nf,$symf,$g,$g,$g,$c2)=split(/\s+/,$_);
             $label=sprintf("%13s",$ni.$symi."-".$nf.$symf);
             #$string=$string."    ".$ni.$symi."-".$nf.$symf." ".$c2;
             $c2=sprintf("%4.1f",$c2);
             $string=$string."  ".$label."  ".$c2;
         } # end if $_
      } # end for ind
      printf FO "%3d %4s %8.2f %8.3f %s \n",$ns,$sym,$energ,$oos[$i],$string;
      $i++;
   } # end if Energy:
} # end while TM

close(TM);
close(FO);
