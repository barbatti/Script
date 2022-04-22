#!/usr/bin/perl -w

# Collect MOLCAS results from a curve calculation
# Usage collect-molcas.pl erefras erefpt2 erefmix <ENTER>
# erefras = RASSCF energy base (au) to compute DE in eV
# erefpt2 = CASPT2 energy base (au) to compute DE in eV
# erefmix = mixed-state energy base (au) to compute DE in eV
use POSIX qw(ceil floor);

open(RAS,">collect-molcas-ras.dat") or die ":( collect-molcas-ras.dat";
open(PT2,">collect-molcas-pt2.dat") or die ":( collect-molcas-pt2.dat";
open(MIX,">collect-molcas-mix.dat") or die ":( collect-molcas-mix.dat";

$i=1;

$au2ev=27.21138386;

$erefras=0;
$erefpt2=0;
$erefmix=0;
if (defined $ARGV[0]){
  $erefras = $ARGV[0];
}
if (defined $ARGV[1]){
  $erefpt2 = $ARGV[1];
}
if (defined $ARGV[2]){
  $erefmix = $ARGV[2];
}

find_energy();

# .............................

sub find_energy{
  collect_erasscf();
  if ($field == 5){
    collect_ecaspt2();
  }else{
    collect_ecaspt276();
  }
  if ($field == 5){
    collect_emix();
  }else{
    collect_emix76();
  }
}

# ..............................

sub collect_erasscf{
  $ist=0;
  open(ML,"molcas.log") or warn ":( molcas.log";
  while(<ML>){
    if (/root number /){
       chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
       @g=split(/\s+/,$_);
       if (/energy:/){
         $field = 7;   # Molcas 8
         $fd2=4; 
       }elsif(/energy =/){
         $field = 8;   # Molcas 7.6
         $fd2=4;
       }elsif(/E =/){
         $field = 5;   # Old Molcas
         $fd2=2;
       }
       if (!defined $ARGV[0]){
         if ($g[$fd2]==1){
           $erefras=sprintf("%14.7f",$g[$field]);
           print "RAS reference: $erefras\n";
         }
       }
       $eras[$ist]=sprintf("%14.7f",$g[$field]);
       $erasev[$ist]=sprintf("%8.3f",-($erefras-$eras[$ist])*$au2ev);
       
       $ist++;
    }
  }
  close(ML);
  printf RAS "%6d  @eras  @erasev\n",$i;
}

# ..............................

sub collect_ecaspt2{
  open(ML,"molcas.log") or warn ":( molcas.log";
  $k=0;
  $all_e="";
  $all_ev="";
  while(<ML>){
    if (/Total energy:/){
      chomp;
      $_ =~ s/^\s*//;         # remove leading blanks
      $_ =~ s/\s*$//;         # remove trailing blanks
      ($grb,$grb,$e[$k])=split(/\s+/,$_);
      if (!defined $ARGV[1]){
        if ($k == 0){
           $erefpt2=$e[0];
           print "PT2 reference: $erefpt2\n";
        } 
      }
      #print STDOUT " >>>>>>>>>>>>>>>>>>>>>>>>>>>     $k   $e[$k] \n";
      $grb=$grb;
      $e[$k]=sprintf("%14.7f",$e[$k]);
      $all_e=$all_e."   $e[$k]";
      $k++;
    }
  }
  close(ML);
  for ($n=0;$n<$k;$n++){
    $ev=sprintf("%7.3f",($e[$n]-$erefpt2)*$au2ev);
    #$ev=($e[$n]-$erefpt2)*$au2ev;
    $all_ev=$all_ev."   $ev";
  }
  printf PT2 "%6d  $all_e  $all_ev\n",$i;
  #print PT2 "$i  $all_e  $all_ev\n";
}

# ..............................

