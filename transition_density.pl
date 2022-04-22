#!/usr/bin/perl -w
#

print "Enter first MO:";
$_=<STDIN>;
chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
$mo_i=$_;

print "Enter second MO:";
$_=<STDIN>;
chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
$mo_f=$_;

print "Enter molden file name:";
$_=<STDIN>;
chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
$file=$_;
if (!-s $file){
  die "ERROR: $file does not exist or is empty!\n";
}

open(FO,">$file.$mo_i.$mo_f") or die ":( $file.$mo_i.$mo_f";

print_introd();

read_norb();

read_mo_i();
read_mo_f();

trans_dens();

close(FO);

print "Transition density between orbitals $mo_i and $mo_f was written to file $file.$mo_i.$mo_f.\n";

#------------------------------------------------------------------------------
sub print_introd{
  open(FL,$file) or die ":( $file";
  while(<FL>){
    if (/\[MO\]/){
      print FO "[MO]\n";
      last;
    }else{
      print FO $_;
    }
  }
  close(FL);
  print FO " Sym=  1a\n";
  print FO " Ene= 0.0E+00\n";
  print FO " Spin= Alpha\n";
  print FO " Occup= 0.000000\n";
}
#------------------------------------------------------------------------------
sub read_norb{
  $n=0;
  open(FL,$file) or die ":( $file";
  while(<FL>){
    if (/Occup=/i){
      while(<FL>){
        $n++;
        if (/SYM=/i){
          $norb=$n-1;
          print "NORB = $norb\n";
          last;
        }
      }
      last;
    }
  }
  close(FL);
}
#------------------------------------------------------------------------------
sub read_mo_i{
  $num_q = $mo_i."a";
  open(FL,$file) or die ":( $file";
  while(<FL>){
    if (/Sym=/i){
       chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
       ($grb,$num)=split(/\s+/,$_);
       if ($num eq $num_q){
         $_=<FL>;$_=<FL>;$_=<FL>;
         for ($k=1;$k<=$norb;$k++){
           $_=<FL>;
           chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
           ($grb,$coeff_i[$k-1])=split(/\s+/,$_); 
         }
         last;
       } 
    }
  } 
  close(FL);
}
#------------------------------------------------------------------------------
sub read_mo_f{
  $num_q = $mo_f."a";
  open(FL,$file) or die ":( $file";
  while(<FL>){
    if (/Sym=/i){
       chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
       ($grb,$num)=split(/\s+/,$_);
       if ($num eq $num_q){
         $_=<FL>;$_=<FL>;$_=<FL>;
         for ($k=1;$k<=$norb;$k++){
           $_=<FL>;
           chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
           ($grb,$coeff_f[$k-1])=split(/\s+/,$_);
         }
         last;
       }
    }
  }
  close(FL);
}
#------------------------------------------------------------------------------
sub trans_dens{
  for ($k=1;$k<=$norb;$k++){
    $tdens=$coeff_i[$k-1]*$coeff_f[$k-1]/sqrt(abs($coeff_i[$k-1]*$coeff_f[$k-1]));
    printf FO "%5d %20.14E\n",$k,$tdens;
  }
}
#------------------------------------------------------------------------------
