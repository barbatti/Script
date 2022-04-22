#!/usr/bin/perl -w
#

  print "File name: ";
  $file=get_answer("os-trajs_1.dat");

  print "Minimum X ";
  $x_min=get_answer("0");

  print "X increment ";
  $dx=get_answer("0.5");

  print "Minimum Y ";
  $y_min=get_answer("0");

  print "Y increment ";
  $dy=get_answer("0.005");

print "Creating array ...\n";

for ($i=0;$i<=1000;$i++){
  for ($j=0;$j<=40;$j++){
    print "$i $j\n";
    $f[$i][$j]=0;
  }
}

print "Reading file ...\n";

$ixmx=0;
$iymx=0;
open(FL,"$file") or die "Cannot read $file";
while(<FL>){
  chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
  ($x,$y)=split(/\s+/,$_);
  $ix=int(($x-$x_min)/$dx);   
  $iy=int(($y-$y_min)/$dy); 
  $f[$ix][$iy]=$f[$ix][$iy]+1;
  if ($ix > $ixmx){
    $ixmx=$ix;
  }  
  if ($iy > $iymx){
    $iymx=$iy;
  }  
}
close(FL);

print "Writing grid ...\n";

open(OUT,">grid") or die "Cannot write grid";
for ($i=0;$i<=$ixmx;$i++){
  for ($j=0;$j<=$iymx;$j++){
     $x=$x_min+$dx/2+($i+1);
     $y=$y_min+$dy/2+($j+1);
     print OUT "$x  $y  $f[$i][$j]\n";
  }
}
close(OUT);

sub get_answer{
  my ($ans,$def);
  ($def)=@_;
  $_=<STDIN>;
  chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
  if ($_ eq ""){
    $ans=$def;
  }else{
    $ans=$_;
  }
  return $ans;
}

