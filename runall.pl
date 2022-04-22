#!/usr/bin/perl -w
# ==================================================================
# Run many trajectories in a single computer in batchs of N jobs.
# ==================================================================
# Give here:
# 1. Command to run
$run="\$NX/moldyn.pl > moldyn.log &";
# 2. Initial trajectory
$i = 1;
# 2. Final trajectories
$imax = 200;
# 3. Number of jobs per batch
$ncore = 4;
# 4. Check jobs every nt minutes
$nt = 15;

$time = $nt*60;

open(LOG,">rall.log");

while($i<=$imax){
 $njob=check_status();
 # $datestring = localtime();
 # print LOG "Local date and time $datestring\n";
 # print LOG "Number of jobs running: $njob\n";
 $nrun=$ncore-$njob;
 if ($nrun > 0){
   for ($k=$i;$k<=$i+$nrun-1;$k++){
     if ($k<=$imax){
       print LOG "submitting job TRAJ$k\n";
       chdir("TRAJ$k");
       system("$run");
       chdir("../");
       $klast=$k;
     }
   }
   $i=$klast+1;
 }
 sleep($time);
}
close(LOG);

sub check_status{
  system("ps > status"); 
  open(IN,"status");
  my $n=0;
  while(<IN>){
    if (/moldyn.pl/){
      $n++;
    }
  }
  close(IN);
  return $n;
}
