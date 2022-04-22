#!/usr/bin/perl -w

# Initial condition =   1
# Geometry in COLUMBUS and NX input format:
# O     7.0   -0.02811481    0.06020010    2.17656260   14.00307401
# Velocity in NX input format:
#   -0.000004058    0.000295875   -0.000059211
# Epot of initial state (eV):    0.4436  Epot of final state (eV):      8.2856
# Vertical excitation (eV):      7.8420  Is Ev in the required range? YES
# Ekin of initial state (eV):    0.9720  Etot of initial state (eV):    1.4156
# Oscillator strength:           0.0259

$k=1;
open(IN,"input") or die ":( input";
open(FO,">final_output") or die ":( final_output";

while(<IN>){
  chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
  ($de,$f)=split(/\s+/,$_);
  print FO " Initial condition = $k\n";
  print FO " Epot of initial state (eV):    0.0000  Epot of final state (eV):   $de\n";
  print FO " Vertical excitation (eV):    $de  Is Ev in the required range? YES\n";
  print FO " Ekin of initial state (eV):    0.0000  Etot of initial state (eV): $de\n";
  print FO " Oscillator strength:         $f\n";
  print FO "\n";
  print FO "\n";
  $k++;
}

