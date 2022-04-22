#!/usr/bin/perl -w
use lib join('/',$ENV{"NX"},"CPAN") ;
use colib_perl;

$DISP="DISPLACEMENT";

# Read geometries in final_output file and writes them in DISPLACEMENT/CALC.c1.d structure.
if (!-s "$DISP"){
  system("mkdir $DISP");
}else{
  die "Cannot create $DISP dir: it already exists!";
}

$nat=  number_of_atoms();

open (FO,"final_output") or die ":( final_output";
open (DL,">$DISP/displfl") or die ":( $DISP/displfl";
print DL "\n\n\n";
while(<FO>){
  if (/Initial condition =/){
      chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
      ($g,$g,$g,$ic)=split(/\s+/,$_);
      print DL " 1 $ic\n";
      $DC="$DISP/CALC.c1.d$ic";
      system("mkdir $DC");
      $_=<FO>;
      open(GE,">$DC/geom") or die ":( $DC/geom";
      for ($n=1;$n<=$nat;$n++){
         $_=<FO>;
         print GE $_;
      }
      close(GE);
  }
}
close(DL);
close(FO);
