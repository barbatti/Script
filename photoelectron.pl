#!/usr/bin/perl -w
#
# This program computes photoelectron spetrum as
# I(E) = sigma(E)*SUM_i[g(E-IP_i,DE)]/E^2,
# where sigma = absorption cross section (cross_section.dat)
#       IP_i  = ionization potential i (list single column in eV in ips.dat)
#       g     = line shape with width DE
# I(E) is in arbitrary units.
#
# The factor E^-2 comes from the relation:
# sigma_(photoelectron) = sigma_(absorption)/E^2
# See Sakurai, section 5.7.
# 
# Mario Barbatti, April 2011.
# 

# Constants:
$pi = 3.141592653589793;

# files:
$f_sig="cross-section.dat";
$f_ips="ips.dat";
$f_log="photoelectron.log";
$f_out="photoelectron.dat";

open(LOG,">$f_log") or die ":( $f_log";
print LOG "====== START PHOTOELECTRON SIMULATION ======\n\n";

read_inputs();
read_ips();
read_sigma();

if (-s $f_out){
  print LOG " Energies, wavelengths, cross sections, photoelectron probability and photoelectron intensities \n were written to $f_out\n";
}else{
  print LOG " File $f_out does not exist or is empty. Something is wrong.\n Check inputs and run again\n";
}

print LOG "======= END PHOTOELECTRON SIMULATION =======\n\n";
close(LOG);

# ===================================================================================
sub read_inputs{
  print LOG "\nStarting reading inputs ...\n";
  $q="Line shape type (gauss = 1 (default) ; lorentz = 2): ";
  $l=question($q,"1");
  if ($l == 2){
    $l_shape="lorentz";
  }else{
    $l_shape="gauss";
  }
  $q="Line shape width (default 0.4 eV): ";
  $DE=question($q,"0.4");
}
# ===================================================================================
sub read_ips{
  open(IPS,$f_ips) or die "Cannot find file $f_ips with IP_i information.\n";
  print LOG "\nStarting reading IP_i ...\n";
  $i=0;
  while(<IPS>){
     chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
     $ip[$i]=$_;
     printf LOG "  IP %5d    %16.8f  eV\n",$i,$ip[$i];
     $i++;
  }
  $imax=$i-1;
  print LOG "  IMAX = $imax\n\n";
  close(IPS);
}
# ===================================================================================
sub read_sigma{
  open(SIG,$f_sig) or die "Cannot find file $f_sig with cross section information.\n";
  open(OUT,">$f_out") or die "Cannot find file $f_out.\n";
  print LOG "\nStarting computing intensities ...\n";
  while(<SIG>){
     chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
     ($E,$lambda,$sigma)=split(/\s+/,$_);
     compute_intensity();    
  }
  print LOG "\n";
  close(OUT);
  close(SIG);
}
# ===================================================================================
sub compute_intensity{
  $pe = 0.0;
  for ($i = 0; $i <= $imax;  $i++ ){
    if ($l_shape eq "gauss"){
      $function=gauss_func();
    }elsif($l_shape eq "lorentz"){
      $function=lorentz_func();
    }
    $pe = $pe + $function;
  }
  $E2=$E*$E;
  #$pe=$pe/$E2;
  $Intens = $sigma*$pe;
  printf OUT "%12.4f  %12.4e   %16.8f   %16.8f   %16.8f\n",$E,$lambda,$sigma,$pe,$Intens;
}
# ===================================================================================
sub gauss_func{
# Gaussian function
  my ($gauss);
  $gauss = 1/($DE*sqrt($pi/2))*exp(-2*($E-$ip[$i])**2/$DE**2);
  return $gauss;
}
# ===================================================================================
sub lorentz_func{
# Lorentzian function
  my ($lorentz);
  $lorentz = $DE/(2*$pi)*1/(($E-$ip[$i])**2+($DE/2)**2);
  return $lorentz;
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

