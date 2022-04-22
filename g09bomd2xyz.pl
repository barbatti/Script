#!/usr/bin/perl -w

$au2ang=0.52917720859;

if ($ARGV[0] eq ""){
  die " Use: g09ibomd2xyz <g09_output.log> \n\n"
}
if (!-s "$ARGV[0]"){
  die "File $ARGV[0] does not exist or is empty.\n\n";
}
$filein=$ARGV[0];
$fileout="g09bomd.xyz";
print " Reading $filein ...\n";

open(IN,"$filein") or die ":( $filein";
while(<IN>){
  if (/NAtoms=/){
    chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
    ($grb,$nat)=split(/\s+/,$_);
    last;
  }
}
close(IN);
print " The number of atoms is $nat\n";

open(IN,"$filein") or die ":( $filein";
while(<IN>){
  if (/Charge =/){
    for ($i=0; $i<=$nat-1; $i++){
      $_=<IN>;
      chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
      ($s[$i])=split(/\s+/,$_);
    }
    last;
  }
}
close(IN);
print " Atomic symbols were found.\n";

open(IN,"$filein") or die ":( $filein";
open(OUT,">$fileout") or die ":( $fileout";
while(<IN>){
  if (/Cartesian coordinates: \(bohr\)/){
    print OUT "$nat\n\n";
    for ($i=0; $i<=$nat-1; $i++){
      $_=<IN>;
      chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
      @a=split(/\s+/,$_);
      $a[3]=~s/D/E/;
      $a[5]=~s/D/E/;
      $a[7]=~s/D/E/;
      printf OUT "%4s  %14.6f %14.6f %14.6f\n",$s[$i],$a[3]*$au2ang,$a[5]*$au2ang,$a[7]*$au2ang;
    }
  }
}
close(IN);
close(OUT);

