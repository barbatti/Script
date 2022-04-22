#!/usr/bin/perl -w
#
# After generating DISPLACEMENT directory using disp.pl routine in COLUMBUS,
# this routine can be used to copy files.
# Mario Barbatti, Oct 2011
#

# Files to be copied ---------------------------------------------------------
 $ptm0="gaussian.com";  # Gaussian input file
# $ptm="m02.com";  # Gaussian input file
$list="$ptm0";         # List of files to be copied (input + checkpoint)
if (-s "gaussian-add"){
  $list=$list." gaussian-add";
}
# ----------------------------------------------------------------------------

$WDIR="DISPLACEMENT";
$disp="displfl";

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
    system("mv $ptm0 g$i-$ptm0");
    $ptm="g$i-$ptm0";
    if (!-s "geom.xyz"){
      if (-s "geom"){
         system("\$NX/nx2xyz");   
      }else{
         die "geom or geom.xyz do not exist or are empty!";
      }
    }
    change_gaussian();
    chdir("../../");
  }
}
#...............................................
sub change_gaussian{
   $found=0;
   system("mv -f $ptm $ptm-temp");
   open(PMT,"$ptm-temp") or die ":( $ptm-temp";
   open(PM,">$ptm") or die ":( $ptm";
   while(<PMT>){
      $line=$_;
      if (/\#/ or /\%/){
         print PM $line;
      }else{
         $found=1;
         print PM $line;
         $_=<PMT>;print PM $_;
         $_=<PMT>;print PM $_;
         $_=<PMT>;print PM $_;
         open(GE,"geom.xyz") or die ":( geom.xyz";
         $_=<GE>;$_=<GE>;
         while(<GE>){
           print PM $_;
         }
         close(GE);
      }
      if ($found == 1){
         while(<PMT>){
           print PM $_; 
         }
      }
   }
   if (-s "gaussian-add"){
     open(GA,"gaussian-add") or die ":( gaussian-add";
     while(<GA>){
       print PM "$_";
     }
     close(GA);
   }
   close(PM);
   close(PMT);
   system("rm -f $ptm-temp");
}
