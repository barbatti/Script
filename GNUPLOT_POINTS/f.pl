#!/usr/bin/perl -w

$s="sp ";
for ($i=0;$i<=99;$i++){
  for ($j=0;$j<=9;$j++){
    $pt=10*$i+$j;
    open(OUT,">p-$pt");
    print OUT "$i  $j  1\n";
    close(OUT);
    $s=$s." \'p-$pt\' u 1:2:3 w p $pt,";
  }
}
open(GP,">gp");
print GP $s; 
close(GP);

