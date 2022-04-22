#!/usr/bin/perl -w
#
#

$name="collect_hop";
open(LOG,">$name.log") or die ":( $name.log!";

print LOG "   TRAJ     STEP   FROM  TO      DE         PROB        RANDOM\n";

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
      open(IN2,"TRAJ$i/RESULTS/tprob") or die ":( TRAJ$itraj/RESULTS/tprob";
      $_=<IN2>;
      $prev_rand = 0;
      $prev_prob[0] = 0;
      $prev_prob[1] = 0;
      $prev_prob[2] = 0;
      while(<IN2>){
        chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
        ($rand,$gb,$fullstep,$prob[0],$prob[1],$prob[2])=split(/\s+/,$_); #3 states!
        if ($step == $fullstep){
	  if ($rand > 10){
	    $my_rand=$prev_rand;
	    if ($to_s == 1){
	      $my_prob = $prev_prob[0];
	    }elsif($to_s == 2){
	      $my_prob = $prev_prob[1];
	    }elsif($to_s == 3){
              $my_prob = $prev_prob[2];
            }
	  } 
	}
	$prev_rand = $rand;
	$prev_prob[0] = $prob[0];
	$prev_prob[1] = $prob[1];
	$prev_prob[2] = $prob[2];
      }
      close(IN2);
      printf LOG "%6d  %8d  %3d  %3d  %9.3f %14.9f  %14.9f\n",$i,$step,$from_s,$to_s,$de,$my_prob,$my_rand;
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
