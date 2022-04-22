#!/usr/bin/perl -w

#
# Usage: get_g09geom.pl <LOG> <CYCLE> <ORIENTATION>
# cycle = N - collect geom cycle N
#       =-1 - collect optimized geometry (default)
#       =-2 - collect geometry of last cycle
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
  print "\n Usage: get_stationarypoint_g09.pl <gaussian.log> <cycle> <orientation>\n";
  print " If <cycle> is not given, it looks for stationary point (cycle=-1).\n";
  print " <orientation> can be \"standard\" or \"input\" (default).\n\n";
  die;
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
if ($cycle == -2){
  $cycle=$ncc;
}

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
  }else{
    if (/$string/){
      if ($cyc == $cycle){
        $found++;
        print ">> Point found ($cycle).\n   Geometry ($orient) written to statp.xyz.\n";
        collect();
        last;
      }else{
        $cyc++;
      }
    }
  }
}
close(IN);
if ($found == 0){
  print ">> Requested point NOT found.\n";
}else{
  open(OUT,">statp.xyz") or die ":( statp.xyz";
  # print "$nat From file $g09log\n";
  print OUT "$nat\nFrom file:$g09log $line";
  close(OUT);
}

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
