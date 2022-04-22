#!/usr/bin/perl -w 
#
# Read final_output and write dyn.mld
#
# Geometry in COLUMBUS and NX input format:
# c     6.0    1.32844949   -0.01899889   -3.30874358   12.00000000
# c     6.0   -1.32759764    0.03819067   -3.31129652   12.00000000
# c     6.0    1.29830154    0.02991040    3.30500285   12.00000000
# c     6.0   -1.29871530   -0.02956944    3.30534052   12.00000000
# h     1.0    2.37642316   -1.88942612   -3.34600780    1.00782504
# h     1.0    2.38484288    1.67243110   -3.34281289    1.00782504
# h     1.0   -2.31023845    1.77343979   -3.34093114    1.00782504
# h     1.0   -2.45446304   -1.78475025   -3.34916809    1.00782504
# h     1.0   -2.32244215   -1.82316426    3.37345295    1.00782504
# h     1.0   -2.40366402    1.72208480    3.37230608    1.00782504
# h     1.0    2.31961502    1.82264924    3.37179552    1.00782504
# h     1.0    2.40470312   -1.72601865    3.37692366    1.00782504
# Velocity in NX input format:

$au2ang=0.529177;

&number_of_atoms();
$nat=$value;

open(FL,"final_output") or die ":( final_output";
open(DM,">dyn.mld") or die ":( dyn.mld";

$j = 0;
while(<FL>){
   if (/Geometry in/i){
     print DM " $nat \n";
     print DM " CARD = $j \n";
     $j++;
     for ($i=1;$i<=$nat;$i++){
        $_=<FL>;
        chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
        @g=split(/\s+/,$_);
        $g[0]=uc($g[0]);
        $g[2]=$g[2]*$au2ang;
        $g[3]=$g[3]*$au2ang;
        $g[4]=$g[4]*$au2ang;
        printf DM " %s  %12.6f  %12.6f  %12.6f \n",$g[0],$g[2],$g[3],$g[4];
     }
   }
}

close(FL);

sub number_of_atoms{
  open(FL,"final_output") or die ":( final_output";
  while(<FL>){
     if (/Geometry in/i){
       $value=0;
       while(<FL>){
          $value++;
          if (/velocity/i){
             $value = $value-1;
             last;
          }
       }
     }
  }
  close(FL);
}
