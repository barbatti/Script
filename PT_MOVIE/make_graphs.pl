#!/usr/bin/perl -w
# This program gets the history of a trajectory, splits in intervals
# and generate 3-D plots for each one.
#
#-----------------------------
# User variables:
$Dt=2;
$ifile="windowB.txt";
$tmax=300;
$dx=0.2;
$dy=0.2;
$string1=" set title \"Time = ";
$string2="fs\" font \"Arial, 22\"";
$box1=-3;
$box2=3;
$gnu="color_contour-plot.gnu";
#-----------------------------

$w="window";
system("rm -f $w-*");

print "Splitting trajectory\n";
open(IN,$ifile) or die ":( Cannot find $ifile";
while(<IN>){
 chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
 ($t,$d1,$d2)=split(/\s+/,$_);
 #$ind=int($t/$Dt+0.99);
 if ($t < $tmax){
   $ind=int($t/$Dt);
   open(OUT,">>$w-$ind") or die ":( $w-$ind";
   print OUT " $t  $d1  $d2\n";
   close(OUT);
 }
}
close(IN);

# For each $ind
$indmax=int($tmax/$Dt-1);
for ($i=0;$i<=$indmax;$i++){
  print "IND = $i\n";
  print "Adding box limits\n";
  open(OUT,">>$w-$i") or die ":( $w-$i";
  $t=$i*$Dt;
  print OUT " $t  $box1  $box1\n";
  print OUT " $t  $box1  $box2\n";
  print OUT " $t  $box2  $box1\n";
  print OUT " $t  $box2  $box2\n";
  close(OUT);
  print "Making grid\n";
  open(INP,">inpg") or die ":( inpg";
  print INP "$w-$i\n$dx\n$dy\n";
  system("make_a_grid < inpg");
  close(INP);
  print "Creating eps\n";
  system("awk -f addblanks.awk grid.dat > waf.dat");
  open(IN,"$gnu") or die ":( $gnu";
  open(OUT,">$gnu-2") or die ":( $gnu-2";
  while(<IN>){
    if (/reset/){
      print OUT $_;
      print OUT "$string1 $t $string2\n"; 
    }else{
      print OUT $_;
    }
  }
  close(OUT);
  close(IN);
  system("gnuplot < $gnu-2");  
  print "Converting to png\n";
  system("mogrify -format png -depth 8 -alpha off -density 600 -resample 150 *.eps");
  if ($i<=9){
    system("mv -f f.png f-000$i.png");
  }elsif($i<=99){
    system("mv -f f.png f-00$i.png");
  }elsif($i<=999){
    system("mv -f f.png f-0$i.png");
  }else{
    system("mv -f f.png f-$i.png");
  }
}

print "Making animation\n";
system("convert -delay 0 -loop 0 *.png animated.gif");
system("rm -f $w-* f.eps grid.dat grid.log waf.dat inpg");
