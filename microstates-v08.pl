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
#   degen   [n]              n - imax different frequencies.
#                            y - imax equal frequencies.
#                            If degen=y, the first frequency is repeated imax times.
#   diff2   [n]              m - test second derivative of Omega during microstate calculation.
#                            t - test second derivative of Omega during thermodynamics calculation.
#                            n - do not test second derivative.
#   d2k     [1]              If diff2 = m, test every d2k million points.                        
#   qreg     [n]              Quadradic regression of Omega(E)
#   ereg     [n]              Exponential regression of Omega(E)
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
# 3. ms.log - log file with running info.
#
# 4. info.dat - file basic microstate info.
# E(au) ZPE(au) (fmax-fmin)(au) imax Omega
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
# This program uses:
#   Algorithm::Loops NestedLoops 
#   Statistics::Regression;
#   Algorithm::CurveFit
#   Math::Symbolic
# from Meta-Cpan
# https://metacpan.org/pod/Algorithm::Loops
# It also use the libraries from Newton-X CS.
#
# Mario Barbatti, 2021-12-14
#

use POSIX;
use strict;
use warnings;
use Algorithm::Loops qw( NestedLoops );
use Statistics::Regression;
use lib join('/',$ENV{"NX"},"lib") ;
use colib_perl;
use Algorithm::CurveFit;
use Data::Dumper;
use Math::Symbolic qw/:all/;

open(LOG,">ms.log") or die "Cannot write to ms.log";

print LOG "\n=== STARTING MICROSTATES COUNTING PROGRAM ===\n\n";

my ($de,$imax,$i,$n,$min_e,$max_e,$n_bins,$zpe,$result1,$k,$nmax,$emax);
my (@f,@n,@energy,@Omega,@S);
my ($list_om,$intmin,$intmax,$jobtype,$njobs);
my ($kdir,$npoints,$npoints_split,$npoints_split_remain);
my ($finp,$np,$ilocmin,$ilocmax);
my ($found,$string,$fit,$degen);
my ($diff2,$d2k,$d2OdE2,$stop,$n_bins_max,$qreg,$ereg);
my ($variable,@parameters);

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

print LOG "\n=== ENDING MICROSTATES COUNTING PROGRAM ===\n\n";

