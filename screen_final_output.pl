#!/usr/bin/perl -w

# This script reads fina_output and rewrites applying YES/NO tags according 
# to a new energetic criteria.
# An input file calle screen_fo must be provided with the following parameters:
# kvert = 0 /use center of the restriction given in evert
#         1 /center of restriction is the vertical energy excitation (first card in final_output)
# evert = energy center (eV)
# de = restriction width (eV) (energy center +/- de/2)
# Mario Barbatti, May 2008

use lib join('/',$ENV{"NX"},"CPAN") ;
use colib_perl;

$kvert  = getkeyword("screen_fo","kvert","1");
if ($kvert == 1){
  $evert  = getkeyword("screen_fo","evert","5.0");
}elsif ($kvert == 0){
  open(FO,"final_output") or die ":( final_output";
  while(<FO>){
     if (/Reference energy/){
         chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
         @g=split(/\s+/,$_);
         $evert=$g[4];
         last;
     }
  }
  close(FO);
}
$de     = getkeyword("screen_fo","de","0.5");

$emin=$evert-$de/2;
$emax=$evert+$de/2;

print "kvert  = $kvert\n";
print "evert  = $evert\n";
print "de     = $de\n";
print "emin   = $emin\n";
print "emax   = $emax\n";

open(FO,"final_output") or die ":( final_output";
open(FS,">final_output_screened") or die ":( final_output_screened";
while(<FO>){
  if (/Accept initial conditions/){
    printf FS " Accept initial conditions between %8.4f eV and %8.4f eV.\n",$emin,$emax;
  }elsif(/the required range/){
    @g=split(/\s+/,$_);
    $ve=$g[4];
    $tag="NO";
    if (($ve >= $emin) and ($ve <= $emax)){
      $tag="YES";
    }
    printf FS " Vertical excitation (eV): %11.4f  Is Ev in the required range? %s\n",$ve,$tag;
  }else{
    print FS $_;
  }
}
close(FO);
close(FS);

