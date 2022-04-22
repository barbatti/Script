#!/usr/bin/perl -w
# Prepare inputs for CIOpt program.
# It works with run_seq_*.pl programs.
# Variables of Control.dat are hard-coded below.
#
# Newest version:
# ---------------
# <version> = v03
#
# Options:
# --------
#
# 1 - ADC(2) G/E [Turbomole]
# 2 - TDDFT G/E [Turbomole]
# 3 - TDDFT E/E [G09]
#
# How to use:
# -----------
#
# WITH TURBOMOLE:
# 1. Create a tmp.com file with the initaila xyz geometry. 
#
# 2. Create Ground state directory and excited state directory.
# The directories should contain templates for the jobs.
# Directory names are:
#    a) Crossing between Ground and Excited States (G/E)
#                        Ground state   Excited state
#       TDDFT  Turbomole   DFT-TM         TDDFT-TM
#       ADC(2) Turbomole   MP2            ADC
#
# 3. Run cioptinp-<version>.pl (newest version is v03).
#
# 4. Run CIOpt.e > CIOpt.out &
#
# WITH GAUSSIAN:
# 1. Create a tmp.com file containing the initial xyz geometry.
#
# 2. Create a directory with a gaussian input file.
#   a) For Excited/Excited crossings (E/E) with TDDFT
#   * Directory must be named TDDFT_EE
#   * Dir must contain a gaussian.inp file with job template.
#     Calculations for both states should be done with linked jobs.
#     Example of gaussian.inp is given below.
#
# 3. Run cioptinp-<version>.pl.
#
# 4. Run CIOpt.e > CIOpt.out &
#
# Example of gaussian.inp:
# -----------------------------------------------------------
# %chk=gck
# %mem=1GB
# #p TD(Root=1,NStates=1) B3LYP SCF(MaxCyc=300) 3-21G nosymm force
# 
# Title1: state 1  # Do NOT change this title!
#
# 0  1
# C         0.000000       0.000000       0.000000
# C         0.000000       0.000000       1.341840
# H         0.928559       0.000000      -0.586081
# H        -0.928559       0.000000      -0.586081
# H         0.928559       0.000000       1.927921
# H        -0.928559       0.000000       1.927921
# 
# --Link1--
# %chk=gck
# %NoSave
# %mem=1GB
# #p TD(Root=2,NStates=2) B3LYP SCF(MaxCyc=300) 3-21G nosymm force
# #p guess=read geom=check
# 
# Title2: state 2
# 
# 0  1
# 
# -----------------------------------------------------------
#
# Mario Barbatti, March 2014-January 2015

# Choose method
print " Which method should the inputs be prepared to?\n";
print " 1 - ADC(2) G/E [Turbomole]\n";
print " 2 - TDDFT  G/E [Turbomole]\n";
print " 3 - TDDFT  E/E [G09]\n";
print " Choose option (default = 2): \n";

$_=<STDIN>;
chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;

if ( $_ =~ /^[\+-]*[0-9]*\.*[0-9]*$/ && $_ !~ /^[\. ]*$/  ) { # numeric?
  if ($_ == 1){
   $method="ADC";    # ADC / Turbomole
  }elsif ($_ == 2){
   $method="TDDFT-TM"; # TDDFT / Turbomole
  }elsif ($_ == 3){
   $method="TDDFT-G09-EE"; # TDDFT /G09 / EE
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
}elsif($method eq "TDDFT-G09-EE"){
  $dir_1="TDDFT_EE";
  $dir_2="NE";
}
if (-s $dir_1){
  print "Ground-state directory $dir_1 exists.\n";
}else{
  print "Ground-state directory $dir_1 does NOT exists. It will be created.\n";
  system("mkdir $dir_1");
}
if ($dir_2 ne "NE"){
  if (-s $dir_2){
    print "Excited-state directory $dir_2 exists.\n";
  }else{
    print "Excited-state directory $dir_2 does NOT exists. It will be created.\n";
    system("mkdir $dir_2");
  }
}

# Auxiliary programs
if ($method eq "ADC"){
  $aux_prog="run_seq_turbo.pl";
}elsif($method eq "TDDFT-TM"){
  $aux_prog="run_seq_turbo-tddft.pl";
}elsif($method eq "TDDFT-G09-EE"){
  $aux_prog="run_seq_g09_tddft_ee.pl";
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
}elsif($method eq "TDDFT-G09-EE"){
  write_trg("template.readg2","State1");
  write_trg("template.readg","State2");
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
