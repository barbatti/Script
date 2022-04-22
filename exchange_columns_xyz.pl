#!/usr/bin/perl -w

if ($ARGV[0] eq ""){
  die "Use: ./exchange_columns_xyz.pl <XYZ file name>"
}

print " Enter the two columns to be exchanged (space separated, eg, \"x y\"): ";
$_=<STDIN>;
chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
@a=split(/\s+/,$_);
if (scalar @a != 2){
  die "Expecting two arguments. Found ".scalar @a;
}
$a[0] = lc $a[0]; 
$a[1] = lc $a[1]; 

$ind{"x"}=0;
$ind{"y"}=1;
$ind{"z"}=2;

print "It will exchange: ".$ind{$a[0]}." and ".$ind{$a[1]}."\n";

$newfile="new-".$ARGV[0];

open(OF,"$ARGV[0]") or die " :( $ARGV[0]";
open(NF,">$newfile") or die " :( $newfile";
$_=<OF>;
print NF "$_";
$_=<OF>;
print NF "$_";
while(<OF>){
  chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
  @g=split(/\s+/,$_);
  if ((($ind{$a[0]} == 0) and ($ind{$a[1]} == 1)) or (($ind{$a[0]} == 1) and ($ind{$a[1]} == 0))){
    print NF "$g[0]  $g[2]  $g[1]  $g[3]\n";
  }
  if ((($ind{$a[0]} == 0) and ($ind{$a[1]} == 2)) or (($ind{$a[0]} == 2) and ($ind{$a[1]} == 0))){
    print NF "$g[0]  $g[3]  $g[2]  $g[1]\n";
  }
  if ((($ind{$a[0]} == 1) and ($ind{$a[1]} == 2)) or (($ind{$a[0]} == 2) and ($ind{$a[1]} == 1))){
    print NF "$g[0]  $g[1]  $g[3]  $g[2]\n";
  }
}
close(OF);
close(NF);
