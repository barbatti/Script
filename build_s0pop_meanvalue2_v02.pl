#!/usr/bin/perl -w

#
# Given a sequence of hop times to a precomputed mean_value.2 NX file,
# this program rebuilds s0 occupation.
#
# Mario Barbatti Nov 2014
# v.02: 2018-09-17: This version fixes problems when S1 does not tend to 1.
#                   Now all states are corrected.

$prop="mean_value.2";
$hopf="hops";
$outf="new_mean_value.2";

check_files();
number_of_trajs();
number_of_states();
read_hops();
build_pop();

#====================================================================
sub build_pop{
# Typical row in mean_value.2:
#"    0.00  43    0.000    0.000    0.000    0.070    0.070    0.258    0.163    0.163    0.374"
#
 open(IN1,$prop) or die ":( $prop";
 open(OUT,">$outf") or die ":( $outf";
 $nh=0;
 $n_hop=0;
 $fraction=0.0;
 while(<IN1>){
   chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
   @g=split(/\s+/,$_);
   format_g();
   if ($nh<=$#nhop){
     $next_hop=$nhop[$nh];
   }
   if ($g[0]==$next_hop){
     $n_hop=$n_hop+$kd[$nh];
     print " Hops at t=$g[0] = $n_hop\n";
     $nh++;
   }
   $fraction=$n_hop/$ntraj;
   print " Fraction at t=$g[0] = $fraction (=$n_hop/$ntraj)\n";
   $g[2]=sprintf("%9.3f",$fraction);
   $sum=$g[2];
   for ($ist=1;$ist<=$nst-1;$ist++){
     $ist_ind=5+3*($ist-1);
     $g[$ist_ind]=sprintf("%9.3f",(1-$fraction)*$g[$ist_ind]);
     $sum=$sum+$g[$ist_ind];
   }
   $total=sprintf("%9.3f",$sum);
   print OUT "@g\n";
   print " Total population at t=$g[0] = $total\n";
   $sum=0;
 } 
 close(OUT);
 close(IN1);
}
#====================================================================
sub format_g{
   $g[0]=sprintf("%8.2f",$g[0]);
   $g[1]=sprintf("%4d",$g[1]);
   for ($i=2;$i<=$#g;$i++){
     $g[$i]=sprintf("%9.3f",$g[$i]);
   }

}
#====================================================================
sub number_of_states{
  read_ntrajs();
  $nst=($#g+1-2)/3;
  print " Number of states in mean_value.2: $nst\n";
}
#====================================================================
sub number_of_trajs{
  print " Enter number of trajectories (Press <ENTER> to read from mean_value.2): ";
  $_=<STDIN>;
  chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
  if ($_ eq ""){
    read_ntrajs();
    $ntraj=$g[1];
  }else{
    $input=$_;
    if ($input =~ /^[\+-]*[0-9]*\.*[0-9]*$/ && $input !~ /^[\. ]*$/) { # numeric?
      $ntraj=$input; 
    }else{ #non-numeric
      die " ntraj = $input, but it should be a number. Try again\n\n";
    }
  }
  print " Number of trajs is: $ntraj\n";
}
#====================================================================
sub read_ntrajs{
 open(IN1,$prop) or die ":( $prop";
 $_=<IN1>;
 chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
 @g=split(/\s+/,$_); 
 close(IN1);
}
#====================================================================
sub check_files{
  if (!-s $prop){
    die " $prop is empty or does not exist. Ending program.\n\n";
  }

  if (!-s $hopf){
    die "
 $hopf is empty or does not exist.
 Prepare a list of S1/S0 hopping times in fs, 
 one in each line and run this program again. 
 Ending program.\n\n";
  }
}
#====================================================================
sub read_hops{
 my ($n);
 print " The following hops will be considered:\n";
 $i=0;
 open(IN2,$hopf) or die ":( $prop";
 while(<IN2>){
   chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
   $hop[$i]=$_;
   $i++;
 }
 close(IN2);
 @hop=sort{$a<=>$b} @hop;                # sort numerical array
 print " @hop\n";
 @kd=0;
 $n=0;
 for ($i=1;$i<=$#hop+1;$i++){
   if ((defined($hop[$i])) and ($hop[$i] == $hop[$i-1])){
     $kd[$n]++;    
   }else{
     $kd[$n]++;    
     $nhop[$n]=sprintf("%7.2f",$hop[$i-1]);
     $n++;
   }
 }
 for ($i=0;$i<=$#nhop;$i++){
   printf "%4d   %7.2f   %4d\n",$i,$nhop[$i],$kd[$i];
 }
}
#====================================================================
