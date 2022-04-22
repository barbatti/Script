#!/usr/bin/perl

$cbus  = $ENV{"COLUMBUS"};                    # Columbus environment
$AD = "/home/barbatti/LIIC";
$igt=0;

check_files();

# User input
print " ---- LIIC ---- \n";
print " Enter the number of atoms:  ";
$_=<STDIN>;
chomp;
$Nat = $_;
print "\n Enter the number of points: ";
$_=<STDIN>;
chomp;
$Np = $_;

# CART -> INT ..... Create cart2intin
open(CTI,">cart2intin") || die "Cannot open car2intin to write.";
print CTI " &input
 calctype='cart2int',
 /&end \n";
close(CTI);

# Create cartgrd
open(GD,">cartgrd")  || die  "Cannot open cartgrd to write.";
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

  open(IN,">liic.inp") || die "Cannot open liic.inp";
  print IN "$Nat $Np $k";

  system("$AD/liic > liic.out");
  system("mv -f aux intgeom.$k");
  system("mv -f aux2 intgeomch.$k");
  #  system("cp -f geom.ini geom");

  #  system("cp -f intgeom.$k intgeom");

  # INT -> CART ..... Create cart2intin
  if ($k == 0) {
    system("cp -f intgeom.$k intgeomch");
    open (NIN,">cart2intin") or die "Cannot open file: cart2intin";
    print NIN " &input\n calctype='int2cart',\n linallow=0,\n";
    print NIN " linonly=0,\n maxiter=200,\n geomch=0,\n maxstep=0.1\n";
    print NIN " /&end\n";
    close NIN;
  } else {
    system("cp -f intgeomch.$k intgeomch");
    open (NIN,">cart2intin") or die "Cannot open file: cart2intin";
    print NIN " &input\n calctype='int2cart',\n linallow=0,\n";
    print NIN " linonly=0,\n maxiter=200,\n geomch=1, \n maxstep=0.1\n";
    print NIN " /&end\n";
    close NIN;
  }

  getint();

  system("cp -f geom.new geom.$k");
  system("cp -f geom.new geom");

}

system("rm -f intgeom*");
print " ---- LIIC done ---- \n";

# .....

sub getint {
 print " $igt: ";
 system("$cbus/cart2int.x < cart2intin");
 $igt = $igt+1;
}

sub check_files {
  if (!-e "intcfl") {
    die "Please, prepare intcfl file. \n";
  }
  if (!-e "geom.ini") {
    die "Please, prepare geom.ini file. \n";
  }
  if (!-e "geom.last") {
    die "Please, prepare geom.last file. \n";
  }
}
