#!/usr/bin/perl -w

# This script collects all geometries from a G09 output.
#
# Usage: get_g09geom.pl <LOG> <ORIENT>
# <LOG>    = G09 log file.
# <ORIENT> = input
#          = standard
#          = zmat (default)
#
# Results re written to statp.xyz
#

system("rm -f statp.xyz");

if (defined $ARGV[0]){
  $g09log = $ARGV[0];
  if (!-s $g09log){
    die "G09 log $g09log does not exist or is empty.";
  }
}else{
  print "\n Usage: get_scan_g09.pl <gaussian.log> \n";
  die;
}

if (defined $ARGV[1]){
  $orient = lc $ARGV[1];
}else{
  $orient = "zmat";
}
if ($orient eq "input"){
  $string="Input orientation:";
}elsif($orient eq "standard"){
  $string="Standard orientation:";
}elsif($orient eq "zmat"){
  $string="Z-Matrix orientation:";
}
print "Looking for $string\n";

open(IN,$g09log) or die ":( $g09log";
while(<IN>){
  if (/$string/){
        collect();
        open(OUT,">>statp.xyz") or die ":( statp.xyz";
        print OUT "$natom\nFrom file:$g09log $line\n";
        close(OUT);
  }
}
close(IN);

sub collect{
    while(<IN>){
       if (/Number     Number       Type/){
         $_=<IN>;
         $line="";
         $nat=0;
         while(<IN>){
           if (/----/){
             last;
           }else{
             chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
             @g=split(/\s+/,$_);
             symbol();
             $x=sprintf("%12.6f",$g[3]);
             $y=sprintf("%12.6f",$g[4]);
             $z=sprintf("%12.6f",$g[5]);
             $line=$line."\n $s     $x   $y   $z";
             $nat++;
           }
         }
         $natom=$nat;
         last;
       }
    }
}

sub symbol{
  if ($g[1] ==-1){
    $s="X";
  }
  if ($g[1] == 1){
    $s="H";
  }
  if ($g[1] == 2){
    $s="He";
  }
  if ($g[1] == 6){
    $s="C";
  }
  if ($g[1] == 7){
    $s="N";
  }
  if ($g[1] == 8){
    $s="O";
  }
  if ($g[1] == 12){
    $s="Mg";
  }
  if ($g[1] == 16){
    $s="S";
  }
  if ($g[1] == 35){
    $s="Br";
  }
}
