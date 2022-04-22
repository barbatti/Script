#!/usr/bin/perl -w 
# ===================================================================================
# 
# This script reads TRAJ directories to collect kinetic energy of part of the atoms.
#
# Usage: 
# 1. Inside TRAJECTORIES, run: get_kinetic-energy_from_trajs.pl
#
# * It will ask for the initial and final trajectories.
# * It will also ask for which group of atoms you want to compute the kinetic energy.
#   The input is very flexible. For instance:
#   1-8,15-18,31-33
# * If a diag.log file is present, this script will use the suggested times there to
#   read and write the trajectories' information. 
#
# 2. After step 1, you will have a file named prop.2 looking like:
#     1  0.000  2  2.2  0.0      0.003794
#     1  0.500  2  2.2  0.0      0.002743
#      :
# The columns are:
# Trajectory number | Time (fs) | garbage | garbage | garbage | kinetic energy (au)
# (There is some garbage written because I wanted to use the analysis.exe program without further modification.) 
# 
# 3. prop.2 can be analysed with analysis.f90 program (by Pavlo).
#
# Mario Barbatti 2018-04-20
# ===================================================================================

  my ($q,$tjini,$tjfin,$l,$i,$j,$nat,$proton,@Mass,@stop,$maxtime);

# parameters and constants
  $proton  = 1822.888515;
  $maxtime = 10000;        # Trajectories analysed up to maxtime 

# log
  open(LOG,">get_kinetic-energy.log") or die "Cannot write get_kinetic-energy.log";
  #open(OUT,">kinetic_energy.dat") or die "Cannot write kinetic_energy.dat";
  open(OUT,">prop.2") or die "Cannot write prop.2";

# Inputs:
  $q="Intial trajectory (default = 1): ";
  $tjini=question($q,"1");
  $q="Final trajectory (default = 100): ";
  $tjfin=question($q,"1");
  $q="Select atoms (comma and dash separated list, e.g., 6-9,11,13): ";
  $l=question($q,"ND");
  chomp($l);$l =~ s/^\s*//;$l =~ s/\s*$//;
  @list=make_num_sequence($l);
  print LOG " Atoms to be checked: @list\n";

# Read diag.log
  read_diag();

# Loop over trajectories:
  for ($i=$tjini;$i<=$tjfin;$i++){
    print LOG ".. Reading TRAJ$i/RESULTS/dyn.out .. ";
    if (-s "TRAJ$i"){
       chdir("TRAJ$i/RESULTS");
       if ($i eq $tjini){
         read_mass();
       }
       read_ke();
       print LOG "results found \n";
       chdir("../../");
    }else{
       print LOG "results NOT found \n";
    }
  }

  close(LOG);

