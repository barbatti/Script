#!/usr/bin/perl -w
#
# Given log files for two excited state outputs,
# It finds the first band and computes P.
# Requires the following programs to run:
# 1) collect-X.pl (X = gaussian only in this version)
# 2) simple_spectrum_convolution.pl
# Mario Barbatti, July, 2013.
#
#

# Input

initial_banner();
input_values();
run_progs();
P_parameter();
end_prog();

# ================================================================
sub initial_banner{
 $log="find_first_band.log";
 open(LOG,">$log") or die ":( $log";
 print LOG "     =========================\n";
 print LOG "     ==   Find First Band   ==\n";
 print LOG "     =========================\n";
}
# ================================================================
sub input_values{

  # Input files
  for ($i=0;$i<=1;$i++){
    $i1=$i+1;
    print "Enter input file $i1: ";
    $_=<STDIN>;
    chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
    $file[$i]=$_;
    if (!-s "$file[$i]"){
      die "$file[$i] does not exist or is empty!"
    }
    undef($_);
  }
  print LOG "Collecting data from files:\n$file[0]\n$file[1]\n\n";

  # Program used in the calculations. Only G09 in the present version.
  print " These are oputputs for which program? [G09 - default] ";
  $_=<STDIN>;
  chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
  $prog=lc $_;
  if ($prog eq ""){
    $prog = "g09"; # default value
  }
  if ($prog ne "g09"){
    die "Cannot recognize program: $prog\n"
  }

  # Define collect script. Only G09 in the present version.
  if ($prog eq "g09"){
    $collect="collect-gaussian.pl";
    $collog="collect-gaussian.dat";
  }

  # simple_spectrum_convolution.pl.
  $ssc="simple_spectrum_convolution.pl";

  # Theshold for minimum intensity of the first band:
  print " Minimum intensity of the band [0.05 - default]: ";
  $_=<STDIN>;
  chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
  if ($_ eq ""){
    $imin=0.05; # default
  }else{
    $imin=$_;
  }
  print LOG "Minimum intensity of the band [0.05 - default]: $imin\n";

  # Theshold for first derivative (1/eV):
  print " Threshold for determining zero in the first derivative [0.05 eV^-1 - default]: ";
  $_=<STDIN>;
  chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
  if ($_ eq ""){
    $eps=0.05; # default
  }else{
    $eps=$_;
  }
  print LOG "Threshold for determining zero in the first derivative (eV^-1): $eps\n\n";
}
# ================================================================
sub run_progs{
  for ($i=0;$i<=1;$i++){
    $i1=$i+1;
    print "\n ===== Collecting data and running spectrum for file $i1. ==== \n";
    print LOG " Collecting data from file $i1.\n";
    system("$collect $file[$i]");
    system("mv $collog f$i1-$collog"); 
    print LOG " Preparing exf for file $i1.\n";
    make_exf();
    system("cp -f f$i1-exf exf");
    print LOG " Simple spectrum for file $i1.\n";
    system($ssc);
    system("mv -f spect_conv.dat f$i1-spect_conv.dat");
    system("mv -f spect_conv.log f$i1-spect_conv.log");
    system("rm -f exf");
    first_derivative();
  }
}
# ================================================================
sub make_exf{
  # Only coded for G09 in this version
  if ($prog eq "g09"){
    open(IN,"f$i1-$collog") or die ":( f$i1-$collog";
    open(OUT,">f$i1-exf") or die ":( f$i1-exf";
    while(<IN>){
      chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
      @g=split(/\s+/,$_);
      print OUT "$g[1]  $g[2]\n";
    }
    close(OUT);
    close(IN);
  }
}
# ================================================================
sub first_derivative{
  open(IN,"f$i1-spect_conv.dat") or die ":( f$i1-spect_conv.dat";
  $k=0;
  while(<IN>){
    chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
    @g=split(/\s+/,$_);
    $eng[$k]=$g[0];
    $int[$k]=$g[2];
    $k++;
  }
  close(IN);
  $N=$k-1;
  print LOG " Computing first derivative for spectrum $i1 (N=$N)\n";
  open(IN,">f$i1-dint") or die ":( f$i1-dint";
  $m=0;
  for ($k=1;$k<=$N-1;$k++){
    $dint[$k]=($int[$k+1]-$int[$k-1])/($eng[$k+1]-$eng[$k-1]);
    print IN "$eng[$k]  $int[$k]  $dint[$k]\n";
    if (($dint[$k] < $eps) and ($int[$k] >= $imin)){
      $x[$m]=$eng[$k];
      $y[$m]=$int[$k];
      $m++;
    }
  }
  close(IN);
  if ($m > 0){
    $eng_max[$i1]=$x[0];
    $int_max[$i1]=$y[0];
  }else{
    print LOG "No maxima was found in the spectrum for a threshold of $eps/eV.\n";
    end_prog();
  }
}
# ================================================================
sub P_parameter{
  print LOG "\n";
  print LOG " Characterization of the first band\n";
  print LOG " File         Energy       Intensity\n";
  print LOG "  1           $eng_max[1]      $int_max[1]\n";
  print LOG "  2           $eng_max[2]      $int_max[2]\n";

  $P=abs($int_max[1]+$int_max[2])*abs($eng_max[2]-$eng_max[1]);

  print LOG "\n P = $P\n\n";
}
# ================================================================
sub end_prog{
  print LOG "======== Normal termination of the program ========\n";
  close(LOG);
  exit;
}
# ================================================================

