#!/usr/bin/perl -w

#$OUTDIR="RENAMED_TRAJS";
$OUTDIR="/scratch/mario/THY/ONLY_S0";

open(LOG,">/scratch/mario/THY/rename_traj.log") or die ":( rename_traj.log";

if (!-e $OUTDIR){
  system("mkdir $OUTDIR");
}else{
  print STDOUT " Directory $OUTDIR exists. Delete it before and run this program again.";
  die;
}

print STDOUT " Enter initial trajectory: ";
$_=<STDIN>;
chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
$it=$_;
print STDOUT " Enter final trajectory: ";
$_=<STDIN>;
chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
$ft=$_;
print LOG " Trajectories between $it and $ft will be checked and copied.\n";

$m=1;
for ($k=$it;$k<=$ft;$k++){
 if (-e "TRAJ$k/RESULTS"){
   system("cp -rf TRAJ$k $OUTDIR/TRAJ$m");
   print LOG "TRAJ$k was copied as $OUTDIR/TRAJ$m.\n";
   $m++;
 }
}
$m_tot=$m-1;
print STDOUT " $m_tot trajectories were copied into $OUTDIR directory.\n";
print STDOUT " Log information was writen to rename_traj.log.\n\n";
