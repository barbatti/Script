#!/usr/bin/perl -w
# Cartesian coordinates for FCC matrix

$R=19; # Ang
$Rcav=19; # Ang
$a=5.256; # Ang
$s="Ar";
$i_max=13;
$qm_mol="fm.xyz";

$vdw{"H"}=1.20; #Ang
$vdw{"C"}=1.70;
$vdw{"N"}=1.55;
$vdw{"O"}=1.52;
$vdw{"Ar"}=1.88;

read_fqm();

open(OUT,">out.xyz") or die ":( out.xyz";

$nat=0;
$string="";
for ($k=-$i_max;$k<=$i_max;$k++){
   for ($l=-$i_max;$l<=$i_max;$l++){
      for ($m=-$i_max;$m<=$i_max;$m++){
         #   0   0   0
         $xi=$k*$a;
         $yi=$l*$a;
         $zi=$m*$a;
         $r_mod=sqrt($k**2+$l**2+$m**2)*$a;
         test_point($xi,$yi,$zi);
         #   0 1/2 1/2
         $xi=$k*$a;
         $yi=($l+0.5)*$a;
         $zi=($m+0.5)*$a;
         $r_mod=sqrt($k**2+$l**2+$m**2)*$a;
         test_point($xi,$yi,$zi);
         # 1/2   0 1/2
         $xi=($k+0.5)*$a;
         $yi=$l*$a;
         $zi=($m+0.5)*$a;
         $r_mod=sqrt($k**2+$l**2+$m**2)*$a;
         test_point($xi,$yi,$zi);
         # 1/2 1/2   0
         $xi=($k+0.5)*$a;
         $yi=($l+0.5)*$a;
         $zi=$m*$a;
         $r_mod=sqrt($k**2+$l**2+$m**2)*$a;
         test_point($xi,$yi,$zi);
      }
   }
}

print OUT "$nat\n\n$string";

sub test_point{
  ($x,$y,$z)=@_;
  $accept="y";
  if ($r_mod > $R){
    $accept="n";
  }
  if ($r_mod < $Rcav){
    for ($n=0;$n<=$nqm-1;$n++){
       $dx=($xqm[$n]-$x);
       $dy=($yqm[$n]-$y);
       $dz=($zqm[$n]-$z);
       $dmod=sqrt($dx**2+$dy**2+$dz**2);
       if ($dmod < $vdw{$sb[$n]}+$vdw{$s}){
          $accept="n";
          last;
       }
    }
  }
  if ($accept eq "y"){
     $nat++;
     $string=$string.sprintf("%s  %12.6f   %12.6f   %12.6f\n",$s,$x,$y,$z); 
  }
}

sub read_fqm{
  my ($ind);
  open(FQM,$qm_mol) or die ":( $qm_mol";
  $_=<FQM>;
  chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
  $nqm=$_;
  $_=<FQM>;
  for ($ind=0;$ind<=$nqm-1;$ind++){
    $_=<FQM>;
    chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
    ($sb[$ind],$xqm[$ind],$yqm[$ind],$zqm[$ind])=split(/\s+/,$_);
    $sb[$ind]=uc($sb[$ind]);
  }
  close(FQM);
}
