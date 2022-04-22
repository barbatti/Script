#!/usr/bin/perl -w

# New version of datconv to Replace Fortran.
# MB March 2015

# Read frame number
open(IN,"frame") or die ":( frame";
$_=<IN>;
chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
$ifrm=$_;
close(IN);

# Read input parameters
open(IN,"datconv.inp") or die ":( datconv.inp";
$_=<IN>;
chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
($nstat,$ifrmax,$iunit,$emin)=split(/\s+/,$_);
close(IN);

# Units
if ($iunit == 1){
  $cv=27.21138386;
}else{
  $cv=1.0;
}

# Run over all frames
open(IN,"en.dat") or die ":( en.dat";
open(OUT,">data.dat") or die ":( data.dat";
for ($i=1;$i<=$ifrmax;$i++){
  # Read line
  $_=<IN>;
  chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
  @g=split(/\s+/,$_);
  $t=$g[0];
  for ($n=0;$n<=$nstat-1;$n++){
    $e[$n]=$g[$n+1];
  } 
  $e_curr=$g[$#g-1];
  # Check state
  for ($n=0;$n<=$nstat-1;$n++){
    if (abs($e[$n]-$e_curr) < 1E-6){
      $ncurr=$n;
    }
  }
  # Write
  $de="";
  for ($n=0;$n<=$nstat-1;$n++){
    $de=$de." ".$cv*(-$emin+$e[$n]);
  }
  if ($i != $ifrm){
    print OUT "$t  $de\n";
  }else{
    $es=$cv*(-$emin+$e[$ncurr]);
    print OUT "$t  $de  $es\n"; 
  }
}
close(IN);
close(OUT);

# Update frame
$ifrm++;
open(OUT,">frame") or die ":( frame";
print OUT "$ifrm\n";
close(OUT);

