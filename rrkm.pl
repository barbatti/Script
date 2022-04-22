#!/usr/bin/perl -w
use Scalar::Util qw(looks_like_number);

# RRKM using direct count
# T. Baer and P. M. Mayer, J Am Soc Mass Spectrom 1997, 8, 103
# 
# Mario Barbatti Nov 2012

$flod="rrkm.dat";
$flog="rrkm.log";
open(LOG,">$flog") or die ":( $flog"; 

print LOG "    ======= RRKM =======\n\n";

$hplanck=4.135667516E-15*8065.73; # cm-1.s

# Input section

print STDOUT "\n File with reactant wavenumbers (cm-1): ";
$_=<STDIN>;
chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
$fl1=$_;
if (!-s $fl1){
  die ":( $fl1";
}
print LOG " File with reactant wavenumbers: $fl1\n"; 

print STDOUT "\n File with transition state wavenumbers (cm-1): ";
$_=<STDIN>;
chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
$fl2=$_;
if (!-s $fl2){
  die ":( $fl2";
}
print LOG " File with transition state wavenumbers: $fl2\n"; 

print STDOUT "\n Activation energy E0 (cm-1): ";
$_=<STDIN>;
chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
$e0=sprintf("%6d",$_);
print LOG " Activation energy E0 (cm-1): $e0\n"; 

print STDOUT "\n Maximum energy E (cm-1): ";
$_=<STDIN>;
chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
$em=sprintf("%6d",$_);
print LOG " Maximum energy E (cm-1): $em\n"; 

print STDOUT "\n Degeneracy factor [default 1]: ";
$_=<STDIN>;
chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
if (looks_like_number($_)){
 $sgm=$_;
}else{
 $sgm=1;
}
print LOG " Degeneracy factor: $sgm\n"; 

print STDOUT "\n Anharmonic factor [default 1]: ";
$_=<STDIN>;
chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
if (looks_like_number($_)){
 $alpha=$_;
}else{
 $alpha=1;
}
print LOG " Anharmonic factor: $alpha\n";

# Read wavenumbers

@w1=read_wavenumbers($fl1);
$nw1=$#w1+1;
@w2=read_wavenumbers($fl2);
$nw2=$#w2+1;

print LOG " Number of wavelengths for reactant is: $nw1\n";
print LOG " Number of wavelengths for t. state is: $nw2\n";
if ($nw1-$nw2 != 1){
  warn " I was expecting the difference between these numbers to 1, but it is $nw1-$nw2. Check it.\n";
}

# Count states
count_states();

# Get density
get_density();

# Compute rate
print LOG "\n    E (cm-1)          k (s-1)             tau (s)\n";
$k=rate($e0+1);
printf LOG  "    %6d         %14.8E      %14.8E\n",$e0+1,$k,1/$k;
$k=rate($em);
printf LOG  "    %6d         %14.8E      %14.8E\n",$em,$k,1/$k;
print LOG "\n   ======= Normal termination =======\n";

open(DAT,">$flod") or die ":( $flod"; 
print DAT "     E/cm-1          k/s-1             tau/s\n";
for ($i=$e0+1;$i<=$em;$i++){
  $k=rate($i);
  printf DAT  "    %6d         %14.8E      %14.8E\n",$i,$k,1/$k;
}
close(DAT);

close(LOG);

print "\n\n";

#=====================================================================
sub read_wavenumbers{
  my ($fl,@w,$i);
  ($fl)=@_;
  $i=0;
  print LOG "\n Wavenumbers in $fl:\n";
  open(IN,$fl) or die ":( $fl";
  while(<IN>){
    chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
    ($w[$i])=split(/\s+/,$_);
    if (looks_like_number($w[$i])){
      $w[$i]=sprintf("%4d",$w[$i]*$alpha);
      printf LOG "%4d   $w[$i]\n",$i+1;
      $i++;
    }else{
      last;
    }
  }
  close(IN);
  return @w;
}
#=====================================================================
sub count_states{
  for ($i=0;$i<=$em-$e0-1;$i++){  
   $N[$i]=1;
  }
  for ($j=0;$j<=$nw2-1;$j++){
    for ($i=$w2[$j];$i<=$em-$e0-1;$i++){
      $N[$i]=$N[$i]+$N[$i-$w2[$j]];
    }
  }
}
#=====================================================================
sub get_density{
  $rho[0]=1;
  for ($i=1;$i<=$em-1;$i++){
   $rho[$i]=0;
  }
  for ($j=0;$j<=$nw1-1;$j++){
    for ($i=$w1[$j];$i<=$em-1;$i++){
      $rho[$i]=$rho[$i]+$rho[$i-$w1[$j]];
    }
  }
}
#=====================================================================
sub rate{
  my ($e,$k);
  ($e)=@_;
  $k=$sgm/$hplanck*$N[$e-$e0-1]/$rho[$e-1];
  return $k;
}
#=====================================================================



