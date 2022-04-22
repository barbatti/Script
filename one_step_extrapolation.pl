#!/usr/bin/perl -w

# You have LIIC step 9, step 10 and figure out that you need step 11.
# This is the program to make the geometry extrapolation.
# R_third = 2*R_second - R_first
# Usage: having geom.first and geom.second (NX/COLUMBUS format) in the same directory,
# run this program to get geom.third.
#
# Mario Barbatti, Sept 2007

# read R(i)
  read_geom("geom.first");
  @r1x=@x;
  @r1y=@y;
  @r1z=@z;

# read R(i-1)
  read_geom("geom.second");
  @r2x=@x;
  @r2y=@y;
  @r2z=@z;

# extrapolate
  extrapolate();

# write
  write_geom();

# ........................................
sub read_geom{
  ($file)=@_;
   open(FL,$file) or die "Cannot find $file!";
   $n=0;
   while(<FL>){ 
      chomp;
      $_ =~ s/^\s*//;         # remove leading blanks
      $_ =~ s/\s*$//;         # remove trailing blanks
      $n++;
      ($s[$n],$atom[$n],$x[$n],$y[$n],$z[$n],$mass[$n])=split(/\s+/,$_);
   }
   $Nat=$n;
   close(FL);
}
# ........................................
sub extrapolate{
  for ($i=1;$i<=$Nat;$i++){
    $rx[$i]=2.0*$r2x[$i]-$r1x[$i];
    $ry[$i]=2.0*$r2y[$i]-$r1y[$i];
    $rz[$i]=2.0*$r2z[$i]-$r1z[$i];
  }
}
# ........................................
sub write_geom{
  open(OUT,">geom.third") or die ":( geom.third";
  for ($i=1;$i<=$Nat;$i++){
    printf OUT " %2s  %5.1f%14.8f%14.8f%14.8f%14.8f\n",$s[$i],$atom[$i],$rx[$i],$ry[$i],$rz[$i],$mass[$i];
  }
  close(OUT);
}
