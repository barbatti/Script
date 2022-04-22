#!/usr/bin/perl -w

# complete prop.2 file
#   4   68.00  2  2  2.2   0.4805   0.5195

open(LG,">completed.log") or die ":( completed";

print STDOUT "Maximum time (fs): ";
$_=<STDIN>;
chomp;
$_ =~ s/^\s*//;         # remove leading blanks
$_ =~ s/\s*$//;         # remove trailing blanks
$tmax=$_;
print STDOUT "Time step (fs): ";
$_=<STDIN>;
chomp;
$_ =~ s/^\s*//;         # remove leading blanks
$_ =~ s/\s*$//;         # remove trailing blanks
$dt=$_;
print STDOUT "Final trajectory: ";
$_=<STDIN>;
chomp;
$_ =~ s/^\s*//;         # remove leading blanks
$_ =~ s/\s*$//;         # remove trailing blanks
$traj_max=$_;

# Check original file
open(PT,"prop.2") or die ":( prop.2";
$traj_previous = 1;
$time_previous = 0.0;
$fs_previous = 2;
$ntraj = 0;
while(<PT>){
  chomp;
  $_ =~ s/^\s*//;         # remove leading blanks
  $_ =~ s/\s*$//;         # remove trailing blanks
  ($traj,$time,$is,$fs,$m1,$m2,$m3)=split(/\s+/,$_);
  if ($traj != $traj_previous){
     if ($time_previous != $tmax){
       print LG "TRAJ $traj_previous will continue from $time_previous fs on state $fs_previous \n";
     }
     $tmf[$traj_previous]=$time_previous;
     $ntraj++;
  }
  $traj_previous = $traj;
  $time_previous = $time;
  $fs_previous = $fs;
}
$tmf[$traj_max] = $time;
$ntraj++;
close(PT);

# Write completed file
open(PT,"prop.2") or die ":( prop.2";
open(PC,">prop.completed") or die ":( prop.completed";
while(<PT>){
  chomp;
  $_ =~ s/^\s*//;         # remove leading blanks
  $_ =~ s/\s*$//;         # remove trailing blanks
  ($traj,$time,$is,$fs,$m1,$m2,$m3)=split(/\s+/,$_);
  printf PC "%4d %8.2f %3d %3d %5.1f %9.4f %9.4f \n",$traj,$time,$is,$fs,$m1,$m2,$m3;
  if (($time == $tmf[$traj]) and ($tmf[$traj] != $tmax)){
    #print STDOUT "$traj $time $tmf[$traj] $tmax \n";
    for ($tc=$time+$dt;$tc<=$tmax;$tc=$tc+$dt){
      printf PC "%4d %8.2f %3d %3d %5.1f %9.4f %9.4f \n",$traj,$tc,$is,$fs,$m1,$m2,$m3;
    }
  }
}
close(PC);
close(PT);

statistic();

sub statistic{
# Valid ONLY to two states starting at t = 0 fs!!!
  my %n1 = ();
  my %n2 = ();
  $tmin = 0.0;
  for ($t=$tmin;$t<=$tmax;$t=$t+$dt){
    $n1{$t} =0;
    $n2{$t} =0;
  }

  open(PC,"prop.completed") or die ":( prop.completed";
  while(<PC>){
    chomp;
    $_ =~ s/^\s*//;         # remove leading blanks
    $_ =~ s/\s*$//;         # remove trailing blanks
    ($traj,$time,$is,$fs,$m1,$m2,$m3)=split(/\s+/,$_);
    $time=$time*1.0;
    $fs = $fs*1;
    #print STDOUT "traj = $traj   fs = $fs   time = $time \n";
    if ($fs == 1){
      $n1{$time}=$n1{$time}+1;
    }
    if ($fs == 2){
      $n2{$time}=$n2{$time}+1;
      #print STDOUT "Time = $time n2 = $n2{$time} \n";
    }
  }
  close(PC);
  open(MN,">mean.dat") or die ":( mean.dat";
  for ($t=$tmin;$t<=$tmax;$t=$t+$dt){
    $frac1 = $n1{$t}/$ntraj;
    $frac2 = $n2{$t}/$ntraj;
    print MN "$t $frac1 $frac2 \n";
    print STDOUT "t = $t   n1 = $n1{$t}  n2 = $n2{$t}  NTRAJ = $ntraj\n";
  }
  close(MN);
}