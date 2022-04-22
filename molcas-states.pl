#!/usr/bin/perl 
#
# Read molcas.log files in the DISPLACEMENT directory, collect the state 
# configurations from MS-CASPT2 and print the configuration with maximumm weight.
# Mario Barbatti, 15.01.2008
#
$logf ="states_in_molcas.log";
$enfl ="ms-energy.dat";
open(LOG,">$logf") or die ":( $logf";
open(ENF,">$enfl") or die ":( $enfl";
$DISP ="DISPLACEMENT";
$CC   ="CALC.c1.d";
$ml   ="molcas.log";
$text ="The CI coefficients for the MIXED";
$txt  ="Energies and eigenvectors:";
$eref =0;
$au2ev=27.211396;
if (@ARGV != 0){
  $eref = $ARGV[0];
}
#
for ($i=0;$i<=10;$i++){
   print LOG "\n";
   open(MF,"$DISP/$CC$i/$ml") or warn ":( $ml \n";
   read_molcas();
   close(MF);
   open(MF,"$DISP/$CC$i/$ml") or warn ":( $ml \n";
   read_ms_molcas();
   close(MF);
}
close(ENF);
close(LOG);
#
sub read_molcas{
   while(<MF>){
      if (/$text/){
         chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
         @g=split(/\s+/,$_);
         $nstat=$g[8];
         get_conf();
         print LOG "POINT = $i   STATE = $nstat   CONF = $conf   WEIGHT = $w\n";
      }
   }
}
#
sub get_conf{
  for ($j=1;$j<=5;$j++){$_=<MF>;} # jump 5 lines
  $nc = 1;
  $k  = 0;
  while($nc >= 1){
    $_=<MF>;
    chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
     if ($_ eq ""){$_="0 0 0 0";}
    ($nc,$conform[$k],$coef,$weight[$k])=split(/\s+/,$_);
    print "$nc\n";
    $k++;
  }
  $kmax=maxind(@weight);
  print "kmax = $kmax \n";
  $w   =$weight[$kmax];
  $conf=$conform[$kmax];
}
# Return maximum value of an array of numbers
sub max
{
         my ($i);
	 my $max = $_[0];
	 foreach my $i (@_) {
		  if ($i > $max) {$max = $i;}
	 }
	 return $max;
}
# Return index for the maximum value of an array of numbers
sub maxind
{
         my ($i,$ind,$indmax);
         my $max = $_[0];
         $ind=0;
         foreach my $i (@_) {
                  if ($i > $max) {
                     $max    = $i;
                     $indmax = $ind;
                  }
                  $ind++;
         }
         return $indmax;
}
#
sub read_ms_molcas{
  while(<MF>){
     if (/$txt/){
        $_=<MF>;
        $_=<MF>;
        chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
        @energy=split(/\s+/,$_);
        $ien=0;
        foreach(@energy){
          $en_ev[$ien]=-$au2ev*($eref-$_);
          $ien++;
        }
        print ENF "$i  @energy  @en_ev\n";
     }
  }
}
