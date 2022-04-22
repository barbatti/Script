#!/usr/bin/perl -w
#

print "Enter initial dir:";
$_=<STDIN>;
chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
$ini=$_;

print "Enter final dir:";
$_=<STDIN>;
chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
$fin=$_;

for ($i=$ini;$i<=$fin;$i++){
  print "Making spectrum for SELECT-$i ...\n";
  chdir("SELECT-$i");
  system("cp ../mkd.inp .");
  system("\$NX/makedir.pl");
  system("cp -f spectrum.dat ../s$i.dat");
  chdir("../");
}

