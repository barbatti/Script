#!/usr/bin/perl -w

open(OUT,">dist_two_frags.out") or die ":( dist_two_frags.out";

#$ang2bohr=1.0/0.52917720859;
#$au2ev=27.21138386;

# Input files
$file1=which_file("Fragment-1 XYZ input file name: ");
print OUT "Fragment-1 geom:    $file1\n";
print "\n";
$file2=which_file("Fragment-2 XYZ input file name: ");
print OUT "Fragment-2 geom:    $file2\n";
print "\n";

# Read coordinate FRAG 1
open(INP,$file1) or die ":( $file1";
$_=<INP>;
chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
$nat1=$_;
print OUT "Number of atoms in fragment 1: $nat1\n";
$_=<INP>;
$i=0;
$x1g=0.0;
$y1g=0.0;
$z1g=0.0;
$x1cm=0.0;
$y1cm=0.0;
$z1cm=0.0;
$mass1=0.0;
while(<INP>){
  chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
  ($s1[$i],$x1[$i],$y1[$i],$z1[$i])=split(/\s+/,$_);
  $mass=which_mass("$s1[$i]");
  $x1g=$x1g+$x1[$i];
  $y1g=$y1g+$y1[$i];
  $z1g=$z1g+$z1[$i];
  $x1cm=$x1cm+$mass*$x1[$i];
  $y1cm=$y1cm+$mass*$y1[$i];
  $z1cm=$z1cm+$mass*$z1[$i];
  $mass1=$mass1+$mass;
  $i++;
}
close(INP);
$x1g=$x1g/$nat1;
$y1g=$y1g/$nat1;
$z1g=$z1g/$nat1;
$x1cm=$x1cm/$mass1;
$y1cm=$y1cm/$mass1;
$z1cm=$z1cm/$mass1;

# Read 2
open(INP,$file2) or die ":( $file2";
$_=<INP>;
chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
$nat2=$_;
print OUT "Number of atoms in fragment 2: $nat2\n";
$_=<INP>;
$i=0;
$x2g=0.0;
$y2g=0.0;
$z2g=0.0;
$x2cm=0.0;
$y2cm=0.0;
$z2cm=0.0;
$mass2=0.0;
while(<INP>){
  chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
  ($s2[$i],$x2[$i],$y2[$i],$z2[$i])=split(/\s+/,$_);
  $mass=which_mass("$s2[$i]");
  $x2g=$x2g+$x2[$i];
  $y2g=$y2g+$y2[$i];
  $z2g=$z2g+$z2[$i];
  $x2cm=$x2cm+$mass*$x2[$i];
  $y2cm=$y2cm+$mass*$y2[$i];
  $z2cm=$z2cm+$mass*$z2[$i];
  $mass2=$mass2+$mass;
  $i++;
}
close(INP);
$x2g=$x2g/$nat2;
$y2g=$y2g/$nat2;
$z2g=$z2g/$nat2;
$x2cm=$x2cm/$mass2;
$y2cm=$y2cm/$mass2;
$z2cm=$z2cm/$mass2;

# Read charge fragment-2

# Monopole interaction CG
$distg=sqrt(($x1g-$x2g)**2+($y1g-$y2g)**2+($z1g-$z2g)**2);

# Monopole interaction CM
$distcm=sqrt(($x1cm-$x2cm)**2+($y1cm-$y2cm)**2+($z1cm-$z2cm)**2);

printf OUT "\nFragment 1 - Number of atoms: %4d     Total Mass (amu): %12.3f   \n",$nat1,$mass1;
printf OUT "             Center of mass (A):   %10.5f  %10.5f  %10.5f \n",$x1cm,$y1cm,$z1cm;
printf OUT "             Geometric center (A): %10.5f  %10.5f  %10.5f \n",$x1g,$y1g,$z1g;
printf OUT   "Fragment 2 - Number of atoms: %4d     Total Mass (amu): %12.3f   \n",$nat2,$mass2;
printf OUT "             Center of mass (A):   %10.5f  %10.5f  %10.5f \n",$x2cm,$y2cm,$z2cm;
printf OUT "             Geometric center (A): %10.5f  %10.5f  %10.5f \n",$x2g,$y2g,$z2g;
printf OUT "Distance between center of masses (A):  %10.5f\n",$distcm;
printf OUT "Distance between geometric centers (A): %10.5f\n",$distg;

