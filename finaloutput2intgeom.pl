#!/usr/bin/perl -w
# This program takes a set of final_outputs and compute internal coordinates.
$nx = $ENV{"NX"};
$cbus  = $ENV{"COLUMBUS"};

$fn="final_output.1";
$ig="intgeom.1";

if (!-s "intcfl"){
  die " Cannot find intcfl. Program will stop.\n";
}

print "Initial $fn ni ";
$_=<STDIN>;
chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
$ni=$_;  
print "Initial $fn nf ";
$_=<STDIN>;
chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
$nf=$_;

number_of_atoms();

for ($n=$ni;$n<=$nf;$n++){

 open(FN,"$fn.$n") or warn "Cannot find $fn.$n\n";
 open(IG,">$ig.$n") or die "Cannot open $ig.$n\n";

 print "Reading $fn.$n\n";

 while(<FN>){
   if (/Initial condition =/){
     chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
     $label=$_;
     print "Found $label\n";
     $_=<FN>;
     open(GE,">geom") or die "Cannot open geom!";
     for ($i=1;$i<=$nat;$i++){
       $_=<FN>;
       print GE $_;
     }
     close(GE);
     transform();
   }
 }

 close(IG);
 close(FN);

}
# ================================================================ 
sub number_of_atoms{
  $nat=0;
  open(FN,"$fn.$ni") or die "Cannot find $fn.$ni\n";
  while(<FN>){
    if (/Geometry in COLUMBUS and NX/){
      while(<FN>){
        if (/Velocity in NX/){
          last;
        }
        $nat++;
      }
      last;
    }
  }
  close(FN);
  print " Number of atoms: $nat\n";
} 
# ================================================================
sub transform{
  system("$nx/nx2xyz;$nx/xyz2nx < geom.xyz"); # Format file

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
  open(IN,"intgeom") or warn "Cannot open intgeom at $n : $label\n";
  #print IG " $label\n";
  print "$n : $label\n";
  $nint=1;
  while(<IN>){
    chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
    printf IG "%4s  %12.6f\n","I".$nint,$_;
    $nint++;
  }
  close(IN);
}
# ================================================================

