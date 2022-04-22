#!/usr/bin/perl -w

$prog     =1;
$high_c2  =0.0; #0.7;
$low_c2   =1.0; #0.1;
$IT       =1;
$FT       =35;

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
        $str2[$ns]=$_;
        $ns++;
      }
   } # end prog = 1

   # Instructions to implement any other program besides Columbus:
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
      $step    =substr($g[2],0,-1);
      $nstatdyn=$g[8];
      $ns=0;
      ($kcsf1,$c_1,$c2_1)=split(/\s+/,$str1[$nstatdyn-1]);
      if ($c2_1 < $high_c2){
         ($kcsf2,$c_2,$c2_2)=split(/\s+/,$str2[$nstatdyn-1]);
         if ($c2_2 >= $low_c2){
            if ($c_1/$c_2 < 0.0){
              $indst ="$kcsf1-$kcsf2";
            }else{
              $indst ="$kcsf1+$kcsf2";
            }
         }elsif ($c2_2 < $low_c2){
            $indst ="$kcsf1";
         }
      }elsif ($c2_1 >= $high_c2){
         $indst ="$kcsf1";
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
   print HT " $itraj    $step    $nstatdyn   $number_ref{$indst}  \n";
}
