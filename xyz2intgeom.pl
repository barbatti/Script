#!/usr/bin/perl -w
# Given a intcfl, this program takes a dyn.xyz and compute internal coordinates.
$nx = $ENV{"NX"};
$cbus  = $ENV{"COLUMBUS"};

$fn="dyn.xyz";
$ig="intgeom.list";

if (!-s "intcfl"){
  die " Cannot find intcfl. Program will stop.\n";
}

number_of_atoms();
number_of_lines();


 open(FN,"$fn") or warn "Cannot find $fn\n";
 open(IG,">$ig") or die "Cannot open $ig\n";

 print "Reading $fn\n";

 for ($ns=1;$ns<=$nst;$ns++){
   $_=<FN>;
   $_=<FN>;
   open(GE,">aux.xyz") or die "Cannot open aux.xyz!";
   print GE "$nat\n\n";
   $label=" Structure $ns\n";
   for ($na=1;$na<=$nat;$na++){
      $_=<FN>;
      print GE $_;
   } 
   close(GE);
   transform();
 }

 close(IG);
 close(FN);

# ================================================================ 
sub number_of_atoms{
  open(FN,"$fn") or die "Cannot find $fn\n";
  $_=<FN>;
  chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
  $nat=$_;
  close(FN);
  print " Number of atoms: $nat\n";
} 
# ================================================================
sub number_of_lines{
  $kl=0;
  open(FN,"$fn") or die "Cannot find $fn\n";
  while(<FN>){
    $kl++;
  }
  close(FN);
  $nst=int($kl/($nat+2));
  print " Number of structures: $nst\n";
}
# ================================================================
sub transform{
  system("$nx/xyz2nx < aux.xyz"); # Format file

  # CART -> INT ..... Create cart2intin
  open(CTI,">cart2intin") or die "Cannot open car2intin to write.";
  print CTI " &input
 calctype='cart2int',
 /&end \n";
  close(CTI);

  # Create cartgrd
  open(GD,">cartgrd") or die  "Cannot open cartgrd to write.";
  for ($igeo = 1; $igeo <= $nat; $igeo++) {
    print GD "0 0 0 \n"  # False cartgrd file. Just to run cart2int.
  }
  close(GD);

  # Transform initial and last geom into internal coord.
  system("$cbus/cart2int.x < cart2intin");
 
  # Write
  open(IN,"intgeom") or warn "Cannot open intgeom at $label\n";
  print IG " $label";
  print "$label";
  $nint=1;
  while(<IN>){
    chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
    printf IG "%4s  %12.6f\n","I".$nint,$_;
    $nint++;
  }
  close(IN);
}
# ================================================================

