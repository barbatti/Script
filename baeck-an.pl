#!/usr/bin/perl -w
# BAECK-AN MODEL
# MB 2021-01-14
#

#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
$smooth = 1;    # 0 - direct numerical derivative
                # 1 - analytical derivative of quadratic regression 

$clean  = 0.1;  # If |vdoh(t)| - |vdoth(t-Dt)| > clean, vdoh(t) = vdoh(t-Dt)
                # 0.01 au is a reasonable value

$traji = 1;      # Initial trajectory
$trajf = 500;    # Final trajectory

$lvprt = 1;    # print level (1-normal or 2-debug)

#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

$au2fs = 24.188843265E-3;

$ba="baeck-an";
open(DAT,">$ba.dat") or die "Cannot write $ba.dat";
open(LOG,">$ba.log") or die "Cannot write $ba.log";
print LOG " ========= BAECK-AN MODEL =======\n\n";

print LOG "SMOOTH = $smooth\n";
print LOG "CLEAN  = $clean\n";
print LOG "TRAJI  = $traji\n";
print LOG "TRAJF  = $trajf\n";
print LOG "LVPRT  = $lvprt\n";

for ($tj=$traji;$tj<=$trajf;$tj++){ 

  if ($lvprt == 2){print LOG "\nTRAJECTORY = $tj\n";}
  read_traj();

  for ($ns=0; $ns<=$nstepmax; $ns++){
    baeck_an();
    print DAT sprintf("%4d ",$tj),sprintf("%8.2f",$t[$ns])," $nac\n";
  }

}

for ($k=2 ; $k<=$nstat; $k++){
  for ($j=1; $j<=$k-1; $j++){
    $rmsd = sqrt($mse[$j][$k]/$nmse[$j][$k]);
    print LOG "RMSD of ($j,$k) over $nmse[$j][$k] estimates is: $rmsd\n";
  }
}

close(DAT);
close(LOG);

