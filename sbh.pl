#!/usr/bin/perl -w
#
# Spin-Boson Hamiltonian in adiabatic representation
#
# Input 1: sbh.par
# Keyword    Meaning                     Units      Default
# nstatdyn   Current state               -            2 (NX must rewtite it every Dt)
# e0         Energy split                hartree      0
# Delta      Energy coupling             hartree      0.05
# N          Number of oscillators       -            1
# wc         Characteristic freq         cm-1        1000
# wmax       Cutoff freq                 cm-1        4000
# Jw         Type of spectral dens       -           debye
#            It can be: debye
#                       ohmic
#                       user
# xi         Kondo parameter for         -           0
#            Jw=debye  
# Er         Reorganization energy for   -           0
#            Jw=ohmic
# Example:
#  e0 = 0.2
#  N = 100
#
# Input 2: user_sd_shb.inp (required if Jw=user)
# Give a list of N w_j and g_j, one pair per line.
# In NX, it should be in JOB_NAD.
#
# Input 3: geom
# Geometry in NX format (with masses).
# The bath oscillator coordiates should be in bohr in the X column.
# Y and Z columns must be zero. Masses in amu.
# Symbols and atomic numbers are not read in this routine.
# 
# Outputs in NX format: epot, grad, grad.all, and nad_vectors
#
# Mario Barbatti 2017-10-25
#
# Define variables, paths and files.....................................
use Math::Trig;
use lib join('/',$ENV{"NX"},"lib") ;
use colib_perl;
$mld        = $ENV{"NX"};                  # NX environment
$mdle       = "sbh.pl:";
$BASEDIR    = `pwd`;
chomp ($BASEDIR);
$DEBG       = "DEBUG";
$RS         = "RESULTS";
$JNAD       = "JOB_NAD";
# log file of the analytical program:
$analytlog  = "sbh.log";
# Newton X information:
$ctd        = "control.d";
#.......................................................................

$hbar=1.0;
$cm2au=units("cm2au");
$proton=units("proton");
$zero=0.0;

open(LOG,">>$analytlog");

# Read control.d 
  if (-s $ctd){
    read_ctd();
  }

# Read parameters
  read_par();

# Read geometry and masses
  read_geom();

# Prepare intermediary quantities
  properties();

# Compute energies
  energies();

# Compute gradients
  gradients();

# Compute couplings
  couplings();

close(LOG);

