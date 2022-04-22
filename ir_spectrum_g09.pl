#!/usr/bin/perl -w
# Reads gaussian.log and prints:
# Freq  Freq*factor(fx)  Intensity 
# factor can have two values one for frequencies larger than fx and other for smaller than.
#

$fx   = 1000;
$lowf = 1.00;
$highf= 0.97;

$nArg=$#ARGV+1;
if ($nArg == 0){
  print STDOUT "\nNo file name was given.\n";
  die;
}

$fvib=$ARGV[0];
print "Looking for frequencies in $fvib\n";
$ir="ir.dat";

if (!-s $fvib){
  die "Cannot find G09 output in $fvib!";
}

open(DAT,">$ir") or die ":( $ir";

open(FV,$fvib) or die ":( $fvib";
while(<FV>){
  if (/Frequencies --/){
     chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
     @g=split(/\s+/,$_);
     while(<FV>){
        if (/IR Inten    --/){
           chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
           @h=split(/\s+/,$_);
           last;
        }
     }
     for ($i=2;$i<=4;$i++){
       if ($g[$i]< $fx){
         $factor=$lowf;
       }else{
         $factor=$highf;
       }
       #printf DAT "%8.1f %8.1f %9.2f \n",$g[$i],$g[$i]*$factor,$h[$i+1]; 
       printf DAT "%8.1f\n",$g[$i]*$factor; 
     }
  }
}
close(FV);

close(DAT);
