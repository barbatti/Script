#!/usr/bin/perl -w
# split trajectories in windows
#
open(LT,">life.log") or die ":(";

# ---------------------------------------------------------------------
$traj_i   = 1;   # First traj
$traj_f   = 62;  # Final traj
$NTRAJ    = 20;  # Number of trajs in each window
$nstatdyn = 3;   # Initial state
# ---------------------------------------------------------------------

print LT "Program lifetime.pl run with the following parameters:\n";
print LT "First state = $traj_i\n";
print LT "Final state = $traj_f\n";
print LT "Number of trajectories per window = $NTRAJ\n";
print LT "Initial excited state = $nstatdyn\n\n";

$au2ev=27.211396;

$N1="NEW_DIR_1";
$N2="NEW_DIR_2";
$N3="NEW_DIR_3";
if (!-s "$N1"){
  system("mkdir $N1");
}else{
  die "$N1 exist";
}
if (!-s "$N2"){
  system("mkdir $N2");
}else{
  die "$N2 exist";
}
if (!-s "$N3"){
  system("mkdir $N3");
}else{
  die "$N3 exist";
}

$nfs=$nstatdyn+3;
for ($i=$traj_i;$i<=$traj_f;$i++){
  $file="TRAJ$i/RESULTS/dyn.out";
  open(IN,"$file") or warn ":( $file \n";
  while(<IN>){
    if (/%     0.0/){
      chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
      @g=split(/\s+/,$_);
      $e0=$g[4];
      $e1=$g[$nfs];
      $vexc[$i]=$au2ev*($e1-$e0);
      print LT " $i   $vexc[$i] \n";
      $ind{$vexc[$i]}=$i;
      last;
    }
  }
  close(IN);
}
print LT "\n\n";
@vord=sort { $a cmp $b } @vexc;

$j=0;
$j1=0;
$j2=0;
$j3=0;
foreach (@vord){
  $j++;
  if ($j <= $NTRAJ){
    $j1++;
    $k=$j1;
    $N=$N1;
    copydir();
  }elsif(($j > $NTRAJ) and ($j <= 2*$NTRAJ)){
    $j2++;
    $k=$j2;
    $N=$N2;
    copydir();
  }elsif($j > 2*$NTRAJ){
    $j3++;
    $k=$j3;
    $N=$N3;
    copydir();
  }
}

sub copydir{
  $i=$ind{$vord[$j]};
  print LT "$N:  $j  $k  $i  $vord[$j] \n";
  #$file="TRAJ$i/RESULTS/dyn.out";
  #$dest="$N/TRAJ$k";
  #system("mkdir $dest");
  #system("mkdir $dest/RESULTS");
  #system("cp -f $file $dest/RESULTS/.");
  system("ln TRAJ$i $N/TRAJ$k");
}

