#!/usr/bin/perl -w

# Input section ----------------------------------------
$fout="grad.out";
$tmpout="tmp.out";
$tmpcom="tmp.com";
$dir_1="DFT-TM";
$dir_2="TDDFT-TM";
# ------------------------------------------------------

print "Starting program\n";
open(TC,$tmpcom) or die ":( tmpcom";
$_=<TC>;
chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
$nat=$_;
close(TC);
print "Number of atoms $nat\n";

system("rm -f $dir_1/gradient $dir_2/gradient $dir_2/$fout $dir_1/coord $dir_2/coord $dir_2/*_a");

open(IN,">>geom.xyz") or die ":( geom.xyz";
open(TC,$tmpcom) or die ":( $tmpcom";
while(<TC>){
  print IN $_;
}
close(TC);
close(IN);
system("x2t $tmpcom > coord");
system("cp -f coord $dir_1/.");
system("cp -f coord $dir_2/.");

  chdir("$dir_1");
  print "Starting job $dir_1\n";
  system("dscf > dscf.out");
  system("grad > $fout");
  chdir("../$dir_2");
  print "Starting job $dir_2\n";
  system("cp -f ../$dir_1/mos .");
  system("dscf > dscf.out");
  system("egrad > $fout");  
  chdir("../");

print "Reading output\n";
rw_out();

sub rw_out{
# Read energies
  print "Reading energies\n";
  system("rm -f $tmpout");
  open(GDO,">$tmpout") or die "Cannot open $tmpout.";
  open(GO,"$dir_2/$fout") or die ":( $dir_2/$fout";
  print GDO "Energies\n";
  while(<GO>){
    if (/Total energy:/){
       chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
       @g=split(/\s+/,$_);
       $es=$g[2];
       printf GDO " %9.7F\n",$es;
    }
  }
  close(GO);
# Read gradients
  print "Reading gradient $dir_1\n";
  r_grad("$dir_1");
  print "Reading gradient $dir_2\n";
  r_grad("$dir_2");
  close(GDO);
}
#
sub r_grad{
  ($dir)=@_;
  open(GD,"$dir/gradient") or die "Cannot open gradient";
  for ($ind=1;$ind<=$nat+2;$ind++) {
    $_=<GD>;
  }
  print GDO "Gradient $dir\n";
  for ($ind1=1;$ind1<=$nat;$ind1++) {
    $_=<GD>;
    chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
    $_=~ s/d/E/ig;
    @g=split(/\s+/,$_);
    printf GDO "%15.9F %15.9F %15.9F\n",@g;
  }
  close(GD);
}
#
