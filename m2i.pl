#!/usr/bin/perl -w
#===================================================================================
# MOCOEF2INPORB
# This program converts a mocoef (COLUMBUS) file into a INPORB (MOLCAS).
# Mario Barbatti, April 2009.
#
# Valid only for C1 symmetry. 
# Work only with s, p, and d functions.
#
# Input:
# Number of atoms
# contracted s for atom 1, contracted p for atom 1, contracted d for atom 1
# ...
# contracted s for atom Nat, contracted p for atom Nat, contracted d for atom Nat
#
# Example: C2H4 with 6-31G*
# In a directory containing the mocoef file:
# 1) Create file moc2inp with:
# 6
# 3 2 1
# 3 2 1
# 2 0 0
# 2 0 0
# 2 0 0
# 2 0 0
# 2) Run mocoef2inporb.pl < moc2inp > moc2inp.log
# Results are written to INPORB file.
#===================================================================================

$DIR="/home3/barbatti/PERL_FILES";

$_=<STDIN>;
chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;

if ($_ eq ""){
  die "\n\nMOCOEF2INPORB: See source code for instructions about how to use this program.\n\n";
}

$nat=$_;
print "NAT = $nat\n";

for ($i=0;$i<=$nat-1;$i++){
  $_=<STDIN>;
  chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
  ($cont[$i][0],$cont[$i][1],$cont[$i][2])=split(/\s+/,$_);
  printf "Atom %5d: $cont[$i][0]s $cont[$i][1]p $cont[$i][2]d\n",$i;
}

read_mocoef();

open(IO,">INPORB.aux") or die":( INPORB.aux";
print IO "#INPORB 1.0\n";
print IO "#INFO\n";
print IO "* Orbitals from Columbus\n";
print IO "       0       1\n";
print IO "     $norb\n";
print IO "     $nbasis\n";
print IO "#ORB\n";
close(IO);

open(RD,">rd.inp") or die":( rd.inp";
print RD "$nbasis\n";
for ($k=0;$k<=$norb-1;$k++){
  $c4=0;
  $count=-1;
  for ($n=0;$n<=$nat-1;$n++){
    @s=();
    @px=();
    @py=();
    @pz=();
    @d2m=();
    @d1m=();
    @d0=();
    @d1p=();
    @d2p=();
    $at=$n+1;
    print "Atom: $at\n";
    print "Mocoef order of basis:\n";
    for ($shell=0;$shell<$cont[$n][0];$shell++){
      print "$at  s\n";
      $count++;
      push(@s,$count);
    }
    for ($shell=0;$shell<$cont[$n][1];$shell++){
      print "$at  px\n";
      $count++;
      push(@px,$count);
      print "$at  py\n";
      $count++;
      push(@py,$count);
      print "$at  pz\n";
      $count++;
      push(@pz,$count);
    }
    for ($shell=0;$shell<$cont[$n][2];$shell++){
      print "$at  d2-\n";
      $count++;
      push(@d2m,$count);
      print "$at  d1-\n";
      $count++;
      push(@d1m,$count);
      print "$at  d0\n";
      $count++;
      push(@d0,$count);
      print "$at  d1+\n";
      $count++;
      push(@d1p,$count);
      print "$at  d2+\n";
      $count++;
      push(@d2p,$count);
    }

    print "INPORB order of basis:\n";
    foreach(@s){
      print "$_\n";
      $c4=write_inporb($k,$_,$c4);
    }
    foreach(@px){
      print "$_\n";
      $c4=write_inporb($k,$_,$c4);
    }
    foreach(@py){
      print "$_\n";
      $c4=write_inporb($k,$_,$c4);
    }
    foreach(@pz){
      print "$_\n";
      $c4=write_inporb($k,$_,$c4);
    }
    foreach(@d2m){
      print "$_\n";
      $c4=write_inporb($k,$_,$c4);
    }
    foreach(@d1m){
      print "$_\n";
      $c4=write_inporb($k,$_,$c4);
    }
    foreach(@d0){
      print "$_\n";
      $c4=write_inporb($k,$_,$c4);
    }
    foreach(@d1p){
      print "$_\n";
      $c4=write_inporb($k,$_,$c4);
    }
    foreach(@d2p){
      print "$_\n";
      $c4=write_inporb($k,$_,$c4);
    }
  }
  print "NBAS = $count\n";
  if ($c4 != 0){
    print RD "\n";
  }
}
close(RD);
system("$DIR/rd_vec");
system("cat INPORB.aux ../I > INPORB");
system("rm -f INPORB.aux");
##system("rm -f rd.inp");
#=============================================================================
sub write_inporb{
  my ($c4,$n,$i);
  ($n,$i,$c4)=@_;
  $coef[$n][$i]=~s/d/E/ig;
  if ($coef[$n][$i]>=0.0E+00){
    printf RD " %18.12E ",$coef[$n][$i];
  }else{
    printf RD "%18.12E ",$coef[$n][$i];
  }
  $c4++;
  if ($c4 == 4){
    print RD "\n";#
    $c4=0;
  }
  return $c4;
}
#=============================================================================
sub read_mocoef{
  if (!-s "mocoef"){
     die "\nERROR: ***** Cannot find mocoef file! *****\n";
  }
  open(MO,"mocoef") or die ":( mocoef";
  while(<MO>){
    if (/formatted orbitals/){
        $_=<MO>;
        $_=<MO>;
      chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
      ($norb,$nbasis)=split(/\s+/,$_);
      $_=<MO>;
      $_=<MO>;
      $_=<MO>;
      last;
    }
  }
  print "NORB,NBAS = $norb, $nbasis\n";

  $ncol=3;
  $nlines=int($nbasis/$ncol);
  $nrem=$nbasis-$nlines*$ncol;

  for ($no=0;$no<=$norb-1;$no++){
    $k=0;
    for ($i=1;$i<=$nlines;$i++){
      $_=<MO>;
      chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
      ($coef[$no][$k],$coef[$no][$k+1],$coef[$no][$k+2])=split(/\s+/,$_);
      $k=$k+3;
    }
    if ($nrem>0){
      $_=<MO>;
      chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
      if ($nrem == 1){
        ($coef[$no][$k])=split(/\s+/,$_);
      }
      if ($nrem == 2){
        ($coef[$no][$k],$coef[$no][$k+1])=split(/\s+/,$_);
      }
    }
  }
  close(MO);
}
