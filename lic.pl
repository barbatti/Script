#!/usr/bin/perl

use strict;
#use warnings;
my ($igeo,$choice,$igt,$q,$Nat,$vaste_,$cbus,$nx,$bab,$nint,$diff,$dispdir,$Np,$ndir,$coldir,$k,$j,$lic,$calculated,@lA,@lB);
my (@ni,@nf,$i,$l,@line,@lnr,@ni,@nt,$a,@nline);
my(@r1x,@x,@r1y,@y,@r1z,@z,@r2x,@x,@r2y,@y,@r2z,@z,$file,@atom,$n,@mass,$intdir,@s,@rx,@ry,@rz);
system("clear");
print "\n     ---- LIC program (Linear Interpolation of Coordinates) ---- \n";
print " Program generates the defined number of intermediate geometries \n";
print " required by the the Columbus input. It has possibility to transform\n";
print " coordinates through the internal coordinates or through the Z-matrix.\n";
print " Please provide initial and final geometry (geom.ini and geom.last)\n";
print " for the interpolation in the Columbus format.\n\n";
print "                 LIC structures generation, J.J. Szymczak, M. Barbatti \n";
print "                   QCCD Group, ITC, University of Vienna, Vienna \n\n";

sub croak { die "$0: @_: $!\n"}

################################
#### ENVIRONMENTAL SETTINGS ####
################################

$cbus = $ENV{"COLUMBUS"};  # Columbus environment
$nx = $ENV{"NX"};  # Columbus environment
$bab = $ENV{"BABEL_DIR"}; # Babel environment 
# IF YOU DON'T HAVE A BABEL POINT ENVIRONMENTAL VALUE BABEL_DIR
#  TO /home/aldon/appl/babel-1.6/ (adler) - do not use openbabel !!!
#$bab = "/home/aldon/appl/babel-1.6/";                            
$lic= "$cbus";  # 

################################
#END OF ENVIRONMENTAL SETTINGS #
################################


print " Do you want do print locations of required packages? (y/n) ";
  $_=<STDIN>;
if (/^y/i){
 print "\n COLUMBUS LOCATION: $cbus";
 print "\n NX       LOCATION: $nx";
 print "\n BABEL    LOCATION: $bab ";
}
$Nat=0;
$igt=0;

if ($lic eq "") {
system("clear");
print"\n\n PLEASE SETUP YOUR ENVIRONMENT VARIABLES AND RUN THE PROGRAM AGAIN !!!\n";
exit;
}
#######################
#START OF THE PROGRAM #
#######################
print " \n\n   Please choose the method of transformation: \n";
print " \n           1. LIZ - TRANSFORMATION THROUGH Z-MATRIX \n";
print "                Requires: Babel \n";
print " \n           2. LIIC - TRANSFORMATION THROUGH PULAY INTERNAL COORDINATES\n";
print " \n           3. LIIC - with customized displacements\n";
print "                Provide:  geom.start (inial geometry)\n";
print "                          geom.ini and geom.last (definition of displacement) \n\n";
print " \n   Special options and tools:\n";
print " \n           4. TRANSFORMATION THROUGH FIXED Z-MATRIX      \n";
print "                Requires saved Z-matrixes from 1st choice  \n";
print " \n           5. Potential curve generation                \n";
print "                Requires GNUPLOT                           \n";
print " \n           6. Visualization of the LIC path (by MOLDEN) \n";
print "                Requires MOLDEN                 \n";
print " \n           7. Change of atom order from modified Z-MATRIX \n";
print " \n           8. Generation of additional step to LIC path \n";
print " \n           9. EXIT \n\n";
print "\nSelect one option (1-8): ";
$_=<STDIN>;
chomp();
$choice=$_;

