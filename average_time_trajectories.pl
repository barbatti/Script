#!/usr/bin/perl -w

# Given a set of Trajectories, return the duration of each one, the total and the averge time.
# Uses calc_time_duration_traj.pl
# Mario Barbatti, May 2008

$perlbase="/home/barbatti/PERL_FILES";

open(TA,">time_average.log") or die ":( time_average.log";

print "Initial TRAJ: ";
$_=<STDIN>;
chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
$ni=$_;

print "Final TRAJ: ";
$_=<STDIN>;
chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
$nf=$_;

$total=0;
$k=0;
for ($n=$ni;$n<=$nf;$n++){
  chdir("TRAJ$n");
  $t=qx($perlbase/calc_time_duration_traj.pl);
  print "$t\n";
  ($g,$_)=split(/\s+/,$t);
  chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
  $tm=$_;
  print TA "TRAJ$n  =  $tm\n";
  $total=$total+$tm;
  $k++;
  chdir("../");
}
print TA "\nTotal of $k traectories: $total seconds\n";
$ave=$total/$k;
print TA "Average time of $k trajectories: $ave\n";

close(TA);
