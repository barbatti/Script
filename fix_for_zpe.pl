#!/usr/bin/perl -w

use lib join('/',$ENV{"NX"},"CPAN") ;
use colib_perl;

$au2ev = units("au2ev");

$file="fix_for_zpe.inp";

open(LOG,">fix_for_zpe.log") or die ":( fix_for_zpe.log";

if (!-s "$file") {die "Create $file first";}

$fo  = getkeyword($file,"FO" ,"final_output");    # final_output file to be checked
$zpe = getkeyword($file,"ZPE","0.0");             # Excited-state ZPE in hartree
$uf0 = getkeyword($file,"Uf0","0.0");             # Energy of the excited-state minimum in hartree

print LOG "FO   = $fo\n";
print LOG "ZPE  = $zpe\n";
print LOG "Uf0  = $uf0\n";

$found=0;
open(IN,"$fo") or die ":( $fo";
while(<IN>){
  if (/Reference energy/){
     chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
     @g=split(/\s+/,$_);
     $eref=$g[3];
     $found++;
     last;
  }
}
close(IN);
if ($found == 0){
  die "Cannot find reference energy in $fo";
}
print LOG "Eref = $eref\n";

$ind = 0;
$i = 0;
open(IN,"$fo") or die ":( $fo";
open(OUT,">$fo.new") or die ":( $fo.new";
while(<IN>){
  $fix = "no";
  if (/Epot of final state/){
     $ind++;
     chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
     @g=split(/\s+/,$_);
     $epotf=$g[11]/$au2ev;
  }elsif(/Ekin of initial state/){
     chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
     @g=split(/\s+/,$_);
     $ekini=$g[5]/$au2ev;
     $fix=check_zpe();
  }

  if ($fix eq "yes"){
    $_=<IN>;
    if (!/Oscillator strength/){
      die "Cannot understand format!";
    }
    print OUT "Oscillator strength:           0.0000\n";
  }else{
    print OUT "$_";
  }

}
close(OUT);
close(IN);

print LOG "\nPoints discarded: $i of $ind\n";
close(LOG);

# ---------------------------------------------------------------------------

sub check_zpe{
  print LOG "\nIND  = $ind  \n";
  printf LOG "EPOT_F             = %f14.6    EKIN_I  = %f14.6\n",$epotf,$ekini;
  printf LOG "EPOT_F+EREF+EKIN_I = %f14.6    Uf0+ZPE = %f14.6\n",$epotf+$eref+$ekini,$uf0+$zpe;
  if ($epotf + $eref + $ekini < $uf0 + $zpe){
    $fix = "yes";
    $i++;
  }
  print LOG "Discard point? $fix\n";
  return $fix;
}

