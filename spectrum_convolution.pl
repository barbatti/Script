#!/usr/bin/perl -w
#
# This program takes a sequence of E and f and convolutes them with a line shape: 
# I(x) = SUM_i[f*g(x-E,DE)].
#
# Mario Barbatti, July 2012.
# 

# Constants:
$pi = 3.141592653589793;

# files:
$f_log="spect_conv.log";
open(LOG,">$f_log") or die ":( $f_log";
print_STDOUT("\n  ====== START CONVOLUTION ======\n\n");
$f_out="spect_conv.dat";

if (@ARGV<1){
  $f_ips="exf";
}else{
  $f_ips = $ARGV[0];
}
if (-s $f_ips){
  print_STDOUT(" Using file $f_ips as source of data.\n");
  print_STDOUT(" The two first rows of $f_ips are:\n");
  open(IN,$f_ips) or die ":( $f_ips !";
  $_=<IN>;
  print_STDOUT("$_");
  $_=<IN>;
  print_STDOUT("$_");
  close(IN);
}else{
  print_STDOUT(" File $f_ips does not exist or is empty. Program will die.\n"); 
  die;
}

read_inputs();
read_ef();
read_convolute();

if (-s $f_out){
  print_STDOUT(" Energies and intensities \n were written to $f_out.\n\n");
}else{
  print_STDOUT(" File $f_out does not exist or is empty. Something is wrong.\n Check inputs and run again.\n\n");
}

print_STDOUT("  ======= END CONVOLUTION =======\n\n");
close(LOG);

# ===================================================================================
sub read_inputs{
  print_STDOUT("\n Starting reading inputs ...\n");
# Columns to be read
  $q="Column X (1 = default):"; 
  $l=question($q,"1");
  $colx=$l-1;
  print_STDOUT(" colx = $l\n");
  $q="Column Y (2 = default; 0 = assume uniform intensities.):"; 
  $l=question($q,"2");
  $coly=$l-1;
  print_STDOUT(" colx = $l\n");
# Type of line
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
  print_STDOUT(" l_shape = $l_shape\n");
  if ($l_shape eq 3){
    print_STDOUT(" eta = $eta\n");
  } 
# Line shape and spacing
  $q="Line shape width (default 0.4 eV): ";
  $DE=question($q,"0.4");
  print_STDOUT(" DE = $DE\n");
  $q="Distance between points (default 0.05 eV): ";
  $dx=question($q,"0.05");
  print_STDOUT(" dx = $dx\n");
  $q="Determine domain automatically? (y(default)/ n) ";
  $auto_domain=question($q,"y");
  print_STDOUT(" auto_domain = $auto_domain\n");
  if ($auto_domain eq "n"){
    $q="Minimum value of E axis (default = 0 eV): ";
    $min=question($q,"0");
    print_STDOUT(" min = $min\n");
    $q="Maximum value of E axis (default = 20 eV): ";
    $max=question($q,"20");
    print_STDOUT(" max = $max\n");
  }
# Output
  $q="Write additional collumn with 1240/x (eV<->nm)? (y/n - n = default):";
  $conv=question($q,"n");
  print_STDOUT(" conv = $conv\n");
}
# ===================================================================================
sub read_ef{
  open(IPS,$f_ips) or die "Cannot find file $f_ips with X and Y information.\n";
  $_=<IPS>;
  chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
  (@row)=split(/\s+/,$_);
  label_row($row[0]);
  if ($label == 0){
    close(IPS);
    open(IPS,$f_ips) or die "Cannot find file $f_ips with X and Y information.\n";
  }else{
    print_STDOUT("\n First entry in $f_ips is not numerical. Assuming a label row.\n");
  }
  print_STDOUT("\n Starting reading X and Y ...\n");
  $i=0;
  while(<IPS>){
     chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
     (@row)=split(/\s+/,$_);
     $E[$i]=$row[$colx];
     if ($coly >= 0){
       $f[$i]=$row[$coly];
     }elsif($coly == -1){
       $f[$i]=1;
     }
     $i++;
  }
  $imax=$i-1;
  print_STDOUT("  IMAX = $imax\n\n");
  close(IPS);
  max_min();
}
# ===================================================================================
sub label_row{
  # Is input numeric?
  ($input)=@_;
  if ( $input =~ /^[\+-]*[0-9]*\.*[0-9]*$/ && $input !~ /^[\. ]*$/  ) {
    $label=0;  #numeric
  }else{
    $label=1;  #non-numeric
  };
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
  print_STDOUT(" Domain: $min to $max\n");
}
# ===================================================================================
sub read_convolute{
  open(OUT,">$f_out") or die "Cannot find file $f_out.\n";
  if ($conv eq "y"){
    print OUT "         X           1240/X          Y\n";
  }else{
    print OUT "         X              Y\n";
  }
  print_STDOUT("\n Starting to compute intensities ...\n");
  $x = $min;
  $j=0;
  while ($x <= $max){
     compute_intensity();    
     $x = $x + $dx;
     $j++;
     if ($j >= 1000000){last;}  # Avoid too large loops!
  }
  print_STDOUT("\n");
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
  if ($conv eq "y"){
    $lambda=1240/$x;
    printf OUT "%12.4f   %12.2f   %16.8f\n",$x,$lambda,$Intens;
  }else{
    printf OUT "%12.4f   %16.8f\n",$x,$Intens;
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
sub print_STDOUT{
   my ($text);
  ($text)=@_;
   print LOG "$text";
   print STDOUT "$text";
}
# ===================================================================================

