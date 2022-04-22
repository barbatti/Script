#!/usr/bin/perl

# you may have to set something like
# setenv COLUMBUS /scr/ronja/mario-expuma/COL591.jun-32/Columbus
# to make liic run.

sub croak { die "$0: @_: $!\n"}

$cbus  = $ENV{"COLUMBUS"};                    # Columbus environment
$AD = "/home3/barbatti/LIIC";
$igt=0;
$Nat=0;

check_files();

# get the number of atoms

open IN, "geom.ini" or croak " Cannot open geom.ini";
while (<IN>) {
 last if (/^\s+$/);
 $Nat++;
}
close IN;

system("clear");
print "        ---- LIIC ----    \n\n";
print " $Nat atoms found in geom.ini";
if ($Nat > 2){
  $nint = 3*$Nat-6;
} else {
  $nint = 3*$Nat-5;  # This will not work for polyatomic linear molecules,
                     # change dispfl by hand in this case.
}

# User input
print "\n Enter the number of points: ";
$_=<STDIN>;
chomp;
$Np = $_;

if (-e 'mocoef') {
  if (not -e 'mocoef.start') {
    system("cp mocoef mocoef.start");
    print " Copied mocoef to mocoef.start\n";
  }
}

# Create output directory
$dispdir= "DISPLACEMENT";
if (-e $dispdir) {
  print " Do you want do delete $dispdir directory? (y/n)";
  $_=<STDIN>;
  if (/^y/i){
    create_disp();
  } else {
    die "Delete $dispdir and run liic again. \n\n";
  }
} else {
  create_disp();
}

# CART -> INT ..... Create cart2intin
open(CTI,">cart2intin") || croak "Cannot open car2intin to write.";
print CTI " &input
 calctype='cart2int',
 /&end \n";
close(CTI);

# Create cartgrd
open(GD,">cartgrd")  || croak  "Cannot open cartgrd to write.";
   for ($igeo = 1; $igeo <= $Nat; $igeo++) {
     print GD "0 0 0 \n"  # False cartgrd file. Just to run cart2int.
   }
close(GD);

# Transform initial and last geom into internal coord.
system("cp -f geom.ini geom");
getint();
system("mv -f intgeom intgeom.ini");

system("cp -f geom.last geom");
getint();
system("mv -f intgeom intgeom.last");

# system("cp -f intgeom.ini intgeomch");
system("cp -f geom.ini geom");
# system("rm -f geom");

# Call interpolation
for ($k=0; $k<=$Np; $k++){

  open(IN,">liic.inp") || croak "Cannot open liic.inp";
  print IN "$Nat $Np $k";

  system("$AD/liic > liic.out");
  system("mv -f aux intgeom.$k");
  system("mv -f aux2 intgeomch.$k");
  #  system("cp -f geom.ini geom");
  system("cp -f intgeom.$k intgeomch");
  #  system("cp -f intgeom.$k intgeom");

  # INT -> CART ..... Create cart2intin
  if ($k == 0) {
    open (NIN,">cart2intin") or croak "Cannot open file: cart2intin";
    print NIN " &input\n calctype='int2cart',\n linallow=0,\n";
    print NIN " linonly=0,\n maxiter=200,\n geomch=0,\n maxstep=0.1\n";
    print NIN " /&end\n";
    close NIN;
  } else {
    open (NIN,">cart2intin") or croak "Cannot open file: cart2intin";
   print NIN " &input\n calctype='int2cart',\n linallow=0,\n";
    print NIN " linonly=0,\n maxiter=200,\n geomch=0, \n maxstep=0.1\n";
    print NIN " /&end\n";
    close NIN;
  }

  getint();

  $coldir = "CALC.c1.d$k";

  system("mkdir $dispdir/$coldir");
  system("cp -f geom.new geom");
  system("cp -f geom.new $dispdir/$coldir/geom");
  print DP "1   $k\n";
}

 system("rm -f intgeom* geom geom.new cart2int* liic.inp bummer bmatrix cartgrd");

## copy columbus directory
#for ($k=0; $k<=$Np; $k++) {
#  system("cp -rf JOB ./$k");
#  system("cp geom.$k $k/geom");
#}

close (DP);

print " ---- LIIC done ---- \n";
print " Run disp.pl and choose 'copy input files for potential curve calculation'\n";
print " to copy the Columbus input. To perform the calculation, run disp.pl again\n";
print " and choose 'perform potential curve calculations'.\n";

# .....

sub getint {
 print " $igt: ";
 system("$cbus/cart2int.x < cart2intin");
 $igt = $igt+1;
}

sub check_files {
  if (!-e "intcfl") {
    croak "Please prepare intcfl file.";
  }
  if (!-e "geom.ini") {
    croak "Please prepare geom.ini file.";
  }
  if (!-e "geom.last") {
    croak "Please prepare geom.last file.";
  }
#  if (!-e "JOB") {
#    croak "Please prepare JOB directory.";
#  }
}

sub create_disp {
  system("rm -rf $dispdir");
  system("mkdir $dispdir");
  open(DP,">$dispdir/displfl") or die "Cannot open displfl to write";
  print DP "$nint   /number of internal coordinates\n";
  print DP "no  /calculate dip.mom.derivatives\n";
  print DP "no  /calculate reference point\n";
}