# %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
sub read_traj{
 
 #Number of states
 open(IN,"TRAJ$tj/RESULTS/en.dat") or die "Cannot open TRAJ$tj/RESULTS/en.dat";
 $_=<IN>;
 chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
 @grb=split(/\s+/,$_);
 $nstat=@grb-3;
 close(IN);
 if ($lvprt == 2){print LOG "NSTAT = $nstat\n";}

 if ($tj == $traji){
   for ($k=2 ; $k<=$nstat; $k++){
     for ($j=1; $j<=$k-1; $j++){
       $mse[$j][$k]=0;
       $nmse[$j][$k]=0;
     }
   }
 }

 # Read Energies
 $ns=0;
 open(IN,"TRAJ$tj/RESULTS/en.dat") or die "Cannot open TRAJ$tj/RESULTS/en.dat";
 while(<IN>){

   #E
   chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
   @grb=split(/\s+/,$_);
   $t[$ns]=$grb[0];
   for ($k=1;$k<=$nstat;$k++){
     $e[$k]=$grb[$k];  
     if ($e[$k] == $grb[$nstat+1]){
        $nstatdyn[$ns]=$k;
     }
   }

   #DE_JK
   for ($k=2 ; $k<=$nstat; $k++){
     for ($j=1; $j<=$k-1; $j++){
       $de[$ns][$j][$k]=$e[$j]-$e[$k];
       $de[$ns][$k][$j]=$e[$k]-$e[$j];
     }
   }   

   $ns++;
 }
 close(IN);

 $nstepmax = $ns-1;
 $dt = $t[1]-$t[0];

 if ($lvprt == 2){
   print LOG "TRAJECTORY = $tj\n";
   print LOG "NSTEPMAX = $nstepmax\n";
   print LOG "DT (fs) = $dt\n";
 }

 $dt = $dt/$au2fs;
 if ($lvprt == 2){print LOG "DT (au) = $dt\n";}
 # Read vdoth
 $ns=0;
 open(IN,"TRAJ$tj/RESULTS/sh.out") or die "Cannot open TRAJ$tj/RESULTS/sh.out";
 while(<IN>){
   if (/v\.h/){

     chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
     @grb=split(/\s+/,$_);
     $i=1;
     for ($k=2 ; $k<=$nstat; $k++){
       for ($j=1; $j<=$k-1; $j++){
          $vdh[$ns][$j][$k]=$grb[$i];
	  $i++;
       }
     } 
     $ns++
   }
 }
 close(IN);
}
# %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
sub baeck_an{
     $nac="";

     for ($k=2 ; $k<=$nstat; $k++){
       for ($j=1; $j<=$k-1; $j++){
          second_derivative();
	  sigma();
	  if ($lvprt == 2){
	    print LOG "traj = $tj  t = $t[$ns]  ns = $ns  jk = $j $k  sgm = $sgm[$ns][$j][$k]  vdh = $vdh[$ns][$j][$k]\n";
          }
	  $nac = $nac." ".sprintf("%9.6f",abs($sgm[$ns][$j][$k]))." ".sprintf("%9.6f",abs($vdh[$ns][$j][$k]));
	  $mse[$j][$k] = $mse[$j][$k]+ (abs($sgm[$ns][$j][$k]) - abs($vdh[$ns][$j][$k]))**2;
	  $nmse[$j][$k]++;
	  if ($lvprt == 2){print LOG "NMSE($j,$k) = $nmse[$j][$k]\n";}
       }
     } 
}
# %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
sub second_derivative{
  if ($ns == 0){
    $nreset=0;	  
  }elsif($nstatdyn[$ns] != $nstatdyn[$ns-1]){
    $nreset=0;
  }
  if ($ns-$nreset < 3){
    $d2E = 0.0; 
  }else{
    if ($smooth == 0){
      $DE0 = $de[$ns][$j][$k];
      $DE1 = $de[$ns-1][$j][$k];
      $DE2 = $de[$ns-2][$j][$k];
      $DE3 = $de[$ns-3][$j][$k];
      $d2E = 1/$dt**2*(2*$DE0-5*$DE1+4*$DE2-$DE3);
      if ($lvprt == 2){
        printf LOG "d2E : %12.9f = 1\/%9.6f**2*(2\*%9.6f -5\*%9.6f +4\*%9.6f -1*%9.6f)\n",$d2E,$dt,$DE0,$DE1,$DE2,$DE3;
      }
    }elsif($smooth == 1){
      $y[3] = $de[$ns][$j][$k];
      $y[2] = $de[$ns-1][$j][$k];
      $y[1] = $de[$ns-2][$j][$k];
      $y[0] = $de[$ns-3][$j][$k];
      #print LOG "y = @y\n";
      ($a,$b,$c,$R2)=quadratic_regression($t[$ns],$dt,@y);
      if ($lvprt == 2){
        printf LOG "a = %9.6f  b = %9.6f  c = %9.6f  R2 = %9.6f\n",$a,$b,$c,$R2;
      }
      $d2E = 2*$a;
    }
  }
}
# %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
sub sigma{
  $q = $d2E/$de[$ns][$j][$k];
  #print LOG "q = $q  d2E =  $d2E  de = $de[$ns][$j][$k]\n";
  if ($q <= 0){
    $sgm[$ns][$j][$k] = 0.0;
  }elsif($q > 0){
    $sign = abs($de[$ns][$j][$k])/$de[$ns][$j][$k];
    $sgm[$ns][$j][$k] = $sign*0.5*sqrt($q);
  }
  $Dvdh = abs($sgm[$ns][$j][$k])-abs($sgm[$ns-1][$j][$k]);
  if ($Dvdh > $clean){
    $sgm[$ns][$j][$k]=$sgm[$ns-1][$j][$k];
  }
}
# %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
sub quadratic_regression{
  my ($a,$b,$c,$R2);
  my (@y,$x,$x2,$n,$xm,$x2m,$x3m,$x4m,$ym);
  my ($Sxx,$Sxy,$Sxx2,$Sx2x2,$Sx2y);
  my ($d,$x0,$dx,$i);

  ($x0,$dx,@y)=@_;

  $n=@y;
  #print LOG "n = $n\n";

  # Mean values
  $xm  =0;
  $ym  =0;
  $x2m =0;
  $x3m =0;
  $x4m =0;
  $xym=0;
  $x2ym=0;
  for ($i=0;$i<=$n-1;$i++){
    $x   = $x0  + $i*$dx; 
    $xm  = $xm  + $x;
    $x2m = $x2m + $x**2;
    $x3m = $x3m + $x**3;
    $x4m = $x4m + $x**4;
    $ym  = $ym  + $y[$i];
    $xym = $xym + $x*$y[$i];
    $x2ym= $x2ym+ $x**2*$y[$i];
  }

  # S values
  $Sxx  = $x2m  - $xm**2/$n;
  $Sxy  = $xym  - $xm*$ym/$n;
  $Sxx2 = $x3m  - $x2m*$xm/$n;
  $Sx2y = $x2ym - $x2m*$ym/$n;
  $Sx2x2= $x4m  - $x2m**2/$n;

  # a,b,c coefficients for y = a*x**2 + b*x + c
  $d = $Sxx*$Sx2x2 - $Sxx2**2;
  $a = ($Sx2y*$Sxx  - $Sxy*$Sxx2 )/$d;
  $b = ($Sxy*$Sx2x2 - $Sx2y*$Sxx2)/$d;
  $c = $ym/$n - $b*$xm/$n - $a*$x2m/$n;

  # R2 value
  $SN = 0;
  $SD = 0;
  for ($i=0;$i<=$n-1;$i++){
    $x  = $x0 + $i*$dx; 
    $SN = $SN + ($y[$i] - $c - $b*$x - $a*$x**2)**2;
    $SD = $SD + ($y[$i] - $ym)**2
  }
  #printf LOG "SN = %9.6f  SD = %9.6f\n",$SN,$SD;
  $R2 = 1 - $SN/$SD;

  return $a,$b,$c,$R2;
}
# %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
