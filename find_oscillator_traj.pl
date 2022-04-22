#!/usr/bin/perl -w
# This program reads the oscillator strengths in a set of NX trajectries and computes the mean as function of time.
# MB 2020-12-29
#
# In the current setup (NX/Columbus), it looks for these lines in properties:
# TIME (fs): 0.0000    STEP: 0    CURRENT STATE: 2
# Trans. dipole components (x,y,z) e*bohr:     0.021743     0.052228    -1.484206
# Oscillator strength (2,1) = -0.498097
#
$traji=1;
$trajf=500;
$stepi=0;
$stepf=2000;

open(DAT,">find_osc.dat") or die "Cannot write to find_osc.dat"; 
open(LOG,">find_osc.log") or die "Cannot write to find_osc.log"; 

print DAT "   step    mean\n";
print LOG "=== FIND_OSCILLATOR_IN_TRAJ ===\n\n";
print LOG "traji = $traji\n";
print LOG "trajf = $trajf\n";
print LOG "stepi = $stepi\n";
print LOG "stepf = $stepf\n\n";

for ($i=$stepi;$i<=$stepf;$i++){
 $mean[$i]=0.0;
}

$nt=0;
for ($n=$traji;$n<=$trajf;$n++){
  $file="TRAJ$n/RESULTS/properties";
  print LOG "Reading TRAJ/$n\n";
  max_step();
  find_osc();
  $nt++;
}

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
	  print LOG "TRAJ $n STEP $i FOSC = $fosc\n";
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
