#!/usr/bin/perl -w
#
#

$name="collect_hop";
open(LOG,">$name.log") or die ":( $name.log!";

print LOG "   TRAJ     STEP   FROM  TO      DE\n";

read_parameters();

for ($i=$itraj;$i<=$ftraj;$i++){
  read_dyn();
}

close(LOG);

# ------------------------------------------------------------------------------------
sub read_dyn{
  open(IN,"TRAJ$i/RESULTS/sh.out") or die ":( TRAJ$itraj/RESULTS/sh.out";
  while(<IN>){
    if (/SURFACE HOPPING!/){
      chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
      (@grb)=split(/\s+/,$_);
      $from_s=$grb[6];
      $to_s=$grb[8];
      $_=<IN>;
      chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
      ($gb,$gb,$step)=split(/\s+/,$_);
      $_=<IN>;
      chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
      ($gb,$gb,$gb,$gb,$de)=split(/\s+/,$_);
      printf LOG "%6d  %8d  %3d  %3d  %9.3f\n",$i,$step,$from_s,$to_s,$de;
    }
  }
  close(IN);
}
# ------------------------------------------------------------------------------------
sub read_parameters{
  $q="Initial trajectory: ";
  $itraj=question($q);
  $q="Final trajectory: ";
  $ftraj=question($q);
}
# ------------------------------------------------------------------------------------
sub question{
  my ($q,$answer);
  ($q)=@_;
  print STDOUT " $q";
  $_=<STDIN>;
  chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
  $answer=$_;
  return $answer;
}
# ------------------------------------------------------------------------------------