# ===================================================================================
# SUBROUTINES
# ===================================================================================
sub read_diag{
  my ($itrj,@g);
  for ($i=$tjini;$i<=$tjfin;$i++){
    $stop[$i]=$maxtime;
  }
  if (-s "diag.log"){
    open(DL,"diag.log") or die "Cannot read diag.log";
    while(<DL>){
      if (/TRAJECTORY /){ 
        chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
        @g=split(/\s+/,$_);
        $itrj=$g[1];                            # Find trajectory number
        chop($itrj);
        while(<DL>){
          if (/Suggestion:/){
            chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
            @g=split(/\s+/,$_);
            $stop[$itrj]=$g[6];                 # Find stop time number
            print LOG " Traj $itrj will be analysed up to time $stop[$itrj] fs.\n";
            last;
          }
        }
      }
    } 
    close(DL);
  }
}
# ===================================================================================
sub read_mass{
  my (@g);
  $nat=number_of_atoms();
  #print LOG "\nNumber of atoms: $nat\n";
  open(IN,"dyn.out") or die "Cannot open dyn.out";
  while(<IN>){
    if (/Initial geometry:/){
      for ($j=0;$j<=$nat-1;$j++){
        $_=<IN>;
        chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
        @g=split(/\s+/,$_);
        $Mass[$j]=$g[5]*$proton;
      }
      last;
    }
  } 
  close(IN);
}
# ===================================================================================
sub read_ke{
  my ($ke,@vx2,@vy2,@vz2,$t,$n);
  open(IN,"dyn.out") or die "Cannot open dyn.out";
  while(<IN>){
   if (/velocity:/){
      for ($j=0;$j<=$nat-1;$j++){
        $_=<IN>;
        chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
        @g=split(/\s+/,$_);
        $vx2[$j]=$g[0]*$g[0];
        $vy2[$j]=$g[1]*$g[1];
        $vz2[$j]=$g[2]*$g[2];
      }
   }
   if (/Time/){
      $_=<IN>;
      chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
      @g=split(/\s+/,$_);
      $t=$g[1];
      # print LOG "t = $t  stop[$i] = $stop[$i]\n";
      if ($t <= $stop[$i]){
        $ke=0.0;
        foreach(@list){
          $n=$_-1;
          $ke=$ke+0.5*$Mass[$n]*($vx2[$n]+$vy2[$n]+$vz2[$n]);
        }
        printf OUT "%5d %6.3f  2  2.2  0.0  %12.6f  \n",$i,$t,$ke;
      }else{
        last;
      }
    }
  }
  close(IN);
}
# ===================================================================================
sub question{
  my ($q,$def,$answer);
  ($q,$def)=@_;
  print STDOUT " $q";
  $_=<STDIN>;
  chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
  if ($_ eq ""){
    $answer = $def;
  }else{
    $answer=$_;
  }
  print LOG " $q  $answer \n";
  return $answer;
}
# ===================================================================================
# Date (last update): 24/03/2014                                                                       Status: Finished            |
# ---------------------------------------------------------------------------------------------------------------------------------|
# This subroutine takes a positive integer sentence like "1,5-7,10-13,9,15" and returns: (1,5,6,7,9,10,11,12,13,15). Returns error |
# if sentence contains A-Z characters. Redundancies are eliminated. Initial sentence do not need to be sorted.                     |
#                                                                                                                                  |
# Usage:  $line="1,5-7,10-13,9,15";                                                                                                |
#         @my_sequence = make_num_sequence($line);                                                                                 |
#------------------------------------------------------------ C 132 ----------------------------------------------------------------
sub make_num_sequence{
    my ($line, @vector, $i, @a, $k, @s, $last_seen);
    ($line) = @_;
    chomp($line);
    $line =~ s/\s+//g;                          # elimilate spaces
    if ($line =~ /[A-Z]/){
       die "Atom list wrong.\n";                # check whether it contain A-Z charac.
    }
    @vector = split(/,/, $line);                # split at comma
    $i = 0;
    foreach(@vector){
       if (/-/){
          @s = split(/-/, $_);                  # split at dash
          for ($k = $s[0]; $k <= $s[1]; $k++){
              $a[$i] = $k;                      # accumulates sequence
              $i++;
          }
       }else{
          $a[$i] = $_;                          # accumulates sequence
          $i++;
       }
    }
    @a = sort{$a<=>$b} @a;                      # sort numerical array
    $last_seen = -1.1;
    $i = 0;
    foreach(@a){                                # eliminate redundancies
       if ($_ != $last_seen){
          $vector[$i] = $_;
          $i++;
       }
       $last_seen = $_;
    }
    return @vector;
}
# ===================================================================================
sub number_of_atoms{
    my $nat;
    $nat=0;
    open(DO,"dyn.out")  || warn "Cannot open dyn.out";
    while (<DO>) {
      if (/geometry:/){
        while(<DO>){
          chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
          if ($_ eq ""){
            last;
          }else{
            $nat++;
          }
        }
        last;
      }
    }
    close(DO);
    return $nat;
}
# ===================================================================================
