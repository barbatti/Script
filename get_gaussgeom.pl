#!/usr/bin/perl -w

#
# Usage: get_gaussgeom.pl <LOG> <CYCLE> <ORIENTATION>
# cycle = N - collect geom cycle N
#       =-1 - collect optimized geometry (default)
#       =-2 - collect geometry of last cycle
#       = all - collect all geometries
# orientation = input (default)
#             = standard
#             = zmat
#

if (defined $ARGV[0]){
  $g09log = $ARGV[0];
  if (!-s $g09log){
    die "G09 log $g09log does not exist or is empty.";
  }
}else{
  print "\n\n Usage: get_gaussgeom.pl <log> <cycle> <orientation>\n";
  print " <log>         = Gaussian log filename (no default value set)\n";
  print " <cycle>       = -2   (last geometry)\n";
  print "               = -1   (optimized geometry; default)\n";
  print "               =  0   (all geometries)\n";
  print "               =  N>0 (geometry N)\n";
  print " <orientation> = \"input\" (default)\n";
  print "                 \"standard\"\n";
  print "                 \"zmat\"\n\n";
  exit;
}

if (defined $ARGV[1]){
  $cycle = $ARGV[1];
}else{
  $cycle = -1;
}
$found=0;
$cyc=1;

if (defined $ARGV[2]){
  $orient = lc $ARGV[2];
}else{
  $orient = "input";
}
if (($orient ne "input") or ($orient ne "standard") or ($orient ne "zmat")){
#  die "Orientation must be \"standard\", \"input\", \"zmat\". Now it is \"$orient\".";
}
if ($orient eq "input"){
  $string="Input orientation:";
}elsif($orient eq "standard"){
  $string="Standard orientation:";
}elsif($orient eq "zmat"){
  $string="Z-Matrix orientation:";
}
print "Looking for $string\n";

#if ($cycle == -2){
  $ncc=0;
  open(IN,$g09log) or die ":( $g09log";
  while(<IN>){
    if (/$string/){
      $ncc++;
    }
  }
  close(IN);
if (($cycle == -2) or ($cycle == 0)){
  $fcycle=$ncc;
}elsif($cycle > 0){
  $fcycle=$cycle;
}

$ind = 0;
open(IN,$g09log) or die ":( $g09log";
while(<IN>){
  if ($cycle == -1){
    if (/Stationary point found/){
      $found++;
      print ">> Stationary point found ($ncc).\n   Geometry ($orient) written to statp.xyz.\n";
      while(<IN>){
        if (/$string/){
          collect();
          last;
        }
      }
      last;
    }
  }elsif(($cycle == -2) or ($cycle > 0)){
    if (/$string/){
      if ($cyc == $fcycle){
        $found++;
        print ">> Point found ($fcycle).\n   Geometry ($orient) written to statp.xyz.\n";
        collect();
        last;
      }else{
        $cyc++;
      }
    }
  }elsif($cycle == 0){
    if (/$string/){
      $found++;
      print ">> Point found (",$ind+1,").\n   Geometry ($orient) written to statp.xyz.\n";
      collect();
      $ind++;
    }
  }
}
close(IN);
if ($found == 0){
  print ">> Requested point NOT found.\n";
}else{
  open(OUT,">statp.xyz") or die ":( statp.xyz";
  # print "$nat From file $g09log\n";
  if (($cycle == -2) or ($cycle == -1) or ($cycle > 0)){
    print OUT "$nat\nFrom file:$g09log $line[0]";
  }elsif($cycle == 0){
    for ($ind = 0; $ind <= $fcycle-1; $ind++){
      print OUT "$nat\nPoint ",$ind+1," From file:$g09log $line[$ind]\n";
    }
  }
  close(OUT);
}

sub collect{
    while(<IN>){
       if (/Number     Number       Type/){
         $_=<IN>;
         $line[$ind]="";
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
             $line[$ind]=$line[$ind]."\n $s     $x   $y   $z";
             $nat++;
           }
         }
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
  if ($g[1] == 9){
    $s="F";
  }
  if ($g[1] == 12){
    $s="Mg";
  }
  if ($g[1] == 14){
    $s="Si";
  }
  if ($g[1] == 16){
    $s="S";
  }
  if ($g[1] == 17){
    $s="Cl";
  }
  if ($g[1] == 35){
    $s="Br";
  }
}
