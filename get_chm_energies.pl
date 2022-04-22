#!/usr/bin/perl -w

if (defined $ARGV[0]){
  $chmlog = $ARGV[0];
  if (!-s $chmlog){
    die "CHEMSHELL log $chmlog does not exist or is empty.";
  }
}
if (defined $ARGV[1]){
  $e00=$ARGV[1];
}
$chmout="get_chm.dat";
$i=0;
open(OUT,">$chmout") or die ":( $chmout";
open(IN,$chmlog) or die ":( $chmlog";
while(<IN>){
  if (/ground state energy:/){
     chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
     @g=split(/\s+/,$_);
     if ($i==0){
       if (!defined $e00){
         $e00=$g[6];
       }
     }
     $e0=($g[6]-$e00)*27.21138386;
     $_=<IN>;
     chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
     @g=split(/\s+/,$_);
     $e1=$e0+$g[5];
     printf OUT "%12d   %12.4f    %12.4f    %12.4f\n",$i,$e0,$e1,$g[5]; 
     $i++;
  }
}
close(IN);
close(OUT);
