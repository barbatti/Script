#!/usr/bin/perl -w

print "Initial final_output \"i j\" for final_output.i.j ";
$_=<STDIN>;
chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
($ii,$ji)=split(/\s+/,$_);

print "Initial file is final_output.$ii.$ji\n";

print "Final final_output \"i j\" for final_output.i.j ";
$_=<STDIN>;
chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
($if,$jf)=split(/\s+/,$_);

print "Initial file is final_output.$if.$jf\n";

print "0 - Collect only values at equilibrium geometry; 1 - Collect all values: ";
$_=<STDIN>;
chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
$type=$_;
if    ($type eq 0){"Collecting only equilibrium.\n"}
elsif ($type eq 1){"Collecting all values.\n"}
else              {die "Value not valid.\n"}

open(OUT,">get_energy_from_finalouput.dat") or die ":( get_energy_from_finalouput.dat\n";

print OUT "  i    j     card        Ei          Ej            Ej-Ei         f\n";

for ($i=$ii;$i<=$if;$i++){
  for ($j=$ji;$j<=$jf;$j++){
    if (!-s "final_output.$i.$j"){ 
      print "Not Found: final_output.$i.$j\n";
      die ":( final_output.$i.$j\n";
    }else{
      print "Found: final_output.$i.$j\n";
      collect();
    }
  }
}

close(OUT);

# =========================================================================

sub collect{
  open(IN,"final_output.$i.$j") or die ":( final_output.$i.$j\n";
  while(<IN>){
    if (/Reference energy/){
      $card=0;
      $e0=0.0;
      while(<IN>){
        if (/Vertical excitation/){
          chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
          (@g)=split(/\s+/,$_);
          $e1=$g[3]; 
          while(<IN>){
             if (/Oscillator strength/){
               (@g)=split(/\s+/,$_);
               $f=$g[3];
               printf OUT "%3d  %3d  %5d  %12.5f  %12.5f  %12.4f  %12.5f\n",$i,$j,$card,$e0,$e1,$e1-$e0,$f;
               last;
             }
          }
          last
        }
      }
    }
    if ($type eq 1){
       if (/Initial condition/){
          chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
          (@g)=split(/\s+/,$_);
          $card=$g[3]; 
          while(<IN>){
            if (/Epot of initial state/){
              chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
              (@g)=split(/\s+/,$_);
              $e0=$g[5]; 
              $e1=$g[11]; 
              while(<IN>){
                 if (/Oscillator strength:/){
                   (@g)=split(/\s+/,$_);
                   $f=$g[3];
                   printf OUT "%3d  %3d  %5d  %12.5f  %12.5f  %12.4f  %12.5f\n",$i,$j,$card,$e0,$e1,$e1-$e0,$f;
                   last;  
                 }
              }
              last;
            }
          }
       }
    }
  }
  close(IN);
}
