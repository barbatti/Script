#!/usr/bin/perl -w

#
# Given a sequence of hop times to a precomputed mean_value.2 NX file,
# this program rebuilds s0 occupation.
#
# Mario Barbatti Nov 2014
#

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
 $pop0=0.0;
 while(<IN1>){
   chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
   @g=split(/\s+/,$_);
   format_g();
   high_pop();
   if ($nh<=$#nhop){
     $next_hop=$nhop[$nh];
   }
   if ($g[0]!=$next_hop){
     $g[2]=sprintf("%9.3f",$g[2]+$pop0);
 #    $g[5]=sprintf("%9.3f",$g[5]-$pop0);
     $g[5]=sprintf("%9.3f",1-$popH-$pop0);
     print OUT "@g\n";
   }else{
     $pop0=$pop0+$kd[$nh]/$ntraj;
     $g[2]=sprintf("%9.3f",$g[2]+$pop0);
 #    $g[5]=sprintf("%9.3f",$g[5]-$pop0);
     $g[5]=sprintf("%9.3f",1-$popH-$pop0);
     format_g();
     print OUT "@g\n";
     $nh++;
   }

 } 
 close(OUT);
 close(IN1);
}
#====================================================================
sub high_pop{
  my ($i);
  $popH=0.0;
  if ($nst > 2){
    for ($i=3;$i<=$nst;$i++){
      $popH=$popH+$g[3*$i-1];
    }
  }
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
     sprintf("%7d",$kd[$n]++);    
     $nhop[$n]=sprintf("%7.2f",$hop[$i-1]);
     $n++;
   }
 }
 for ($i=0;$i<=$#nhop;$i++){
   printf "%4d   %7.2f   %4d\n",$i,$nhop[$i],$kd[$i];
 }
}
#====================================================================