close(OUT);

# ======================================================================================

sub which_file{
  my ($text,$file);
  ($text)=@_;
  print " $text";
  $_=<STDIN>;
  chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
  if ($_ ne ""){
    $file=$_;
  }else{
    die "We need a name...\n";
  }
  if (-s $file){
    return $file;
  }else{
    die ":( $file does not exist or is empty";
  }
}

# ======================================================================================

sub which_mass{
        my ($s,$num_z,$atomic_mass);
        ($s)=@_;
        if ($s=~m/x/i){
          $numz  = 0;
          $atomic_mass = 0.0;
        }
        if ($s=~m/h/i){
          $numz  = 1;
          $atomic_mass = 1.007825037;
        }
        if ($s=~m/he/i){
          $numz  = 2;
          $atomic_mass = 4.00260325;
        }
        if ($s=~m/li/i){
          $numz  = 3;
          $atomic_mass = 7.0160045;
        }
        if ($s=~m/be/i){
          $numz  = 4;
          $atomic_mass = 9.0121825;
        }
        if ($s=~m/b/i){
          $numz  = 5;
          $atomic_mass = 11.0093053;
        }
        if ($s=~m/c/i){
          $numz  = 6;
          $atomic_mass = 12.0;
        }
        if ($s=~m/n/i){
          $numz  = 7;
          $atomic_mass = 14.003074008;
        }
        if ($s=~m/o/i){
          $numz  = 8;
          $atomic_mass = 15.99491464;
        }
        if ($s=~m/f/i){
          $numz  = 9;
          $atomic_mass = 18.99840325;
        }
        if ($s=~m/ne/i){
          $numz  = 10;
          $atomic_mass = 19.9924391;
        }
        if ($s=~m/na/i){
          $numz  = 11;
          $atomic_mass = 22.9897697;
        }
        if ($s=~m/mg/i){
          $numz  = 12;
          $atomic_mass = 23.9850450;
        }
        if ($s=~m/al/i){
          $numz  = 13;
          $atomic_mass = 26.9815413;
        }
        if ($s=~m/si/i){
          $numz  = 14;
          $atomic_mass = 27.9769284;
        }
        if ($s=~m/p/i){
          $numz  = 15;
          $atomic_mass = 30.9737634;
        }
        if ($s=~m/s/i){
          $numz  = 16;
          $atomic_mass = 31.9720718;
        }
        if ($s=~m/cl/i){
          $numz  = 17;
          $atomic_mass = 34.968852729;
        }
        if ($s=~m/ar/i){
          $numz  = 18;
          $atomic_mass = 39.9623831;
        }
        if ($s=~m/k/i){
          $numz  = 19;
          $atomic_mass = 38.9637079;
        }
        if ($s=~m/ca/i){
          $numz  = 20;
          $atomic_mass = 39.9625907;
        }
        if ($s=~m/sc/i){
          $numz  = 21;
          $atomic_mass = 44.9559136;
        }
        if ($s=~m/ti/i){
          $numz  = 22;
          $atomic_mass = 47.9479467;
        }
        if ($s=~m/v/i){
          $numz  = 23;
          $atomic_mass = 50.9439625;
        }
        if ($s=~m/cr/i){
          $numz  = 24;
          $atomic_mass = 51.9405097;
        }
        if ($s=~m/mn/i){
          $numz  = 25;
          $atomic_mass = 54.9380463;
        }
        if ($s=~m/fe/i){
          $numz  = 26;
          $atomic_mass = 55.9349393;
        }
        if ($s=~m/co/i){
          $numz  = 27;
          $atomic_mass = 58.9331978;
        }
        if ($s=~m/ni/i){
          $numz  = 28;
          $atomic_mass = 57.9353471;
        }
        if ($s=~m/cu/i){
          $numz  = 29;
          $atomic_mass = 62.9295992;
        }
        if ($s=~m/zn/i){
          $numz  = 30;
          $atomic_mass = 63.9291454;
        }
        if ($s=~m/ga/i){
          $numz  = 31;
          $atomic_mass = 68.9255809;
        }
        if ($s=~m/ge/i){
          $numz  = 32;
          $atomic_mass = 73.9211788;
        }
        if ($s=~m/as/i){
          $numz  = 33;
          $atomic_mass = 74.9215955;
        }
        if ($s=~m/se/i){
          $numz  = 34;
          $atomic_mass = 79.9165205;
        }
        if ($s=~m/br/i){
          $numz  = 35;
          $atomic_mass = 78.9183361;
        }
        if ($s=~m/kr/i){
          $numz  = 36;
          $atomic_mass = 83.80;
        }
        if ($s=~m/rb/i){
          $numz  = 37;
          $atomic_mass = 85.4678;
        }
        if ($s=~m/sr/i){
          $numz  = 38;
          $atomic_mass = 87.62;
        }
        if ($s=~m/y/i){
          $numz  = 39;
          $atomic_mass = 88.9059;
        }
        if ($s=~m/zr/i){
          $numz  = 40;
          $atomic_mass = 91.22;
        }
        if ($s=~m/nb/i){
          $numz  = 41;
          $atomic_mass = 92.9064;
        }
        if ($s=~m/mo/i){
          $numz  = 42;
          $atomic_mass = 95.94;
        }
        if ($s=~m/tc/i){
          $numz  = 43;
          $atomic_mass = 98;
        }
        if ($s=~m/ru/i){
          $numz  = 44;
          $atomic_mass = 101.07;
        }
        if ($s=~m/rh/i){
          $numz  = 45;
          $atomic_mass = 102.9055;
        }
        if ($s=~m/pd/i){
          $numz  = 46;
          $atomic_mass = 106.4;
        }
        if ($s=~m/ag/i){
          $numz  = 47;
          $atomic_mass = 107.868;
        }
        if ($s=~m/cd/i){
          $numz  = 48;
          $atomic_mass = 112.41;
        }
        if ($s=~m/in/i){
          $numz  = 49;
          $atomic_mass = 114.82;
        }
        if ($s=~m/sn/i){
          $numz  = 50;
          $atomic_mass = 118.69;
        }
        if ($s=~m/sb/i){
          $numz  = 51;
          $atomic_mass = 121.75;
        }
        if ($s=~m/te/i){
          $numz  = 52;
          $atomic_mass = 127.60;
        }
        if ($s=~m/i/i){
          $numz  = 53;
          $atomic_mass = 126.9045;
        }
        if ($s=~m/xe/i){
          $numz  = 54;
          $atomic_mass = 131.30;
        }
        if ($s=~m/cs/i){
          $numz  = 55;
          $atomic_mass = 132.9054;
        }
        if ($s=~m/ba/i){
          $numz  = 56;
          $atomic_mass = 137.33;
        }
        if ($s=~m/la/i){
          $numz  = 57;
          $atomic_mass = 138.9055;
        }
        if ($s=~m/ce/i){
          $numz  = 58;
          $atomic_mass = 140.12;
        }
        if ($s=~m/pr/i){
          $numz  = 59;
          $atomic_mass = 140.9077;
        }
        if ($s=~m/nd/i){
          $numz  = 60;
          $atomic_mass = 144.24;
        }
        if ($s=~m/pm/i){
          $numz  = 61;
          $atomic_mass = 145;
        }
        if ($s=~m/sm/i){
          $numz  = 62;
          $atomic_mass = 150.4;
        }
        if ($s=~m/eu/i){
          $numz  = 63;
          $atomic_mass = 151.96;
        }
        if ($s=~m/gd/i){
          $numz  = 64;
          $atomic_mass = 157.25;
        }
        if ($s=~m/tb/i){
          $numz  = 65;
          $atomic_mass = 158.9254;
        }
        if ($s=~m/dy/i){
          $numz  = 66;
          $atomic_mass = 162.50;
        }
        if ($s=~m/ho/i){
          $numz  = 67;
          $atomic_mass = 164.9304;
        }
        if ($s=~m/er/i){
          $numz  = 68;
          $atomic_mass = 167.26;
        }
        if ($s=~m/tm/i){
          $numz  = 69;
          $atomic_mass = 168.9342;
        }
        if ($s=~m/yb/i){
          $numz  = 70;
          $atomic_mass = 173.04;
        }
        if ($s=~m/lu/i){
          $numz  = 71;
          $atomic_mass = 174.967;
        }
        if ($s=~m/hf/i){
          $numz  = 72;
          $atomic_mass = 178.49;
        }
        if ($s=~m/ta/i){
          $numz  = 73;
          $atomic_mass = 180.9479;
        }
        if ($s=~m/w/i){
          $numz  = 74;
          $atomic_mass = 183.85;
        }
        if ($s=~m/re/i){
          $numz  = 75;
          $atomic_mass = 186.207;
        }
        if ($s=~m/os/i){
          $numz  = 76;
          $atomic_mass = 190.2;
        }
        if ($s=~m/ir/i){
          $numz  = 77;
          $atomic_mass = 192.22;
        }
        if ($s=~m/pt/i){
          $numz  = 78;
          $atomic_mass = 195.09;
        }
        if ($s=~m/au/i){
          $numz  = 79;
          $atomic_mass = 196.9665;
        }
        if ($s=~m/hg/i){
          $numz  = 80;
          $atomic_mass = 200.59;
        }
        if ($s=~m/tl/i){
          $numz  = 81;
          $atomic_mass = 204.37;
        }
        if ($s=~m/pb/i){
          $numz  = 82;
          $atomic_mass = 207.2;
        }
        if ($s=~m/bi/i){
          $numz  = 83;
          $atomic_mass = 208.9804;
        }
        if ($s=~m/po/i){
          $numz  = 84;
          $atomic_mass = 209;
        }
        if ($s=~m/at/i){
          $numz  = 85;
          $atomic_mass = 210;
        }
        if ($s=~m/rn/i){
          $numz  = 86;
          $atomic_mass = 222;
        }
        if ($s=~m/fr/i){
          $numz  = 87;
          $atomic_mass = 223;
        }
        if ($s=~m/ra/i){
          $numz  = 88;
          $atomic_mass = 226.0254;
        }
        if ($s=~m/ac/i){
          $numz  = 89;
          $atomic_mass = 227.0278;
        }
        if ($s=~m/th/i){
          $numz  = 90;
          $atomic_mass = 232.0381;
        }
        if ($s=~m/pa/i){
          $numz  = 91;
          $atomic_mass = 231.0359;
        }
        if ($s=~m/u/i){
          $numz  = 92;
          $atomic_mass = 238.029;
        }
        if ($s=~m/np/i){
          $numz  = 93;
          $atomic_mass = 237.0482;
        }
        if ($s=~m/pu/i){
          $numz  = 94;
          $atomic_mass = 244;
        }
        if ($s=~m/am/i){
          $numz  = 95;
          $atomic_mass = 243;
        }
        if ($s=~m/cm/i){
          $numz  = 96;
          $atomic_mass = 247;
        }
        if ($s=~m/bk/i){
          $numz  = 97;
          $atomic_mass = 247;
        }
        if ($s=~m/cf/i){
          $numz  = 98;
          $atomic_mass = 251;
        }
        if ($s=~m/es/i){
          $numz  = 99;
          $atomic_mass = 254;
        }
        if ($s=~m/fm/i){
          $numz  = 100;
          $atomic_mass = 257;
        }
        if ($s=~m/md/i){
          $numz  = 101;
          $atomic_mass = 258;
        }
        if ($s=~m/no/i){
          $numz  = 102;
          $atomic_mass = 259;
        }
        if ($s=~m/lr/i){
          $numz  = 103;
          $atomic_mass = 260;
        }
        return $atomic_mass;
}










