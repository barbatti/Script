#!/usr/bin/env perl
#
#
$cm2au=4.55633539E-6;

$imax = 3;

$f[1]=$cm2au*345.96;
$f[2]=$cm2au*956.41;
$f[3]=$cm2au*1330.32;
#$f[4]=$cm2au*1468.85;
#$f[5]=$cm2au*3704.25;
#$f[6]=$cm2au*3708.87;

$zpe = 0.00;
for ($i = 1; $i <= $imax; $i++){
  $zpe = $zpe + 0.5*$f[$i];
}

$nmax[1]=200;
$nmax[2]=200;
$nmax[3]=200;
#$nmax[4]=11;
#$nmax[5]=11;
#$nmax[6]=11;

$result="";
#for ($n[6] = 0; $n[6] <= $nmax[6]; $n[6]++){
#  for ($n[5] = 0; $n[5] <= $nmax[5]; $n[5]++){
#    for ($n[4] = 0; $n[4] <= $nmax[4]; $n[4]++){
      for ($n[3] = 0; $n[3] <= $nmax[3]; $n[3]++){
        for ($n[2] = 0; $n[2] <= $nmax[2]; $n[2]++){
          for ($n[1] = 0; $n[1] <= $nmax[1]; $n[1]++){

            $e = $zpe;
            for ($i = 1; $i <= $imax; $i++){
              $e = $e + $f[$i]*$n[$i];
            }
	    #$result = $result.sprintf("%2d %2d %2d %2d %2d %2d %12.6f\n",$n[1],$n[2],$n[3],$n[4],$n[5],$n[6],$e);
            $result = $result.sprintf("%2d %2d %2d %12.6f\n",$n[1],$n[2],$n[3],$e);

          }
        }
      }
      #    } 
    #  }
  #}

open(OUT,">microstates.dat");
print OUT $result;
close(OUT);
