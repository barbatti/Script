#!/usr/bin/perl -w
# ==================================================================
# Run many DISPLACEMENT/CALC.c*.d* jobs in a single computer 
# in batchs of N jobs.
# ==================================================================
# Give here the following info:

# 1. Command to run
$run="\$COLUMBUS/runc -m 1600 > runls &";

# 2. Number of jobs per batch
$ncore = 5;

# 3. Check jobs every nt minutes
$nt = 0.1;

#===================================================================

$time = $nt*60;

open(LOG,">rall.log");

# Run REFPOINT if requested
open(IN,"displfl") or die "Cannot open displfl. Are we in the DISPLACEMENT directory?\n";
while(<IN>){
  if (/reference point calculation/){
     chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
     (@g)=split(/\s+/,$_);
     if ($g[0] eq "yes"){
       chdir("REFPOINT");
       system("$run");
       chdir("../");
     }
  }
}
close(IN);

# Count number of jobs
open(IN,"displfl") or die "Cannot open displfl. Are we in the DISPLACEMENT directory?\n";
$_=<IN>;
$_=<IN>;
$_=<IN>;
$i=0;
while(<IN>){
  chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
  ($m[$i],$n[$i])=split(/\s+/,$_);
  $i++;  
}
close(IN);
$imax = $i-1;

# Run CALC jobs
$i = 0;
while($i <= $imax){
  $njob=check_status();
  $nrun=$ncore-$njob;
  if ($nrun > 0){
    for ($k=$i;$k<=$i+$nrun-1;$k++){
      if ($k<=$imax){
        print LOG "submitting job CALC.c$m[$k].d$n[$k]\n";
        chdir("CALC.c$m[$k].d$n[$k]");
        system("$run");
        chdir("../");
        $klast=$k;
      }
    }
    $i=$klast+1;
  }
} 

close(LOG);

#===================================================================

sub check_status{
  system("ps -u > status"); 
  open(IN,"status");
  my $n=0;
  while(<IN>){
    if (/runc/){
      $n++;
    }
  }
  close(IN);
  return $n;
}