sub collect_ecaspt276{
  undef(@ept2);
  undef(@ept2ev);
  $ist=0;
  open(ML,"molcas.log") or warn ":( molcas.log";
  while(<ML>){
    if (/ CASPT2 Root/){
       chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
       @g=split(/\s+/,$_);
       $ept2[$ist]=sprintf("%14.7f",$g[6]);
       if (!defined $ARGV[1]){
         if ($ist == 0){
           $erefpt2=$ept2[0];
           print "PT2 reference: $erefpt2\n";
         } 
       }
       $ept2ev[$ist]=sprintf("%8.3f",-($erefpt2-$ept2[$ist])*$au2ev);

       $ist++;
    }
  }
  close(ML);
  printf PT2 "%6d  @ept2   @ept2ev\n",$i;
}

# ..............................

sub collect_emix76{
  undef(@emix);
  undef(@emixev);
  $ist=0;
  open(ML,"molcas.log") or warn ":( molcas.log";
  while(<ML>){
    if (/MS-CASPT2 Root/){
       chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
       @g=split(/\s+/,$_);
       $emix[$ist]=sprintf("%14.7f",$g[6]);
       if (!defined $ARGV[2]){
         if ($ist == 0){
           $erefmix=$emix[0];
           print "MIX reference: $erefmix\n";
         } 
       }
       $emixev[$ist]=sprintf("%8.3f",-($erefmix-$emix[$ist])*$au2ev);

       $ist++;
    }
  }
  close(ML);
  printf MIX "%6d  @emix   @emixev\n",$i;
}

# ..............................

sub collect_emix{
  $ncol=5;
  open(ML,"molcas.log") or warn ":( molcas.log";
  while(<ML>){
    if (/Number of CI roots used/){
       @g=split(/\s+/,$_);
       $nstmix=$g[6];
      # print STDOUT "\nNumber of mixed states: $nstmix \n"; 
       $q=$nstmix/$ncol;
       $nl=ceil($q);
      # print STDOUT "Number of lines to be read: $nl\n";
    }
  }
  close(ML);
  open(ML,"molcas.log") or warn ":( molcas.log";
  while(<ML>){
    if (/Energies and eigenvectors:/){
       $_=<ML>;
       $nmax=-1;
       if ($nl > 1){
          for ($il=1;$il<=$nl-1;$il++){
             $i0=($il-1)*$ncol;
             $_=<ML>;
             chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
             @g=split(/\s+/,$_);
             if (!defined $ARGV[2]){
               if ($il == 1){
                 $erefmix = $g[0];
                 print "MIX reference: $erefmix\n";
               }
             }
             for ($k=0;$k<=$ncol-1;$k++){
                $emix[$i0+$k]=sprintf("%14.7f",$g[$k]);
                $emixev[$i0+$k]=sprintf("%8.3f",-($erefmix-$emix[$i0+$k])*$au2ev);
                $nmax=$i0+$k;
                #print  "$i  $k  $i0  $nmax   $emix[$i0+$k] \n";
             }
             for ($k=1;$k<=$nstmix+2;$k++){
                $_=<ML>;
             }
          }
       }
       $_=<ML>;
       chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
       @g=split(/\s+/,$_);
       if ($nl == 1){
         if (!defined $ARGV[2]){
            $erefmix = $g[0];
            print "MIX reference: $erefmix\n";
         }
       }
       $rem=$nstmix-$ncol*($nl-1);
       for ($k=1;$k<=$rem;$k++){
          #$emix[$nmax+$k]=$g[$k-1];
          $emix[$nmax+$k]=sprintf("%14.7f",$g[$k-1]);
          #$emixev[$nmax+$k]=-($erefmix-$emix[$nmax+$k])*$au2ev;
          $emixev[$nmax+$k]=sprintf("%8.3f",-($erefmix-$emix[$nmax+$k])*$au2ev);
          #print  "$i  $k   $nmax   $emix[$nmax+$k] \n";
       }
    }
  }
  close(ML);
  #print MIX "$i   @emix    @emixev\n";
  printf MIX "%6d   @emix    @emixev\n",$i;
}

# ..............................

