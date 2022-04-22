#!/usr/bin/perl -w
# I created this to merge CP analysis for Adenine.
# MB

$dt=0.5;
$stpmn=1;
$maxtj=49;

open(OUT1,">merged") or die ":( merged";
open(OUT2,">merged_interp") or die ":( merged_interp";
open(OUT3,">phytheta") or die ":( phytheta";
for ($i=1;$i<=$maxtj;$i++){
 open(IN,"t-cp$i.dat") or die ":( t-cp$i.dat";
 $_=<IN>;
 $k=0;
 undef(@q);
 while(<IN>){
   print OUT1 $_;
   chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
   (@g)=split(/\s+/,$_);
   $q[$g[0]]=$g[1];
   print OUT3 "$g[3]  $g[2]\n";
   $k++;
 }
 close(IN);
 $kmax=$g[0];

 $lastq=rand()*0.05;
 for ($j=$stpmn;$j<=$kmax;$j++){
   if (defined $q[$j]){
     $lastq=$q[$j];
   }elsif(!defined $q[$j]){
     $r=rand();
     $q[$j]=$r*$lastq; 
   }

   $time=($j-1)*$dt/1000;
   printf OUT2 "%8.5f   %12.3f\n",$time,$q[$j];
 }

}
close(OUT1);
close(OUT2);


#1 -
#2 -
#3 3 0.1
#4 4 0.1
#5 -
#6 6 0.1