if ($choice == 9 ) {
exit "\n\n            LIC ABORTED BY USER \n\n ";
}
if ($choice == 8 ) {
system("clear");
  print "\nStarting interpolation  script...\n\n" ;
  print "\nEnter desired number of step (it will be calculated from two previous points):  " ;
  $_=<STDIN>;
chomp;
$Np=$_;
$l=$Np-1;
print "\n Reading point $l ";
  read_geom("DISPLACEMENT/CALC.c1.d$l/geom");
  @r1x=@x;
  @r1y=@y;
  @r1z=@z;
print " ...done\n";
$l=$Np-2;
print "\n Reading point $l ";
  read_geom("DISPLACEMENT/CALC.c1.d$l/geom");
  @r2x=@x;
  @r2y=@y;
  @r2z=@z;
print " ...done\n";
print "\n extrapolating now  ";
  extrapolate();
print " ...done\n";
  write_geom();
print "\n\n Point number $Np has been created - see DISPLACEMENT directory for CALC.c1.d$Np\n\n";

exit "\n\n        Program ends here... \n\n ";
}
if($choice == 7 ) {
system("clear");
  print "\nStarting reordering script...\n\n" ;
  getnat();
print "\n";
  userinput();
  reordord();
$dispdir="DISPLACEMENT";
if (-e $dispdir) {
#  system("cd $dispdir");
chdir($dispdir);
                 }
else { exit "\n DISPLACEMENT directory is missing, exiting now...\n";
     }
print"\n Proceeding with reordering\n";
for ($ndir=0;$ndir<=$Np;$ndir++) {
#system("cd CALC.c1.d$ndir");
chdir("CALC.c1.d$ndir");
#system("pwd");
reord();
print " directory CALC.c1.d$ndir ..... done\n";
system("cd ..");
}
  system("cd ..");
  exit "\n\n   ... done, files have been reordered \n\n ";
}
if($choice == 5 ) {
  print "\nInvoking the licplot script...\n\n" ;
  system("$lic/licplot");
  exit "\n\n   ... done, curve has been generated \n\n ";
}
if($choice == 6 ) {
  print "\nInvoking the licstruct tool...\n\n" ;
  system("$lic/licstruct.pl");
  exit "\n\n   Structures have been saved to dyn.mld file \n\n ";
}
check_files();
if ($choice == 1 || $choice == 4 ) {
if ($bab eq "") {
system("clear");
print"\n\n PLEASE SETUP YOUR BABEL ENVIRONMENT FIRST AND RUN THE PROGRAM AGAIN !!!\n";
print "\n ex.: export BABEL_DIR=/home/aldon/appl/babel-1.6/ (bash) \n      setenv BABEL_DIR /home/aldon/appl/babel-1.6 (tcsh)\n\n";
exit;
}
}
if ($choice == 2 ) {
if ($cbus eq "") {
system("clear");
print"\n\n PLEASE SETUP YOUR COLUMBUS ENVIRONMENT FIRST AND RUN THE PROGRAM AGAIN !!!\n";
print "\n ex.: export COLUMBUS=/quant/COLUMBUS/Columbus-opt64/Columbus (bash) \n      setenv COLUMBUS /quant/COLUMBUS/Columbus-opt64/Columbus (tcsh) \n\n";
exit;
}
check_intcfl();
}
if ($choice == 3 ) {
  if (!-e "geom.start") {
    croak "Please provide also geom.start";
  }
}
getnat();
userinput();

