#!/usr/bin/perl -w
#
# After generating DISPLACEMENT directory using disp.pl routine in COLUMBUS,
# this routine can be used to copy files.
# Mario Barbatti, Oct 2011
#

# Files to be copied ---------------------------------------------------------
# $ptm="pcol7";
 $ptm="ptm-para";
# $ptm="pdftci-par";
# $list="TEMPLATE/$ptm TEMPLATE/auxbasis TEMPLATE/basis TEMPLATE/control TEMPLATE/mos TEMPLATE/mrci.inp";
 $list="TEMPLATE/auxbasis TEMPLATE/basis TEMPLATE/control TEMPLATE/mos TEMPLATE/mrci.inp";
# $list="TEMPLATE/$ptm TEMPLATE/mos TEMPLATE/basis TEMPLATE/auxbasis TEMPLATE/control";
# $list="../TEMPLATE/$ptm ../TEMPLATE/mos ../TEMPLATE/basis ../TEMPLATE/auxbasis ../TEMPLATE/control";
# $list="TEMPLATE/$ptm TEMPLATE/mos TEMPLATE/basis TEMPLATE/auxbasis TEMPLATE/control";
# $list="JOB_AD/*";
# $list="TEMPLATE/$ptm TEMPLATE/mos TEMPLATE/basis TEMPLATE/control";
# $list="TEMPLATE/*";
#$list="$ptm ";
#$list="j1.com";
# ----------------------------------------------------------------------------

$WDIR="DISPLACEMENT";
$disp="displfl";
#$DIR="/ns80th/nas/users/barbatti/PERL_FILES/";

print " Coordinate number [default = 1]:";
$_=<STDIN>;
chomp;
$_ =~ s/^\s*//;         # remove leading blanks
$_ =~ s/\s*$//;         # remove trailing blanks
if ($_ eq ""){
  $c = 1;
}else{
  $c=$_;
}

print " Job name [default = jmc]:";
$_=<STDIN>;
chomp;
$_ =~ s/^\s*//;         # remove leading blanks
$_ =~ s/\s*$//;         # remove trailing blanks
if ($_ eq ""){
  $name = "jmc";
}else{
  $name=$_;
}

if (!-s $WDIR){
  die "$WDIR directory does not exist!";
}

open(DP,"$WDIR/$disp") or die ":( $WDIR/$disp";
$_=<DP>;
$_=<DP>;
$_=<DP>;
$ind=0;
while(<DP>){
  chomp;
  $_ =~ s/^\s*//;         # remove leading blanks
  $_ =~ s/\s*$//;         # remove trailing blanks
  ($c,$i)=split(/\s+/,$_);
  change_dir();
  $ind++;
}
close(DP);

#...............................................
sub change_dir{
  if (!-s "$WDIR/CALC.c$c.d$i"){
    die "$WDIR/CALC.c$c.d$i does not exist!";
  }else{
    system("cp -f $list $WDIR/CALC.c$c.d$i/.");
    chdir("$WDIR/CALC.c$c.d$i");
    if (-s "geom"){
    #  die "geom does not exist or is empty!";
      system("\$NX/nx2tm");
    }
    if (-s "$ptm"){
      change_ptm();
    }
    chdir("../../");
  }
}
#...............................................
sub change_ptm{
   system("mv -f $ptm $ptm-temp");
   open(PMT,"$ptm-temp") or die ":( $ptm-temp";
   open(PM,">$ptm") or die ":( $ptm";
   while(<PMT>){
      if (/-N/){
         ($before)=split(/-N/,$_);
         $before =~ s/\s*$//;         # remove trailing blanks
         print PM "$before -N $name.$c-$i \n";
      }else{
         print PM $_;
      }
   }
   close(PM);
   close(PMT);
   system("rm -f $ptm-temp");
}
