#!/usr/bin/perl -w

# list of trajectories:
#@list=(1,3,22,28,32,36,38,44,57,60,61,65,72,79,83,89,94);
@list=(4,5,10,11,12,14,15,16,19,20,21,23,24,26,27,29,33,35,37,39,40,42,45,47,50,51,52,53,54,56,62,64,66,67,70,75,76,81,88,95,96,97);

open(TQ,">list_ttq.dat") or die ":( list_ttq.dat";
foreach(@list){
  $nt=$_;
  open(CP,"t-cp$nt.dat") or die ":( t-cp$nt.dat";
  while(<CP>){ 
      chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
      @g=split(/\s+/,$_);
      print TQ " $nt  $g[0]  $g[1]\n";
  }
  close(CP);
}
close(TQ);
system("/home/barbatti/PERL_FILES/average_ttq");
