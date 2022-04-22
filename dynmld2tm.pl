#!/usr/bin/perl -w
# Read dyn.nld and converts into a series of turbomole coord files.
$mld   = $ENV{"NX"}; 
$dm="dyn.mld";
$FD="TURBOMOLE_FILES";
$xyz="c.xyz";

if (!-s $dm){
  die "Cannot find $dm file!\n";
}

if (-s $FD){
  die "$FD exists. Delete it and run again.";
}else{
  system("mkdir $FD");
  system("cp -f $dm $FD/.");
  chdir($FD);
}

$i=1;
open(DM,$dm) or die "Cannot read $dm!";
while(<DM>){
   open(XYZ,">$xyz") or die "Cannot write $xyz!";
   chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
   $nat=$_;
   print XYZ " $nat\n";
   $_=<DM>;
   print XYZ "\n";
   for ($n=1;$n<=$nat;$n++){
      $_=<DM>;
      chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
      ($s,$x,$y,$z)=split(/\s+/,$_);
      # VERY SPECIAL RESTRICTION !!!!
      if ($s=~/o/i){
         $s="N";
      }
      #
      print XYZ " $s   $x   $y   $z\n";
   }
   close(XYZ);
   system("$mld/xyz2nx < c.xyz");
   system("$mld/nx2tm");
   system("mv coord coord.$i");
   $i++;
}
close(DM);
system("rm -f geom c.xyz");
