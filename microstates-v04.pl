#!/usr/bin/env perl
#
# This program computes the microstates of an ensemble of quantum harmonic oscillators.
# It takes micro.inp as input. This file may contain the following keywords:
#   Keyword  Default  Unity  Description
#   -------  -------  -----  -----------
#   jobtype  [run]           run - compute microstates and thermodynamics.
#                            split - only split and prepare several jobs.
#                            merge - merge the results from previous jobs.
#   de       [0.01]   eV     Bin size of equiprobable microstates. 
#   nmax     [5]             Maximum number of quanta in each mode.
#   imax     [-]             Number of modes followed by vibrational frequencies (cm-1),
#                            with one per line.
#   emax     [4.0]    eV     Discard microstates with energies above this threshold.
#   list_om  [n]             Write (y) or not (n) list of microstates.
#   intmin   [0]             Minimum number of quanta in the internal loop. 
#   intmax   [nmax]          Maximum number of quanta in the internal loop.
#   njobs    [1]             Number of jobs for jobtype = split and merge.
#   fit      [y]             Type of histogram scale.
#                            y - scale is set in the minimum/maximum energy range.
#                            n - scale uses zpe/emax energy range.
#                            fit = n is needed for merging jobs.
#
# Example of micro.inp:
#   nmax = 10
#   de = 0.005
#   imax = 6
#   345.96
#   956.41
#   1330.32
#   1468.85
#   3704.25
#   3708.87
#   emax = 4
#   list_om = Y
#   fit = y
#
# The results are written to:
# 1. microstates.dat - list of microstates with their energies in the order:
# n1  n2  ...  n_imax  Energy (au)
#
# Example for imax = 6:
# 0  0  0  0  0  0     0.026232
# 0  0  0  0  0  1     0.043131
# 0  0  0  0  0  2     0.060030
# :  :
#
# 2. thermo.dat - histogram properties containing:
# E (au)   Omega   S (au/K)  1/T (K^-1)  T (K)
#
# where
# E is the harmonic oscillator energy. 
# Omega is the number of microstates with energy E +/- de/2.
# S = kB*ln(Omega) is the entropy.
# 1/T = dS/dE is the inverse of the temperature.
#
# Example:
#  0.0387     13 8.1227e-06 6.0519e-04 1652.4
#  0.0437     30 1.0771e-05 4.7359e-04 2111.5
#  0.0487     58 1.2859e-05 4.0270e-04 2483.2
#  :
#
# The number of microstates grow very quickly and they easily either
# take forever to be computed or take all computer memory.
#
# Therefore, be careful setting imax and nmax values.
# Setting a small value for emax reduces the memory consumption,
# but it does not reduce the computational time.
# intmin and intmax can used to split the job in several shorter ones. 
# For intance, the job with nmax = 10, can be split in two, the first with
#  intmin = 0
#  intmax = 5
# and the second with 
#  intmin = 6
#  intmax = 10
# Each job should be excecuted separately and merged afterward. 
# This split and merging can be automatically done with typejob keyword.
#
# This program uses Algorithm::Loops NestedLoops from Meta-Cpan:
# https://metacpan.org/pod/Algorithm::Loops
# It also use the libraries from Newton-X CS.
#
# Mario Barbatti, 2021-12-14
#

use POSIX;
use strict;
use warnings;
use Algorithm::Loops qw( NestedLoops );
use lib join('/',$ENV{"NX"},"lib") ;
use colib_perl;

print "\n=== STARTING MICROSTATES COUNTING PROGRAM ===\n\n";

my ($de,$imax,$i,$n,$min_e,$max_e,$n_bins,$zpe,$result1,$k,$nmax,$emax);
my (@f,@n,@energy,@Omega,@S);
my ($list_om,$intmin,$intmax,$jobtype,$njobs);
my ($kdir,$npoints,$npoints_split,$npoints_split_remain);
my ($finp,$np,$ilocmin,$ilocmax);
my ($found,$string,$fit);

