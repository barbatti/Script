#!/usr/bin/perl -w

# Takes collect line like:
#   4    a     8.494   0.0063     37a-39a 81.2    37a-41a 8.9
# rewrites it like:
#  8.494   0.0063     37
#  8.494   0.0063     39

$a=2; # Change these indexes for other collect formats
$b=3;
$c=4;
$lumo=37;

eingenvalues();

open(OUT,">tps.dat") or die ":( tps.dat";
open(IN,"collect-turbomole.dat") or die ":( collect-turbomole.dat";
while(<IN>){
 chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
 (@g)=split(/\s+/,$_);
 $g[$c]=~ s/a//g;
 ($mo1,$mo2)=split(/-/,$g[$c]);
 $enH=($en[$mo1-1]-$en[$lumo-1])*27.21138386;
 $enL=($en[$mo2-1]-$en[$lumo-1])*27.21138386;
 printf OUT "%12.7f  %12.7f  %12.7f   %5d\n",$g[$a],$g[$b],$enH,$mo1;
 printf OUT "%12.7f  %12.7f  %12.7f   %5d\n",$g[$a],$g[$b],$enL,$mo2;
}
close(OUT);
close(IN);

sub eingenvalues{
 open(IN,"mos") or die ":( mos";
 $ind=0;
 while(<IN>){
   if (/eigenvalue=/){
     chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
     $_=~s/D/E/g;
     @g1=split(/\s+/,$_);
     ($lab,$en[$ind])=split(/=/,$g1[2]); 
     $lab=$lab;
     $ind++;
   }
 }
 close(IN);
}
