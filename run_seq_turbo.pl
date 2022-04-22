#!/usr/bin/perl -w

# Input section ----------------------------------------
$fout="grad.out";
$tmpout="tmp.out";
$tmpcom="tmp.com";
# ------------------------------------------------------

print "Starting program\n";
open(TC,$tmpcom) or die ":( tmpcom";
$_=<TC>;
chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
$nat=$_;
close(TC);
print "Number of atoms $nat\n";

open(MI,"method.inp") or die ":( method.inp";
$_=<MI>;
chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
$method=$_;
close(MI);

if ($method eq "ADC"){
 $dir1="MP2";
 $dir2="ADC";
 $gslabel="MP2";
}elsif($method eq "CC2"){
 $dir1="CC2-G";
 $dir2="CC2-E";
 $gslabel="CC2";
}

system("rm -f $dir1/gradient $dir2/gradient $dir2/$fout $dir1/coord $dir2/coord");

open(IN,">>geom.xyz") or die ":( geom.xyz";
open(TC,$tmpcom) or die ":( $tmpcom";
while(<TC>){
  print IN $_;
}
close(TC);
close(IN);
system("x2t $tmpcom > coord");
system("cp -f coord $dir1/.");
system("cp -f coord $dir2/.");

  chdir("$dir1");
  print "Starting job $dir1\n";
  system("dscf > dscf.out");
  system("ricc2 > $fout");
  chdir("../$dir2");
  print "Starting job $dir2\n";
  system("cp -f ../$dir1/mos .");
  system("dscf > dscf.out");
  system("ricc2 > $fout");  
  chdir("../");

print "Reading output\n";
rw_out();

sub rw_out{
# Read energies
  print "Reading energies\n";
  system("rm -f $tmpout");
  open(GDO,">$tmpout") or die "Cannot open $tmpout.";
  open(GO,"$dir2/$fout") or die ":( $dir2/$fout";
  print GDO "Energies\n";
  while(<GO>){
    if (/Final $gslabel energy/){
       chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
       @g=split(/\s+/,$_);
       $egs=$g[5];
       printf GDO " %9.7F\n",$egs;
    }
  }
  close(GO);
  open(GO,"$dir2/$fout") or die ":( $dir2/$fout";
  $grb=0;
  while(<GO>){
    if (/       Energy:/){
       chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
       ($grb,$exe)=split(/\s+/,$_);
       $eee=$egs+$exe;
       printf GDO " %9.7F\n",$eee;     
    }
  }
  close(GO);
# Read gradients
  print "Reading gradient $dir1\n";
  r_grad("$dir1");
  print "Reading gradient $dir2\n";
  r_grad("$dir2");
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
