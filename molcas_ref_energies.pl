#!/usr/bin/perl -w

$inp="molcas.log";
$string1="root number  1";
$string2="Total energy:";
$string3="Energies and eigenvectors:";
$log="molcas-ref-energies.dat";

$count=0;
open(IN,$inp) or warn "Cannot Find $inp!\n";
while(<IN>){
  if (/$string1/){
     chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
     @g=split(/\s+/,$_);
     $eras=$g[5];
  }
  if (/$string2/){
     if ($count == 0){
       chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
       @g=split(/\s+/,$_);
       $ept2=$g[2];
       $count++;
     }
  }
  if (/$string3/){
     $_=<IN>;
     $_=<IN>;
     chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
     @g=split(/\s+/,$_);
     $emix=$g[0];
  }
}
close(IN);

open(OUT,">$log") or die "Cannot write to $log!";
print OUT "$eras   $ept2   $emix"; 
close(OUT);

