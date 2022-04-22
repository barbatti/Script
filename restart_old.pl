#!/usr/bin/perl -w

@list=(103,113,123,139,143,144,148,157,158,15,16,17,19,1,20,21,24,26,28,3,46,48,54,57,62,64,81,8,96,98);

foreach(@list){
  $i=$_;
  print "TRAJ$i ";
  system("cp -f sh.inp TRAJ$i/.");
  open(R,"TRAJ$i/INFO_RESTART/restart.inf");
  while(<R>){
    if (/Time /){
      chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
      @g=split(/\s+/,$_); 
      $t=$g[3];
      last;
    }
  }
  close(R);
  open(T,"TRAJ$i/INFO_RESTART/control.dyn") or warn ":( $i";
  open(TA,">control.dyn.aux");
  $_=<T>;
  print TA $_;
  print TA "  nxrestart = 1\n";
  print TA "  t = $t\n";
  while(<T>){
     print TA $_;
  }
  close(T);
  close(TA);
  system("mv control.dyn.aux TRAJ$i/control.dyn");
}