my $au2ev = units("au2ev"); # au -> eV
my $kB = units("BK"); # au/K
my $cm2au = units("cm2au"); # cm -> au
my $eps = 1E-8; 

read_input();

if ($jobtype =~ /run/i){

  microstates();
  histogram();
  entropy();

}elsif($jobtype =~ /split/){

  splitjob();

}elsif($jobtype =~ /merge/){

  mergejob();

}

print "\n=== ENDING MICROSTATES COUNTING PROGRAM ===\n\n";

# ===================================================================================
#
sub read_input{
  my ($grb);

  $finp = "micro.inp";  	
  if (!-s "$finp"){
    die "Error: Missing micro.inp\n";
  }

  $de = getkeyword($finp,"de",0.01);
  $nmax = getkeyword($finp,"nmax",5);
  $emax = getkeyword($finp,"emax",101);
  $imax = getkeyword($finp,"imax",101);
  $list_om = getkeyword($finp,"list_om","n");
  $intmin = getkeyword($finp,"intmin",0);
  $intmax = getkeyword($finp,"intmax",0);
  $jobtype = getkeyword($finp,"jobtype","run");
  $njobs = getkeyword($finp,"njobs",1);
  $fit = getkeyword($finp,"fit","n");

  print "Input parameters:\n";
  print "de   = $de\n";
  print "nmax = $nmax\n";
  print "imax = $imax\n";
  print "emax = $emax\n";
  print "list_om = $list_om\n";
  print "intmin = $intmin\n";
  print "intmax = $intmax\n";
  print "jobtype = $jobtype\n";
  print "njobs = $njobs\n";
  print "fit = $fit\n";

  $emax = $emax/$au2ev;

  open(INP,"$finp") or die "Cannot open $finp";
  while(<INP>){
    if (/imax/i){
      for ($i = 0; $i <= $imax-1; $i++){
	$_=<INP>;     
        chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
	$f[$i]=$_;      
        print "f[$i] = $f[$i]\n";
	$f[$i] = $cm2au*$f[$i];
      }
    }
  }
  close(INP);

  if ($intmax == 0){
    $intmax = $nmax;
  }

  if ($njobs > $nmax){
    warn "Error: njobs cannot be bigger than nmax. Are you sure do you want that?\n";	  
  }

  $zpe = 0.00;
  for ($i = 0; $i <= $imax-1; $i++){
    $zpe = $zpe + 0.5*$f[$i];
  }
  print "ZPE = $zpe eV\n"; 

}
# ===================================================================================
#
sub microstates{
  print "\nComputing microstates ...\n";
  $result1="";
  $k=0;

# If NestedLoops is not installed in your system,
# you can replace it by explicit loops.
# For instance, for imax = 6, the code would be:
#   
#  for ($n[5] = 0; $n[5] <= $nmax; $n[5]++){
#    for ($n[4] = 0; $n[4] <= $nmax; $n[4]++){
#      for ($n[3] = 0; $n[3] <= $nmax; $n[3]++){
#        for ($n[2] = 0; $n[2] <= $nmax; $n[2]++){
#          for ($n[1] = 0; $n[1] <= $nmax; $n[1]++){
#            for ($n[0] = 0; $n[0] <= $nmax; $n[0]++){
#
#	      process_mst();
#
#            }
#          }
#        }
#      }
#    }
#  }
#
  NestedLoops(
      [  ( [ 0..$nmax ] ) x ($imax-1), ( [ $intmin .. $intmax ] )  ],
      { OnlyWhen => "" },
      \&process_mst,
  );

  print "Total number of microstates = $k\n";
  print "Reordering microstates...\n";
  @energy = sort @energy;
  if ($list_om =~ /y/i){
    open(OUT,">microstates.dat");
    print OUT $result1;
    close(OUT);
  }
}
# ===================================================================================
#
sub process_mst{
  my ($e);	
  $e = $zpe;
  (@n) = @_;
  for ($i = 0; $i <= $imax-1; $i++){
    $e = $e + $f[$i]*$n[$i];
  }
  if ($e <= $emax){
    if ($list_om =~ /y/i){	  
      $result1 = $result1.sprintf("%2d %2d %2d %2d %2d %2d %12.6f\n",$n[0],$n[1],$n[2],$n[3],$n[4],$n[5],$e);
    }
    $energy[$k] = $e;
    $k++;
  }
}
# ===================================================================================
#
sub histogram{

  if ($fit =~ /y/i){
    $min_e = $energy[0];
    $max_e = $energy[-1];
  }else{
    $min_e = $zpe;
    $max_e = $emax;
  }

  $n_bins = ceil( ($max_e-$min_e)/$de );

  print "\nComputing histogram\n";
  print "Min E = $min_e\n";
  print "Max E = $max_e\n";
  print "Number of bins = $n_bins\n";

  for ($i = 1; $i <= $n_bins; $i++){
    $Omega[$i] = 0;
  }

  foreach(@energy){
    my $x = $_;
    for ($i = 1; $i <= $n_bins; $i++){
       if (($x >= $min_e + ($i-1)*$de) and ($x < $min_e + $i*$de)){
	  $Omega[$i]++; 
          last;	  
       }
    }    
  }

}
# ===================================================================================
#
sub entropy{
  my ($invT,$T);

  print "\nComputing thermodynamics\n";
  open(OUT2,">thermo.dat");
  for ($i = 1; $i <= $n_bins; $i++){
    if ($Omega[$i] > 0){	  
      $S[$i] = $kB*log($Omega[$i]);
    }else{
      $S[$i] = -1000;
    }
  }

  for ($i = 1; $i <= $n_bins; $i++){

    if ($i == 1){
      $invT = 0.0;	    
    }elsif($i == 2){
      $invT = ($S[$i]-$S[$i-1])/$de
    }elsif(($i >= 3) and ($i < $n_bins)){
      $invT = ($S[$i+1]-$S[$i-1])/(2.0*$de)
    }elsif($i == $n_bins){
      $invT = ($S[$i]-$S[$i-1])/$de
    }
    
    if (abs($invT) > $eps){
      $T = 1.0/$invT;
    }else{
      $T = 10000;
    }

    my $e_bin = $min_e + ($i-0.5)*$de;
    printf OUT2 "%10.6f  %6d  %10.4e  %10.4e  %7.1f\n",$e_bin,$Omega[$i],$S[$i],$invT,$T;
  }
  close(OUT2);

}
# ===================================================================================
#
sub splitjob{

  print "\nSpliting job:\n";	

  $npoints = $intmax-$intmin;
  $npoints_split = int(($npoints/$njobs) + 0.5);
  $npoints_split_remain = $npoints - $npoints_split*($njobs-1) + 1;

  print "$npoints quanta will be split between $njobs jobs.\n";
  print "In each of the first ",$njobs-1," jobs, $npoints_split quanta will be computed.\n";
  print "In the last job, $npoints_split_remain quanta will be computed\n\n";

  for ($kdir = 1; $kdir <= $njobs; $kdir++){
     if (-s "MST$kdir"){
       die "Error: found preexistent MST* directories. Delete them and run the program again.\n";
     }	  
     system("mkdir MST$kdir");	 
     system("cp -f $finp MST$kdir/$finp"); 
     change_key();
  }

}
# ===================================================================================
#
sub change_key{

  if ($kdir < $njobs){
    $np = $npoints_split;
  }elsif($kdir == $njobs){
    $np = $npoints_split_remain;
  }
  $ilocmin = $intmin + ($kdir-1)*$npoints_split;
  $ilocmax = $intmin + ($kdir-1)*$npoints_split + $np - 1;
 
  print "Directory MST$kdir will treat quanta $ilocmin to $ilocmax\n";

  $found = searchkeyword("MST$kdir/$finp","jobtype");
  if ($found == 0){
    addkeyword("MST$kdir/$finp","MST$kdir/$finp","jobtype","run");
  }else{
    changekeyword("MST$kdir/$finp","MST$kdir/$finp","jobtype","run");
  }

  $found = searchkeyword("MST$kdir/$finp","intmin");
  if ($found == 0){
    addkeyword("MST$kdir/$finp","MST$kdir/$finp","intmin",$ilocmin);
  }else{
    changekeyword("MST$kdir/$finp","MST$kdir/$finp","intmin",$ilocmin);
  }

  $found = searchkeyword("MST$kdir/$finp","intmax");
  if ($found == 0){
    addkeyword("MST$kdir/$finp","MST$kdir/$finp","intmax",$ilocmax);
  }else{
    changekeyword("MST$kdir/$finp","MST$kdir/$finp","intmax",$ilocmax);
  }

  $found = searchkeyword("MST$kdir/$finp","fit");
  if ($found == 0){
    addkeyword("MST$kdir/$finp","MST$kdir/$finp","fit","n");
  }else{
    changekeyword("MST$kdir/$finp","MST$kdir/$finp","fit","n");
  }

}
# ===================================================================================
#
sub mergejob{

  check_jobs();

  create_dir();
  
  if ($found == 1){
    merge_ms();
  }

  merge_th();

}
# ===================================================================================
#
sub check_jobs{

  $found = 1;

  print "\nMerging jobs:\n";

  print "Checking directories and files.\n";
  for ($kdir = 1; $kdir <= $njobs; $kdir++){
    if (-s "MST$kdir"){
      if (-s "MST$kdir/thermo.dat"){
	 print "MST$kdir/thermo.dat found.\n"; 
      }else{
	 die "Error: MST$kdir/thermo.dat not found.\n";     
      } 
      if (-s "MST$kdir/microstates.dat"){
	 print "MST$kdir/microstates.dat found.\n";     
      }else{
	 print "MST$kdir/microstates.dat not found.\n";     
         $found = $found*0;
      } 
    }else{
      die "Error: directory MST$kdir not found.\n";
    }

  }

  print "\nthermo.dat files will be merged.\n";
  if ($found == 1){
    print "microstates.dat files will be merged.\n";
  }else{
    print "At least one microstate.dat file is missing. They will not be merged.\n";	    
  }

}
# ===================================================================================
#
sub create_dir{
  if (-s "MST-MERGED"){
    system("rm -rf MST-MERGED");
  }
  system("mkdir MST-MERGED");
}
# ===================================================================================
#
sub merge_ms{

  print "Merging microstates.dat\n";

  $string="";
  for ($kdir = 1; $kdir <= $njobs; $kdir++){
    $string = $string." MST$kdir/microstates.dat";
  }

  system("cat $string > MST-MERGED/microstates.dat");
}
# ===================================================================================
#
sub merge_th{
  my (@g);

  print "Merging thermo.dat\n";

  $i = 0;
  open(IN,"MST1/thermo.dat") or die "Cannot open MST1/thermo.dat.";
  while(<IN>){
     chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
     (@g)=split(/\s+/,$_);
     $energy[$i] = $g[0];
     $i++;
  }
  close(IN);

  $n_bins = @energy;
  $de = $energy[1]-$energy[0];
  $min_e = $energy[0] - 0.5*$de;
  $max_e = $energy[-1]+ 0.5*$de;

  for ($i = 1; $i <= $n_bins; $i++){
    $Omega[$i] = 0;
  }

  for ($kdir = 1; $kdir <= $njobs; $kdir++){
     $i = 1;	  
     open(IN,"MST$kdir/thermo.dat") or die "Cannot open MST$kdir/thermo.dat."; 
     while(<IN>){
        chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
        (@g)=split(/\s+/,$_);
        
	$energy[$i] = $g[0];
	$Omega[$i]  = $Omega[$i] + $g[1];

        $i++;
     }
     close(IN); 
  }

  print "\nComputing histogram\n";
  print "Min E = $min_e\n";
  print "Max E = $max_e\n";
  print "Number of bins = $n_bins\n";

  chdir("MST-MERGED");
  entropy();
  chdir("../");

}
# ===================================================================================
#
