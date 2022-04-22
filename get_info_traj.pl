#!/usr/bin/perl -w

# Check running trajectories

print "Intial TRAJ:";
$_=<STDIN>;
chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
$ini=$_;

print "Final TRAJ:";
$_=<STDIN>;
chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
$end=$_;

$running=0;
$error1=0;
$error2=0;
$normal1=0;
$normal2=0;
for ($i=$ini;$i<=$end;$i++){
  $status=0;
  print "Checking TRAJ$i: ";
  if (-s "TRAJ$i"){
    open(IN,"TRAJ$i/RESULTS/nx.log") or warn "Cannot open nx.log in TRAJ$i/RESULTS\n";
    while(<IN>){
      if (/ FINISHING STEP /){
         chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
         @g=split(/\s+/,$_);
         $step=$g[2];
         $time=$g[4];
         $state=$g[8];
      }
      if (/with ERROR/){
         print "Ended ERROR at step $step ($time fs) on state $state.\n";
         $status=1;
         if ($state==1){
           $error1++;
         }else{
           $error2++;
         }
         last;
      }
      if (/ends here/){
         print "Ended NORMAL at step $step ($time fs) on state $state.\n";
         $status=1;
         if ($state==1){
           $normal1++;
         }else{
           $normal2++;
         }
         last;
      }
    }
    close(IN);
    if ($status==0){
      print    "Still RUNNING at step $step ($time fs) on state $state.\n";
      $running++;
    }
  }
}

print "\nSummary:\n";
print "Running: $running\n";
print "Normal termination in state 1: $normal1\n";
print "Normal termination other state: $normal2\n";
print "Ended in error in state 1: $error1\n";
print "Ended in error in other state: $error2\n";
