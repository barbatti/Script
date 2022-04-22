#!/usr/bin/perl -w

$file="dyn2.mld";
open(INP,$file) or die ":( $file";
$_=<INP>;
chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
$Nat=$_;
close(INP);
$flog=">stretch_in_dynmld.log";
$fdat=">stretch_in_dynmld.dat";
open(LOG,$flog);
open(DAT,$fdat);

print " First atom:  ";
$_=<STDIN>;
chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
$Ni=$_;
print " Second atom: ";
$_=<STDIN>;
chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
$Nf=$_;

print LOG " Reading file $file.\n";
print LOG " Number of atoms is $Nat.\n";
print LOG " Distance between atoms $Ni and $Nf.\n";

$k=0;
open(INP,$file) or die ":( $file";
while(<INP>){
  print $_;
  $_=<INP>;
  $k++;
  print LOG " Geometry $k\n";
  for ($i=1;$i<=$Nat;$i++){
    $_=<INP>;
    chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
    if ($i == $Ni){
       @first=split(/\s+/,$_);
       print LOG " Cartesian coordinates $Ni: $first[1]  $first[2]  $first[3]\n";
    }
    if ($i == $Nf){
       @second=split(/\s+/,$_);
       print LOG " Cartesian coordinates $Nf: $second[1]  $second[2]  $second[3]\n";
    }
  }
  distance();
}
close(INP);

close(DAT);
close(LOG);

sub distance{
  $norm=($first[1]-$second[1])**2+($first[2]-$second[2])**2+($first[3]-$second[3])**2;
  $dist=sqrt($norm);
  print LOG " Distance in Angstrom: $dist\n";
  print DAT " $k   $dist\n";
}