# Create output directory
$dispdir= "DISPLACEMENT";
if (-e $dispdir) {
  print " Do you want do delete $dispdir directory? (y/n)";
  $_=<STDIN>;
  if (/^y/i){
    create_disp();
  } else {
    die "Delete $dispdir and run liz again. \n\n";
  }
} else {
  create_disp();
}
if($choice == 4 ) {
 print "\nThe initial point in Z-matrix format taken from file: Z-mat.ini\n\n" ;
 system("cat Z-mat.ini");
 system("cp Z-mat.ini zmat.ini");
 print "\nThe final point in Z-matrix format taken from file: Z-mat.last\n\n" ;
 system("cat Z-mat.last");
 system("cp Z-mat.last zmat.last");
 print "\nAll the points during the transformation will be saved\n\n" ;
 $q=1;
#starting interpolation 
print "\n Starting the interpolation procedure...\n\n";
for ($k=0; $k<=$Np; $k++) {
 $j=0;
 open(A,"zmat.ini");
 open(B,"zmat.last");
 open(OUT,">zmat.$k");

 while(<A>) {
 if(/Variables/) {
   print OUT $_ ;
   $j=1;
   $vaste_=<B>;
   next;
 }
  if($j == 0) {
   print OUT $_ ;
   $vaste_=<B>;
    if($_ ne $vaste_) {
    print("\nPOTENTIAL PROBLEM WITH Z-MATRIX DETECTED A G A I N !!!\n");
    print("Definition of problem coordinate is:\n $_ in Z-mat.ini\n $vaste_ in Z-mat.last\n\n");
    print("DO YOU WANT TO PROCEED (NOTE: You will end up with wrong intermediate geometries ) ? (y/n)");
     $_=<STDIN>;
     if (/^y/i){
     print("\nPROCEEDING...\n");
     } else {
      print("Please change the initial or final matrix and proceed with main option 4\n");
      system("rm -f geom.zmt* geom.xyz* xyz2col.log zmat* geom ");
      exit;
      }
   }
  }
  else {
   chomp;
   s/^\s+//;
   s/\s+//;
   @lA=split/=/;
   $_=<B>;
   chomp;
   s/^\s+//;
   s/\s+//;
   @lB=split/=/;
   $diff=$lB[1]-$lA[1];
   if( abs($diff) > 180. ) {
    if( $diff > 0. ) {
      $calculated = $lA[1] + $k/$Np*($lB[1]-$lA[1]-360);
    } else {
      $calculated = $lA[1] + $k/$Np*($lB[1]-$lA[1]+360);
    }
   } else {
   $calculated = $lA[1] + $k/$Np*($lB[1]-$lA[1]);
   }
   print OUT "$lA[0]= $calculated\n";
   }
 }
print OUT "\n";
system("cp -f zmat.$k geom.zmt.$k");
system("mv -f zmat.$k geom.zmt");
getgeom();
$coldir = "CALC.c1.d$k";
system("mkdir $dispdir/$coldir");
system("cp -f geom.xyz geom.xyz.$k");
system("cp -f geom $dispdir/$coldir/geom");
if ($q==1) {
print  "The $k point in Z-matrix format has been saved to file: Z-mat.$k \n\n" ;
system("cp -f  geom.zmt.$k $dispdir/$coldir/Z-mat.$k");
}
print DP "1   $k\n";
}
system("rm -f geom.zmt* geom.xyz* xyz2col.log zmat* geom ");


} elsif ($choice == 1 ) {
  print " Do you want do keep  initial, intermediate, and final geometries in Z-matrix ? (y/n)";
  $_=<STDIN>;
  if (/^y/i){
   $q=1;
   } else {
   $q=0;
  } 

# Transform initial and last geom into zmatrix  coord.
system("cp -f geom.ini geom");
print  "\nThe initial point in Columbus format:\n\n" ;
system("cat geom");
getzmt();
if ($q==1) {
print  "\nThe initial point in Z-matrix format has been saved to file: Z-mat.ini\n\n" ;
system("cp geom.zmt Z-mat.ini");
}
system("mv -f geom.zmt zmat.ini");
system("cp -f geom.last geom");
print  "\nThe final point in Columbus format:\n\n" ;
system("cat geom");
getzmt();
if ($q==1) {
print  "\nThe final point in Z-matrix format has been saved to file: Z-mat.last \n\n" ;
system("cp geom.zmt Z-mat.last");
}
system("mv -f geom.zmt zmat.last");
# Call interpolation
print "\n Starting the interpolation procedure...\n\n";
for ($k=0; $k<=$Np; $k++) {
 $j=0;
 open(A,"zmat.ini");
 open(B,"zmat.last");
 open(OUT,">zmat.$k");
 
 while(<A>) {
 if(/Variables/) {
   print OUT $_ ;
   $j=1;
   $vaste_=<B>;
   next;
 }
  if($j == 0) {
   print OUT $_ ;
   $vaste_=<B>;
    if($_ ne $vaste_) {
    print("\nPOTENTIAL PROBLEM WITH Z-MATRIX DETECTED.\n");
    print("Definition of problem coordinate is:\n $_ in Z-mat.ini\n $vaste_ in Z-mat.last\n\n");
    print("DO YOU WANT TO PROCEED (NOTE: You will end up with wrong set of intermediate geometries ) ? (y/n)");
     $_=<STDIN>;
     if (/^y/i){
     print("\nPROCEEDING...\n");
     } else {
      print("Please change the initial or final matrix and proceed with main option 4\n");
      print("\nHINT: \nto make Z-mat readable by molden remove all lines before matrix definition \nand replace line \"Variable:\" with blank line\n");
      system("rm -f geom.zmt* geom.xyz* xyz2col.log zmat* geom ");
      exit;
      }
   }
  }
  else {
   chomp;
   s/^\s+//;
   s/\s+//;
   @lA=split/=/;
   $_=<B>;
   chomp;
   s/^\s+//;
   s/\s+//;
   @lB=split/=/;
   $diff=$lB[1]-$lA[1];
   if( abs($diff) > 180. ) {
    if( $diff > 0. ) {
      $calculated = $lA[1] + $k/$Np*($lB[1]-$lA[1]-360);
    } else {
      $calculated = $lA[1] + $k/$Np*($lB[1]-$lA[1]+360);
    }
   } else {
   $calculated = $lA[1] + $k/$Np*($lB[1]-$lA[1]);
   }
   print OUT "$lA[0]= $calculated\n";
   }
 }
print OUT "\n";
system("cp -f zmat.$k geom.zmt.$k");
system("mv -f zmat.$k geom.zmt");
getgeom();
$coldir = "CALC.c1.d$k";
system("mkdir $dispdir/$coldir");
system("cp -f geom.xyz geom.xyz.$k");
system("cp -f geom $dispdir/$coldir/geom");
if ($q==1) {
print  "The $k point in Z-matrix format has been saved to file: Z-mat.$k \n\n" ;
system("cp -f  geom.zmt.$k $dispdir/$coldir/Z-mat.$k");
}
print DP "1   $k\n";
}
system("rm -f geom.zmt* geom.xyz* xyz2col.log zmat* geom ");
} elsif ($choice == 2 ) {

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
system("cp -f geom.ini geom");

# Call interpolation
for ($k=0; $k<=$Np; $k++){
  open(IN,">liic.inp") || croak "Cannot open liic.inp";
  print IN "$Nat $Np $k";
  system("$lic/liic.x > liic.out");
  system("mv -f aux intgeom.$k");
  system("mv -f aux2 intgeomch.$k");
  system("cp -f intgeom.$k intgeomch");

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
} elsif ($choice == 3 ) {

print "\nYOUR FILES:\n geom.start - is used as inial geometry\n geom.ini and geom.last - are used to define internal displacement\n\n";
#system("sleep 1");
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
system("cp -f geom.start geom");
getint();
system("mv -f intgeom intgeom.start");
#system("cp -f geom.ini geom");
system("cp -f geom.start geom");

# Call interpolation
for ($k=0; $k<=$Np; $k++){
  open(IN,">liic.inp") || croak "Cannot open liic.inp";
  print IN "$Nat $Np $k";
  system("$lic/liicm.x > liic.out");
  system("mv -f aux intgeom.$k");
  system("mv -f aux2 intgeomch.$k");
  system("cp -f intgeom.$k intgeomch");

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
} else {
print " Please choose from available possibilities, Program is exiting NOW";
croak();
}

close (DP);

print "\n All files have been transformed successfully. \n\n";
print " ---- LIZ done ---- \n";
print " Run disp.pl and choose 'copy input files for potential curve calculation'\n";
print " to copy the Columbus input. To perform the calculation, run disp.pl again\n";
print " and choose 'perform potential curve calculations'.\n";


##################################################################
########## ..... S U B P R O G R A M S ........ ##################
##################################################################


sub getnat {
# get the number of atoms
open IN, "geom.ini" or croak " Cannot open geom.ini";
while (<IN>) {
 last if (/^\s+$/);
 $Nat++;
}
close IN;
print " $Nat atoms found in geom.ini";
if ($Nat > 2){
  $nint = 3*$Nat-6;
} else {
  $nint = 3*$Nat-5;  # This will not work for polyatomic linear molecules,
}
}

sub userinput {
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

}
sub getzmt {
 system("$nx/nx2xyz");
 system("$bab/obabel -ixyz geom.xyz -ogzmat -O geom.zmt");
}

sub getgeom {
 system("$bab/obabel -igzmat geom.zmt -oxyz -O geom.xyz");
# system("echo 'do xyz' $k");
 system("$nx/xyz2nx < geom.xyz");
 system("echo 'point $k transformed successfully'");
}

sub getint {
 print " $igt: ";
 system("$cbus/cart2int.x < cart2intin");
 $igt = $igt+1;
}

sub check_files {
  if (!-e "geom.ini") {
    croak "Please prepare geom.ini file.";
  }
  if (!-e "geom.last") {
    croak "Please prepare geom.last file.";
  }
}

sub check_intcfl {
  if (!-e "intcfl") {
    croak "Please prepare intcfl file.";
  }
}

sub create_disp {
  system("rm -rf $dispdir");
  system("mkdir $dispdir");
  open(DP,">$dispdir/displfl") or die "Cannot open displfl to write";
  print DP "$nint   /number of internal coordinates\n";
  print DP "no  /calculate dip.mom.derivatives\n";
  print DP "no  /calculate reference point\n";
}

sub reordord {
#my (@ni,@nf,$i,$l,@line,@lnr,@ni,@nt,$a,@nline);
if (-e "order.inp") {
print "\nFile with equivalent pairs has been found, proceeding now....\n";
print "\nChanges in lines are :\n";
open(O,"order.inp");
$a=0;$j=0;
while(<O>) {
#$_=<O>;
chomp;
$j++;
@lnr=split/=/;
$ni[$j]=$lnr[0];
$nf[$j]=$lnr[1];
print "\tline $ni[$j] will be line $nf[$j] \n";
$a++;
}
}
else {
print "\nFile with equivalent pairs has not been found, reading from standard input...\n";
# User input
$a=0;
  for($l=1;$l<=$Nat;$l++){
   print "\n Enter the $l out of $Nat pairs of equivalent atoms in Z-matrix (Z) and geom (g) in format: Z=g ";
   print "\n Pair $l out of $Nat: ";
   $_=<STDIN>;
   print
   chomp;
   @lnr=split/=/;
   $ni[$l]=$lnr[0];
   $nf[$l]=$lnr[1];
   $a++;
   }
   print "\n input reading: done....\n";
}
   if ($Nat!=$a) {
   exit "\n Reordering failed - list of pair is incomplete\n";}
}
         
sub reord {
#my (@ni,@nf,$i,$l,@line,@lnr,@ni,@nt,$a,@nline);
   open(A,"geom");
   open(B,">geom.R");
   $i=1;
   while(<A>) {
   $line[$i]=$_;
   $i++;
   }

   for($k=1;$k<=$i-1;$k++) {
   $nline[$nf[$k]]=$line[$ni[$k]];}

   for($k=1;$k<=$i-1;$k++) {
   print B $nline[$k];}

   close(B);
   system("cp -rf geom geom.i");
   system("cp -rf geom.R geom");
}

sub read_geom{
  ($file)=@_;
   open(FL,$file) or die "Cannot find $file!";
   $n=0;
   while(<FL>){
      chomp;
      $_ =~ s/^\s*//;         # remove leading blanks
      $_ =~ s/\s*$//;         # remove trailing blanks
      $n++;
      ($s[$n],$atom[$n],$x[$n],$y[$n],$z[$n],$mass[$n])=split(/\s+/,$_);
   }
   $Nat=$n;
   close(FL);
}

sub extrapolate{
  for ($i=1;$i<=$Nat;$i++){
    $rx[$i]=2.0*$r1x[$i]-$r2x[$i];
    $ry[$i]=2.0*$r1y[$i]-$r2y[$i];
    $rz[$i]=2.0*$r1z[$i]-$r2z[$i];
  }
}

#sub extrapolate{
#  for ($i=1;$i<=$Nat;$i++){
#    $rx[$i]=2.0*$r2x[$i]-$r1x[$i];
#    $ry[$i]=2.0*$r2y[$i]-$r1y[$i];
#    $rz[$i]=2.0*$r2z[$i]-$r1z[$i];
#  }
#}

sub write_geom{
$dispdir="DISPLACEMENT";
if (-e $dispdir) {
chdir($dispdir);
                 }
else { exit "\n DISPLACEMENT directory is missing, exiting now...\n";
     }
$intdir="CALC.c1.d$Np";
if ( ! -e $intdir ) {system("mkdir $intdir");
print "\n Directory $intdir has been created..\n";}
else  { print "\n Directory $intdir exists, overwriting geom file ...\n";}
if (-e $intdir) {
chdir($intdir);
}
else { exit "\n Directory $intdir has not been created in DISPLACEMENT folder, exiting now...\n";}
  open(OUT,">geom") or die ":( interpolated geom cannot be created";
  for ($i=1;$i<=$Nat;$i++){
    printf OUT " %2s  %5.1f%14.8f%14.8f%14.8f%14.8f\n",$s[$i],$atom[$i],$rx[$i],$ry[$i],$rz[$i],$mass[$i];
  }
  close(OUT);
chdir("../..");
}

