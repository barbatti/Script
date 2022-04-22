#!/usr/bin/perl -w

$DISP="DISPLACEMENT";

# Read geometries in dyn.mld file and writes them in DISPLACEMENT/CALC.c1.d structure.
if (!-s "$DISP"){
  system("mkdir $DISP");
}else{
  die "Cannot create $DISP dir: it already exists!";
}

$file="dyn.mld";

if (!-s "$file"){
  die "$file is empty or does not exist!";
}
open(FL,$file) or die ":( $file!";
$_=<FL>;
chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
$nat=$_;
$nlines=1;
while(<FL>){
 $nlines++;
}
close(FL);
$ngeom=$nlines/($nat+2);

print "NAT      $nat\n";
print "NLINES   $nlines\n";
print "NGEOM    $ngeom\n";

if (-s "TEMP"){
  die "TEMP exists. Delete it and run again";
}
system("mkdir TEMP");
chdir("TEMP");

open(DL,">../$DISP/displfl") or die ":( $DISP/displfl!";
print DL "\n\n\n";
open (FL,"../$file") or die ":( $file";
$ic=0;
for ($n=1;$n<=$ngeom;$n++){

  open (GX,">geom.xyz") or die ":( geom.xyz";
  for ($ncp=1;$ncp<=$nat+2;$ncp++){
    $_=<FL>;
    print GX "$_";
  }
  close(GX);
  system("\$NX/xyz2nx < geom.xyz");
  system("x2t geom.xyz > coord");

  $DC="../$DISP/CALC.c1.d$ic";
  system("mkdir $DC");
  system("mv geom coord $DC/.");
  system("mv geom.xyz $DC/.");

  print DL " 1  $ic\n";
  print "Geometry $ic was copied to $DC\n";
  $ic++;
}

close(DL);

close(FL);
chdir("../");
system("rm -rf TEMP");

