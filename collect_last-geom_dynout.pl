#!/usr/bin/perl -w
# This script goes over a set of trajectories, collects the last geometry
# from each one into a dyn-last.xyz file and adds the corresponding times
# to time-last.dat.
$nx = $ENV{"NX"};

# Inputs
print "Initial Traj: ";
$_=<STDIN>;
chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
$ni=$_;
print "Final Traj: ";
$_=<STDIN>;
chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
$nf=$_;

$dynl="dyn-last.xyz";
$timel="time-last.dat";

# Number of atoms
open(IN,"TRAJ$ni/RESULTS/nx.log") or die ":( TRAJ$n/RESULTS/nx.log\n";
while(<IN>){
  if (/Nat/){
    chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
    @g=split(/\s+/,$_);
    $nat=$g[2];
    print " Nat = $nat\n";
    last;
  }
}
close(IN);

# Read trajectories
open(TL,">$timel") or die ":( $timel";
for ($n=$ni;$n<=$nf;$n++){
  #Read times
  open(DO,"TRAJ$n/RESULTS/dyn.out") or warn ":( TRAJ$n/RESULTS/dyn.out\n";
  while(<DO>){
    if (/TIME =/){
      @g=split(/\s+/,$_);
      $tlast=$g[9];
    }  
  } 
  print TL "$tlast\n";
  close(DO);
  # Read geoms
  open(DO,"TRAJ$n/RESULTS/dyn.out") or warn ":( TRAJ$n/RESULTS/dyn.out\n";
  while(<DO>){
    if (/TIME =/){
      @g=split(/\s+/,$_);
      $t=$g[9];
      if ($t == $tlast){
        $_=<DO>;
        $_=<DO>;
        $_=<DO>;
        open(AUX,">geom") or die ":( geom\n";
        for ($k=1;$k<=$nat;$k++){
          $_=<DO>;
          print AUX $_;
        }
        close(AUX);
        system("$nx/nx2xyz");
        system("cat geom.xyz >> $dynl");
      }
    }  
  } 
  close(DO);
}
close(TL);
