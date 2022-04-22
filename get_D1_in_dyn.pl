#!/usr/bin/perl -w

# Get D1 and D2 for trajectories with ADC(2)
# Mario Barbatti 2013

print "Initial Trajectory: ";
$_=<STDIN>;
chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
$it=$_;

print "Final Trajectory: ";
$_=<STDIN>;
chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
$ft=$_;

open(OUT,">get_d1_in_dyn.dat") or die ":( get_d1_in_dyn.dat";
open(OUT2,">get_d1_in_dyn_last.dat") or die ":( get_d1_in_dyn_last.dat";
for ($i=$it;$i<=$ft;$i++){
  $file="TRAJ$i/RESULTS/nx.log";
  open(IN,$file) or die ":( $file";
  while(<IN>){
    if (/D1 diagnostic for/){
      @g=split(/\s+/,$_); 
      chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
      $d1=$g[4];
    }
    if (/D2/){
      $_=<IN>;
      $d2="";
      while(<IN>){
        if (/\+/){
          last;
        }else{
          @g=split(/\s+/,$_); 
          chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
          $d2=$d2."  ".$g[14];
        }
      }
    }
    if (/TIME/){
        @g=split(/\s+/,$_);
        chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
        $t=$g[5];
        print OUT "$i   $t    $d1    $d2\n";
    }
  }
  close(IN);
  print OUT2 "$i   $t    $d1    $d2\n";
  print OUT "\n";
}
close(OUT);
