#!/usr/bin/perl -w

# This program reads sh.out, for instance:
# ...
#|v.h|=     0.000107    0.000150   -0.003645
#       21        2     3    0.000000058    1.000000000
#                            0.004071035
#                            0.995928907
#|v.h|=     0.000110    0.000249   -0.003934
#       41        3     3    0.000000261    1.000000000
#                            0.010969606
#                            0.989030132
# ...
# and writes:
# ...
# 21  0.000107    0.000150   -0.003645
# 41  0.000110    0.000249   -0.003934
# ...
# to collected_vdoth.dat
#

$log="collected_vdoth.dat";
$so="sh.out";

if (!-s $so){
  die ":( $so";
}

open(SO,$so) or die ":( $so";
open(LOG,">$log") or die ":( $log";

$n=0;
while(<SO>){
  if (/v\.h/){
     chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
     ($g,$vdoth)=split(/=/,$_);
     if ($n == 0){
       while(<SO>){
         if (/substep/){
           $_=<SO>;
           chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
           ($step,$sub,$surf,$g)=split(/\s+/,$_);
           last;
         }
       }
     }else{
       $_=<SO>;
       chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
       ($step,$sub,$surf,$g)=split(/\s+/,$_);
     }
     print LOG "$n   $step   $sub   $surf   $vdoth\n";
     $n++;
  }
}

close(LOG);
close(SO);

