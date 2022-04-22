#!/usr/bin/perl -w

$q="First internal coordinate file: ";
$f_int[0]=question($q,"");

$q="Second internal coordinate file: ";
$f_int[1]=question($q,"");

open(OUT,">diff_two_intcord.log") or die "Cannot write diff_two_intcord.log!";

$i=0;
foreach(@f_int){
  $file_name=$_;
  $k=0;
  print OUT "\nFile: ...$file_name\n";
  open(FILE,"$file_name") or die "Cannot read $file_name!";
  while(<FILE>){
    chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
    $int[$i][$k]=$_;
    printf OUT "%4d    %12.6f\n",$k,$int[$i][$k];
    $k++; 
  }
  close(FILE);
  $nint[$i]=$k;
  printf OUT "\nNumber of internal coordinates in file %2d: %4d\n",$i,$nint[$i];
  $i++;
}

if ($nint[0] != $nint[1]){
  die "Number of internal coordinates in both files must be the same!\n";
}

if (-s "intcfl"){
  open(INT,"intcfl") or die ":(";
  $k=0;
  while(<INT>){
    chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
    (@test)=split(/\s+/,$_);
    if ($test[0] =~ "K"){
      $int_card[$k]=$_;
      $k++;
    }
  }
  close(INT);
}

print OUT "\nDeviations:\n";
print OUT "   k        int1           int2            diff            dev         card\n";
for ($k=0;$k<=$nint[0]-1;$k++){
  $diff=($int[1][$k]-$int[0][$k]);
  $ave=($int[1][$k]+$int[0][$k])/2;
  $dev = $diff/$ave*100;
  printf OUT "%4d   %12.6f   %12.6f   %12.2f   %12.1f   %s\n",$k,$int[0][$k],$int[1][$k],$diff,$dev,$int_card[$k];
}

close(OUT);


sub question{
  my ($q,$def,$answer);
  ($q,$def)=@_;
  print STDOUT " $q";
  $_=<STDIN>;
  chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
  if ($_ eq ""){
    $answer = $def;
  }else{
    $answer=$_;
  }
  return $answer;
}

