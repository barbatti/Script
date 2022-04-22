#!/usr/bin/perl -w

# Input section ----------------------------------------
$minutes=2;    # check every $minutes minutes
$maxtime=120;  # for a maximum of $maxtime minutes
$fout="grad.out";
$tmpout="tmp.out";
$tmpcom="tmp.com";
$local="yes"; # no - submitt to batch, yes - run locally
# $subsc is used only if local = "no"
$subsc="ptm-para";
# $para is used only if local = "no"
$para_w="#!/bin/csh
setenv PARNODES 4
setenv PARA_ARCH \"SMP\"
setenv TURBOMOLE_SYSNAME x86_64-unknown-linux-gnu_smp
set path = ( \$TURBODIR/smprun_scripts \$path )
source \${TURBODIR}/Config_turbo_env.tcsh";
# ------------------------------------------------------

if ($local eq "yes"){
  open(CS,">.cs") or die ":( .cs";
  print "$para_w\n";
  close(CS);
}

print "Starting program\n";
open(TC,$tmpcom) or die ":( tmpcom";
$_=<TC>;
chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
$nat=$_;
close(TC);
print "Number of atoms $nat\n";

system("rm -f MP2/gradient ADC/gradient ADC/$fout MP2/coord ADC/coord");

open(IN,">>geom.xyz") or die ":( geom.xyz";
open(TC,$tmpcom) or die ":( $tmpcom";
while(<TC>){
  print IN $_;
}
close(TC);
close(IN);
system("x2t $tmpcom > coord");
system("cp -f coord MP2/.");
system("cp -f coord ADC/.");

$time=$minutes*60;
if ($local eq "no"){
  chdir("MP2");
  if (!-s $subsc){
    die ":( MP2/$subsc";
  }
  print "Submitting job MP2\n";
  system("qsub $subsc");
  chdir("../ADC");
  if (!-s $subsc){
    die ":( ADC/$subsc";
  }
  print "Submitting job ADC\n";
  system("qsub $subsc");
  chdir("../");
}else{
  chdir("MP2");
  print "Starting job MP2\n";
  system("source ../.cs;dscf > dscf.out");
  system("source ../.cs;ricc2 > $fout");
  chdir("../ADC");
  print "Starting job ADC\n";
  system("cp -f ../MP2/mos .");
  system("source ../.cs;dscf > dscf.out");
  system("source ../.cs;ricc2 > $fout");  
  chdir("../");
}

if ($local eq "no"){
  $test="no";
  $i=0;
  while($test eq "no"){
    if ($i >= $maxtime){
       $test="Too long";
       die ".... Too Long ...\n";
    }
    sleep $time;
    if ((-s "ADC/$fout") and (-s "MP2/$fout")){
      print "Checking ... $i yes\n";
      $test="yes";
    }else{
      print "Checking ... $i no\n";
      $i++;
    }
  }
}

print "Reading output\n";
rw_out();

sub rw_out{
# Read energies
  print "Reading energies\n";
  system("rm -f $tmpout");
  open(GDO,">$tmpout") or die "Cannot open $tmpout.";
  open(GO,"ADC/$fout") or die ":( ADC/$fout";
  print GDO "Energies\n";
  while(<GO>){
    if (/Final MP2 energy/){
       chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
       @g=split(/\s+/,$_);
       $egs=$g[5];
       printf GDO " %9.7F\n",$egs;
    }
  }
  close(GO);
  open(GO,"ADC/$fout") or die ":( ADC/$fout";
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
  print "Reading gradient MP2\n";
  r_grad("MP2");
  print "Reading gradient ADC\n";
  r_grad("ADC");
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
