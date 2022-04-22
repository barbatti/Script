#!/usr/bin/perl -w
# This program reads the wavefunction information in nx.log (or moldyn.log)
# and analyses the state character using this information.
#
# The present version reads NX outputs with TURBOMOLE (TDDFT only) and COLUMBUS.
# Information about how it can be extended to other methods is given below at the end
# of routine read_state.
#
# The parameters for this program should be set directly in the code below:
# PROG    - program information (1 - Columbus; 2 - Turbomole TDDFT; 2.1 - Turbomole CC2/ADC(2))
# HIGH_C2 - Threshold for the first CI coefficient (see explanation below).
# LOW_C2  - Threshold for the second CI coefficient (see explanation below).
# IT      - initial trajectory
# FT      - final trajectory
# -----------------------------------------------
# SET PARAMETERS HERE:
# -----------------------------------------------
  $prog     =2.1;
  $high_c2  =0.0; #0.5; #0.0; #0.7;
  $low_c2   =1.0; #0.2; #1.0; #0.1;
  $IT       =1;
  $FT       =7;
# -----------------------------------------------
#
# For each step in the dynamics, the program reads the CI information for the most important 
# and second most important configuration contributing to the current electronic state (NSTATDYN).
#
# For a certain state, the coefficiemt squared for the most important configuration (C1**2)
# is compared to HIGH_C2. Each different CI vector (step vector or orbital occupation scheme)
# is labeled in stat_on_csf.log.
#
# If C1(state n)**2 > HIGH_C2 then the electronic state is considered to be a single reference state
# and it is labeled with the same label attributed to C1 CI vector. 
# If C1(state n)**2 <= HIGH_C2 then the second more important configuration (C2**2) is compared to LOW_C2.
# If C2(state n)**2 > LOW_C2 then the electronic state is considered a multireference state
# with two important CI configurations. This linear combination is also labeled in stat_on_csf.log.
# If C2(state n)**2 <= LOW_C2 the C1 is treated as single reference and labeled as such. 
#
# HIGH_C2 = 0 and LOW_C2 = 1 means only the most important configuration will be used in the analysis 
# of the state (the state will be always treated as single reference).
#
# Two log files are written:
#
# 1) stat_on_csf.log - contains the labels of the states.
# For Turbomole (TDDFT) it may contain a list like:
# STATE=1   IND=17,21
# STATE=2   IND=18,24
# STATE=3   IND=18,23
# ...
# This means that State 1 is dominated by an excitation from orbital 17 into orbital 21.
#
# For Columbus it may contain a list like:
# STATE=1   IND=11
# STATE=2   IND=2
# STATE=3   IND=176
# ...
# This means that State 1 is dominated by CSF number 11 (Columbus' DRT file order).
#
# 2) history - contains the state classification for all trajectories from IT to FT for all time steps.
#
# This file may look like (for Turbomole (TDDFT)):
# ...
#    4       41.00    9   60.400    24.600      6   18,25
#    4       41.50    9   47.900    39.500      6   18,25
#    4       42.00    9   53.200    33.400      2   18,24
# ...
# This means, e.g.
# Trajectory 4 at time 42.00 fs was in state 9 (8th excited state).
# This state had C**2 equal 53.2% for the main configuration and 33.4% for the second main one. 
# This state was classified as state 6, corresponding to an excitation from orbital 18 to 24.
# 
# This progran was written by Mario Barbatti, 2009-2013.
#

@ref_list=0;
$nref=0;
$ns=0;

open(LG,">stat_on_csf.log") or die ":( stat_on_csf.log";
open(HT,">history") or die ":( history";

for ($itraj=$IT;$itraj<=$FT;$itraj++){
  read_traj();
}

close(HT);
close(LG);

