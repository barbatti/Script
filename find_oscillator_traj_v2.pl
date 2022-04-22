#!/usr/bin/perl -w
# ================ FIND OSCILLATOR STRENGTH IN TRAJ ======================================
#
# This program reads the oscillator strengths in a set of NX trajectries and 
# computes the mean as function of time.
#
# In the current version (v2), it works with:
#
# * NX/COLUMBUS: it looks for these lines in properties:
# TIME (fs): 0.0000    STEP: 0    CURRENT STATE: 2
# Trans. dipole components (x,y,z) e*bohr:     0.021743     0.052228    -1.484206
# Oscillator strength (2,1) = -0.498097
#
# * NX/GAUSSIAN: it looks for these lines in nx.log:
# Excited State   1:      Singlet-?Sym    3.4232 eV  362.19 nm  f=0.8178  <S**2>=0.000
#      81 -> 82         0.69042
# Excited State   2:      Singlet-?Sym    3.9863 eV  311.03 nm  f=0.0685  <S**2>=0.000
#      80 -> 82         0.66979
#
# Usage:
# After changing the input parameters in the USER INPUTS block below, run this script 
# in the TRAJECTORIES directory. It will generate two output files:
# * find_osc.dat - Two columns with time-step and mean oscillator strength
# * find_osc.log - Log information
#
# MB 2020-02-04
#
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
#     USER INPUTS:
#
$traji=1;    # Initial trajectory
$trajf=500;  # Final trajectory

$stepi=0;    # Initial step
$stepf=2000; # Final step

$prog = "columbus"; # Interface program (gaussian/columbus) 
#
#     END OF USER INPUTS
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
open(DAT,">find_osc.dat") or die "Cannot write to find_osc.dat"; 
open(LOG,">find_osc.log") or die "Cannot write to find_osc.log"; 

print DAT "   step    mean\n";
print LOG "=== FIND_OSCILLATOR_IN_TRAJ ===\n\n";
print LOG "traji = $traji\n";
print LOG "trajf = $trajf\n";
print LOG "stepi = $stepi\n";
print LOG "stepf = $stepf\n";
print LOG "prog  = $prog\n\n";

if (($prog !~ /columbus/i) and ($prog !~ /gaussian/i)){
  die "Cannot recognize prog = $prog. Please check and try again.\n";
}elsif($prog =~ /gaussian/i){
    $file = "TRAJ$traji/RESULTS/nx.log";
    open(IN,$file) or warn "Cannot open $file\n";
    while(<IN>){
      if (/dt /){
        chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
        ($gb,$gb,$dt)=split(/\s+/,$_);
	print LOG "dt    = $dt\n\n";
	last;
      }
    }
}

# Read trajectories
for ($i=$stepi;$i<=$stepf;$i++){
 $mean[$i]=0.0;
}
$nt=0;
for ($n=$traji;$n<=$trajf;$n++){
  if ($prog =~ /columbus/i){
    $file="TRAJ$n/RESULTS/properties";
    print LOG "Reading TRAJ/$n\n";
    max_step();
    find_osc();
  }elsif($prog =~ /gaussian/i){
    $file="TRAJ$n/RESULTS/nx.log";
    print LOG "Reading TRAJ/$n\n";
    read_nxlog(); 
  }
  $nt++;
}

# Compute average
for ($i=$stepi;$i<=$stepf;$i++){
 $mean[$i]=$mean[$i]/$nt;
 printf DAT "%5d %9.3f\n",$i,$mean[$i];
}

# %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
sub max_step{
  open(IN,$file) or warn "Cannot open $file\n";
  while(<IN>){
    if  (/TIME /){
      chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
      ($gb,$gb,$gb,$gb,$stpf)=split(/\s+/,$_);
    }
  }
  close(IN);
  print LOG "Read until step = $stpf\n";
}
# %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
sub find_osc{
  open(IN,$file) or warn "Cannot open $file\n";
  for ($i=$stepi;$i<=$stpf;$i++){
    while(<IN>){
      if  (/TIME /){
        chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
        ($gb,$gb,$gb,$gb,$step,$gb,$gb,$state)=split(/\s+/,$_);
	if ($step == $i){
          if ($state != 1){
            $_=<IN>;
            $_=<IN>;
            chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
            ($gb,$gb,$gb,$gb,$fosc)=split(/\s+/,$_);
	    $fosc=abs($fosc);
          }elsif($state == 1){
            $fosc=0.0;
          }
	  print LOG "TRAJ $n STEP $i STATE = $state FOSC = $fosc\n";
	  $mean[$i]=$mean[$i]+$fosc;
	  last;
	}
      }
    }
  }
  close(IN); 
  if ($stpf < $stepf){
    for ($i=$stpf+1;$i<=$stepf;$i++ ){
       $mean[$i]=$mean[$i]+0;
    }
  }
}
# %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
sub read_nxlog{
  open(IN,$file) or warn "Cannot open $file\n";
  while(<IN>){
    if (/Excited State /){
      chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
      (@grb)=split(/\s+/,$_);
      ($st)=split(/:/,$grb[2]);
      $st=$st+1;
      ($gb,$f[$st])=split(/=/,$grb[8]);
    }elsif(/FINISHING STEP /){
      chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
      (@grb)=split(/\s+/,$_);
      ($time)=$grb[4];
      $i=int($time/$dt);
      $state=$grb[8];
      print LOG "TRAJ $n STEP $i STATE = $state FOSC = $f[$state]\n";
      $mean[$i]=$mean[$i]+$f[$state]; 
      if ($i >= $stepf){
	last;
      } 
    }
  }
  close(IN);
}
# %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
