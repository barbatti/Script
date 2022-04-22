#!/usr/bin/perl -w 
#
# This program reads a pdb file with DNA coordinates, a Tinker file with the smae coordinates
# and includes the Amber parameters into the Tinker.
#
# It needs:
# dna.pdb: pdb file
# dna-aux.tinker: Tinker file with the same coordinates and same atom order. (Created by Babel, for example.)
# amber99.prm: Tinker parameter file.
#
# Run: conversion.pl
#
# Output: dna.tinker
#
# Mario Barbatti Jul 2009
#

# File names
$pdb="dna.pdb";
$auxtxyz="dna-aux.txyz";
$txyz="dna.tinker";
$amber="amber99.prm";

open(PDB,$pdb) or die ":( $pdb";
open(ATX,$auxtxyz) or die ":( $auxtxyz";
open(TNK,">$txyz") or die ":( $txyz";

# Jump labels
$_=<PDB>;
$_=<ATX>;
print TNK "$_";

# Read PDB
while(<PDB>){
  read_pdb();
  if ($grb eq "ATOM"){
    read_atx();
    find_amber();
    print_tinker();  
  }
}
#================================================================================
sub print_tinker{
  $g[0]=sprintf("%4d",$g[0]);
  $g[1]=sprintf("%2s",$g[1]);
  $g[2]=sprintf("%13.6f",$g[2]);
  $g[3]=sprintf("%13.6f",$g[3]);
  $g[4]=sprintf("%13.6f",$g[4]);
  $g[5]=sprintf("%6d",$g[5]);
  $g[6]=sprintf("%6d",$g[6]);
  print TNK "@g\n";
}
#================================================================================
sub read_pdb{
  chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
  ($grb,$gpdb,$spdb,$respdb,$gpdb,$gpdb,$gpdb,$gpdb,$gpdb,$gpdb)=split(/\s+/,$_);
}
#================================================================================
sub read_atx{
  $_=<ATX>;
  chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
  @g=split(/\s+/,$_);
  $g[5]=0;
}
#================================================================================
sub find_amber{
  $res{"ADE"} = "D-Adenosine";
  $res{"GUA"} = "D-Guanosine";
  $res{"CYT"} = "D-Cytosine";
  $res{"THY"} = "D-Thymine";
  
  $residue=$res{$respdb};
  find_in_amber();
}
#================================================================================
sub find_in_amber{
  $found="n";
  if ($spdb =~ /\'\'/){
    $spdb=~s/\'\'/\'2/;
  }
  $spdb=~s/'/\\'/g;
  open(AMB,$amber) or die ":( $amber";
  while(<AMB>){
     if (/$residue/){
       if ($spdb=~/\'/){
         if (/\b$spdb/){
           chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
           @h=split(/\s+/,$_);
           $g[5]=$h[1];
           $found ="y";
	   last;
         }
       }else{
         if ((/\b$spdb\b/) and ($_!~/'/)){
           chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
           @h=split(/\s+/,$_);
           $g[5]=$h[1];
           $found ="y";
           last;
         }
       }
     }
  }
  close(AMB);
  if ($found eq "n"){
    exceptions();
  }
}
#================================================================================
sub exceptions{
  # Phosphodiester bond
  if ($spdb eq "P"){
    $g[5]=1242;
  }
  if ($spdb eq "O1P"){
    $g[5]=1243;
  }
  if ($spdb eq "O2P"){
    $g[5]=1243;
  }
  if ($spdb eq "O5\'"){
    $g[5]=1244;
  }
  if ($spdb eq "H5T"){
    $g[5]=1245;
  }
  if ($spdb eq "O3\'"){
    $g[5]=1249;
  }
  if ($spdb eq "H3T"){
    $g[5]=1250;
  }
  # Methyl in thymine
  if ($spdb eq "C5M"){
    $g[5]=1227;
  }
  if ($spdb eq "H51"){
    $g[5]=1228;
  }
  if ($spdb eq "H52"){
    $g[5]=1228;
  }
  if ($spdb eq "H53"){
    $g[5]=1228;
  } 
}
