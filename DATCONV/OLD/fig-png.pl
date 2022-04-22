#!/usr/bin/perl -w
#
# fig.pl is used to produce a sequence of gif files
# based on gnuplot graphs of energy x time.
#
# The graphs are based on en.dat file generated by NX.
#
# Input files:
# en.dat - NX output file 
# ip     - file containing the gnuplot instructions
#
# An ip file is given as example in DATCONV directory,
# but bear in mind that this file is user specific and
# certainly has to be modified in each case.
# 
# Usage: 
# Having en.dat and ip files, run DATCONV/fig.pl
#
# Mario Barbatti, 2006-2015.
#

$AD = "\$hm/PERL_FILES/DATCONV";

system("rm -f frame");

print "\nEnter the number of states: ";
$_=<STDIN>;
chomp;
$nstat=$_;
print "\nIs file en.dat in a.u. (1) or in eV (2)? ";
$_=<STDIN>;
chomp;
$iunit=$_;
if ($iunit == 1){
   print "\nEnter the reference energy in a.u.: ";
   $_=<STDIN>;
   chomp;
   $emin=$_;
} else {
   $emin=0.0;
}

# ...................
$imax = 0;
open(EN,"en.dat") or die ":( en.dat!";
while(<EN>){
  $imax++;
}
close(EN);
# ...................

open(DC,">datconv.inp") or die ":( datconv.inp!";
print DC "$nstat $imax $iunit $emin";
close(DC);

if (!-e "frame") {
open(FR,">frame") || die "Cannot open frame to write!" ;
print FR "  0";
close(FR);
}

  $i=0;

  while ($i < $imax) {
  $i++;  

  system("$AD/./datconv");

#  system("sed \'s/points 7/points $i/\' ip > ip1");

  system("gnuplot ip");
  system("mv f.png f-$i.png");
  system("rm -f f.png");

  }

system("rm -f frame datconv.inp data.dat");