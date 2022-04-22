#!/usr/bin/perl -w
#
# This program makes a regular geometry grid
# along two specific internal coordinates. It uses Gaussian
# OPT=ModRedundant to do the displacements.
# 
# Each point is written as xyz to DISPLACEMENT/CALC.ci.dj
#
# Few parameters should be provided below:
# imin,imax (jmin,jmax): minimum and maximum values of the grid
#                        along i (j).
# file: name of the xyz geometry file
# xmin,xmax (ymin,ymax): minimum and maximum values of the
#                        internal coordinates along x (y).
# strg1 (strg2): definition of the redundant internal coordinate
#                1 (2) in Gaussian format.
# mode = 1 use first geometry
#      = 2 use previous geometry
#
# Mario Barbatti, August 2013.  
#
# ================== INPUT PARAMETERS ============================

# How many directories?
$imin=1;
$imax=5;
$jmin=1;
$jmax=5;

# XYZ input (Angstrom)
$file="geom.xyz";
if (!-s $file){
  die "XYZ input $file is empty or does not exist.";
}

# SELECT MODE:
$mode = 2;

# Minimum and maximum values
$xmin=-0.06; 
$xmax=1.94;
$ymin=-0.06;
$ymax=1.94;

# String 1 for Mod Redundant:
$stg1="5  20 +=";
$stg2="6  21 +=";

# Gaussian route:
$gaussian_route="#p OPT(MaxCyc=300,ModRedund,MaxStep=2) SCF(MaxCyc=300) PM6\n\ntest\n\n-1  2\n";

# ============= END OF INPUT PARAMETERS ==========================

$dispdir= "DISPLACEMENT";
$disp="displfl";
$dispo="displfl.out";

open(IN,$file) or die ":( $file";
$_=<IN>;
chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
$nat=$_;
close(IN);

open(ALL,">all.xyz") or die ":( all,xyz";

# Make DISPLACEMENT
if (-e $dispdir) {
  print " Do you want to delete $dispdir directory? (y/n)";
  $_=<STDIN>;
  if (/^y/i){
    create_disp();
  } else {
    die "Delete $dispdir and run  this program again. \n\n";
  }
} else {
  create_disp();
}

open(DP,">$dispdir/$disp") or die ":( $dispdir/$disp";
open(OUT,">$dispdir/$dispo") or die ":( $dispdir/$dispo";

# Make CALC
for ($i=$imin;$i<=$imax;$i++){
  for ($j=$jmin;$j<=$jmax;$j++){
    print DP " $i  $j\n";
    print " $i  $j\n";
    $coldir = "CALC.c$i.d$j";
    system("mkdir $dispdir/$coldir");
    make_change();
  }
}

close(DP);
close(OUT);

close(ALL);

# =============================================================================
sub create_disp {
  system("rm -rf $dispdir/*");
  system("rm -rf $dispdir");
  system("mkdir $dispdir");
}
# =============================================================================
sub make_change{
  chdir("$dispdir/$coldir");
  print ALL "$nat\n";
  $dx=($xmax-$xmin)/($imax-$imin);
  $dy=($ymax-$ymin)/($jmax-$jmin);
  if ($mode==1){ 
    $x=sprintf("%8.3f",$xmin+$dx*($i-$imin)); 
    $y=sprintf("%8.3f",$ymin+$dy*($j-$jmin)); 
    open(IN,"../../$file") or die ":( ../../$file";
  }elsif($mode==2){
    if (($i==$imin) and ($j==$jmin)){
      $i1=0;
      $j1=0;
      open(IN,"../../$file") or die ":( ../../$file";
    }elsif(($i>$imin) and ($j==$jmin)){
      $i1=$i-1;
      $j1=$jmin;
      open(IN,"../CALC.c$i1.d$j1/$file") or die ":( ../CALC.c$i1.d$j1/$file";
    }else{
      $i1=$i;
      $j1=$j-1;
      open(IN,"../CALC.c$i1.d$j1/$file") or die ":( ../CALC.c$i1.d$j1/$file";
    }
    print "Using geometry $i1 $j1.\n";
    if (($i==$imin) and ($j==$jmin)){
      $x=sprintf("%8.3f",$xmin);
      $y=sprintf("%8.3f",$ymin);
    }else{
      $x=sprintf("%8.3f",($i-$i1)*$dx);
      $y=sprintf("%8.3f",($j-$j1)*$dx);
    }
  }
#
  printf OUT " %3d  %10.4f   %3d   %10.4f\n",$i,$x,$j,$y;
  printf ALL " %3d  %10.4f   %3d   %10.4f\n",$i,$x,$j,$y;
  # GS is a G09 input for a quick PM3 calculation
  open(GS,">g.com") or die ":( g.com";
  print GS $gaussian_route;
  $_=<IN>;
  $_=<IN>;
  for ($k=1;$k<=$nat;$k++){
    $_=<IN>;
    chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
    print GS " $_\n";
  }
  print GS "\n";
  print GS "$stg1 $x F\n";
  print GS "$stg2 $y F\n\n";
  close(GS);
  system("\$g09root/g09/bsd/g09.profile &> /dev/null ; \$g09root/g09/g09 g.com &> /dev/null ");
  system("get_g09geom.pl g.log -2 input");
  if (!-s "statp.xyz"){
    system("get_g09geom.pl g.log -2 input");
    print "Using the last cycle...\n";
  }
  system("mv statp.xyz geom.xyz");
  open(GE,"geom.xyz") or warn ":( geom.xyz";
  $_=<GE>;
  $_=<GE>;
  while(<GE>){
    print ALL "$_";
  }
  print ALL "\n";
  close(GE);
#   system("rm -f g.*");
  chdir("../../");
}

