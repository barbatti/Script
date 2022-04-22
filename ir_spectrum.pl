#!/usr/bin/perl -w
# Reads force.out and prints:
# Freq  Freq*factor(fx)  Intensity 
# factor can have two values one for frequencies larger than fx and other for smaller than.
#

$fx   = 1000;
$lowf = 1.00;
$highf= 0.97;

$fvib="force.out";
$ir="ir.dat";

if (!-s $fvib){
  die "Cannot find Turbomole output named force.out!";
}

open(DAT,">$ir") or die ":( $ir";

open(FV,$fvib) or die ":( $fvib";
while(<FV>){
  if (/frequency   /){
     chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
     @g=split(/\s+/,$_);
     while(<FV>){
        if (/intensity \(km/){
           chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
           @h=split(/\s+/,$_);
           last;
        }
     }
     for ($i=1;$i<=6;$i++){
       if ($g[$i]< $fx){
         $factor=$lowf;
       }else{
         $factor=$highf;
       }
       if ($g[$i] != 0){
          printf DAT "%8.1f %8.1f %9.2f \n",$g[$i],$g[$i]*$factor,$h[$i+1]; 
       }
     }
  }
}
close(FV);

close(DAT);
