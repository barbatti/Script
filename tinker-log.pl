#!/usr/bin/perl -w
# MB Jul 2009

print "\n  Usage: ./tinker-log.pl < <tinker.log>\n  Output written to tinker_energy.log\n\n";

open(LOG,"> tinker_energy.log") or ":( tinker_energy.log";
print LOG "       Time(ps)   Etot(Kcal/mole) Epot(Kcal/mole) Ekin(Kcal/mole) Eint(Kcal/mole)     T(K)\n";

while(<STDIN>){
  if (/Simulation Time/){
     read_log();
     $time=$g[2];
  }
  if (/Total Energy/){
     read_log();
     $Etot=$g[2];
  }
  if (/Potential Energy/){
     read_log();
     $EP=$g[2];
  }
  if (/Kinetic Energy/){
     read_log();
     $K=$g[2];
  }
  if (/Intermolecular/){
     read_log();
     $U=$g[1];
  }
  if (/Temperature/){
     read_log();
     $Temp=$g[1];
  }
  if (/Instantaneous Values/){
    printf LOG "%15.4f %15.4f %15.4f %15.4f %15.4f %11.2f \n",$time,$Etot,$EP,$K,$U,$Temp;
  }
}

 

sub read_log{
     chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
     @g=split(/\s+/,$_);
}
