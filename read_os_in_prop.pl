#!/usr/bin/perl -w
#

  print "Target state (1): ";
  $target_state=get_answer("1");
  print "\nCollecting oscillator strength between current state and state $target_state.\n";

  print "\nMaximum time (press <Enter> for full trajectory): ";
  $max_time=get_answer("");

  if ($max_time ne ""){
     print "\nMaximum time $max_time.\n\n";
  }else{
     print "\nGo over complete trajectory.\n\n";
  }

  open(PP,"properties") or die "Cannot read properties";
  open(OUT,">os.dat") or die "Cannot write os.dat";
  while(<PP>){
    if (/TIME \(fs\)/){
       chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
       @g=split(/\s+/,$_);
       $time=$g[2];
       $current_state=$g[7];
       while (<PP>){
         if (/Oscillator strength/){
           if ((/\($current_state,$target_state\)/) or (/\($target_state,$current_state\)/)){
              @g=split(/\s+/,$_);
              $os=$g[5];
              printf OUT "%8.2f  %3d  %3d  %10.4f\n",$time,$target_state,$current_state,$os;
              last;
           }
         }
       }
       if (($max_time ne "") and ($time >= $max_time)){
         last;
       }
    }
  }
  close(OUT);
  close(PP);


# =======================================================================
sub get_answer{
  my ($ans,$def);
  ($def)=@_;
  $_=<STDIN>;
  chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
  if ($_ eq ""){
    $ans=$def;
  }else{
    $ans=$_;
  }
  return $ans;
}

