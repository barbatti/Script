#!/usr/bin/env perl
#
#
use POSIX;
use strict;
use warnings;
use Algorithm::Loops qw( NestedLoops );

print "STARTING MICROSTATES COUNTING PROGRAM\n";

my ($de,$imax,$i,$n,$min_e,$max_e,$n_bins,$zpe,$result1,$k,$nmax);
my (@f,@n,@energy,@Omega,@S);

my $kB = 0.3166813639E-5; # au/K
my $cm2au = 4.55633539E-6; # cm -> au
my $eps = 1E-8;

read_input();

microstates();

histogram();

entropy();

print "ENDING MICROSTATES COUNTING PROGRAM\n";

# ===================================================================================
#
sub read_input{
  my ($finp,$grb);

  $finp = "micro.inp";  	
  if (!-s "$finp"){
    die "Error: Missing micro.inp\n";
  }

  # Defaults
  $de = 0.01;
  $nmax = 5;

  open(INP,"$finp") or die "Cannot open $finp";
  while(<INP>){
    if (/de/){
      chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
      ($grb,$de)=split(/=/,$_);
      print "de   = $de\n";
    }
    if (/nmax/){
      chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
      ($grb,$nmax)=split(/=/,$_);
      print "nmax = $nmax\n";
    }
    if (/imax/){
      chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
      ($grb,$imax)=split(/=/,$_);
      print "imax = $imax\n";
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

  $zpe = 0.00;
  for ($i = 0; $i <= $imax-1; $i++){
    $zpe = $zpe + 0.5*$f[$i];
  }
  print "ZPE = $zpe eV\n"; 
}
# ===================================================================================
#
sub microstates{
  print "Computing microstates ...\n";
  $result1="";
  $k=0;
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

  NestedLoops(
      [  ( [ 0..$nmax ] ) x $imax  ],
      { OnlyWhen => "" },
      \&process_mst,
  );

  print "Total number of microstates = $k\n";
  print "Reordering microstates\n";
  @energy = sort @energy;
  open(OUT,">microstates.dat");
  print OUT $result1;
  close(OUT);
}
# ===================================================================================
#
sub process_mst{
  my ($e);	
  $e = $zpe;
  (@n) = @_;
  for ($i = 0; $i <= $imax-1; $i++){
    #print "$i f = $f[$i] n = $n[$i]\n";	  
    $e = $e + $f[$i]*$n[$i];
  }
  #printf "%2d %2d %2d %2d %2d %2d %12.6f\n",$n[0],$n[1],$n[2],$n[3],$n[4],$n[5],$e;
  $result1 = $result1.sprintf("%2d %2d %2d %2d %2d %2d %12.6f\n",$n[0],$n[1],$n[2],$n[3],$n[4],$n[5],$e);
  $energy[$k] = $e;
  $k++;
}
# ===================================================================================
#
sub histogram{

  $min_e = $energy[0];
  $max_e = $energy[-1];

  $n_bins = ceil( ($max_e-$min_e)/$de );

  print "Computing histogram\n";
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

  print "Computing thermodynamics\n";
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

    #print "i = $i Omega = $Omega[$i] S = $S[$i] 1/T = $invT\n";	  

    my $e_bin = $min_e + ($i+0.5)*$de;
    printf OUT2 "%8.4f %6d %8.4e %8.4e %6.1f\n",$e_bin,$Omega[$i],$S[$i],$invT,$T;
  }
  close(OUT2);

}
# ===================================================================================