# 
#====================================================================
sub read_par{
  my $file="sbh.par";
  if (!-s $ctd){
    $nstatdyn=getkeyword($file,"nstatdyn",2);  
  }
  $e0      =getkeyword($file,"e0",0);
  $Delta   =getkeyword($file,"Delta",0.05);
  $N       =getkeyword($file,"N",1);
  $wc_cm   =getkeyword($file,"wc",1000);
  $wmax_cm =getkeyword($file,"wmax",4000);
  $Jw      =getkeyword($file,"Jw","debye");
  if ($Jw eq "debye"){
    $xi    =getkeyword($file,"xi",0);
  }elsif($Jw eq "ohmic"){
    $Er    =getkeyword($file,"Er",0);
  }
  $wc=$wc_cm*$cm2au;
  $wmax=$wmax_cm*$cm2au;
}
#====================================================================
sub read_geom{
  my $file="geom";
  open(GE,$file) or die "Cannot read $file.";
  $j=0;
  while(<GE>){
    chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
    @GEOM=split(/\s+/,$_);
    $Q[$j]=$GEOM[2];
    $M[$j]=$GEOM[5];
    print LOG "Q[$j] = $Q[$j]   M[$j] = $M[$j]\n";
    $j++;
  }
  close(GE);
  if ($j != $N){
    exit "Number of atoms in $file ($j) is not N ($N). Please check.\n";
  }
}
#====================================================================
sub properties{
  # eta constant
  $eta=$e0;
  for ($j=0;$j<=$N-1;$j++){
    $eta=$eta+$g[$j]*sqrt($M[$j])*$Q[$j];
  }
  $factor=sqrt($eta**2+$Delta**2);
  # spectral density
  J_w();
}
#====================================================================
sub energies{
  my $file="epot";
  open(OUT,">$file") or die "Cannot write to $file";
  printf LOG "%8.3f ";
  for ($i=0;$i<=1;$i++){
    $Vi=(-1)**($i)*$factor;
    for ($j=0;$j<=$N-1;$j++){
      $Vi=$Vi+0.5*$M[$j]*$w[$j]**2*$Q[$j]**2;      
    }
    printf OUT "%20.12f\n",$Vi;
    printf LOG "  %20.12f",$Vi;
  }
  close(OUT);
  print LOG "\n";
}
#====================================================================
sub gradients{
  my $file1="grad";
  my $file2="grad.all";
  open(OUT1,">$file1") or die "Cannot write to $file1";
  open(OUT2,">$file2") or die "Cannot write to $file2";
  for ($i=0;$i<=1;$i++){
    for ($j=0;$j<=$N-1;$j++){
      my $A1=$M[$j]*$w[$j]**2*$Q[$j];
      my $A2=(-1)**($i)*$g[$j]*sqrt($M[$j])*($eta/$factor);
      $dVi=$A1+$A2;
      if ($i == $nstatdyn-1){
        printf OUT1 "%20.12f %20.12f %20.12f\n",$dVi,$zero,$zero;
      }
      printf OUT2 "%20.12f %20.12f %20.12f\n",$dVi,$zero,$zero;
    }
  }
  close(OUT1);
  close(OUT2);
}
#====================================================================
sub couplings{
  my $file="nad_vectors";
  open(OUT,">$file") or die "Cannot write to $file";
  for ($i=0;$i<=1;$i++){
    for ($j=0;$j<=$N-1;$j++){
      $F12=0.5*$g[$j]*sqrt($M[$j])*($Delta/$factor);
      printf OUT "%20.12f %20.12f %20.12f\n",$F12,$zero,$zero;
    }
  }
  close(OUT);
}
#====================================================================
sub J_w{
   if ($Jw eq "debye"){
     debye_sd();
   }elsif($Jw eq "ohmic"){
     ohmic_sd();
   }elsif($Jw eq "user"){
     user_sd();
   }else{
     exit "Unknown spectral density. Program will stop\n";
   }
}
#====================================================================
sub debye_sd{
  for ($j=0;$j<=$N-1;$j++){
     $atan=atan($wmax/$wc);
     $w[$j]=tan($j/$N)*$atan;
     $g[$j]=sqrt($Er/pi/$N*$atan)*$w[$j]; 
  }
}
#====================================================================
sub ohmic_sd{
  for ($j=0;$j<=$N-1;$j++){
    $w0=$wc/$N*(1.0-exp(-$wmax/$wc));
    $w[$j]=-$wc*ln(1.0-$j*$w0/$wc);
    $g[$j]=sqrt($xi*$hbar*$w0*$M[$j])*$w[$j];
  }
}
#====================================================================
sub user_sd{
  my $file="user_sd_sbh.inp";
  open(IN,$file) or die "Cannot find $file.\n";
  my $j=0;
  while(<IN>){
    chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
    ($w[$j],$g[$j])=split(/\s+/,$_);
    print LOG "w [$j] = $w[$j]   g[$j] = $g[$g]\n";
    $j++;
  }
  if ($j != $N){
    exit "Number of frequencies in $file ($j) is not equal N ($N). Please check.\n";
  }
  close(IN);
}
#====================================================================
sub read_ctd{
# Read control.d
 ($nat,$istep,$nstat,$nstatdyn,$ndamp,$kt,$dt,$t,$tmax,$nintc,
  $mem,$nxrestart,$thres,$killstat,$timekill,$prog,$lvprt,$etot_jump,
  $etot_drift)=load_status($ctd,$mdle);
}
#====================================================================
