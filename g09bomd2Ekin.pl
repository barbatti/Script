#!/usr/bin/perl -w
use lib join('/',$ENV{"NX"},"CPAN") ;
use colib_perl;

$au2fs  = units("timeunit")*1E-15;
$amu2e  = units("proton");

if ($ARGV[0] eq ""){
  die " Use: g09ibomd2Ekin.pl <g09_output.log> \n\n"
}
if (!-s "$ARGV[0]"){
  die "File $ARGV[0] does not exist or is empty.\n\n";
}
$filein=$ARGV[0];
$fileout="g09bomdEkin.dat";

open(IN,"$filein") or die ":( $filein";
while(<IN>){
  if (/NAtoms=/){
    chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
    ($grb,$nat)=split(/\s+/,$_);
    last;
  }
}
close(IN);

print STDOUT "\n Select atoms (comma separated list, e.g., 6-9,11,13): ";
$_=<STDIN>;
chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
@list=make_num_sequence($_);
if ($_ eq ""){
  @list=(1..$nat);
}

open(IN,"$filein") or die ":( $filein";
open(OUT,">$fileout") or die ":( $fileout";
printf OUT "    time(fs)        Ekintot(au)     Ekin(au)        Ratio\n";
while(<IN>){
  $ekin=0.0;
  $ekintot=0.0;
  if (/Summary information for step/){
    $_=<IN>;
    chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
    ($grb,$grb,$time)=split(/\s+/,$_);
    while(<IN>){
      if (/MW cartesian velocity:/){
        for ($i=0; $i<=$nat-1; $i++){
          $_=<IN>;
          chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
          @a=split(/\s+/,$_);
          $a[3]=~s/D/E/;
          $a[5]=~s/D/E/;
          $a[7]=~s/D/E/;
          $vx[$i]=$a[3]*sqrt($amu2e)*$au2fs;
          $vy[$i]=$a[5]*sqrt($amu2e)*$au2fs;
          $vz[$i]=$a[7]*sqrt($amu2e)*$au2fs;
          $atkin=0.5*($vx[$i]**2+$vy[$i]**2+$vz[$i]**2);
          $ekintot=$ekintot+$atkin;
        }
        foreach(@list){
          $k=$_-1;
          $atkin=0.5*($vx[$k]**2+$vy[$k]**2+$vz[$k]**2);
          $ekin=$ekin+$atkin;
        }
        $ratio=$ekin/$ekintot;
        printf OUT "%14.8f  %14.8f  %14.8f  %14.8f\n",$time,$ekintot,$ekin,$ratio;
        last;
      }
    }
  }
}
close(IN);
close(OUT);

