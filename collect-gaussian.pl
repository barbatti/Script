#!/usr/bin/perl -w

$string=" Excited State ";
$string1=" Excited State   1: ";

$nArg=$#ARGV+1;
if ($nArg == 0){
  print STDOUT "\nNo file name was given.\n";
  die;
}

# Number of states and cycles
open(IN,"$ARGV[0]") or die "Cannot read $ARGV[0] file!";
  $ncy=0;
while(<IN>){
  if (/$string1/){
    $ncy++;
  }
}
close(IN);
print "Number of cycles: $ncy\n";

# Read Gaussian output
open(IN,"$ARGV[0]") or die "Cannot read $ARGV[0] file!";
open(OUT,">collect-gaussian.dat") or die "Cannot write to collect-gaussian.dat!";

$kcy=0;
while(<IN>){
  if (/$string1/){
     $kcy++;
  }
  if (/$string/){
    if ($kcy == $ncy){
      chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
      @g=split(/\s+/,$_);
      $ind=$g[2];
      $ind=~s/://g;
      $sym=$g[3];
      $eng=$g[4];
      $f  =$g[8];
      $f=~s/f=//g;
      read_vector(); 
      printf OUT "%4d   %11.3f   %12.4f    %s     %s\n",$ind,$eng,$f,$sym,$vector;
    }
  }
}

close(OUT);
close(IN);

sub read_vector{
  my (@g);
  $coeff=0;
  while(<IN>){
    chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
    @g=split(/\s+/,$_);
    if (!defined($g[0])){
      $g[0]="not a number";
    }
    if ($g[0] =~ /^[+-]?\d+$/ ) {
      $vec=$_;
      @c=split(/\s+/,$_);
      if ($#g == 2){
        $coeff_new=$c[2]; 
      }else{
        $coeff_new=$c[3];
      }
      if (abs($coeff_new) > abs($coeff)){
        $coeff=$coeff_new;
        $vector=$vec;
      }
    } else {
       last;
    }
  }
}
