#!/usr/bin/perl -w

# Collect data about the seam from two-state dynamics
# typeofdyn.log file:
#Time =    1.00   Threshold=10.0   PES = 2   DE_inf =  4.73   DE_sup = -----   Type = 2   Next type = 2

# Run in trajectories
open(LG,">map_seam.log") or die "map_seam.log";
open(OP,">map_seam.dat") or die "map_seam.dat";
print OP " NT     tis     tfs     dtt    ave    si   sf  class   tfs1  ffs1    thop\n";

# Parameter inputs
$def = 1;
$question = "Enter initial trajectory ($def):";
get_par();
$traj_i = $inp;

$def = "";
$question = "Enter final trajectory:";
get_par();
$traj_f = $inp;

$def = 0.5;
$question = "Enter time step ($def fs):";
get_par();
$dt = $inp;

$def = 0.5;
$question = "Enter energy threshold ($def eV):";
get_par();
$e_thres = $inp;

$def = 1.2;
$question = "Enter max. energy threshold ($def eV):";
get_par();
$e_thres_max = $inp;

$def = 0.8;
$question = "Enter energy-deviation theshold ($def eV):";
get_par();
$dev_thres = $inp;

$def = 10.0;
$question = "Enter long/short theshold ($def fs):";
get_par();
$class_def = $inp;

# log
print LG "       Initial trajectory    = $traj_i\n";
print LG "       Final trajectory      = $traj_f\n";
print LG "       Time step             = $dt\n";
print LG "       Energy threshold      = $e_thres\n";
print LG "       Max. Energy threshold = $e_thres_max\n";
print LG "       Deviation threshold   = $dev_thres\n";
print LG "       Class threshold       = $class_def\n\n";

for ($nt=$traj_i;$nt<=$traj_f;$nt++){
  $ADD = "TRAJ$nt/RESULTS";
  if (-s "$ADD/typeofdyn.log"){
    open(TD,"$ADD/typeofdyn.log") or die "$ADD/typeofdyn.log";
    while(<TD>){
      read_TD();
      $fs[1]=0;
      $fs[2]=0;
      $thop = 0.0;
      if ($de <= $e_thres){
          print LG "\n    Crossing seam reached \n\n";
          $tis = $time; # initial time in the seam
          $si  = $surf; # initial surface
          $tfs = $time;
          $sf = $surf;
          $dtt = $tfs-$tis;
          $class = "S";
          $npoints = 1;
          $tot_e = $de;
          $av_e  = $de/$npoints;
          #$t_fs1 = $fs[1]*$dt;
          #$f_fs1 = 0;
          $t_fs2 = $fs[2]*$dt;
          $f_fs2 = 1;
          if ($surf == 1){
            #$fs[1] = $fs[1]+1; # number of points of X seam in S0
          }elsif($surf == 2){
  
            $fs[2] = $fs[2]+1; # number of points of X seam in S1
          }
          if ( ($type == 2) and ($next == 3) ){
            $thop = $time;
          }
          while(<TD>){
            read_TD();
            # still in the seam?
            $npoints++;
            $tot_e = $tot_e + $de;
            $av_e = $tot_e/$npoints;
            if ( ($de <= $e_thres_max) and ($av_e <= $dev_thres) ){
                # Yes, still in the seam
                printf LG "     Seam: DE = %6.2f    <DE> = %6.2f    npoints = %4d\n",$de,$av_e,$npoints;
                $tfs = $time;
                $sf = $surf;
                $dtt = $tfs-$tis;
                if ( ($type == 2) and ($next == 3) ){
                  $thop = $time;
                }
                if ($dtt >= $class_def){
                  $class = "L";
                }else{
                  $class = "S";
                }
                #$t_fs1 = $fs[1]*$dt;
                #$f_fs1 = $t_fs1/$dtt;
                $t_fs2 = $fs[2]*$dt;
                $f_fs2 = $t_fs2/$dtt;
                if ($surf == 1){
                  #$fs[1] = $fs[1]+1; # number of points of X seam in S0
                }elsif($surf == 2){
                  $fs[2] = $fs[2]+1; # number of points of X seam in S1
                }
            }else{
                # No, seam is gone
                print LG "\n    Crossing seam is gone (DE = $de eV, <DE> = $av_e eV) \n\n";
                printf OP "%4d %7.1f %7.1f %7.1f %6.2f %4d %4d %4s %7.1f %6.3f %7.1f\n",
                          $nt,$tis, $tfs, $dtt, $av_e,$si,$sf,$class,$t_fs2,$f_fs2,$thop;
                last;
            } # endif
          } # end while
      } # endif
    } # end while
    close(TD);
  } # endif
} # end for


close(OP);
close(LG);

sub get_par{
   print STDOUT $question;
   $_=<STDIN>;
   chomp;
   $_ =~ s/^\s*//;         # remove leading blanks
   $_ =~ s/\s*$//;         # remove trailing blanks
   if ($_ eq ""){
     $inp = $def;
   }else{
     $inp = $_;
   }
}

sub read_TD{
   chomp;
   $_ =~ s/^\s*//;         # remove leading blanks
   $_ =~ s/\s*$//;         # remove trailing blanks
   @g =split(/\s+/,$_);
   $time = $g[2];
   $surf = $g[6];
   $de_inf = $g[9];
   $de_sup = $g[12];
   $type = $g[15];
   $next = $g[19];
   if ($de_inf eq "----"){
      $de_inf = 1000;
   }
   if ($de_sup eq "----"){
      $de_sup = 1000;
   }
   if ($surf == 1){
      $de = $de_sup;
   }elsif($surf == 2){
      $de = $de_inf;
   }
   # File LG should be opened before this subroutine
   print LG "traj = $nt t = $time surf = $surf dei = $de_inf des = $de_sup types: $type, $next\n";
}
