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
  read_line();
  $time0 = $time;
  close(FL);
# time criterion
  open(FL,$file) or warn ":( $file";
  while(<FL>){
    read_line();
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
   chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
   @g =split(/\s+/,$_);
   $time = $g[2];
   $surf = $g[6];
   $de_inf = $g[9];
   $de_sup = $g[12];
   $tp   = $g[15];
   $next = $g[19];
   if ($de_inf eq "----"){
      $de_inf = 1000;
   }
   if ($de_sup eq "----"){
      $de_sup = 1000;
   }
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
   if ($surf == $iup){
     if (($de_inf >= $demin) and ($de_inf < $demax)){
       $match="Y";
       message($de_inf);
     }
   }
   if ($back=~/Y/i){
     if ($surf == $idown){
       if (($de_sup >= $demin) and ($de_sup < $demax)){
         $match="Y";
         message($de_sup);
       }
     }
   }
}
# ------------------------------------------------------------------------------------
sub criteria_2{
   if ($tp != $next){
     print STDOUT ">>>> $tp    $next \n";
     criteria_1();     
   }
}
# ------------------------------------------------------------------------------------
sub rw_geom{
   $dmld="TRAJ$it/RESULTS/dyn.mld";
   $step=int(($time-$time0)/$dt);
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
  print LOG "TRAJ: $it  TIME: $time (fs)  PES: $surf DE: $de_curr (eV) -> POSITIVE MATCH: $k \n";
  $k++;
}
# ------------------------------------------------------------------------------------
