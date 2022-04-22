#!/usr/bin/perl -w


print " First XYZ input file name: ";
$_=<STDIN>;
chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
if ($_ ne ""){
  $file1=$_;
}else{
  die "We need a name...\n";
}

print " Second XYZ input file name: ";
$_=<STDIN>;
chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
if ($_ ne ""){
  $file2=$_;
}else{
  die "We need a name...\n";
}

# Read 1
open(INP,$file1) or die ":( $file1";

$_=<INP>;
chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
$nat1=$_;
$_=<INP>;

$i=0;
while(<INP>){
  chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
  (@x)=split(/\s+/,$_);
  $row[$i]=sprintf("%3s   %12.6f    %12.6f    %12.6f\n",$x[0],$x[1],$x[2],$x[3]);  
  $i++;
}

close(INP);

# Read 2
open(INP,$file2) or die ":( $file2";

$_=<INP>;
chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
$nat2=$_;
$_=<INP>;

while(<INP>){
  chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
  (@x)=split(/\s+/,$_);
  $row[$i]=sprintf("%3s   %12.6f    %12.6f    %12.6f\n",$x[0],$x[1],$x[2],$x[3]);  
  $i++;
}

close(INP);

# Write 1+2
open(OUT,">merged.xyz") or die ":( merged.xyz";
$nat=$nat1+$nat2;
print OUT "$nat\n\n";
foreach(@row){
  print OUT "$_";
}
close(OUT);
