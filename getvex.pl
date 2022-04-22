#!/usr/bin/perl -w


use strict;
use warnings;

my($i,$n,$firstt,$lastt,@vex,$HteV,$mean,$stddev,%slot);
sub getvex();
sub calcmean();
sub calcstddev();
sub makehist();

$HteV = 27.2113961;
$firstt = 1;
$lastt = 150;
$n = 0;
@vex = 0;
%slot = ();
$mean = 0;
$stddev = 0;

for ($i=$firstt;$i<=$lastt;$i++){
  if (-s "./TRAJ$i/RESULTS/en.dat"){
    open (ENDAT,"<./TRAJ$i/RESULTS/en.dat") or die "can't open $i-en.dat\n$!\n";
    $n += 1;
    getvex();
    close ENDAT or print STDERR "warning: can't close $i-en.dat\n$!\n";
  }
  else{
    $vex[$i] = "na";
    next;
  }
}

calcmean();
calcstddev();
makehist();

#print STDOUT "values: ",@vex,"\n";
print STDOUT "mean: ", $mean,"\n";
print STDOUT "stddev: ",$stddev,"\n";
print STDOUT "n: $n\n";
#print STDOUT %slot,"\n";
#------------------------------------------------------------------------------
sub getvex(){
  my (@line);
  $_=<ENDAT>;
  chomp;
  s/^\s+//;
  @line = split /\s+/;
  $vex[$i] = ($line[2]-$line[1])*$HteV;
}

#------------------------------------------------------------------------------
sub calcmean(){
  open (VX, ">vex.dat") or die "can't create vex.dat\n$!\n";
  my ($sum);
  $sum = 0;
  for($i=$firstt;$i<=$lastt;$i++){
    if ($vex[$i] ne "na"){
      $sum = $sum + $vex[$i];
      printf VX "% 3d % 7.5f\n",$i, $vex[$i];
    }
  }
  if ($n != 0){
    $mean = $sum/$n;
  }
}

#------------------------------------------------------------------------------
sub calcstddev(){
  my($sum);
  $sum = 0;
  die "not enough data" if ($n<2);
  for($i=$firstt;$i<=$lastt;$i++){
    if ($vex[$i] ne "na"){
      $sum = $sum + ($vex[$i]-$mean)**2;
    }
  }
  $stddev = sqrt($sum/($n-1));
}

#------------------------------------------------------------------------------
sub makehist(){
  my ($maxval,$minval,$nslots,$slotw,$ubound,$lbound,$j);
  $nslots = 7;
  $maxval = $mean;
  $minval = $mean;
  for($i=$firstt;$i<=$lastt;$i++){
    if ($vex[$i] ne "na"){
      if ($vex[$i] > $maxval){$maxval = $vex[$i];print "max: $maxval  -  $i\n";}
      if ($vex[$i] < $minval && $vex[$i]){$minval = $vex[$i];print "min: $minval  -  $i\n";}
    }
  }
  print STDOUT "min: $minval;  max: $maxval\n";
  $slotw=($maxval+0.0001-$minval)/$nslots;
  for($i=$firstt;$i<=$lastt;$i++){
    for($j=0;$j<$nslots;$j++){
      if ($vex[$i] ne "na"){
        $lbound = $minval+$j*$slotw;
        $ubound = $minval+($j+1)*$slotw;
#        print STDOUT $lbound," - ",$ubound," - ",$vex[$i],"\n";
        if($lbound<=$vex[$i] and $ubound>$vex[$i]){
          $slot{"$lbound"} += 1;
#          print STDOUT "  -> ",$lbound," -> ",$slot{"$lbound"},"\n";
        }
      }
    }
  } 
  open(VH,">vexhist.dat") or die "can't create vexhist.dat\n$!\n";
  for ($j=0;$j<$nslots;$j++){
    $lbound = $minval+$j*$slotw;
    $ubound = $minval+($j+1)*$slotw;
    printf VH "% 7.5f % 3d\n",($ubound+$lbound)/2,$slot{"$lbound"};
  }
  close VH or print STDERR "warning: can't close vexhist.dat\n$!\n";
}
