#!/usr/bin/perl -w

use strict;
use warnings;

my($i,$n,@data,$mean,$stddev,%slot,$filename,$nslots);

sub getdata();
sub calcmean();
sub calcstddev();
sub makehist();

$n = 0;
@data = 0;
%slot = ();
$mean = 0;
$stddev = 0;
if (@ARGV<1){
  $filename = "spectrum.dat";
  # this is only for a special problem
  # make this better
}
else{
  $filename = $ARGV[0];
  print STDOUT "using file $filename as source for data\n";
}

if (@ARGV > 1){
  $nslots = $ARGV[1];
  print STDOUT "using $nslots slots.\n";
}
else{
  $nslots = 0;
}


getdata();
calcmean();
calcstddev();
makehist();

#print STDOUT "values: ",@data,"\n";
print STDOUT "mean: ", $mean,"\n";
print STDOUT "stddev: ",$stddev,"\n";
print STDOUT "n: $n\n";
#print STDOUT %slot,"\n";
#------------------------------------------------------------------------------
sub getdata(){
  my (@line);
  $n = 0;
  open (DATA,"<$filename") or die "can't open $filename\n$!\n";
  while(<DATA>){
    chomp;
    s/^\s+//;
    @line = split /\s+/;
    $data[$n] = $line[0];
    $n += 1;
  }
  close DATA or print STDERR "warning: can't close $filename\n$!\n";
}

#------------------------------------------------------------------------------
sub calcmean(){
  my ($sum);
  $sum = 0;
  for($i=0;$i<$n;$i++){
    $sum = $sum + $data[$i];
  }
  if ($n != 0){
    $mean = $sum/($n+1); # $n begins to count at 0!
  }
}

#------------------------------------------------------------------------------
sub calcstddev(){
  my($sum);
  $sum = 0;
  die "not enough data" if ($n<1);
  for($i=0;$i<$n;$i++){
    $sum = $sum + ($data[$i]-$mean)**2;
  }
  $stddev = sqrt($sum/($n)); # $n begins to count at 0!
}

#------------------------------------------------------------------------------
sub makehist(){
  my ($maxval,$minval,$slotw,$ubound,$lbound,$j);
  $maxval = $mean;
  $minval = $mean;
  for($i=0;$i<$n;$i++){
    if ($data[$i] > $maxval){$maxval = $data[$i];print "max: $maxval  -  $i\n";}
    if ($data[$i] < $minval && $data[$i]){$minval = $data[$i];print "min: $minval  -  $i\n";}
  }
  if ($nslots == 0){
    $nslots = int(($maxval - $minval)/0.05);
    # make this better sometime - this is special for Mario :-)
  }
  print STDOUT "min: $minval;  max: $maxval\n";
  $slotw=($maxval+0.0001-$minval)/$nslots;
  for($i=0;$i<$n;$i++){
    for($j=0;$j<$nslots;$j++){
      $lbound = $minval+$j*$slotw;
      $ubound = $minval+($j+1)*$slotw;
      if($lbound<=$data[$i] and $ubound>$data[$i]){
        $slot{"$lbound"} += 1;
      }
      # the last slot has to be taken care of seperately
      $j += 1;
      if($lbound<=$data[$i] and $ubound>=$data[$i]){
        $slot{"$lbound"} += 1;
      }
    }
  } 
  open(HIST,">hist.dat") or die "can't create hist.dat\n$!\n";
  for ($j=0;$j<$nslots;$j++){
    $lbound = $minval+$j*$slotw;
    $ubound = $minval+($j+1)*$slotw;
    printf HIST "% 7.5f % 3d\n",($ubound+$lbound)/2,$slot{"$lbound"};
  }
  close HIST or print STDERR "warning: can't close hist.dat\n$!\n";
}
