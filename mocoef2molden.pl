#!/usr/bin/perl -w

# Generate molden input from NX output files.
# Useful to velocities and molecular orbitals
# in specific timesteps.
#
# Mario Barbatti, 2007
# Based on NX arrow program
# 
$cbus  = $ENV{"COLUMBUS"};   # Columbus environment

print STDOUT "\n *** MOCOEF2MOLDEN ***\n";
print STDOUT " This program converts molecular orbital file from the COLUMBUS format to MOLDEN format.\n";
print STDOUT " To run it you will need the following COLUMBUS files:\n";
print STDOUT "    Geometry file (default: geom)\n";
print STDOUT "    Molecular orbital file (default: mocoef)\n";
print STDOUT "    hermitin\n";
print STDOUT "    daltaoin\n\n";
 
# Temporary directory
$orbdir="DIR_mocoef2molden";
if (-s $orbdir){
  system("rm -rf $orbdir");
}
system("mkdir $orbdir");

# Check geom file
print STDOUT " Enter the name of the geometry file [<ENTER> to geom]: ";
$_=<STDIN>;
chomp;
$_ =~ s/^\s*//;         # remove leading blanks
$_ =~ s/\s*$//;         # remove trailing blanks
if ($_ eq ""){
  $geom="geom";
}else{
  $geom=$_;
}
if (!-s $geom){
  print STDOUT "File $geom not found!\n";
}
# number of atoms
open(GM,$geom) or die "Cannot read $geom!";
$nat = 0;
while(<GM>){
   $nat++;
}
close(GM);
system("cp -f $geom $orbdir/geom");

# check mocoef file
print STDOUT " Enter the name of the molecular orbitals file [<ENTER> to mocoef]: ";
$_=<STDIN>;
chomp;
$_ =~ s/^\s*//;         # remove leading blanks
$_ =~ s/\s*$//;         # remove trailing blanks
if ($_ eq ""){
  $mocoef="mocoef";
}else{
  $mocoef=$_;
}
if (!-s $mocoef){
  print STDOUT "File $mocoef not found!\n";
}
system("cp -f $mocoef $orbdir/mocoef");

# create transmoin
  open(MOC,">$orbdir/transmoin") or die " Cannot write to file 'transmoin'.\n The systems answer was: $!";
  print MOC "&input\n";
  print MOC " motype=2\n";   # any MOs
  print MOC " molden=1\n";   # just give the molden file, do not change the MOs themself
  print MOC "&end\n";
  close(MOC);

# copy daltaoin
$dal="daltaoin";
if (-s $dal){
  system("cp -f $dal $orbdir/.");
} else {
  die " Could not find $dal\n";
}

# copy hermitin
$her="hermitin";
if (-e $her) {
  system("cp -f $her $orbdir/.");
} else {
  die " Could not find $her\n";
}

chdir($orbdir);

# create soinfo.dat
system("cp -f hermitin daltcomm");
open HERMITIN, ">daltcomm" or die " Cannot open daltcomm for output";
open HERMITOLD, "<hermitin" or die " Cannot open hermitin for input";
$/="";
$inp=<HERMITOLD>;
$inp=~s/\*\*INTEGRALS/**INTEGRALS\n.NOTWO/;
print HERMITIN $inp;
close HERMITIN;
close HERMITOLD;
system("$cbus/dalton.x > hermitls.molden 2>/dev/null");
$/="\n";

# execute transmo.x, which performs the conversion mocoef -> molden
system("$cbus/transmo.x > transmols 2>/dev/null");

# there is a blank line at a certain point of the molden file
# which needs to be removed in order make it readable for molekel

$molden='molden';
open (MOIN,"$molden") or die " Cannot open $molden\n The systems answer was: $!";
open (MOOUT,">$molden.tmp") or die "Cannot open $molden.tmp\n The systems answer was: $!";

while (<MOIN>) {
  if ($_ =~ '\[GTO\]') {
     <MOIN>;
     if ($_ =~ '  ') {
     } else { # only modify the file if it has not been done before
       print MOOUT $_;
     }
  } else {
     print MOOUT $_;
  }
}

close(MOIN);
close(MOOUT);

system("mv -f $molden.tmp $molden");

# End of User inputs
$in = "mocoef.molden";
if (-s "../$in"){
  system("rm -rf ../$in");
}
open(MM,">>../$in") or die "Cannot open $in to write";
open(GM,"$geom") or die "Cannot open $geom";

print MM " [Molden Format]\n";

# orbitals

print MM " [Atoms] AU\n";

# read geometry from geom and write to arrow.mld

 $i = 1;

 while (<GM>) {
  chomp;
  @geom=split(/\s+/, $_);
  print MM
  sprintf(" %2s %4u %3u  %15.10f %15.10f %15.10f\n",
   $geom[1],$i,$geom[2],$geom[3],$geom[4],$geom[5]);
  $i++;
  }

  # write molden orbitals
  open(MO,"$molden") or die "Cannot open $molden";

  for ($i=1; $i <= $nat+2; $i++) {
   # coordinate section
   <MO>;
  }
  while (<MO>) {
   # molden orbital section
   print MM $_;
  }

 close(MO);

close(MM);
close(GM);

print "\n Output written to $in file. \n\n";

chdir("../");
system("rm -rf $orbdir") && warn "Cannot remove files in orbital directory to clean up";

