#!/usr/bin/perl -w
#
# Probability of hopping at step n is P(n) = g(n)*PROD_k[(1-g(k))]
#
# Giving a list of g(n), computes P(n).
#
# Mario Barbatti, July 2008/March 2009.
#

open(LOG,">Phop_t.log") or die ":( Phop_t.log!";
#.........................................................
# Compute P(n) to which state? (Ground state = 1)
  $state_f=1;
  $state_i=2;
  print LOG " Probability from state $state_i to $state_f \n";
#.........................................................

$column=$state_f+2;    # This line will work ONLY for state_f=1! Fix it later.

$map="map_seam.dat";
if (!-s "$map"){
  die "Cannot find map_seam.dat. Run map_seam.pl first.\nThis program should run in the TRAJECTORIES directory.\n";
}

open(MS,"$map") or die ":( $map";
$_=<MS>;

open(PH,">Phop_t.dat") or die ":( Phop_t.dat!";
open(LOG2,">Phop_t_sumary.dat") or die ":( Phop_t_sumary.dat!";
print PH " TRAJ     K        g(K)           P(K)          SUM \n";
while(<MS>){
  chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
  ($it,$tstep_i,$tstep_f)=split(/\s+/,$_);
  $DIR="TRAJ$it/RESULTS";
  if (!-s "$DIR/tprob"){
    warn "Cannot find $DIR/tprob!\n";
  }
  ($st_i,$state_ini)=tstep2step($tstep_i,$DIR);
  ($st_f,$state_end)=tstep2step($tstep_f,$DIR);
  $step_i=step2substep($st_i,$DIR,"first");
  $step_f=step2substep($st_f,$DIR,"last");
  print LOG "Ti = $tstep_i Si = $state_ini  Tf = $tstep_f Sf = $state_end \n";
  if (($step_i >= 0) and ($step_f >= 0)){
    if ($state_ini == $state_i){
      print LOG "Computing probability for TRAJ$it, from steps $step_i to $step_f.\n";
      probability();
    }
  }
}
close(PH);
close(LOG2);

# -------------------------------------------------------------

sub step2substep{
  my ($substep,$step,$line,@g,@g1,$file,$dir);
  ($step,$dir,$line)=@_;
  $file="$dir/tprob";
  if (!-s "$file"){
    warn "Cannot find $file!\n";
  }
  open(FL,$file) or die ":( $file";
  $substep=-1;
  $_=<FL>;
  while(<FL>){
    chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
    @g=split(/\s+/,$_);  
    if ($g[2] == $step){
      if ($line eq "first"){
        $substep=$g[1];
        last;
      }elsif($line eq "last"){
         while(<FL>){
           chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
           @g1=split(/\s+/,$_);
           if ($g1[2] > $step){
              $substep=$g[1];
              last;
           }
           @g=@g1;
         }
      }
    }
  }
  return $substep;
}

# -------------------------------------------------------------

sub tstep2step{
 my (@g,$time,$step,$tstep,$dir,$state);
 ($tstep,$dir)=@_;
  $file="$dir/dyn.out";
  if (!-s "$file"){
    warn "Cannot find $file!\n";
  }
  open(FL,$file) or die ":( $file";
  $step=-1;
  $state=-1;
  while(<FL>){
    if (/TIME =/){
      chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
      @g=split(/\s+/,$_); 
      $time=$g[9];
      if ($tstep == $time){
        $step=$g[1];
        $state=$g[6];
        last;
      }
    }
  }
  close(FL);
  return $step,$state;
}

# -------------------------------------------------------------

sub probability{

open(TP,"$DIR/tprob") or die ":( $DIR/tprob!";
$k=0;
while(<TP>){
   if ($k>=$step_i){
      chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
      @c=split(/\s+/,$_);
      $g[$k]=$c[$column];
      if ($k==$step_f){
         last;
      }
   }
   $k++;
}
close(TP);

for ($n=$step_i;$n<=$step_f;$n++){
  $prod = 1;
  for ($k=$step_i;$k<=$n;$k++){
    if ($k != $n){
      $P[$n]=$prod*(1-$g[$k]);
    }else{
      $P[$n]=$prod*$g[$k];
    }
    $prod=$P[$n];
  }
  print LOG "$n  $P[$n] \n";
}

$P_sum=0;
for ($k=$step_i;$k<=$step_f;$k++){
   $P_sum=$P_sum+$P[$k];
   printf PH "%5d %6d %14.7f %14.7f %14.7f \n",$it,$k,$g[$k],$P[$k],$P_sum;
}
printf LOG2 "%5d %5d %14.7f\n",$it,$k,$P_sum;
}


