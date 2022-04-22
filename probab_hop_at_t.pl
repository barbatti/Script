#!/usr/bin/perl -w
#
# Probability of hopping at step n is P(n) = g(n)/(1-g(n))*PROD_k[(1-g(k))]
#
# Giving a list of g(n), computes P(n).
#
# Mario Barbatti, July 2008.
#

print "Computes P(n) to which state? (Ground state = 1) ";
$_=<STDIN>;
chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
$state=$_;
$column=$state+2;

print "Initial step: ";
$_=<STDIN>;
chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
$step_i=$_;

print "Final step: ";
$_=<STDIN>;
chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
$step_f=$_;

if (!-s "tprob"){
  die "Cannot find tprob!\n";
}

open(TP,"tprob") or die ":( tprob!";
$k=0;
while(<TP>){
   if ($k>=$step_i){
      chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
      @c=split(/\s+/,$_);
      $g[$k]=$c[$column];
      if ($k==$step_f){
         last;
      }
   }
   $k++;
}
close(TP);

for ($n=$step_i;$n<=$step_f;$n++){
  $prod = 1;
  for ($k=$step_i;$k<=$step_f;$k++){
    if ($k != $n){
      $P[$n]=$prod*(1-$g[$k]);
    }else{
      $P[$n]=$prod*$g[$k];
    }
    $prod=$P[$n];
  }
  print "$n  $P[$n] \n";
}

$P_sum=0;
open(PH,">Phop_t.dat") or die ":( Phop_t.dat!";
for ($k=$step_i;$k<=$step_f;$k++){
   $P_sum=$P_sum+$P[$k];
   print PH "$k    $g[$k]   $P[$k]   $P_sum\n";
}
close(PH);

