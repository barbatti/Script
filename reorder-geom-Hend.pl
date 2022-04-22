#!/usr/bin/perl -w
#
# Reorder dyn.xyz moving H-atoms to the end.
#

open(OUT,">dyn-out.xyz") or die ":( dyn-out.xyz";

open(IN,"dyn.xyz") or die ":( dyn.xyz";
$_=<IN>;
chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
$nat=$_;
close(IN);

$do_again="y";
open(IN,"dyn.xyz") or die ":( dyn.xyz";
$_=<IN>;
while ($do_again eq "y"){
  $_=<IN>;
  print OUT " $nat\n$_";
  $nH=0;
  $yH=0;
  for ($n=0;$n<=$nat-1;$n++){
    $_=<IN>;
    chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
    @g=split(/\s+/,$_);
    $sn[$n]=$g[0];
    $sn[$n]=uc($sn[$n]);
    if ($sn[$n] ne "H"){
      $line_nH[$nH]=" $_\n";
      $nH++;
    }elsif($sn[$n] eq "H"){
      $line_yH[$yH]=" $_\n";
      $yH++;
    }
  }
  print OUT @line_nH;
  print OUT @line_yH;
  $_=<IN>;
  chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
  if ($_ ne $nat){
    $do_again="n";
  }
}
close(IN);

close(OUT);

