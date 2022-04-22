#!/usr/bin/perl -w

# This program goes over each state in collect and calculate A2 for sunlight.
# Mario Barbatti, 2020.04.12
#
my ($fin,$fout,$flog);
my (@ns,@sym,@energ,@oos,@string);
my ($i,$imax);
my ($C2,$NA,$P,$A2,$w);
my ($ev2au);

$finp="collect-turbomole-cc2.dat";
$fout="sunlight.dat";
$flog="sunlight.log";

open(FL,">$flog") or die ":( $flog";

$ev2au=27.21138386;

$i=0;
open(FI,$finp) or die ":( $finp";
while(<FI>){
  chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
  ($ns[$i],$sym[$i],$energ[$i],$oos[$i],$string[$i])=split(/\s+/,$_);
  $i++;
}
close(FI);
$imax=$i-1;

$NA=get_NA();
print FL "Normalization factor: $NA\n\n";

$sump = 0.0;
open(FO,">$fout") or die ":( $fout";
for ($i=0;$i<=$imax;$i++){
  $P=get_P();
  $sump = $sump + $P;
  print FL "* Probability state $i: $P\n";
  $w=$energ[$i]/$ev2au;
  $C2=get_C2($energ[$i]);
  $A2=$oos[$i]/($NA*$w)*$C2;
  printf FO "%3d %4s %8.2f %8.3f %8.3f %s \n",$ns[$i],$sym[$i],$energ[$i],$oos[$i],$A2,$string[$i];
}
close(FO);

print FL "\nTotal probability: $sump\n";

close(FL);

# %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

sub get_NA{
  my ($n,$sum,$w,$C2);

  $sum=0.0;
  for ($i=0;$i<=$imax;$i++){
    $w = $energ[$i]/$ev2au;
    $C2 = get_C2($energ[$i]);
    $sum = $sum + $oos[$i]/$w*$C2;
  }
  $n = $sum;

  return $n;
}

sub get_P{
  my ($w,$C2,$P);
  
  $w = $energ[$i]/$ev2au;
  $C2 = get_C2($energ[$i]);
  $P = $oos[$i]/$w*$C2/$NA;

  return $P;
}

sub get_C2{
 my ($f,$x,$c1,$c2,$c3,$c4,$c5,$c6);

 $x=@_;

 $c0 = 0.988383E-6;
 $c1 = 8.62855E-5;
 $c2 = 0.06527;
 $c3 = 0.40123;
 $c4 = 0.44859;
 $c5 = 1.17981;

 $f=$c0+$c1*($x+$c2)^$c3*exp(-$c4*($x+$c2)^$c5);

 return $f;
}
