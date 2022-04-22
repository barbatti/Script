#!/usr/bin/perl -w

# This program reads a dyn.mld and rewrites it formated.
# Useful when each geometry in dyn.mld comes from a different source.
# Mario Barbatti Nov 2014

$fin="dyn.mld";

if (!-s $fin){
  die "$fin is empty of does not exist.";
}

open(IN,$fin) or die ":( $fin";
open(OUT,">formated-$fin") or die ":( formated-$fin";
while(<IN>){
 chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
 $nat=$_;
 printf OUT " %4d\n",$nat;
 $_=<IN>;
 print OUT $_;
 for ($i=1;$i<=$nat;$i++){
   $_=<IN>;
   chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
   @g=split(/\s+/,$_);
   printf OUT "%2s %11.6f %11.6f %11.6f\n",uc($g[0]),$g[1],$g[2],$g[3];
 } 
}
close(IN);
close(OUT);
