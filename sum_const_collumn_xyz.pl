#!/usr/bin/perl -w

print " Constant to be summed (Angstrom):";
$_=<STDIN>;
chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
if ($_ ne ""){
  $const=$_;
}else{
  $const = 0;
}

print " Column (x=1; y=2; z=3; default:3): ";
$_=<STDIN>;
chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
if ($_ ne ""){
  $col=$_;
}else{
  $col = 3;
}

print " XYZ input file name: ";
$_=<STDIN>;
chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
if ($_ ne ""){
  $file=$_;
}else{
  die "We need a name...\n";
}

open(INP,$file) or die ":( $file";
open(OUT,">out-$file") or die ":( $file";

$_=<INP>;
print OUT "$_";
$_=<INP>;
print OUT "$_";

while(<INP>){
  chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
  (@x)=split(/\s+/,$_);
  $x[$col]=$x[$col]+$const;
  printf OUT "%3s   %12.6f    %12.6f    %12.6f\n",$x[0],$x[1],$x[2],$x[3];  
  undef(@x);
}

close(OUT);
close(INP);

