#!/usr/bin/perl -w
# Prepare inputs for CIOpt program.
# It works with run_seq_turbo.pl.
# Variables of Control.dat are hard-coded below.
#
# How to use:
# 1. Create Ground state directory, excited state directory, and tmp.com
# tmp.com is the xyz of the initial geometry. 
# The directories should contain templates for the jobs.
# Directory names are:
#                   Ground state   Excited state
# TDDFT  Turbomole   DFT-TM         TDDFT-TM
# ADC(2) Turbomole   MP2            ADC
#
# 2. Run cioptinp.pl (newest is v. 02).
#
# 3. Run CIOpt.e > CIOpt.out &
#
# Mario Barbatti, March-July 2014

# Choose method
print " Which method should the inputs be prepared to?\n";
print " 1 - ADC(2)/CC2 [Turbomole]\n";
print " 2 - TDDFT [Turbomole]\n";
print " Choose option (default = 2): \n";

$_=<STDIN>;
chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;

if ( $_ =~ /^[\+-]*[0-9]*\.*[0-9]*$/ && $_ !~ /^[\. ]*$/  ) { # numeric?
  if ($_ == 1){
   $method="ADC";    # ADC / Turbomole
  }elsif ($_ == 2){
   $method="TDDFT-TM"; # TDDFT / Turbomole
  }else{
   $method="TDDFT-TM"; # TDDFT / Turbomole
  }
}else{
 $method="TDDFT-TM"; # TDDFT / Turbomole
}

print "Creating inputs for $method.\n";

# read tmp.com
if (!-s "tmp.com"){
  die "Prepare tmp.com containing xyz for initial geometry and run it again.\n\n";
}

open(TC,"tmp.com") or die ":( tmp.com";
$_=<TC>;
chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
$nat=$_;
print "tmp.com was found. It is a molecule with $nat atoms.\n";
$_=<TC>;
for ($i=0;$i<=$nat-1;$i++){
  $_=<TC>;
  chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
  ($s[$i],$x[$i],$y[$i],$z[$i])=split(/\s+/,$_);
}
close(TC);

# Creating directories
if ($method eq "ADC"){
  $dir_1="MP2";
  $dir_2="ADC";
}elsif($method eq "TDDFT-TM"){
  $dir_1="DFT-TM";
  $dir_2="TDDFT-TM";
}
if (-s $dir_1){
  print "Ground-state directory $dir_1 exists.\n";
}else{
  print "Ground-state directory $dir_1 does NOT exists. It will be created.\n";
  system("mkdir $dir_1");
}
if (-s $dir_2){
  print "Excited-state directory $dir_2 exists.\n";
}else{
  print "Excited-state directory $dir_2 does NOT exists. It will be created.\n";
  system("mkdir $dir_2");
}

# Auxiliary programs
if ($method eq "ADC"){
  $aux_prog="run_seq_turbo.pl";
}elsif($method eq "TDDFT-TM"){
  $aux_prog="run_seq_turbo-tddft.pl";
}

#========================================================================
# write Control.dat
open(IN,">Control.dat") or die ":( Control.dat";
print IN "&control\n";
print IN "nopt=3\n";  # 3=BFGS
print IN "natoms=$nat\n";
print IN "nstates=2\n";
print IN "istate=2\n";
print IN "nefunc=7\n";  # 8=Second penalty formula
print IN "crunstr='$aux_prog'\n";
print IN "zangrad=.true.\n";
print IN"/\n";
for ($i=0;$i<=$nat-1;$i++){
  printf IN "%3s  %9.5f  %9.5f  %9.5f\n",$s[$i],$x[$i],$y[$i],$z[$i];
}
close(IN);
#========================================================================

# write template.write
# write template.writeg
open(TW,">template.write") or die ":( template.write";
print TW "$nat\n\n";
for ($i=0;$i<=$nat-1;$i++){
  $a=3*$i+1;$b=3*$i+2;$c=3*$i+3;
  if ($c <= 9){
    print TW "$s[$i]  %%00$a  %%00$b  %%00$c\n";
  }elsif ($c <= 99){
    print TW "$s[$i]  %%0$a  %%0$b  %%0$c\n";
  }elsif ($c <= 999){
    print TW "$s[$i]  %%$a  %%$b  %%$c\n";
  }
  if ($c >= 1000){
    die "Too many atoms ...\n";
  }
}
close(TW);
system("cp -f template.write template.writeg");

# write template.read
open(TR,">template.read") or die ":( template.read";
print TR "^001Energies\n";
print TR "&%07(f12.7)00101\n";
print TR "&%07(f12.7)00201\n";
close(TR);

# write template.readg
# write template.readg2
if ($method eq "ADC"){
  write_trg("template.readg2","MP2");
  write_trg("template.readg","ADC");
}elsif($method eq "TDDFT-TM"){
  write_trg("template.readg2","DFT-TM");
  write_trg("template.readg","TDDFT-TM");
}

sub write_trg{
  ($file,$type)=@_;
  open(TG,">$file") or die ":( $file";
  print TG "^001Gradient $type\n";
  for ($i=0;$i<=$nat-1;$i++){
    $a=3*$i+1;$b=3*$i+2;$c=3*$i+3;
    if ($c <= 9){
      print TG "&%07(f15.9)00$a"."01%07(f15.9)00$b"."17%07(f15.9)00$c"."33\n";
    }elsif ($c <= 99){
      print TG "&%07(f15.9)0$a"."01%07(f15.9)0$b"."17%07(f15.9)0$c"."33\n";
    }elsif ($c <= 999){
      print TG "&%07(f15.9)$a"."01%07(f15.9)$b"."17%07(f15.9)$c"."33\n";
    }
  }
  close(TG);
}