close(LOG);
system("mv ms.log ms-$jobtype.log");

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
  $degen = getkeyword($finp,"degen","n");
  $diff2 = getkeyword($finp,"diff2","n");
  $d2k = getkeyword($finp,"d2k",1);
  $qreg = getkeyword($finp,"qreg","n");
  $ereg = getkeyword($finp,"ereg","n");

  print LOG "Input parameters:\n";
  print LOG "de = $de\n";
  print LOG "nmax = $nmax\n";
  print LOG "imax = $imax\n";
  print LOG "emax = $emax\n";
  print LOG "list_om = $list_om\n";
  print LOG "intmin = $intmin\n";
  print LOG "intmax = $intmax\n";
  print LOG "jobtype = $jobtype\n";
  print LOG "njobs = $njobs\n";
  print LOG "fit = $fit\n";
  print LOG "degen = $degen\n";
  print LOG "diff2 = $diff2\n";
  print LOG "d2k = $d2k\n";
  print LOG "qreg = $qreg\n";
  print LOG "ereg = $ereg\n\n";

  $emax = $emax/$au2ev;

  $d2k = $d2k*1000000;

  open(INP,"$finp") or die "Cannot open $finp";
  while(<INP>){
	  
    if (/imax/i){
      if ($degen =~ /n/){	    
        for ($i = 0; $i <= $imax-1; $i++){
  	  $_=<INP>;     
          chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
	  $f[$i]=$_;      
          print LOG "f[$i] = $f[$i]\n";
	  $f[$i] = $cm2au*$f[$i];
        }
      }elsif($degen =~ /y/){
  	$_=<INP>;     
        chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
	my $fd=$_;
        print LOG "f = $fd ($imax x degenerated)\n";
        for ($i = 0; $i <= $imax-1; $i++){
  	  $f[$i] = $cm2au*$fd;
        }
      }
    }

  }
  close(INP);

  if ($intmax == 0){
    $intmax = $nmax;
  }

  if ($njobs > $nmax+1){
    warn "Warning: njobs cannot be bigger than nmax. Are you sure do you want that?\n";	  
  }

  $zpe = 0.00;
  for ($i = 0; $i <= $imax-1; $i++){
    $zpe = $zpe + 0.5*$f[$i];
  }
  print LOG "\nZPE = $zpe au\n"; 

}
# ===================================================================================
#
sub microstates{
  print LOG "\nComputing microstates ...\n";
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

  system("rm -f microstates.dat");
  print LOG "Total number of microstates = $k\n";
  print LOG "Reordering microstates...\n";
  @energy = sort { $a <=> $b } @energy;
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
    
    if ($diff2 =~ /m/){
      if ($k == $d2k){

        $stop = "n";	

        print LOG "\nTesting second derivative after $k points\n";
        print LOG "Partial number of microstates = $k\n";
        print LOG "Reordering microstates...\n";
        @energy = sort { $a <=> $b } @energy;
        histogram();
        test_diff2();

        if ($stop =~ "y"){
           last;
        }

      }
    }

    $k++;
  }
}
# ===================================================================================
#
sub test_diff2{
  print LOG "\nTesting second derivative\n";

  for ($i = 2; $i <= $n_bins-1; $i++){
    $d2OdE2 = ($Omega[$i+1] - 2*$Omega[$i] + $Omega[$i-1])/($de*$de);
    print LOG "d2Omega/dE2($i) = $d2OdE2\n";
    if ($d2OdE2 <= 0){
      $n_bins_max = $i-1;
      $stop = "y";   
      last;
    }
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

  if (defined($n_bins_max)){
    $n_bins = $n_bins_max;
  }else{
    $n_bins = ceil( ($max_e-$min_e)/$de );
  }

  print LOG "\nComputing histogram\n";
  print LOG "Min E = $min_e\n";
  print LOG "Max E = $max_e\n";
  print LOG "Number of bins = $n_bins\n";

  for ($i = 0; $i <= $n_bins; $i++){
    $Omega[$i] = 0;
  }

  foreach(@energy){
    my $x = $_;
    for ($i = 0; $i <= $n_bins; $i++){
       if (($x > $min_e + ($i-1)*$de) and ($x <= $min_e + $i*$de)){
	  $Omega[$i]++; 
          last;	  
       }
    }    
  }

}
# ===================================================================================
#
sub entropy{
  my ($invT,$T,$e_bin);

  print LOG "\nComputing thermodynamics\n";
  open(OUT2,">thermo.dat");
  open(OUT3,">info.dat");
  for ($i = 0; $i <= $n_bins; $i++){
    if ($Omega[$i] > 0){	  
      $S[$i] = $kB*log($Omega[$i]);
    }else{
      $S[$i] = -1000;
    }
  }

  if ($diff2 =~ /t/){
    test_diff2();
    if (defined($n_bins_max)){
      $n_bins = $n_bins_max;
    }
  }

  for ($i = 0; $i <= $n_bins; $i++){

    if ($i == 0){
      $invT = 0.0;	    
    }elsif($i == 1){
      $invT = ($S[$i]-$S[$i-1])/(0.5*$de);
    }elsif(($i >= 2) and ($i < $n_bins)){
      $invT = ($S[$i+1]-$S[$i-1])/(2.0*$de);
    }elsif($i == $n_bins){
      $invT = ($S[$i]-$S[$i-1])/$de;
    }
    
    if (abs($invT) > $eps){
      $T = 1.0/$invT;
    }else{
      $T = 10000;
    }

    if ($i == 0){
      $e_bin = $min_e;
      printf OUT2 "%10.6f  %6d  %10.4e  -            -\n",$e_bin,$Omega[$i],$S[$i];
    }else{
      $e_bin = $min_e + ($i-0.5)*$de;
      printf OUT2 "%10.6f  %6d  %10.4e  %10.4e  %7.1f\n",$e_bin,$Omega[$i],$S[$i],$invT,$T;
    }
    printf OUT3 "%10.6f  %10.6f  %10.6f  %10.6f  %6d  %6d\n",$e_bin,$zpe,$f[0],$f[$imax-1],$imax,$Omega[$i];

  }
  close(OUT2);
  close(OUT3);

  if ($qreg =~ /y/){
    quadreg();
  }

  if ($ereg =~ /y/){
    expreg();
  }
  
}
# ===================================================================================
#
sub quadreg{
  my (@x,@y);
  print LOG "\nQuadratic regression with the function\n";
  #print LOG "\nf(E) = a*(Omega^2-ZPE^2) + b*(Omega-ZPE) + 1\n";
  print LOG "\nf(E) = a*Omega^2 + b*Omega + c\n";

  for ($i = 1; $i<= $n_bins;$i++){
    $x[$i-1] = $min_e + ($i-0.5)*$de;
    $y[$i-1] = $Omega[$i];  
  }

  my @model = ('const', 'X', 'X**2');

  my $reg = Statistics::Regression->new( '', [@model] );
  #$reg->include( $y[$_]-1, [ 0.0, $x[$_]-$zpe, $x[$_]**2-$zpe**2 ]) for 0..@y-1;
  $reg->include( $y[$_], [ 1.0, $x[$_], $x[$_]**2 ]) for 0..@y-1;
  my @coeff = $reg->theta();

  print LOG "a = $coeff[2]\n";
  print LOG "b = $coeff[1]\n";
  print LOG "c = $coeff[0]\n";

  my $rsq = $reg->rsq();
  print LOG "R^2 = $rsq\n";

}
# ===================================================================================
#
sub expreg{
  my (@xdata,@ydata); 
  # Known form of the formula
  my $formula = parse_from_string(<<'HERE');
      formula(a, b, c, z)
HERE
  $formula->implement(formula => '1 + a * (x-z) * exp( b * (x-z) + c * (x-z)^2 )');
  #$formula->implement(formula => '1 + a * (x-z) * exp( b*x*(log(x)-1) )');
  $formula->set_value(z => $zpe);  
  #
  # my $formula = 'a * exp(b * x)';
  print LOG "\nExponential regression with the function\n";
  #print LOG "\nf(E) = a*(Omega^2-ZPE^2) + b*(Omega-ZPE) + 1\n";
  #print LOG "\nf(E) = a*Omega^2 + b*Omega + c\n";
  for ($i = 1; $i<= $n_bins;$i++){
    $xdata[$i-1] = $min_e + ($i-0.5)*$de;
    $ydata[$i-1] = $Omega[$i];  
  }
  $variable = 'x';
  @parameters = (
    # Name    Guess   Accuracy
    ['a',  1900,    0.001],  # If an iteration introduces smaller
    ['b',    53,    0.005],  # changes that the accuracy, end.
    ['c',  -170,    0.005],  # changes that the accuracy, end.
  );
  my $max_iter = 100; # maximum iterations

  my $square_residual = Algorithm::CurveFit->curve_fit(
    formula            => $formula, # may be a Math::Symbolic tree instead
    params             => \@parameters,
    variable           => $variable,
    xdata              => \@xdata,
    ydata              => \@ydata,
    maximum_iterations => $max_iter,
  );

  print LOG "$formula\n";
  my $a = parval(0);
  my $b = parval(1);
  my $c = parval(2);
  print LOG "a = $a\n";
  print LOG "b = $b\n";
  print LOG "c = $c\n";

}
# ===================================================================================
#
sub parval{
 use Data::Dumper;
 my ($ind)=@_;
 my $testv = sprintf Dumper($parameters[$ind]);
 my (@g)=split(/\n/,$testv);
 my (@h)=split(/\'/,$g[2]);
 return $h[1];

} 
# ===================================================================================
#
sub splitjob{

  print LOG "\nSpliting job:\n";	

  $npoints = $intmax-$intmin;
  $npoints_split = int(($npoints/$njobs) + 0.5);
  $npoints_split_remain = $npoints - $npoints_split*($njobs-1) + 1;

  print LOG "$npoints quanta will be split between $njobs jobs.\n";
  print LOG "In each of the first ",$njobs-1," jobs, $npoints_split quanta will be computed.\n";
  print LOG "In the last job, $npoints_split_remain quanta will be computed\n\n";

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
 
  print LOG "Directory MST$kdir will treat quanta $ilocmin to $ilocmax\n";

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

  print LOG "\nMerging jobs:\n";

  print LOG "Checking directories and files.\n";
  for ($kdir = 1; $kdir <= $njobs; $kdir++){
    if (-s "MST$kdir"){
      if (-s "MST$kdir/thermo.dat"){
	 print LOG "MST$kdir/thermo.dat found.\n"; 
      }else{
	 die "Error: MST$kdir/thermo.dat not found.\n";     
      } 
      if (-s "MST$kdir/microstates.dat"){
	 print LOG "MST$kdir/microstates.dat found.\n";     
      }else{
	 print LOG "MST$kdir/microstates.dat not found.\n";     
         $found = $found*0;
      } 
    }else{
      die "Error: directory MST$kdir not found.\n";
    }

  }

  print LOG "\nthermo.dat files will be merged.\n";
  if ($found == 1){
    print LOG "microstates.dat files will be merged.\n";
  }else{
    print LOG "At least one microstate.dat file is missing. They will not be merged.\n";	    
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

  print LOG "Merging microstates.dat\n";

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

  print LOG "Merging thermo.dat\n";

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

  print LOG "\nComputing histogram\n";
  print LOG "Min E = $min_e\n";
  print LOG "Max E = $max_e\n";
  print LOG "Number of bins = $n_bins\n";

  chdir("MST-MERGED");
  entropy();
  chdir("../");

}
# ===================================================================================
#
