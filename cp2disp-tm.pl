#!/usr/bin/perl -w
#
# After generating DISPLACEMENT directory using disp.pl routine in COLUMBUS,
# this routine can be used to create turbomole files.
# Mario Barbatti, Dec 2016
#

# Files to be copied ---------------------------------------------------------
 $ptm="ptm-para";
 $tminp="adc2-inp";
# ----------------------------------------------------------------------------

$WDIR="DISPLACEMENT";
$disp="displfl";

print " Coordinate number [default = 1]:";
$_=<STDIN>;
chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
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
  chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
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
    print "DOING:   $c    $i\n";
    system("cp -f $tminp $WDIR/CALC.c$c.d$i/.");
    chdir("$WDIR/CALC.c$c.d$i");
    if (!-s "coord"){
      if (-s "geom"){
        #  die "geom does not exist or is empty!";
        system("\$NX/nx2tm");
      }
    }
    system("define < adc2-inp");
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
