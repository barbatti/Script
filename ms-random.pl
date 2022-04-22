#!/usr/bin/env perl
use strict;
use warnings;
my ($i,$nv,@f,$imax,$ind,$indmax);

my $prog = "microstates-v09.pl";
my $imax_min = 6;
my $imax_max = 9;
my $nvib = 10;

$indmax = ($imax_max-$imax_min+1)*$nvib;

my $lowf = 400;
my $highf = 2500;
my $fmin = 100;
my $fmax = 4000;
my $f1max = 1000;
my $f2max = 2000;

open(LOG,">ms-rand.log");

print LOG "prog = $prog\n";
print LOG "imax_min = $imax_min\n";
print LOG "imax_max = $imax_max\n";
print LOG "nvib = $nvib\n";
print LOG "lowf = $lowf\n";
print LOG "highf = $highf\n";
print LOG "fmin = $fmin\n";
print LOG "fmax = $fmax\n";
print LOG "f1max = $f1max\n";
print LOG "f2max = $f2max\n";

$ind = 1;
for ($imax = $imax_min; $imax <= $imax_max; $imax++){
  for ($nv=1; $nv <= $nvib; $nv++){  
    print LOG "imax = $imax  nv = $nv\n";	
    make_f();
    input_ms();
    call_ms();
    $ind++;  
  }
}

system("rm -f *old *tmp info.dat thermo.dat ms-run.log micro.inp infoT.dat");

close(LOG);

#=========================================================
sub make_f{
  my ($x,$test);
  
  $test = "f";

  while ($test eq "f"){
    for ($i=0; $i<=$imax-1; $i++){	
      $x=rand();
      $f[$i] = $fmin + $x*($fmax-$fmin);
    }
    @f = sort { $a <=> $b } @f;
    if (
	($f[0] < $lowf) and 
	($f[$imax-1] > $highf) and
        ($f[1] < $f1max) and
        ($f[2] < $f2max)
       ){
      $test = "t";
    }
  }

}
#=========================================================
sub input_ms{
  open(INP,"micro.tpt") or die "Cannot read micro.tpt";
  open(OUT,">micro.inp") or die "Cannot write micro.inp";
  while(<INP>){
    if (/imax/i){
      print OUT "imax = $imax\n";
      for ($i=0; $i<=$imax-1; $i++){
        print OUT "$f[$i]\n";	      
        print LOG "f[$i] = $f[$i]\n";	      
      }
    }else{
      print OUT $_;
    }
  }
  close(OUT);
  close(INP);
}
#========================================================
sub call_ms{
  my ($file);	
  system("$prog");
  my @files=("ms-run.log","infoT.dat","info.dat","thermo.dat");
  if ($ind == 1){
    foreach(@files){
      $file = $_;
      system("mv $file $file.old");
    }	  
  }elsif($ind == $indmax){
    foreach(@files){
      $file = $_;
      system("cat $file.old $file > $file.tmp");
      system("mv $file.tmp $file.all");
    }	  
  }else{
    foreach(@files){
      $file = $_;
      system("cat $file.old $file > $file.tmp");
      system("mv $file.tmp $file.old");
    }  
  }
}
