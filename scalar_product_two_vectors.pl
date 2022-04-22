#!/usr/bin/perl -w

# Given vector 1 in file v1, for instance:
#    -4.6494501      1.5427876      0.9441466
#     3.5484543      1.4163149     -2.6723879
#     0.9069375      0.1920786     -0.0811402
#     1.8390183     -2.1445465      0.7958901
#    -0.2005753     -0.3051817      0.8381499
#    -1.4441556     -0.6866668      0.1661493
# and vector 2 in file v2, for instance:
#   -0.00014707    0.00023761   -0.00000647
#   -0.00005023   -0.00045818    0.00057278
#    0.00579734   -0.00137417    0.00382532
#   -0.00470633    0.00232953   -0.00075969
#   -0.00320814   -0.00169885   -0.00474903
#    0.00475833    0.00289460   -0.00505237
# computes v1.v2.

print " File with vector 1: ";
$_=<STDIN>;
chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
$v1=$_;

print " File with vector 2: ";
$_=<STDIN>;
chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
$v2=$_;

$l1=count_lines($v1);
$l2=count_lines($v2);

if ($l1 != $l2){
  die "Different number of lines in v1 and v2!";
}

open(V1,$v1) or die ":( $v1 ";
open(V2,$v2) or die ":( $v2 ";

$i=0;
while(<V1>){
  chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
  ($x1[$i],$y1[$i],$z1[$i])=split(/\s+/,$_);
  $i++;
}

$i=0;
while(<V2>){
  chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
  ($x2[$i],$y2[$i],$z2[$i])=split(/\s+/,$_);
  $i++;
}

close(V2);
close(V1);

$prod=0;
for ($i=0; $i<=$l1-1; $i++){
  $prod=$prod+$x1[$i]*$x2[$i]+$y1[$i]*$y2[$i]+$z1[$i]*$z2[$i];
}


print "\n FILE 1: $v1\n FILE 2: $v2\n LINES = $l1\n\n";

print " PROD = $prod\n\n";

if ($v1 eq $v2){
  $norm=sqrt($prod);
  print " NORM = $norm\n\n";
}

sub count_lines{
  my ($lines,$file);
  ($file)=@_;
  if (!-s $file){
     die " $file does not exist or is empty! ";
  }
  open(FL,$file) or die ":( $file";
  $lines=0;
  while(<FL>){
    $lines++;
  }
  close(FL);
  return $lines;  
}
