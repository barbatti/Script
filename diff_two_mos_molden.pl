#!/usr/bin/perl -w
#
# Given MO_A and MO_B in a Molden file, this programs computes:
# MO_C^2 = MO_B^2 - MO_A^2 
# MO_C^2 is printed at the end of the MO's list as a new orbital.
# 
# Useful to estimate the density difference between the excited and the ground states.
#
# Mario Barbatti, Dez 2014
#
## Molden format:
# [MO]
# Sym=     1a
# Ene=   -15.6401
# Spin= Alpha
# Occup=    2.00000
#   1        -0.00000829
#   2        -0.00001453
#   :
#   $nbas
# Sym=     2a
#   :
# Sym=     $nmos
#   :
molden_file();
which_mos();
read_write();

#-----------------------------------------------------------------------------------------
sub molden_file{
  print " Enter molden file name: ";
  $_=<STDIN>;
  chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
  $fmold=$_;
  if (!-s $fmold){
    die_mess("$fmold is empty or does not exist!");
  } 
  read_info();
}
#------------------------------------------------------------------------------------------
sub read_info{
  $moind="n";
  open(IN,$fmold) or die ":( $fmold";
  while(<IN>){
    # Look for [MO]
    if (/[MO]/){
      $moind="y";
      $nmos=0;
      # Count MOs
      while(<IN>){
        if (/Sym=/i){
          $nmos++;
        }
      }      
    }
  }
  close(IN);
  if ($moind eq "n"){
    die_mess("Cannot find MOs in $fmold");
  }
  print " Number of MOs: $nmos\n";
  # Count NBAS
  $nbas=0;
  open(IN,$fmold) or die ":( $fmold";
  while(<IN>){
    if (/Sym=/i){
      while(<IN>){
        $nbas++;
        if (/Sym/i){
          last;
        }
        last
      }
    }
  }
  close(IN);
  print " Number of MO coeff: $nbas\n\n";
}
#------------------------------------------------------------------------------------------
sub which_mos{
  # MO_A
  print " Number of the orbital donating an electron: ";
  $_=<STDIN>;
  chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
  $moa=$_;
  if ($moa =~ /^[\+-]*[0-9]*\.*[0-9]*$/ && $moa !~ /^[\. ]*$/) { # numeric?
     print " Donnor MO: $moa\n";
  }else{ #non-numeric
     die_mess("MO_A = $moa, but it should be a number.");
  }
  # MO_B
  print " Number of the orbital accepting an electron: ";
  $_=<STDIN>;
  chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
  $mob=$_;
  if ($mob =~ /^[\+-]*[0-9]*\.*[0-9]*$/ && $mob !~ /^[\. ]*$/) { # numeric?
     print " Acceptor MO: $mob\n";
  }else{ #non-numeric
     die_mess("MO_B = $mob, but it should be a number.");
  }
}
#------------------------------------------------------------------------------------------
sub read_write{
  open(IN,$fmold) or die ":( $fmold";
  open(OUT,">new-$fmold") or die ":( new-$fmold";
  while(<IN>){
    if ((/Sym=/) and (/ $moa/)){
      print OUT $_;
      read_moa();
    }elsif ((/Sym=/) and (/ $mob/)){
      print OUT $_;
      read_mob();
    }else{
      print OUT $_;
    }
  }
  close(IN);
  print_dens();
  close(OUT);
}
#------------------------------------------------------------------------------------------
sub read_moa{
  $_=<IN>;
  print OUT $_;
  $_=<IN>;
  print OUT $_;
  $_=<IN>;
  print OUT $_;
  for($i=0;$i<=$nbas-1;$i++){
    $_=<IN>;
    print OUT $_;
    chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
    @g=split(/\s+/,$_);
    $ca[$i]=$g[1];
  }
}
#------------------------------------------------------------------------------------------
sub read_mob{
  $_=<IN>;
  print OUT $_;
  $_=<IN>;
  print OUT $_;
  $_=<IN>;
  print OUT $_;
  for ($i=0;$i<=$nbas-1;$i++){
    $_=<IN>;
    print OUT $_;
    chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
    @g=split(/\s+/,$_);
    $cb[$i]=$g[1];
  }
}
#------------------------------------------------------------------------------------------
sub print_dens{
  $nb1=sprintf("%6d",$nbas+1);
  print OUT " Sym=".$nb1."a\n";
  print OUT "Ene=  1000.0000\n";
  print OUT " Spin= Alpha\n";
  print OUT "Occup=    2.00000\n";
  for ($i=0;$i<=$nbas-1;$i++){
    $dens=sprintf("%12.8f",abs($cb[$i])-abs($ca[$i]));
    $i1=sprintf("%4d",$i+1);
    print OUT "$i1       $dens\n";
  }
}
#------------------------------------------------------------------------------------------
sub die_mess{
  my ($mess);
  ($mess)=@_;
  die ":( $mess\n\n";
}
#------------------------------------------------------------------------------------------
