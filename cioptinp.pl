#!/usr/bin/perl -w
# Prepare inputs for CIOpt program.
# It works with run_seq_turbo.pl.
# Variables of Control.dat are hard-coded below.
# Mario Barbatti, March 2014

$method="ADC";  # Only ADC(2) is implemented

# read tmp.com
if (!-s "tmp.com"){
  die "Prepare tmp.com containing xyz for initial geometry.\n";
}
open(TC,"tmp.com") or die ":( tmp.com";
$_=<TC>;
chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
$nat=$_;
$_=<TC>;
for ($i=0;$i<=$nat-1;$i++){
  $_=<TC>;
  chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
  ($s[$i],$x[$i],$y[$i],$z[$i])=split(/\s+/,$_);
}
close(TC);

# write Control.dat
open(IN,">Control.dat") or die ":( Control.dat";
print IN "&control\n";
print IN "nopt=3\n";  # 3=BFGS
print IN "natoms=$nat\n";
print IN "nstates=2\n";
print IN "istate=2\n";
print IN "nefunc=8\n";  # 8=Second penalty formula
print IN "crunstr='run_seq_turbo.pl'\n";
print IN"/\n";
for ($i=0;$i<=$nat-1;$i++){
  printf IN "%3s  %9.5f  %9.5f  %9.5f\n",$s[$i],$x[$i],$y[$i],$z[$i];
}
close(IN);

# write template.write
# write template.writeg
open(TW,">template.write") or die ":( template.write";
print TW "$nat\n\n";
for ($i=0;$i<=$nat-1;$i++){
  $a=3*$i+1;$b=3*$i+2;$c=3*$i+3;
  if ($c <= 9){
    print TW "$s[$i]  %%00$a  %%00$b  %%00$c\n";
  }elsif ($c <= 99){
    print TW "$s[$i]  %%0$a  %%0$b  %%0$c\n";
  }elsif ($c <= 999){
    print TW "$s[$i]  %%$a  %%$b  %%$c\n";
  }
  if ($c >= 1000){
    die "Too many atoms ...\n";
  }
}
close(TW);
system("cp -f template.write template.writeg");

# write template.read
open(TR,">template.read") or die ":( template.read";
print TR "^001Energies\n";
print TR "&%07(f12.7)00101\n";
print TR "&%07(f12.7)00201\n";
close(TR);

# write template.readg
# write template.readg2
if ($method eq "ADC"){
  write_trg("template.readg","MP2");
  write_trg("template.readg2","ADC");
}

sub write_trg{
  ($file,$type)=@_;
  open(TG,">$file") or die ":( $file";
  print TG "^001Gradient $type\n";
  for ($i=0;$i<=$nat-1;$i++){
    $a=3*$i+1;$b=3*$i+2;$c=3*$i+3;
    if ($c <= 9){
      print TG "&%07(f15.9)00$a"."01%07(f15.9)00$b"."17%07(f15.9)00$c"."33\n";
    }elsif ($c <= 99){
      print TG "&%07(f15.9)0$a"."01%07(f15.9)0$b"."17%07(f15.9)0$c"."33\n";
    }elsif ($c <= 999){
      print TG "&%07(f15.9)$a"."01%07(f15.9)$b"."17%07(f15.9)$c"."33\n";
    }
  }
  close(TG);
}
