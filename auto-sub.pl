#!/usr/bin/perl -w
#
# Read the number of jobs of a user and if this number is smaller
# than some maximum number submit more jobs specified in a separated list.
# The list should be in the format:
# PATH SCRIPT FLAG
# where PATH   - absolute path to the job
#       SCRIPT - submission script name
#       FLAG   - w = 'waiting'
#                s = 'submited'
# Only jobs with flag w are submitted. After running this script the
# list is rewritten with the new adequated flags. 
# Add this routine to crontab to schedule the submission of jobs.
# Mario Barbatti, Sept 2007
#
#...............................................................
# User-dependent variables:
#User:
$user="barbatti";
#Home directory:
$home="/home/$user";
# Maximum number of jobs running or queued:
$max_jobs=10;
# List of jobs:
$list="$home/my_job_list";
#...............................................................
#

# Determine the number of jobs in the system:
system("/usr/local/bin/qstat -u $user > $home/auto-sub.temp"); 
system("grep -c workq $home/auto-sub.temp > $home/qstat-now");

# Read number of jobs:
if (!-s "$home/qstat-now"){
  $actual_jobs=0;
}else{
  open(QN,"$home/qstat-now") or warn ":( $home/qstat-now! \n";
  $_=<QN>;
  close(QN);
  chomp;
  $_ =~ s/^\s*//;         # remove leading blanks
  $_ =~ s/\s*$//;         # remove trailing blanks
  $actual_jobs=$_;
}

# print "jobs = $actual_jobs\n"; # For tests

if ($actual_jobs < $max_jobs){
  # Read list of jobs
  if (!-s $list){die "AUTO-SUB: $home/my_job_list does not exist! auto-sub.pl is dying now.\n"}
  open(LJ,"$list") or warn ":( $list \n";
  $i=0;
  while(<LJ>){
    $i++;
    chomp;
    $_ =~ s/^\s*//;         # remove leading blanks
    $_ =~ s/\s*$//;         # remove trailing blanks
    ($path[$i],$script[$i],$flag[$i])=split(/\s+/,$_);
  }
  $imax=$i;
  close(LJ);

  # submit jobs
  $i=0;
  $my_jobs=$actual_jobs;
  while($my_jobs < $max_jobs){
    $i++;
    if ($i > $imax){
      last;
    }
    if ($flag[$i] eq "w"){
      chdir($path[$i]) or warn "$path[$i] does not exist! \n";
      system("/usr/local/bin/qsub $script[$i]");
      chdir($home);
      $flag[$i]="s";
      $my_jobs++;
    }
  }

  # Rewrite list
  open(LJ,">$list") or warn ":( $list \n";
  for ($i=1;$i<=$imax;$i++){
    print LJ " $path[$i]  $script[$i]  $flag[$i]\n";
  }
  close(LJ);
}

# Clean up
#system("rm -f $home/auto-sub.temp $home/qstat-now");

