#!/usr/bin/perl -w

if (defined $ARGV[0]){
  $g09log = $ARGV[0];
  if (!-s $g09log){
    die "G09 log $g09log does not exist or is empty.";
  }
}else{
  print " Usage: get_stationarypoint_g09.pl <gaussian.log> <cycle>\n";
  print " If <cycle> is not given, it looks for stationary point.\n";
}
if (defined $ARGV[1]){
  $cycle = $ARGV[1];
}else{
  $cycle = -1;
}
$found=0;
$cyc=1;
open(IN,$g09log) or die ":( $g09log";
while(<IN>){
  if ($cycle == -1){
    if (/Stationary point found/){
      $found++;
      print ">> Stationary point found.\n   Geometry written to statp.xyz.\n";
      collect();
      last;
    }
  }else{
    if (/Input orientation:/){
      if ($cyc == $cycle){
        $found++;
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
  if ($g[1] == 1){
    $s="H";
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
}
