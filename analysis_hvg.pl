#!/usr/bin/perl -w
#
# analysis_hvg.pl reads the output of get_geoms_in_dyn
# to get a list of hopping times and uses this info to 
# collect h12, v, g1, and g2 in the ensemble of trajectories.
# The program then computes gred, p, and L and the projections 
# of all these vectors on h12. 
#
# Run: analisys_hvg.pl < <inp-file> in TRAJECTORIES.
# <inp-file> is the log file from get_geom_in_dyn prgram.
#
# Resuslts are written to analysis-hvg.log.
#
# MB 2020-12-26
#
open(LOG,">analysis-hvg.log") or die "Cannot open analysis-hvg.log";
print LOG "==== ANALYSIS HVG ===\n\n";
open(DAT,">analysis-hvg.dat") or die "Cannot open analysis-hvg.dat";
print DAT "    N   TRAJ  TIME      DE       COSVH     COSGH     COSGiH    COSGjH    COSPH     COSLH     COSGRH\n";

$amu2au = 1822.888515;
$type = "before"; # "before"/"after" for choosing v before or after hopping

($nat,$dt)=parameters();
print LOG "NAT = $nat\nDT = $dt\nTYPE = $type\n\n";
$eps = $dt/100;

$k=0;
while(<STDIN>){
  #Looking for lines like:
  #TRAJ:     1  TIME:    93.00 (fs)  PES_I:   2 PES_F:   1 DE:     0.82 (eV) -> POSITIVE MATCH:     1
  #TRAJ:     2  TIME:   109.40 (fs)  PES_I:   2 PES_F:   1 DE:     0.15 (eV) -> POSITIVE MATCH:     7
  if (/TRAJ:/){
     chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
     ($gb,$traj,$gb,$time,$gb,$gb,$si,$gb,$sj,$gb,$de)=split(/\s+/,$_);
     $k++;

     #order states
     if ($si > $sj){
       $is=$sj;
       $js=$si;
     }elsif($si<$sj){
       $is=$si;
       $js=$sj;
     }

     $step = int($time/$dt);
     print LOG "TRAJ = $traj  TIME = $time  STEP = $step  IS = $is  JS = $js  DE = $de\n";
     print "TRAJ = $traj  TIME = $time  STEP = $step  IS = $is  JS = $js  DE = $de\n";
     
     #read quantities
     $dir="TRAJ$traj/RESULTS";
     if (!-s $dir){
       print "Cannot find $dir\n";
     }else{
       if ($type eq "after"){
         find_v_in_traj();
       }elsif($type eq "before"){
         find_vb_in_traj();
       }
       find_r_in_traj();
       find_gk_in_traj();
       find_gj_in_traj();
       calc_g();
       find_h_in_traj();
       calc_momenta();
       projections();
     }
  }
}
close(LOG);
# %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
sub parameters{
  my ($nat,$dt);
  open(INP,"TRAJ1/RESULTS/nx.log") or die "Cannot find TRAJ1/RESULTS/nx.log"; 
  while(<INP>){
    if (/Nat       =/i){
      chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
      ($gb,$gb,$nat)=split(/\s+/,$_);
    }elsif(/dt        =/i){
      chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
      ($gb,$gb,$dt)=split(/\s+/,$_); 
      last;
    }
  }
  close(INP);
  return $nat,$dt;
}
# %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
sub find_v_in_traj{
    for ($i=0;$i<=$nat-1;$i++){
      $v[$i][0]=0;
      $v[$i][1]=0;
      $v[$i][2]=0;
    }
    $file1="$dir/dyn.out";
    open(F1,$file1) or warn "Cannot open $file1";
    while(<F1>){
      #Looking for lines like:
      #STEP        1    Molecular dynamics on state  2    TIME =       0.10 fs
      if (/STEP  /){
        chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
        @a=split(/\s+/,$_);
	if ($time == $a[9]){
	  while(<F1>){
	    if (/New velocity:/){
	      # Read velocity
	      print LOG "v:\n";
	      for ($i=0;$i<=$nat-1;$i++){
	        $_=<F1>;
                chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
                ($v[$i][0],$v[$i][1],$v[$i][2])=split(/\s+/,$_);
		printf LOG "%12.6f %12.6f %12.6f\n",$v[$i][0],$v[$i][1],$v[$i][2];
	      }
    	      last;
	    }
	  }
	}
      }
    }
    close(F1);
}
# %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
sub find_vb_in_traj{
    my ($n);
    for ($i=0;$i<=$nat-1;$i++){
      $v[$i][0]=0;
      $v[$i][1]=0;
      $v[$i][2]=0;
    }
    $file1="$dir/sh.out";
    open(F1,$file1) or warn "Cannot open $file1";
    $n=0;
    while(<F1>){
      if (/v\.h/){
	 $n++;
	 if ($n > 1){
	   $_=<F1>;
           chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
	   @a=split(/\s+/,$_);
	   #print "$a[1] == $step\n";
	   if ( abs($a[1] - $step) < $eps){
	      #print "FOUND: $a[1] == $step\n";  
              while(<F1>){
	        if (/Velocity before hopping/){
                  # Read velocity
                  print LOG "v:\n";
                  for ($i=0;$i<=$nat-1;$i++){
                    $_=<F1>;
                    chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
                    ($v[$i][0],$v[$i][1],$v[$i][2])=split(/\s+/,$_);
                    printf LOG "%12.6f %12.6f %12.6f\n",$v[$i][0],$v[$i][1],$v[$i][2];
                  }
                  last;
	        }
 	      }
	      last;
  	   }
        }
      }
    }
    close(F1);
}
# %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
sub find_r_in_traj{
    for ($i=0;$i<=$nat-1;$i++){
      $r[$i][0]=0;
      $r[$i][1]=0;
      $r[$i][2]=0;
      $M[$i]=0;
    }
    $file1="$dir/dyn.out";
    open(F1,$file1) or warn "Cannot open $file1";
    while(<F1>){
      #Looking for lines like:
      #STEP        1    Molecular dynamics on state  2    TIME =       0.10 fs
      if (/STEP  /){
        chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
        @a=split(/\s+/,$_);
        if ($time == $a[9]){
          while(<F1>){
            if (/New geometry:/){
              # Read geometry
              print LOG "r:\n";
              for ($i=0;$i<=$nat-1;$i++){
                $_=<F1>;
                chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
                ($gb,$gb,$r[$i][0],$r[$i][1],$r[$i][2],$M[$i])=split(/\s+/,$_);
                printf LOG "%12.6f %12.6f %12.6f  %12.6f\n",$r[$i][0],$r[$i][1],$r[$i][2],$M[$i];
		$M[$i]=$M[$i]*$amu2au;
              }
              last;
            }
          }
        }
      }
    }
    close(F1);
}
# %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
sub find_gk_in_traj{
    my ($i);
    for ($i=0;$i<=$nat-1;$i++){
      $gk[$i][1]=0;
      $gk[$i][2]=0;
      $gk[$i][3]=0;
    }
    # print LOG "Looking for gradient $is\n";
    $file2="$dir/nx.log";
    open(F2,$file2) or warn "Cannot open $file2";
    while(<F2>){
      #Looking for lines like:
      # FINISHING STEP 0, TIME 0.0000 fs on SURFACE 2
      if (/ FINISHING STEP/){
        chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
        @a=split(/\s+/,$_);
	# print LOG "$time == ",$a[4]+$dt,"\n";
	if ( abs($time - ($a[4]+$dt) ) < $eps ){
	  # print LOG "FOUND: $time == ",$a[4]+$dt,"\n";
          while(<F2>){
            if (/Gradient for state/){
              chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
              @a=split(/\s+/,$_);
              if ($a[3] == $is){
		# Read gradient ks
		print LOG "gk:\n";
                for ($i=0;$i<=$nat-1;$i++){
                  $_=<F2>;
                  chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
                  ($gk[$i][0],$gk[$i][1],$gk[$i][2])=split(/\s+/,$_);
		  printf LOG "%12.6f %12.6f %12.6f\n",$gk[$i][0],$gk[$i][1],$gk[$i][2];
                }
		last;
	      }
	    }
          }
        }
      }
    }
    close(F2);
}
# %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
sub find_gj_in_traj{
    my ($i);
    for ($i=0;$i<=$nat-1;$i++){
      $gj[$i][1]=0;
      $gj[$i][2]=0;
      $gj[$i][3]=0;
    }
    #print LOG "Looking for gradient $js\n";
    $file2="$dir/nx.log";
    open(F2,$file2) or warn "Cannot open $file2";
    while(<F2>){
      #Looking for lines like:
      # FINISHING STEP 0, TIME 0.0000 fs on SURFACE 2
      if (/ FINISHING STEP/){
        chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
        @a=split(/\s+/,$_);
        # print LOG "$time == ",$a[4]+$dt,"\n";
        if ( abs($time - ($a[4]+$dt) ) < $eps ){
          # print LOG "FOUND: $time == ",$a[4]+$dt,"\n";
          while(<F2>){
            if (/Gradient for state/){
              chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
              @a=split(/\s+/,$_);
              if ($a[3] == $js){
                # Read gradient ks
                print LOG "gj:\n";
                for ($i=0;$i<=$nat-1;$i++){
                  $_=<F2>;
                  chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
                  ($gj[$i][0],$gj[$i][1],$gj[$i][2])=split(/\s+/,$_);
                  printf LOG "%12.6f %12.6f %12.6f\n",$gj[$i][0],$gj[$i][1],$gj[$i][2];
                }
                last;
              }
            }
          }
        }
      }
    }
    close(F2);
}
# %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
sub calc_g{
   my ($i);
   # Compute g = gj - gk
   print LOG "g:\n";
   for ($i=0;$i<=$nat-1;$i++){
     $g[$i][0] = $gj[$i][0] - $gk[$i][0];
     $g[$i][1] = $gj[$i][1] - $gk[$i][1];
     $g[$i][2] = $gj[$i][2] - $gk[$i][2];
     printf LOG "%12.6f %12.6f %12.6f\n",$g[$i][0],$g[$i][1],$g[$i][2];
   }
   # Compute gred = (gj - gk)/sqrt(M)
   print LOG "gred:\n";
   for ($i=0;$i<=$nat-1;$i++){
     $gred[$i][0] = ($gj[$i][0] - $gk[$i][0])/sqrt($M[$i]);
     $gred[$i][1] = ($gj[$i][1] - $gk[$i][1])/sqrt($M[$i]);
     $gred[$i][2] = ($gj[$i][2] - $gk[$i][2])/sqrt($M[$i]);
     printf LOG "%12.6f %12.6f %12.6f\n",$gred[$i][0],$gred[$i][1],$gred[$i][2];
   }
}
# %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
sub find_h_in_traj{
    for ($i=0;$i<=$nat-1;$i++){
      $h[$i][1]=0;
      $h[$i][2]=0;
      $h[$i][3]=0;
    }
    $file2="$dir/nx.log";
    open(F2,$file2) or warn "Cannot open $file2";
    while(<F2>){
      #Looking for lines like:
      # FINISHING STEP 0, TIME 0.0000 fs on SURFACE 2
      if (/ FINISHING STEP/){
        chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
        @a=split(/\s+/,$_);
        # print LOG "$time == ",$a[4]+$dt,"\n";
        if ( abs($time - ($a[4]+$dt) ) < $eps ){
          # print LOG "FOUND: $time == ",$a[4]+$dt,"\n";
          while(<F2>){
            if (/Nonadiabatic coupling vectors after phase adjustment/){
                # Read NAC vector
                print LOG "h:\n";
                for ($i=0;$i<=$nat-1;$i++){
                  $_=<F2>;
                  chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
                  ($h[$i][0],$h[$i][1],$h[$i][2])=split(/\s+/,$_);
                  printf LOG "%12.6f %12.6f %12.6f\n",$h[$i][0],$h[$i][1],$h[$i][2];
                }
                last;
            }
          }
        }
      }
    }
    close(F2);
}
# %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
sub calc_momenta{
  #Linear momentum
  for ($i=0;$i<=$nat-1;$i++){
    $p[$i][0]=$M[$i]*$v[$i][0];
    $p[$i][1]=$M[$i]*$v[$i][1];
    $p[$i][2]=$M[$i]*$v[$i][2];
  }
  print LOG "p:\n";
  for ($i=0;$i<=$nat-1;$i++){
     printf LOG "%12.6f %12.6f %12.6f\n",$p[$i][0],$p[$i][1],$p[$i][2];
  }
  #Center of mass position and velocity
  $MT=0.0;
  $rcm[0]=0.0;
  $rcm[1]=0.0;
  $rcm[2]=0.0;
  $vcm[0]=0.0;
  $vcm[1]=0.0;
  $vcm[2]=0.0;
  for ($i=0;$i<=$nat-1;$i++){
    $MT=$MT+$M[$i];
    $rcm[0]=$rcm[0]+$M[$i]*$r[$i][0];
    $rcm[1]=$rcm[1]+$M[$i]*$r[$i][1];
    $rcm[2]=$rcm[2]+$M[$i]*$r[$i][2];
    $vcm[0]=$vcm[0]+$M[$i]*$v[$i][0];
    $vcm[1]=$vcm[1]+$M[$i]*$v[$i][1];
    $vcm[2]=$vcm[2]+$M[$i]*$v[$i][2];
  }
  $rcm[0]=$rcm[0]/$MT;
  $rcm[1]=$rcm[1]/$MT;
  $rcm[2]=$rcm[2]/$MT;
  $vcm[0]=$vcm[0]/$MT;
  $vcm[1]=$vcm[1]/$MT;
  $vcm[2]=$vcm[2]/$MT;
  $LT[0]=0.0;
  $LT[1]=0.0;
  $LT[2]=0.0;
  #Angular momentum about CM
  for ($i=0;$i<=$nat-1;$i++){
    $rc[$i][0]=$r[$i][0]-$rcm[0];
    $rc[$i][1]=$r[$i][1]-$rcm[1];
    $rc[$i][2]=$r[$i][2]-$rcm[2];
    $pc[$i][0]=$M[$i]*$v[$i][0]-$MT*$vcm[0];
    $pc[$i][1]=$M[$i]*$v[$i][1]-$MT*$vcm[1];
    $pc[$i][2]=$M[$i]*$v[$i][2]-$MT*$vcm[2];
    $L[$i][0]=$rc[$i][1]*$pc[$i][2]-$rc[$i][2]*$pc[$i][1];
    $L[$i][1]=$rc[$i][2]*$pc[$i][0]-$rc[$i][0]*$pc[$i][2];
    $L[$i][2]=$rc[$i][0]*$pc[$i][1]-$rc[$i][1]*$pc[$i][0];
    $LT[0]=$LT[0]+$L[$i][0];
    $LT[1]=$LT[1]+$L[$i][1];
    $LT[2]=$LT[2]+$L[$i][2];
  }
  print LOG "L:\n";
  for ($i=0;$i<=$nat-1;$i++){
     printf LOG "%12.6f %12.6f %12.6f\n",$L[$i][0],$L[$i][1],$L[$i][2];
  }
  printf LOG "Total L:\n%12.6f %12.6f %12.6f\n",$LT[0],$LT[1],$LT[2];
}
# %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
sub projections{
  # v.h
  $vdoth=0;
  for ($i=0;$i<=$nat-1;$i++){
    $vdoth=$vdoth+$v[$i][0]*$h[$i][0]+$v[$i][1]*$h[$i][1]+$v[$i][2]*$h[$i][2];
  }

  $vv=0;
  for ($i=0;$i<=$nat-1;$i++){
    $vv=$vv+$v[$i][0]*$v[$i][0]+$v[$i][1]*$v[$i][1]+$v[$i][2]*$v[$i][2];
  }

  $hh=0;
  for ($i=0;$i<=$nat-1;$i++){
    $hh=$hh+$h[$i][0]*$h[$i][0]+$h[$i][1]*$h[$i][1]+$h[$i][2]*$h[$i][2];
  }
  
  $cosvh=$vdoth/(sqrt($vv*$hh));

  # g.h
  $gdoth=0;
  for ($i=0;$i<=$nat-1;$i++){
    $gdoth=$gdoth+$g[$i][0]*$h[$i][0]+$g[$i][1]*$h[$i][1]+$g[$i][2]*$h[$i][2];
  }

  $gg=0;
  for ($i=0;$i<=$nat-1;$i++){
    $gg=$gg+$g[$i][0]*$g[$i][0]+$g[$i][1]*$g[$i][1]+$g[$i][2]*$g[$i][2];
  }

  $cosgh=$gdoth/(sqrt($gg*$hh));

  # gk.h
  $gkdoth=0;
  for ($i=0;$i<=$nat-1;$i++){
    $gkdoth=$gkdoth+$gk[$i][0]*$h[$i][0]+$gk[$i][1]*$h[$i][1]+$gk[$i][2]*$h[$i][2];
  }

  $gkgk=0;
  for ($i=0;$i<=$nat-1;$i++){
    $gkgk=$gkgk+$gk[$i][0]*$gk[$i][0]+$gk[$i][1]*$gk[$i][1]+$gk[$i][2]*$gk[$i][2];
  }

  $cosgkh=$gkdoth/(sqrt($gkgk*$hh));

  # gj.h
  $gjdoth=0;
  for ($i=0;$i<=$nat-1;$i++){
    $gjdoth=$gjdoth+$gj[$i][0]*$h[$i][0]+$gj[$i][1]*$h[$i][1]+$gj[$i][2]*$h[$i][2];
  }

  $gjgj=0;
  for ($i=0;$i<=$nat-1;$i++){
    $gjgj=$gjgj+$gj[$i][0]*$gj[$i][0]+$gj[$i][1]*$gj[$i][1]+$gj[$i][2]*$gj[$i][2];
  }

  $cosgjh=$gjdoth/(sqrt($gjgj*$hh));

  # p.h
  $pdoth=0;
  for ($i=0;$i<=$nat-1;$i++){
    $pdoth=$pdoth+$p[$i][0]*$h[$i][0]+$p[$i][1]*$h[$i][1]+$p[$i][2]*$h[$i][2];
  }

  $pp=0;
  for ($i=0;$i<=$nat-1;$i++){
    $pp=$pp+$p[$i][0]*$p[$i][0]+$p[$i][1]*$p[$i][1]+$p[$i][2]*$p[$i][2];
  }

  $cosph=$pdoth/(sqrt($pp*$hh));

  # L.h
  $Ldoth=0;
  for ($i=0;$i<=$nat-1;$i++){
    $Ldoth=$Ldoth+$L[$i][0]*$h[$i][0]+$L[$i][1]*$h[$i][1]+$L[$i][2]*$h[$i][2];
  }

  $LL=0;
  for ($i=0;$i<=$nat-1;$i++){
    $LL=$LL+$L[$i][0]*$L[$i][0]+$L[$i][1]*$L[$i][1]+$L[$i][2]*$L[$i][2];
  }

  $cosLh=$Ldoth/(sqrt($LL*$hh));
  
  # gred.h
  $grdoth=0;
  for ($i=0;$i<=$nat-1;$i++){
    $grdoth=$grdoth+$gred[$i][0]*$h[$i][0]+$gred[$i][1]*$h[$i][1]+$gred[$i][2]*$h[$i][2];
  }

  $grgr=0;
  for ($i=0;$i<=$nat-1;$i++){
    $grgr=$grgr+$gred[$i][0]*$gred[$i][0]+$gred[$i][1]*$gred[$i][1]+$gred[$i][2]*$gred[$i][2];
  }

  $cosgrh=$grdoth/(sqrt($grgr*$hh));

  printf DAT "%5d %5d %8.3f %8.3f %9.4f %9.4f %9.4f %9.4f %9.4f %9.4f %9.4f\n",$k,$traj,$time,$de,$cosvh,$cosgh,$cosgkh,$cosgjh,$cosph,$cosLh,$cosgrh;
}
# %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
