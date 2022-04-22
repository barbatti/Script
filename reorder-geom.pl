#!/usr/bin/perl -w
$mld  = $ENV{"NX"};        # NX environment

# Reorder the atoms in the dyn.mld file
# The input file is in dyn.mld format.
# The new order is given in the vector @no (below).
# New labels can also be given in the vector @sn (below).
# The output is dyn-final.mld and a DISPLACEMENT directory.
#
#........................................................................
@no=(7,6,4,3,2,1,8,10,9,5,11,14,15,12,13);
@sn=("N","N","C","C","C","C","B","B","B","O","H","H","H","H","H");
#........................................................................
#
$au2ang=0.529177;

# Number of atoms
open(DM,"dyn.mld") or die ":( dyn.mld";
$_=<DM>;
chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
$nat=$_;
close(DM);

# Create dir
if (!-s "DISPLACEMENT"){
  system("mkdir DISPLACEMENT");
  open(DL,">DISPLACEMENT/dispfl") or die ":( DISPLACEMENT/dispfl";
  $nic=3*$nat-6;
  print DL "$nic   /number of internal coordinates\n";
  print DL "no  /calculate dip.mom.derivatives\n";
  print DL "no  /calculate reference point\n";
}else{
  die "DISPLACEMENT directory already exists!";
}

# Read and write
$ng=0;
open(DM,"dyn.mld") or die ":( dyn.mld";
open(DF,">dyn-final.mld") or die ":( dyn-final.mld";
while(<DM>){
  $_=<DM>;
  chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
  $title=$_;
  for ($in=0;$in<=$nat-1;$in++){
    $_=<DM>;
    chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
    ($s[$in],$x[$in],$y[$in],$z[$in])=split(/\s+/,$_);
  }
  # write geom
  print DL "1   $ng\n";
  $DIR="DISPLACEMENT/CALC.c1.d$ng";
  system("mkdir $DIR");
  open(GZ,">$DIR/geom.xyz") or die ":( $DIR/geom.xyz";
  print DF " $nat\n";
  print GZ " $nat\n";
  print DF " $title\n";
  print GZ " $title\n";
  for ($in=0;$in<=$nat-1;$in++){
    printf DF " %s %10.7F %10.7F %10.7F\n",$sn[$in],$x[$no[$in]-1],$y[$no[$in]-1],$z[$no[$in]-1];
    printf GZ " %s %10.7F %10.7F %10.7F\n",$sn[$in],$x[$no[$in]-1],$y[$no[$in]-1],$z[$no[$in]-1];
  }
  close(GZ);
  system("cd $DIR;$mld/xyz2nx <geom.xyz");
  $ng++; 
}
close(DL);
close(DF);
close(DM);