#------------------------------------------------------------------------
sub read_traj{
   $skip="no";
   $flog="TRAJ$itraj/RESULTS/nx.log";
   if (-s $flog){
     open(FL,$flog) or warn ":( $flog";
   }elsif(!-s $flog){
      $flog="TRAJ$itraj/moldyn.log";
      if(-s $flog){
        open(FL,$flog) or warn ":( $flog";
      }elsif(-s $flog){
         warn "Cannot find either moldyn.log or nx.log. Skiping TRAJ$itraj.\n";
         $skip="yes";
      }
   }

   if ($skip eq "no"){
      while(<FL>){
         read_state();
      }            
      close($flog);
   }
}
#------------------------------------------------------------------------
sub read_state{
# PROG = 1 (COLUMBUS)
# Read blocks like:
#   indcsf     c     c**2   v  lab:rmo  lab:rmo   step(*)
#  ------- -------- ------- - ---- --- ---- --- ------------
#        1  0.95426 0.91060 z*                    333333333333333333333333333333333330
#        2  0.11629 0.01352 z*                    333333333333333333333333333333333312
#        3 -0.10204 0.01041 z*                    333333333333333333333333333333333303
#
#   indcsf     c     c**2   v  lab:rmo  lab:rmo   step(*)
#  ------- -------- ------- - ---- --- ---- --- ------------
#        4  0.68362 0.46733 z*                    333333333333333333333333333333333132
#        7 -0.51022 0.26033 z*                    333333333333333333333333333333331332
#       99  0.25423 0.06463 y           a  : 37  1333333333333333333333333333333333320
#
#            FINISHING STEP        1, TIME     0.50 fs on SURFACE        4

   if ($prog == 1){
      if (/indcsf     c/){
        $_=<FL>;
        $_=<FL>;
        chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
        $str1[$ns]=$_;
        $_=<FL>;
        chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
        if ($_ ne ""){
          $str2[$ns]=$_;
        }else{
          $str2[$ns]="undef 0.0 0.0";
        }
        $ns++;
      }
   } # end prog = 1

# PROG = 2 (TDDFT - TURBOMOLE)
# Read blocks like:
# Dominant contributions:
#
#    occ. orbital  energy / eV   virt. orbital  energy / eV   |coeff.|^2*100
#      18 a          -6.27          19 a          -0.23           98.8
#
# Dominant contributions:
#
#    occ. orbital  energy / eV   virt. orbital  energy / eV   |coeff.|^2*100
#      18 a          -6.27          23 a           1.06           63.7
#      17 a          -6.89          21 a           0.58           12.9
#      18 a          -6.27          24 a           1.13           10.0
#
#            FINISHING STEP        1, TIME     0.50 fs on SURFACE        4

   if ($prog ==2){
      if (/Dominant contributions:/){
        if ($ns == 0){
          $str1[0]="undef 0.0 0.0";
          $str2[0]="undef 0.0 0.0";
          $ns = 1;
        }
        $_=<FL>;
        $_=<FL>;
        $_=<FL>;
        chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
        @g=split(/\s+/,$_);
        $stind=$g[0].",".$g[3];
        $c1=sqrt($g[6]/100);
        $c21=$g[6]/100;
        $str1[$ns]=$stind." ".$c1." ".$c21; 
        $_=<FL>;
        chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
        if ($_ ne ""){
          @g=split(/\s+/,$_);
          $stind=$g[0].",".$g[3];
          $c2=sqrt($g[6]/100);
          $c22=$g[6]/100;
          $str2[$ns]=$stind." ".$c2." ".$c22; 
        }else{
          $str2[$ns]="undef 0.0 0.0";
        }       
        $ns++;
      }
   }

# PROG = 2.1 (CC2/ADC(2) - TURBOMOLE)
# Read blocks like:
#Information about the excited states:
#     | type: RE0                    symmetry: a               state:    1    |
#     +-----------------------+-----------------------+-----------------------+
#     | occ. orb.  index spin | vir. orb.  index spin |  coeff/|amp|     %    |
#     +=======================+=======================+=======================+
#     |   33 a       33       |   42 a       42       |   0.57883      33.5   |
#     |   33 a       33       |   41 a       41       |   0.45664      20.9   |
#     |   33 a       33       |   46 a       46       |  -0.37548      14.1   |
#
#     | type: RE0                    symmetry: a               state:    2    |
#     +-----------------------+-----------------------+-----------------------+
#     | occ. orb.  index spin | vir. orb.  index spin |  coeff/|amp|     %    |
#     +=======================+=======================+=======================+
#     |   34 a       34       |   42 a       42       |   0.43494      18.9   |
#     |   35 a       35       |   46 a       46       |  -0.40395      16.3   |
#     |   34 a       34       |   48 a       48       |   0.33679      11.3   |

   if ($prog ==2.1){
      if (/occ. orb.  index spin /){
        if ($ns == 0){
          $str1[0]="undef 0.0 0.0";
          $str2[0]="undef 0.0 0.0";
          $ns = 1;
        }
        $_=<FL>;
        $_=<FL>;
        chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
        @g=split(/\s+/,$_);
        $stind=$g[1].",".$g[5];
        $c1=$g[9];
        $c21=$g[10]/100;
        $str1[$ns]=$stind." ".$c1." ".$c21;
        $_=<FL>;
        chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
        if ($_ ne ""){
          @g=split(/\s+/,$_);
          $stind=$g[1].",".$g[5];
          $c2=$g[9];
          $c22=$g[10]/100;
          $str2[$ns]=$stind." ".$c2." ".$c22;
        }else{
          $str2[$ns]="undef 0.0 0.0";
        }
        $ns++;
      }
   }


   # Instructions to implement any other program besides Columbus and Turbomole (TDDFT/CC2/ADC(2)):
   # At this point the program should have a space separated array of strings containing:
   # srt1[1]="kscf1 c1 c2_1"    
   # srt2[1]="kscf2 c2 c2_2"    
   # srt1[2]="kscf1 c1 c2_1"    
   # srt1[2]="kscf2 c2 c2_2"    
   # :          :
   # srt2[nstat]="kscf1 c1 c2_1"  
   #
   # kcsf1, c1 and c2_1 are, respectively, the identity of the most important configuration, 
   # its ci coefficient, and the squared ci coefficient.
   # kcsf2, c2 and c2_2 are the same for the second most important configuration.
   # The array runs from state 1 to the highest excited state (nstat).

   if (/FINISHING STEP/){
      chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
      @g       =split(/\s+/,$_);
      $time    =$g[4];
      $nstatdyn=$g[8];
      $ns=0;
      ($kcsf1,$c_1,$c2_1)=split(/\s+/,$str1[$nstatdyn-1]);
      ($kcsf2,$c_2,$c2_2)=split(/\s+/,$str2[$nstatdyn-1]);
      if ($c2_1 < $high_c2){
        # ($kcsf2,$c_2,$c2_2)=split(/\s+/,$str2[$nstatdyn-1]);
         if ($c2_2 >= $low_c2){
            if ($c_1/$c_2 < 0.0){
              $indst ="$kcsf1-$kcsf2";
              $indst1 ="$kcsf2-$kcsf1";
            }else{
              $indst ="$kcsf1+$kcsf2";
              $indst1 ="$kcsf2+$kcsf1";
            }
         }elsif ($c2_2 < $low_c2){
            $indst ="$kcsf1";
            $indst1="$kcsf1";
         }
      }elsif ($c2_1 >= $high_c2){
         $indst ="$kcsf1";
         $indst1="$kcsf1";
      }
      new_ref_check();
      print_hist();
   }
}
#------------------------------------------------------------------------
sub new_ref_check{

   $new_ref="yes";
   for ($iref=0;$iref<=$nref-1;$iref++){
      if ($indst eq $ref_list[$iref]){
        $new_ref="no";
        last;
      }elsif($indst1 eq $ref_list[$iref]){
        $new_ref="no";
        $indst=$indst1;
        last;
      }
   }
   if ($new_ref eq "yes"){
      $ref_list[$nref]=$indst;
      $number_ref{$indst}=$nref+1;
      print LG " STATE=$number_ref{$indst}   IND=$indst \n";
      $nref++;
   }

}
#------------------------------------------------------------------------
sub print_hist{
   printf HT "%5d  %10.2f  %3d   %6.3f    %6.3f   %4d   %s\n",$itraj,$time,$nstatdyn,$c2_1,$c2_2,$number_ref{$indst},$indst;
}
