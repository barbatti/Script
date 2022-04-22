#!/usr/bin/perl -w

# Read Trajectories, collect the geometries and write to file dyn-n.mld.
#
# Input parameters:
# itraj  - initial trajectory
# ftraj  - final trajectory
# is     - initial state
# fs     - final state
# type   - Type of criteria (1 or 2, see below)
# de_min - minimum energy gap (eV) 
# de_max - maximum energy gap (eV) 
# first  - Y: stop searching after the first match in the file 
#          N: search all matches in the file
# back   - Y: check both directions (is->fs and fs->is)
#          N: check only up -> down direction
# type:
# 1. Search for energy gaps between states is and fs in the range [DEMIN,DEMAX].
# Ex: DE < 0.3; is = 1 (GS); fs = 2 
# Look at typeofdyn.log. The line below matches the parameters:
# Time =   81.00   Threshold=****   PES = 2   DE_inf =  0.21   DE_sup =  2.24   Type = 4   Next type = 4
#
# 2. Search for hoppings between is and fs also satisfying the energy criteria above.
# Ex: is = 1; fs = 2
# Look at typeofdyn.log. The line below matches the parameters:
# Time =   81.50   Threshold=****   PES = 1   DE_inf = -----   DE_sup =  0.28   Type = 4   Next type = 3
#

open(LOG,">get_geom_in_dyn.log") or die ":( get_geom_in_dyn.log!";

read_parameters();
$k=1;
open(DM,">dyn$type.mld") or die ":( dyn$type.mld";
for ($it=$itraj;$it<=$ftraj;$it++){
  read_typeofdyn();
}
close(DM);

close(LOG);

# ------------------------------------------------------------------------------------
sub read_parameters{
  print LOG " Input parameters:\n";
  $q="Initial trajectory: ";
  $itraj=question($q);
  $q="Final trajectory: ";
  $ftraj=question($q);
  $q="Initial state: ";
  $is=question($q);
  $q="Final state: ";
  $fs=question($q);
  $q="Type of analysis (1- Gap; 2 - Hopping): ";
  $type=question($q);
  $q="Minimum energy gap (eV): ";
  $demin=question($q);
  $q="Maximum energy gap (eV): ";
  $demax=question($q);
  $q="Match only the first occurence in the file (Y/N): ";
  $first=question($q);
  $q="Check both directions (Y/N)? ";
  $back=question($q);
  print LOG "\n";
  # Number of atoms
  $nat=0;
  $dmld="TRAJ$itraj/RESULTS/dyn.mld"; 
  if (-s $dmld){
    open(DD,$dmld) or warn ":( $dmld";
    $_=<DD>;
    close(DD);
    chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
    $nat=$_;
  }
  print LOG " Number of atoms: $nat\n";
  # Time step (fs)
  $dt = 0.0;
  $gout="TRAJ$itraj/RESULTS/dyn.out";
  if (-s $gout){
    open(DD,$gout) or warn ":( $gout";
    while(<DD>){
      if (/Output/){
        chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
        @g=split(/\s+/,$_);
        $dt = $g[8];
        last;
      }    
    }
    close(DD);
  }
  print LOG " Time step: $dt\n";
  print LOG "\n\n";
}
# ------------------------------------------------------------------------------------
sub question{
  my ($q,$answer);
  ($q)=@_;
  print STDOUT " $q";
  $_=<STDIN>;
  chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
  $answer=$_;
  print LOG " $q  $answer \n";
  return $answer;
}
# ------------------------------------------------------------------------------------
sub read_typeofdyn{
  $file = "TRAJ$it/RESULTS/typeofdyn.log"; 
# time 0
  open(FL,$file) or warn ":( $file";
  $_=<FL>;
  read_line(0);
  $time0 = $time[0];
  close(FL);
# time criterion
  open(FL,$file) or warn ":( $file";
  while(<FL>){
    read_line(0);
    $_=<FL>;
    if (defined($_)){
      read_line(1);
    }else{
      same_line();
    }
    check_criteria();
    if ($match=~/Y/i){
       rw_geom();
       if ($first=~/Y/i){
         last;
       }
    }
  }
  close(FL);
}
# ------------------------------------------------------------------------------------
sub read_line{
   my ($i);
   ($i)=@_;
   chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
   @g =split(/\s+/,$_);
   $time[$i]   = $g[2];
   $surf[$i]   = $g[6];
   $de_inf[$i] = $g[9];
   $de_sup[$i] = $g[12];
   $tp[$i]     = $g[15];
   $next[$i]   = $g[19];
   if ($de_inf[$i] eq "----"){
      $de_inf[$i] = 1000;
   }
   if ($de_sup[$i] eq "----"){
      $de_sup[$i] = 1000;
   }
}
# ------------------------------------------------------------------------------------
sub same_line{
   $next[0]   = $tp[0];
   $time[1]   = $time[0];
   $surf[1]   = $surf[0];
   $de_inf[1] = $de_inf[0];
   $de_sup[1] = $de_sup[0];
   $tp[1]     = $tp[0];
   $next[1]   = $next[0];
}
# ------------------------------------------------------------------------------------
sub check_criteria{
   $match="N";
   if ($type == 1){
      criteria_1();
   }elsif($type == 2){
      criteria_2();
   }
}
# ------------------------------------------------------------------------------------
sub criteria_1{
   if ($is < $fs){
     $iup=$fs;
     $idown=$is;
   }elsif($is > $fs){
     $iup=$is;
     $idown=$fs;
   }  
   if ($surf[0] == $iup){
     if (($de_inf[0] >= $demin) and ($de_inf[0] < $demax)){
       $match="Y";
       message($de_inf[0]);
     }
   }
   if ($back=~/Y/i){
     if ($surf[0] == $idown){
       if (($de_sup[0] >= $demin) and ($de_sup[0] < $demax)){
         $match="Y";
         message($de_sup[0]);
       }
     }
   }
}
# ------------------------------------------------------------------------------------
sub criteria_2{
   my ($criterium);
   $criterium = "N";
   if ($back=~/Y/i){
     if (($surf[0] == $is) and ($surf[1] == $fs)
      or ($surf[0] == $fs) and ($surf[1] == $is)){
       $criterium = "Y";
     }
   }else{
     if (($surf[0] == $is) and ($surf[1] == $fs)){
       $criterium = "Y";
     }
   }
   if ($criterium eq "Y"){
     print STDOUT ">>>> $it   $time[0] \n";
     criteria_1();     
   }
}
# ------------------------------------------------------------------------------------
sub rw_geom{
   $dmld="TRAJ$it/RESULTS/dyn.mld";
   $step=int(($time[0]-$time0)/$dt);
   open(DD,$dmld) or warn ":( $dmld";
     for ($l=1;$l<=($nat+2)*($step-1);$l++){
        $_=<DD>;
     }
     for ($l=1;$l<=($nat+2);$l++){
        $_=<DD>;
        print DM $_;
     }
   close(DD);
}
# ------------------------------------------------------------------------------------
sub message{
  ($de_curr)=@_;
  printf LOG "TRAJ: %5d  TIME: %8.2f (fs)  PES_I: %3d PES_F: %3d DE: %8.2f (eV) -> POSITIVE MATCH: %5d \n",$it,$time[0],$surf[0],$surf[1],$de_curr,$k;
  $k++;
}
# ------------------------------------------------------------------------------------
