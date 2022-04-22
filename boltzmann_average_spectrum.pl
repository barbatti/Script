#!/usr/bin/perl -w

# Make Bolzmann average over several spectra computed for different isomers.
# Mario Barbatti, May 2010

####################################################
# This section should be changed case to case.
####################################################

# 1) List of directories contanining the isomers:
$dir[0] = "/ns80th/nas/users/barbatti/PPC/T1/SPECTRUM/INITIAL_CONDITIONS/I_merged/";
$dir[1] = "/ns80th/nas/users/barbatti/PPC/T2/SPECTRUM/I_merged/";
$dir[2] = "/ns80th/nas/users/barbatti/PPC/A1/SPECTRUM/INITIAL_CONDITIONS/I_merged/";

# 2) Read reference energy from:
$fo = "final_output.1.2";

# 3) Temperature (K):
$temp=298;

####################################################

$BK   =0.3166813639E-5; # Boltzmann constant (hartree/K)
$nm2ev=1239.841875;
$cs   ="cross-section.dat";
$log  ="boltzmann_average_spectrum.log";
$dat  ="boltzmann_average_spectrum.dat";
$out  ="boltzmann_average_spectrum.out";
$eps  =1E-8;

eps_nx();

open(LOG,">$log") or die ":( Cannot write $log";
print LOG "Boltzmann Average of Spectra\n\n";

print LOG "The following directories will be used:\n";
foreach(@dir){
  if (-s "$_/$cs"){
    print LOG "$_\n";
  }else{
    print LOG "$_/$cs\n";
    print LOG "File $cs cannot be found in $_ or is empty.\nCheck your inputs and try again.\n";
    die;
  }
  if (!-s "$_/$fo"){
    print LOG "File $fo cannot be found in $_ or is empty.\nCheck your inputs and try again.\n";
    die;
  }
}

print LOG "\nReference energies will be read from file $fo.\n";
print LOG "Temperature = $temp K.\n";

$niso=@dir;

print LOG "Number of isomers to be included in the average: $niso\n";

get_ref_e(@dir);

average_spectra(@dir);

compute_average(@dir);

close(LOG);

# ==================================================================================================

sub eps_nx{
  my ($dei,$wli,$sigmai,$dej,$wlj,$sigmaj);
  open(CS,"$dir[0]/$cs") or die "$dir[0]/$cs";
  $_=<CS>;
  chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
  ($dei,$wli,$sigmai)=split(/\s+/,$_);
  $_=<CS>;
  chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
  ($dej,$wlj,$sigmaj)=split(/\s+/,$_);
  close(CS);
  $epsnx=$dej-$dei;
}

# ==================================================================================================

sub get_ref_e{
  my ($i,$emin,$de,$path,@dir);
  @dir=@_;
  print LOG "\nReference energies:\n";
  $i=0;
  $emin=0;
  foreach(@dir){
    $path=$_;
    open(FO,"$path/$fo") or die ":( $path/$fo";
    while(<FO>){
      if (/Reference energy \(au\)/){
         chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
         @g=split(/\s+/,$_);
         $eref[$i]=$g[3];
         if ($emin > $eref[$i]){
           $emin=$eref[$i];
         }
         last;
      }
    }
    close(FO);
    $i++;
  }

  print LOG "Minimum energy: $emin hartree.\n"; 

  $Z=0;
  for ($i = 0; $i <= $niso-1 ; $i++){
     $de=$eref[$i]-$emin;
     if ($temp < $eps){
       $bfactor[$i]=1;
     }else{
       $bfactor[$i]=exp(-$de/($BK*$temp));
     }
     $Z=$Z+$bfactor[$i];
     printf LOG "Eref(%d) = %9.6f au     DE = %8.5f au     Boltzmann factor = %8.6f\n",$i,$eref[$i],$de,$bfactor[$i];
  }
  print LOG "Partition function Z($temp) = $Z\n";
  for ($i = 0; $i <= $niso-1 ; $i++){
     printf LOG "Fraction %d = %8.6f\n",$i,$bfactor[$i]/$Z;
  }
}

# ==================================================================================================

sub average_spectra{
  my ($i,$j,$de,$wl,$sigma,@line,@dir,$pt);
  @dir=@_;
  $i=0;
  $smalest_de=1000;
  $largest_de=0;
  undef(@line);
  foreach(@dir){
    open(CS,"$_/$cs") or die ":( $_/$cs";
    $j=0;
    while(<CS>){
       chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
       ($de,$wl,$sigma)=split(/\s+/,$_);
       $de=sprintf "%9.4f",$de;
       $wl=sprintf "%9.4f",$wl;
       $pt=$sigma*$bfactor[$i]/$Z;
       $pt=sprintf "%12.6f",$pt;
       if ($de<$smalest_de){
         $smalest_de=$de;
       }
       if ($de>$largest_de){
         $largest_de=$de;
       }
       if ($line[$j]){
         $line[$j]=$line[$j]."   ".$wl." ".$pt;
       }else{
         $line[$j]=$wl." ".$pt;
       }
       $j++;
    }
    close(CS);
    $i++;
  } 
  print LOG "\nAveraged spectrum will be computed between $smalest_de (eV) and $largest_de (eV).\n";
  write_dat(@line);
}

# ==================================================================================================

sub write_dat{
  my (@line);
  @line=@_;
  open(DAT,">$dat") or die "Cannot write to $dat";
  foreach(@line){
    print DAT "$_\n";
  }
  close(DAT);
}

# ==================================================================================================

sub compute_average{
  my ($wl,$i,$e,@dir);
  @dir=@_;
  open(OUT,">$out") or die ":( $out";
  for ($e = $smalest_de ; $e <= $largest_de ; $e = $e + $epsnx){
     printf "Computing %9.4f ...\n",$e;
     $sigma_t=0;
     for ($i = 0 ; $i <= $niso-1 ; $i++){
       $sigma=sigma_ip($i,$e);
       $sigma_t=$sigma_t+$sigma*$bfactor[$i];
     }
     $wl=$nm2ev/$e;
     $sigma_t=$sigma_t/$Z;
     printf OUT "%8.4f %10.4f %12.6f\n",$e,$wl,$sigma_t;
  }
  close(OUT);
}

# ==================================================================================================

sub sigma_ip{
  my ($dei,$wli,$sigmai,$dej,$wlj,$sigmaj,$wl,$sigma,$i,$e);
  ($i,$e)=@_;
  $sigma=0;
  open(CS,"$dir[$i]/$cs") or die ":( $dir[$i]/$cs";
  while(<CS>){
    chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
    ($dei,$wli,$sigmai)=split(/\s+/,$_);
    if ($e-$dei < $epsnx){
       $_=<CS>;
       if ($_){
         chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
         ($dej,$wlj,$sigmaj)=split(/\s+/,$_);
         $sigma=1/($dei-$dej)*($sigmaj*$dei-$sigmai*$dej+($sigmai-$sigmaj)*$e);
       }
       last;
    }
  }
  close (CS);
  
  return $sigma;
}

# ==================================================================================================
  
