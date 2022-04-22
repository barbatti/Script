#!/usr/bin/perl -w

# Calculate the distances in the LIIC path

$WDIR="DISPLACEMENT";
$disp="displfl";
#$DIR="/home3/barbatti/PERL_FILES";
#$DIR="\$hm/PERL_FILES";
$DIR="/home/mario/Scripts/";

if (-s "dyn.mld"){
 system("rm -f dyn.mld");
}

open(DP,"$WDIR/$disp") or die ":( $WDIR/$disp";
$_=<DP>;
$_=<DP>;
$_=<DP>;
$ind=0;
while(<DP>){
  chomp;
  $_ =~ s/^\s*//;         # remove leading blanks
  $_ =~ s/\s*$//;         # remove trailing blanks
  ($c,$i)=split(/\s+/,$_);
  find_geom();
  $ind++;
}
close(DP);

system("$DIR/distance.pl");
#system("cp dyn.mld dyn.xyz");

# .........................

sub find_geom{
  $add="";
  if (-s "$WDIR/CALC.c$c.d$i"."au"){
    $add="au";
  }
  if (-s "$WDIR/CALC.c$c.d$i"."ang"){
    $add="ang";
  }
  $file="$WDIR/CALC.c$c.d$i$add/geom";
  geom2xyz();  
}

# .........................
sub geom2xyz{
   $au2ang=0.529177;
   $xyztemp="dyn.mld";
   open (FILE, $file) or die "Failed to open file: $file\n";
   $i=0;
   while (<FILE>)
    {
      $i++;
      chomp;
      $_ =~ s/^\s*//;         # remove leading blanks
      $_ =~ s/\s*$//;         # remove trailing blanks
      ($symbol[$i],$charge[$i],$x[$i],$y[$i],$z[$i])=split(/\s+/,$_);
      $charge[$i]=$charge[$i];
      $natom=$i;
    }
    open (OUT,">>$xyztemp")or die" Failed to open file: $xyztemp\n";
    print {OUT}" $natom\n\n";
    for ($i=1; $i<=$natom; $i++)
    {
      $x[$i]=$x[$i]*$au2ang;
      $y[$i]=$y[$i]*$au2ang;
      $z[$i]=$z[$i]*$au2ang;
      printf {OUT}("%7s  %15.6f  %15.6f   %15.6f\n", $symbol[$i],$x[$i],$y[$i],$z[$i]);
    }
   close OUT;
   close FILE;
   if ($ind == 0){
    open (OUT,">geom.molden")or die" Failed to open file: geom.molden\n";
    print {OUT}" $natom\n\n";
    for ($i=1; $i<=$natom; $i++)
    {
      printf {OUT}("%7s  %15.6f  %15.6f   %15.6f\n", $symbol[$i],$x[$i],$y[$i],$z[$i]);
    }
    close OUT;
   }
}

