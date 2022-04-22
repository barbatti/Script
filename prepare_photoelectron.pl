#!/usr/bin/perl -w


$f_ips="ips.dat";  # file with IPs
$f_log="prepare_photoelectron.log";
$fo="final_output.1.";
$dir="NEW_FILES";

open(LOG,">$f_log") or die ":( $f_log";
print LOG "====== START PHOTOELECTRON SIMULATION ======\n\n";

read_inputs();
create_dir();
read_ips();
read_vexc();
loop_over();

print LOG "\n\n======= END PHOTOELECTRON SIMULATION =======\n\n";
close(LOG);

# ===================================================================================
sub read_inputs{
  print LOG "\n Starting reading inputs ...\n";
  $q="Energy window for matching quantum numbers (gauss = 0.1 eV): ";
  $Delta=question($q,"0.1");
  print LOG " Delta = $Delta\n";  
  $q="Number of excited states (Default = 1): ";
  $jmax=question($q,"1");
  print LOG " jmax = $jmax\n";
  check_files();  
}
# ===================================================================================
sub check_files{
  $end=0;
  for ($j=1;$j<=$jmax;$j++){
    $k=$j+1;
    $fok=$fo.$k;
    if (!-s "$fok"){
       print LOG "Cannot find $fok or it is empty.\n";
       $end++;
    }
  }
  if ($end > 0){
    die "Missing files. Check $f_log.\n\n";
  }
}
# ===================================================================================
sub create_dir{
  if (-e $dir){
    die "$dir exists. Delete it and run again.\n\n"
  }else{
    mkdir($dir) or die "Cannot create $dir!";
    print LOG " Files will be written to $dir.\n";
  }
}
# ===================================================================================
sub read_ips{
  open(IPS,$f_ips) or die "Cannot find file $f_ips with IP_n information.\n";
  print LOG "\n Starting reading IP_n ...\n";
  $n=0;
  while(<IPS>){
     chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
     $ip[$n]=$_;
     printf LOG "  IP %5d    %16.8f  eV\n",$n,$ip[$n];
     $n++;
  }
  $nmax=$n-1;
  print LOG "  NMAX = $nmax\n\n";
  close(IPS);
}
# ===================================================================================
sub read_vexc{
  print LOG " Getting $jmax vertical excitations:\n";
  for ($j=1;$j<=$jmax;$j++){
    $k=$j+1;
    $l=$j-1;
    $fok=$fo.$k;
    print LOG " File $fok\n";
    open(FO,"$fok") or die ":( $fok";
    while(<FO>){
      if (/Equilibrium geometry/){
        while(<FO>){
          if (/Vertical excitation/){
            $vexc[$l] = get_energy($_);
            printf LOG " Vertical energy %4d = %8.4f (eV)\n",$j,$vexc[$l];
            last;
          }
        }
      }
    }
    close(FO);
  }
}
# ===================================================================================
sub loop_over{
  for ($n=0;$n<=$nmax-1;$n++){
    $matches[$n]=0;
    $n1=$n+1;
    $n2=$n+2;
    #@string=();
    @SUM=(0)x@SUM;
    @SUM_E=(0)x@SUM_E;
    $indmax=0;
    for ($j=0;$j<=$jmax-1;$j++){
       $j1=$j+1;
       $j2=$j+2;
       if (($vexc[$j]>=($ip[$n]-$Delta)) and 
           ($vexc[$j]<=($ip[$n]+$Delta))){
           print LOG " State $j1 matches IP$n1\n";
           $matches[$n]++;
           $foj=$fo.$j2;
           open(FO,"$foj") or die ":( $foj";
           read_fo();           
           close(FO);
       }
    }
    print LOG " ==== $matches[$n] states matches IP$n1 =====\n";
    if ($matches[$n] > 0){
       write_new_files();
    }
  }
}
# ===================================================================================
sub read_fo{
  while(<FO>){
    if (/Initial condition =/){
      $ind = get_index($_);
      if ($ind > $indmax){
        $indmax=$ind;
      }
      if (!defined $SUM_E[$ind]){
        $SUM_E[$ind]=0;
      }
      if (!defined $SUM[$ind]){
        $SUM[$ind]=0;
      }
      while(<FO>){
        if (/Vertical excitation/){
           $de = get_energy($_);
           $SUM_E[$ind]=$SUM_E[$ind]+$de;
           # $string[$ind]=$string[$ind]." + ".$de;
        }
        if (/Oscillator strength/i){
           $os = get_oscillator($_);
           $SUM[$ind]=$SUM[$ind]+sqrt($os/$de);
           last;
        }
      }
    }
  }
}
# ===================================================================================
sub write_new_files{
  $nf="$dir/$fo".$n2;
  open(NF,">>$nf") or die ":( $NF";
  for ($ind=1;$ind<=$indmax;$ind++){
    #print LOG "Energies: $string[$ind] = $SUM_E[$ind]\n";
    print NF " Initial condition = $ind\n";
    print NF " Geometry in COLUMBUS and NX input format:\n";
    print NF " Velocity in NX input format:\n";
    print NF " Epot of initial state (eV):    0.0000  Epot of final state (eV):      0.0000\n";
    #printf NF " Vertical excitation (eV):   %8.4f  Is Ev in the required range? YES\n",$SUM_E[$ind]/$matches[$n];
    printf NF " Vertical excitation (eV):   %8.4f  Is Ev in the required range? YES\n",$ip[$n];
    print NF " Ekin of initial state (eV):    0.0000  Etot of initial state (eV):    0.0000\n";
    printf NF " Oscillator strength:        %8.4f\n\n",$ip[$n]*abs($SUM[$ind])**2;
  }
  close(NF);
  system("cp $nf $dir/final_output");
}
# ===================================================================================
sub get_energy{
  # Get energy in the line:
  # "Vertical excitation";

  my ($de,@g);

  ($_)=@_;
  chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
  @g=split(/\s+/,$_);
  $de=abs($g[3]);
  if ($de < 0.001){
    $de = 0.001;
  }
  return $de;

}
# ===================================================================================
sub get_oscillator{
  # Get oscillator strength in the line:
  # "Oscillator strength:"

  my ($os,$grb);

  ($_)=@_;
  chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
  ($grb,$grb,$os)=split(/\s+/,$_);
  return $os;

}
# ===================================================================================
sub get_index{
  my ($i,$a,@g);
  ($a)=@_;
  chomp($a);$a =~ s/^\s*//;$a =~ s/\s*$//;
  @g=split(/\s+/,$a);
  $i=$g[3];
  return $i;
}
# ===================================================================================
sub question{
  my ($q,$def,$answer);
  ($q,$def)=@_;
  print STDOUT " $q";
  $_=<STDIN>;
  chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
  if ($_ eq ""){
    $answer = $def;
  }else{
    $answer=$_;
  }
  print LOG " $q  $answer \n";
  return $answer;
}
# ===================================================================================

