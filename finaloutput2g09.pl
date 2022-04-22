#!/usr/bin/perl -w 
#
# Read final_output and write dyn-vec-i.mld
#    File            Geometry    Velocity
#    final_output    au          au
#    dyn-vec-1.mld   Ang         a0/s
#    dyn-vec-2.mld   Ang         Ang/ps
#

$au2ang=0.529177;
$au2a0sec=1/(2.418884326505E-017);
$au2angps=$au2ang*$au2a0sec*1/1E12;

&number_of_atoms();
$nat=$value;

open(FL,"final_output") or die ":( final_output";
open(DM1,">dyn-vec-1.mld") or die ":( dyn-vec-1.mld";
open(DM2,">dyn-vec-2.mld") or die ":( dyn-vec-2.mld";

$j = 0;
while(<FL>){
   if (/Geometry in/i){
     print DM1 " $nat \n";
     print DM2 " $nat \n";
     print DM1 " CARD = $j \n";
     print DM2 " CARD = $j \n";
     $j++;
     for ($i=1;$i<=$nat;$i++){
        $_=<FL>;
        chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
        @g=split(/\s+/,$_);
        $g[0]=uc($g[0]);
        $gc[2]=$g[2]*$au2ang;
        $gc[3]=$g[3]*$au2ang;
        $gc[4]=$g[4]*$au2ang;
        printf DM1 " %s  %12.6f  %12.6f  %12.6f \n",$g[0],$gc[2],$gc[3],$gc[4];
        printf DM2 " %s  %12.6f  %12.6f  %12.6f \n",$g[0],$gc[2],$gc[3],$gc[4];
     }
     print DM1 "\n0\n\n";
     print DM2 "\n0\n\n";
   }
   if (/Velocity/){
     for ($i=1;$i<=$nat;$i++){
        $_=<FL>;
        chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
        @g=split(/\s+/,$_);
        $gv[0]=$g[0]*$au2a0sec;
        $gv[1]=$g[1]*$au2a0sec;
        $gv[2]=$g[2]*$au2a0sec;
        printf DM1 " %14.7E  %14.7E  %14.7E \n",$gv[0],$gv[1],$gv[2];
        $gv[0]=$g[0]*$au2angps;
        $gv[1]=$g[1]*$au2angps;
        $gv[2]=$g[2]*$au2angps;
        printf DM2 " %14.7E  %14.7E  %14.7E \n",$gv[0],$gv[1],$gv[2];
     }
     print DM1 "\n";
     print DM2 "\n";
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
