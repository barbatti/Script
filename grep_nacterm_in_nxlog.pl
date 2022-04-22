#!/usr/bin/perl -w

# Get NAC value for a specific cartesian coordinate of an specific atom
# in nx.log.

print " Which coupling number? ";
$_=<STDIN>;
chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
$ncoup=$_;

print " Which atom number? ";
$_=<STDIN>;
chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
$ind=$_;

print " Which cartesian element? (x,y,z)=(1,2,3) ";
$_=<STDIN>;
chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
$cart=$_;

$nxl="nx.log";

if (!-s $nxl) {
  die ":( $nxl does not exist or is empty!  ";
}

open(NXL,$nxl) or die ":( $nxl";
while(<NXL>){
    if (/Nat/){
      chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
      ($g,$g,$nat)=split(/\s+/,$_);
      last;
    }
}
close(NXL);

open(NXL,$nxl) or die ":( $nxl";
open(LOG,">get_nac.log") or die ":( get_nac.log";
while(<NXL>){
    if (/Nonadiabatic coupling vectors \(a.u.\):/){
      $nac_b=get_nac($ncoup,$ind,$cart);
      while (<NXL>){
        if (/Nonadiabatic coupling vectors after phase adjustment \(a.u.\):/){
          $nac_a=get_nac($ncoup,$ind,$cart);
          while(<NXL>){
            if (/FINISHING STEP/){
               chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
               ($g,$g,$step,$g,$time)=split(/\s+/,$_);
               last;
            }
          }
          last;
        }
      }
      print LOG " $step   $time    $nac_b    $nac_a\n";
    }
}

close(LOG);
close(NXL);

sub get_nac{
  my ($nac,@g);
  ($ncoup,$ind,$cart)=@_;
  for ($i=1; $i<=($ncoup-1)*$nat+$ind; $i++){
    $_=<NXL>;
  } 
  chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
  (@g)=split(/\s+/,$_);
  $nac=$g[$cart-1];
  return $nac;
}

