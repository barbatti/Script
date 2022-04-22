#!/usr/bin/perl -w
#
# This program takes a sequence of E and f and convolutes them with a line shape: 
# I(x) = SUM_i[f*g(x-E,DE)].
#
# Mario Barbatti, April 2011.
# 

# Constants:
$pi = 3.141592653589793;
$xmin=0.8; # minimum DE (eV) in the scale 

# files:
$f_ips="exf"; # Two columns, space separated: E f
$f_log="spect_conv.log";
$f_out="spect_conv.dat";

open(LOG,">$f_log") or die ":( $f_log";
print LOG "====== START CONVOLUTION ======\n\n";

read_inputs();
read_ef();
read_convolute();

if (-s $f_out){
  print LOG " Energies and intensities \n were written to $f_out.\n\n";
}else{
  print LOG " File $f_out does not exist or is empty. Something is wrong.\n Check inputs and run again.\n\n";
}

print LOG "======= END CONVOLUTION =======\n\n";
close(LOG);

# ===================================================================================
sub read_inputs{
  print LOG "\nStarting reading inputs ...\n";
  $q="Line shape type (gauss = 1 (default) ; lorentz = 2 ; pseudo-voigt = 3): ";
  $l=question($q,"1");
  if ($l == 2){
    $l_shape="lorentz";
  }elsif($l == 1){
    $l_shape="gauss";
  }elsif($l == 3){
    $l_shape="voigt";
    $q="Voigt mixing parameter (default 0.5 eV): ";
    $eta=question($q,"0.5");
  }
  $q="Line shape width (default 0.4 eV): ";
  $DE=question($q,"0.4");
  $q="Distance between points (default 0.05 eV): ";
  $dx=question($q,"0.05");
  $q="Determine domain automatically? (y(default)/ n) ";
  $auto_domain=question($q,"y");
  if ($auto_domain eq "n"){
    $q="Minimum value of E axis (default = 0 eV): ";
    $min=question($q,"0");
    $q="Maximum value of E axis (default = 20 eV): ";
    $max=question($q,"20");
  }
}
# ===================================================================================
sub read_ef{
  open(IPS,$f_ips) or die "Cannot find file $f_ips with E and f information.\n";
  print LOG "\nStarting reading E and f ...\n";
  $i=0;
  while(<IPS>){
     chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
     ($E[$i],$f[$i])=split(/\s+/,$_);
     $i++;
  }
  $imax=$i-1;
  print LOG "  IMAX = $imax\n\n";
  close(IPS);
  max_min();
}
# ===================================================================================
sub max_min{
  if ($auto_domain eq "y"){
    $min=$E[0];
    $max=$E[0];
    foreach(@E){
      if ($_ < $min){
        $min=$_;
      }
      if ($_ > $max){
        $max=$_;
      }
    }
    $min=$min-3*$DE;
    $max=$max+3*$DE;
  }
  print LOG "Domain: $min to $max\n";
}
# ===================================================================================
sub read_convolute{
  open(OUT,">$f_out") or die "Cannot find file $f_out.\n";
  print LOG "\nStarting computing intensities ...\n";
  $x = $min;
  $j=0;
  while ($x <= $max){
     compute_intensity();    
     $x = $x + $dx;
     $j++;
     if ($j >= 1000000){last;}  # Avoid too large loops!
  }
  print LOG "\n";
  close(OUT);
}
# ===================================================================================
sub compute_intensity{
  $pe = 0.0;
  for ($i = 0; $i <= $imax;  $i++ ){
    if ($l_shape eq "gauss"){
      $function=gauss_func();
    }elsif($l_shape eq "lorentz"){
      $function=lorentz_func();
    }elsif($l_shape eq "voigt"){
      $function=pvoigt_func();
    }
    $pe = $pe + $f[$i]*$function;
  }
  $Intens = $pe;
  $lambda=1240/$x;
  if ($x >= $xmin){
    printf OUT "%12.4f   %12.2f   %16.8f\n",$x,$lambda,$Intens;
  }
}
# ===================================================================================
sub gauss_func{
# Gaussian function
  my ($gauss);
  $gauss = 1/($DE*sqrt($pi/2))*exp(-2*($x-$E[$i])**2/$DE**2);
  return $gauss;
}
# ===================================================================================
sub lorentz_func{
# Lorentzian function
  my ($lorentz);
  $lorentz = $DE/(2*$pi)*1/(($x-$E[$i])**2+($DE/2)**2);
  return $lorentz;
}
# ===================================================================================
sub pvoigt_func{
# Sum pseudo-Voigt function
  my ($pvoigt,$GF,$LF);
  $GF=gauss_func();
  $LF=lorentz_func();
  $pvoigt = (1.0-$eta)*$GF+$eta*$LF;
  return $pvoigt;
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

