#!/usr/bin/perl -w

open(IN,"iter.log") or die "Cannot find iter.log\n";
open(OUT,">iter-ev.dat") or die "Cannot find iter-ev.dat\n";
$au2ev=27.21138386;

$i=0;
$_=<IN>;
while(<IN>){
  chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
  @g=split(/\s+/,$_);
  if ($i==0){
    $ref=$g[7];
  }
  $abs=$au2ev*($g[7]-$ref);
  $eev=-$au2ev*($g[7]-$g[6]);
  printf OUT "%6d  %14.5f  %14.5f  %12.3f  %12.3f\n",$i,$g[7],$g[6],$abs,$eev;  
  $i++;
}

close(OUT);
close(IN);
