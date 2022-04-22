#!/usr/bin/perl -w
#
#$nx = $ENV{"NX"};

print " Please enter the number of the initial trajectory: ";
$_ = <STDIN>;
chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
$first = $_;

print " Please enter the number of the final trajectory: ";
$_ = <STDIN>;
chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
$last = $_;

print " Please enter the number of states: ";
$_ = <STDIN>;
chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
$nstat = $_;

$nstat1=$nstat+2;
$nstat2=$nstat+3;

$i=$first;

while ($i <= $last) {
  if (-s "TRAJ$i/RESULTS/en.dat"){
    ip();
    system("cp -f TRAJ$i/RESULTS/en.dat .");
    system("gnuplot ip");
    system("convert f.ps g.jpg");
    system("mv g.jpg f-$i.jpg");
#    system("rm -f f.ps en.dat ip");
  }
  $i++;
}

sub ip{

  $sentence="";
  for ($k=2;$k<=1+$nstat;$k++){
    $sentence=$sentence."'en.dat' u 1:$k title '' w l, ";
  }
  $sentence=$sentence."'en.dat' u 1:$nstat1 title '' w p,'en.dat' u 1:$nstat2 title 'TRAJ $i' w l";

  open(IP,">ip");
  print IP "set xlabel \"Time (fs)\"\n";
  print IP "set ylabel \"Energy (eV)\"\n";
  print IP "set pointsize 1.0\n";
  print IP "plot $sentence\n";
  print IP "set output \"f.ps\"\n";
  print IP "set terminal postscript solid\n";
  print IP "set terminal postscript color\n";
  print IP "replot\n";

}

