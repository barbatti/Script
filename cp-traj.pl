#!/usr/bin/perl -w
$PLATON = $ENV{"PLATON"};
$my_ring="";
# This program reads a dyn.mld file (multiple xyz format), 
# gets the CP parameters and the conformation for 5 and 6 
# membered rings.
# Mario Barbatti, Mar 2007 - May 2008.
#
# The order of atoms in the original file (dyn.mld) is not 
# necessarely the IUPAC order. Since the CP parameters should 
# be obtained with the IUPAC order, you can change the order 
# in the line below. 
# Example: @myOrder=(1,3,2,5,4,6,7,9,8);
# Atom 3 in dyn.mld will be assumed to be number 2.
# Atom 2 in dyn.mld will be assumed to be number 3.
#------------------------------------------------------------
# Change the atoms order here:
#------------------------------------------------------------
#@myOrder=(2,4,1,7,6,5,8,3,9,10,11,12,13);
#@myOrder=(5,4,6,1,2,3,7,8,9,10,11,12);
#@myOrder=(8,7,6,3,2,9,1,5,4,10,11,15,14,13,12);
@myOrder=(1..15);
#@myOrder=(7,4,6,3,2,1,8,5,10,9,11,14,15,12,13);
#------------------------------------------------------------
# This optional line below will force PLATON recognize the ring 
# even when dissociation happens.
# The definition of the atoms should correspond to the reordered
# atoms and numbered according to the elements. For example, if
# the reorcered atoms that form the ring are: N C N C C (imidazole),
# then $my_ring="RING N(1) C(1) N(2) C(2) C(3)".
#------------------------------------------------------------
# Define the ring here:
#------------------------------------------------------------
$my_ring="RING N(1) C(1) N(2) C(2) C(3) C(4)";
#------------------------------------------------------------
#------------------------------------------------------------
#
open(LG,">cp.log") or die ":( cp.log";
system("rm -f calc");
$dt = 1;
print STDOUT "\nAnalysis of 5 or 6 membered rings? ";
$_=<STDIN>;
chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
$nmemb=$_;
if (($nmemb != 5) and ($nmemb != 6)){
  die "Only for 5- or 6-membered rings.";
}
print LG "NMEMB = $nmemb\n";

if (!-s "dyn.mld"){
  die "Prepare dyn.mld before (multiple xyz format).";
}

print STDOUT "Atoms will be reordered according to:\n";
  print LG "MYORDER = ";
foreach (@myOrder){
  print STDOUT "$_ ";
  print LG "$_ ";
}
print STDOUT "\nIf you want to change this ordering, change \@myOrder in the source code.\n";
if ($my_ring ne ""){
  print STDOUT "Force the recognition of the following ring:\n";
  print STDOUT "$my_ring\n";
  print LG "\nMY_RING = $my_ring\n";
}else{
  print STDOUT "No ring was predefined.\n";
  print LG "No ring was predefined.\n";
}
print STDOUT "If you want automatic recognition of any ring, define it in \$my_ring variable.\n";

open(DM,"dyn.mld") or die ":( dyn.mld";
$_=<DM>;
chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
$nat=$_;
$_=<DM>;
if (/Time/){
  $print_t="Y";
}
close(DM);

open(RS,">t-cp.dat") or die ":( t-cp.dat";
if ($nmemb == 5){
  if ($print_t eq "Y"){
    print RS "geom    Time     Q        Phi        Conf.\n";
  }else{
    print RS "geom    Q        Phi        Conf.\n";
  }
}elsif($nmemb == 6){
  if ($print_t eq "Y"){
     print RS "geom    Time    Q        Theta       Phi      Conf.\n";
  }else{
     print RS "geom    Q        Theta       Phi      Conf.\n";
  }
}

$count = `wc -l < dyn.mld`;
$kfinal=$count/($nat+2);
open(DM,"dyn.mld") or die ":( dyn.mld";
for ($kt=1;$kt<=$kfinal;$kt++){
    print STDOUT "...";
    $t = $kt*$dt;   # time
    print LG "t = $t    kt = $kt \n";
    $_=<DM>;
    chomp;
    $_ =~ s/^\s*//;         # remove leading blanks
    $_ =~ s/\s*$//;         # remove trailing blanks
    $nat=$_;
    $_=<DM>;
    if ($print_t eq "Y"){
      chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
      @g=split(/\s+/,$_);
      $time=$g[2];
      # print "Time = $time\n";
    }
    for ($iat=1;$iat<=$nat;$iat++){  # read geometry
        $_=<DM>;
        chomp;
         $_ =~ s/^\s*//;         # remove leading blanks
         $_ =~ s/\s*$//;         # remove trailing blanks
        ($symb[$iat],$x[$iat],$y[$iat],$z[$iat])=split(/\s+/,$_);
    }
    print LG "$symb[1] $x[1] $y[1] $z[1]  NAT = $nat\n";
    writepdb();
    run_platon();
    collect_cp();
}
#system("rm -f temp.* calc");
print "\nResults written to t-cp.dat\n\n";
close(DM);
close(RS);
# ---------------------------------------------------------------------------------

sub writepdb{
   $i=1;
   open(PD,">temp.pdb") or die ":( temp.pdb";
   print PD "HEADER\n";
   foreach (@myOrder){
      $iat=$_;
      printf PD "%8s %2d %2s %15s %7.3f %7.3f %7.3f \n",
      "HETATM  ",$i,$symb[$iat],"    2     2    ",$x[$iat],$y[$iat],$z[$iat];
      $i++;
   }
   close(PD);
}
# ---------------------------------------------------------------------------------
sub run_platon{
   if (!-s "calc"){
      open(CC,">calc") or die ":( calc";
      if ($my_ring ne ""){
        print CC "$my_ring\n";
      }
      print CC "CALC ALL \n\n";
      close(CC);
   }
   if (-s "temp.lis"){
      #system("rm -f temp.lis");
   }
   system("$PLATON/platon -o temp.pdb < calc > /dev/null 2>&1");
   #system("platon -o temp.pdb ");
   #system("rm -f temp.pdb");
}
# ---------------------------------------------------------------------------------

sub collect_cp{
   open(TL,"temp.lis") or die ":( temp.lis";
   while(<TL>){
      if ($nmemb == 5){
        if (/5-Membered Ring /){
          while(<TL>){
            if (/Q\(2\)/){
               #Q(2)  =          0.2824 Ang.,  Phi(2)        =302.2360 Deg
               print LG "Phi found. \n";
               chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
               @g=split(/=/,$_);
               @g1=split(/\s+/,$g[1]);
               $q=$g1[1];
               $g[2] =~ s/^\s*//;$g[2] =~ s/\s*$//;
               @g1=split(/\s+/,$g[2]);
               $phi=$g1[0];
               print LG "Phi = $phi. \n";
               class5memb();
               if ($print_t eq "Y"){
                   print RS "$t    $time    $q     $phi     $class \n";
               }else{
                   print RS "$t     $q     $phi     $class \n";
               }
               last;
            }
          }
          last;
        }
      }elsif ($nmemb == 6){
        if (/Theta =/){
           print LG "Theta found. \n";
           chomp;
           @g=split(/=/,$_);
           $g[1] =~ s/^\s*//;         # remove leading blanks
           $g[1] =~ s/\s*$//;         # remove trailing blanks
           ($q,$grb)=split(/\s+/,$g[1]);
           $g[2] =~ s/^\s*//;         # remove leading blanks
           $g[2] =~ s/\s*$//;         # remove trailing blanks
           ($theta,$grb)=split(/\s+/,$g[2]);
           $g[3] =~ s/^\s*//;         # remove leading blanks
           $g[3] =~ s/\s*$//;         # remove trailing blanks
           ($phi,$grb)=split(/\s+/,$g[3]);
           print LG "Theta = $theta   Phi = $phi. \n";
           boeyens($theta,$phi);
           if ($print_t eq "Y"){
             print RS "$t    $time    $q     $theta     $phi     $class \n";
           }else{
             print RS "$t     $q     $theta     $phi     $class \n";
           }
           last;
        }
      }
   }
   close(TL);
}

#---------------------------------------------------------------------------------

sub class5memb{
# Conformation for 5-membered rings

# Reduce angle to 0 <= phi <= 360
while($phi < 0){
  $phi=$phi+360;
}
while($phi > 360){
  $phi=$phi-360;
}

find_conf($phi);

$class=$conf;
return $class;
}

#---------------------------------------------------------------------------------

sub find_conf{
my ($right,$left,$type,$phi,$invert);
($phi)=@_;

  $invert="n";
  if ($phi >= 180){
    $phi = $phi-180;
    $invert="y";
  }

# Find conformation
  $right="";
  $left="";
  $type="X";

  if (($phi>= 0) and ($phi< 9)){
   $right=1;
   $type="E";
  }
  if (($phi>= 9) and ($phi< 27)){
   $left=2;
   $right=1;
   $type="T";
  }
  if (($phi>= 27) and ($phi< 45)){
   $left=2;
   $type="E";
  }
  if (($phi>= 45) and ($phi< 63)){
   $left=2;
   $right=3;
   $type="T";
  }
  if (($phi>= 63) and ($phi< 81)){
   $right=3;
   $type="E";
  }
  if (($phi>= 81) and ($phi< 99)){
   $left=4;
   $right=3;
   $type="T";
  }
  if (($phi>= 99) and ($phi< 117)){
   $left=4;
   $type="E";
  }
  if (($phi>= 117) and ($phi< 135)){
   $left=4;
   $right=5;
   $type="T";
  }
  if (($phi>= 135) and ($phi< 153)){
   $right=5;
   $type="E";
  }
  if (($phi>= 153) and ($phi< 171)){
   $left=1;
   $right=5;
   $type="T";
  }
  if (($phi>= 171) and ($phi< 180)){
   $left=1;
   $type="E";
  }
  if ($invert eq "n"){
    $conf = $left.$type.$right;
  }elsif($invert eq "y"){
    $conf = $right.$type.$left;
  }
}

# -------------------------------------------------------------------------------------

sub boeyens{
# Conformation for 6-membered rings
  use Math::Trig;
  local ($theta,$phi,$n_test,$trunc_n,$remainder_n,$n_final);
  local ($n_test,$trunc_n,$remainder_n,$n_final);
  local ($phi_class,$sqrt2,$sqrt32);
  local ($L_C,$L_C1,$L_E1,$L_E2,$L_B,$L_H1,$L_H2,$L_T,$L_S1,$L_S2);
  local ($l0,$l1,$l2,$l3,$l4,$l5);
  my ($kangi,$kangf,$nang);

  $sqrt2 = sqrt(2.0);
  $sqrt32 = sqrt(1.5);

  $theta = $_[0];
  $phi = $_[1];
  if ($phi < 0.0){
    while($phi < 0){
      $phi=$phi+360;
    }
    while($phi > 360){
      $phi=$phi-360;
    }
    #die "ERROR: phi = $phi The program is not prepared to deal with phi < 0.\n";
  }

# Reduce theta
  if ($theta > 360){
     $n360=int($theta/360);
     $theta=$theta-$n360*360;
  }
  if ($theta > 180){
     $theta=$theta-180;
  }

# Reduce phi
  if ($phi > 360){
     $n360=int($phi/360);
     $phi=$phi-$n360*360;
  }

# DEG -> RAD
  $theta = deg2rad($theta);
  $phi = deg2rad($phi);

# Phi test
  $n_test = 6.0/pi*$phi;
  $trunc_n = int($n_test);
  $remainder_n = $n_test-$trunc_n;
  if ($remainder_n < 0.5){
    $n_final = $trunc_n;
  }elsif ($remainder_n >= 0.5){
    $n_final = $trunc_n + 1;
  }
  if ($n_final % 2){
    $phi_class = "HST";
   # print "Class: ODD = $phi_class \n";
  }else{
    $phi_class = "EBE";
   # print "Class: EVEN = $phi_class \n";
  }

# Theta test
  $L_C  = 0.0;
  $L_C1 = pi;
  # print $L_C," ";
  if ($phi_class eq "EBE"){
    $L_E1 = atan($sqrt2);
    $L_B  = pi/2.0;
    $L_E2 = pi+atan(-$sqrt2);
    $l0   = ($L_C+$L_E1)/2.0;
    $l1   = ($L_E1+$L_B)/2.0;
    $l2   = ($L_B+$L_E2)/2.0;
    $l3   = ($L_E2+$L_C1)/2.0;
    if    (($theta >= $L_C) and ($theta < $l0)){
       $class = "C";
    }elsif(($theta >= $l0)  and ($theta < $l1)){
       $class = "E1";
    }elsif(($theta >= $l1)  and ($theta < $l2)){
       $class = "B";
    }elsif(($theta >= $l2)  and ($theta < $l3)){
       $class = "E2";
    }elsif(($theta >= $l3)  and ($theta <= $L_C1)){
       $class = "C";
    }else{
       warn "ERROR: theta = ",rad2deg($theta),"deg: out of limits.";
    }
    if ($class ne "C"){
      $class=class_even();
    }
  }elsif ($phi_class eq "HST"){
    $L_H1 = atan($sqrt32);
    $L_S1 = atan(1.0+$sqrt2);
    $L_T  = pi/2.0;
    $L_S2 = pi+atan(-(1.0+$sqrt2));
    $L_H2 = pi+atan(-$sqrt32);
    $l0   = ($L_C+$L_H1)/2.0;
    $l1   = ($L_H1+$L_S1)/2.0;
    $l2   = ($L_S1+$L_T)/2.0;
    $l3   = ($L_T+$L_S2)/2.0;
    $l4   = ($L_S2+$L_H2)/2.0;
    $l5   = ($L_H2+$L_C1)/2.0;
    if    (($theta >= $L_C) and ($theta < $l0)){
       $class = "C";
    }elsif(($theta >= $l0)  and ($theta < $l1)){
       $class = "H1";
    }elsif(($theta >= $l1)  and ($theta < $l2)){
       $class = "S1";
    }elsif(($theta >= $l2)  and ($theta < $l3)){
       $class = "T";
    }elsif(($theta >= $l3)  and ($theta < $l4)){
       $class = "S2";
    }elsif(($theta >= $l4)  and ($theta < $l5)){
       $class = "H2";
    }elsif(($theta >= $l5)  and ($theta <= $L_C1)){
       $class = "C";
    }else{
       warn "ERROR: theta = ",rad2deg($theta),"deg: out of limits.";
    }
    if ($class ne "C"){
      $class=class_odd();
    }
  }
  if ($class eq "C"){
    $class=class_c();
  }
  #print "class = $class \n";

  return $class;
}
sub class_c{
   my ($indaux);
   if ((0 <= $phi) and ($phi < pi/6)){
     $ind1=1;
     $ind2=4;
   }
   if ((pi/6 <= $phi) and ($phi < pi/2)){
     $ind1=2;
     $ind2=5;
   }
   if ((pi/2 <= $phi) and ($phi < 5*pi/6)){
     $ind1=3;
     $ind2=6;
   }
   if ((5*pi/6 <= $phi) and ($phi < 7*pi/6)){
     $ind1=1;
     $ind2=4;
   }
   if ((7*pi/6 <= $phi) and ($phi < 3*pi/2)){
     $ind1=2;
     $ind2=5;
   }
   if ((3*pi/2 <= $phi) and ($phi < 11*pi/2)){
     $ind1=3;
     $ind2=6;
   }
   if ((11*pi/2 <= $phi) and ($phi < pi)){
     $ind1=1;
     $ind2=4;
   }
   if ($theta > pi/2.0){
     $indaux=$ind1;
     $ind1=$ind2;
     $ind2=$indaux;
   }
   $class=$ind1.$class.$ind2;
}
sub class_even{
   if ($class eq "E1"){
     $cl = "E";
     $ind1 = ($n_final+2)/2;
     $ind2 = "";
   } elsif ($class eq "B"){
     $cl = "B";
     $ind1 = ($n_final+2)/2;
     $ind2 = "";
   } elsif ($class eq "E2"){
     $cl = "E";
     $ind1 = "";
   }
   if ($ind1 eq "7"){
     $ind1=1;
   }
   if      ($n_final == 0){
      if (($class eq "B") or ($class eq "E2")){$ind2 = 4};
      $class = $ind1.$ind2.$cl;
    }elsif ($n_final == 2){
      if (($class eq "B") or ($class eq "E2")){$ind2 = 5};
      $class = $cl.$ind1.$ind2;
    }elsif ($n_final == 4){
      if (($class eq "B") or ($class eq "E2")){$ind2 = 6};
      $class = $ind2.$ind1.$cl;
    }elsif ($n_final == 6){
      if (($class eq "B") or ($class eq "E2")){$ind2 = 1};
      $class = $cl.$ind1.$ind2;
    }elsif ($n_final == 8){
      if (($class eq "B") or ($class eq "E2")){$ind2 = 2};
      $class = $ind2.$ind1.$cl;
    }elsif ($n_final ==10){
      if (($class eq "B") or ($class eq "E2")){$ind2 = 3};
      $class = $cl.$ind1.$ind2;
    }elsif ($n_final ==12){
      if (($class eq "B") or ($class eq "E2")){$ind2 = 4};
      $class = $ind2.$ind1.$cl;
    }else{
       warn "ERROR: phi = $phi is out of limits.";
    }
}
sub class_odd{
  if ($class =~ m/H/){
    $cl = "H";
  }elsif($class =~ m/S/){
    $cl = "S";
  }elsif($class =~ m/T/){
    $cl = "T";
  }

   if      ($n_final == 1){
      if     (($class eq "H1") or ($class eq "S1")){
        $ind1 = 1;
        $ind2 = 2;
      }elsif (($class eq "H2") or ($class eq "S2")){
        $ind1 = 4;
        $ind2 = 5;
      }elsif ($class eq "T"){
        $ind1 = 4;
        $ind2 = 2;
      }
    }elsif ($n_final == 3){
      if     (($class eq "H1") or ($class eq "S1")){
        $ind1 = 3;
        $ind2 = 2;
      }elsif (($class eq "H2") or ($class eq "S2")){
        $ind1 = 6;
        $ind2 = 5;
      }elsif ($class eq "T"){
        $ind1 = 6;
        $ind2 = 2;
      }
    }elsif ($n_final == 5){
      if     (($class eq "H1") or ($class eq "S1")){
        $ind1 = 3;
        $ind2 = 4;
      }elsif (($class eq "H2") or ($class eq "S2")){
        $ind1 = 6;
        $ind2 = 1;
      }elsif ($class eq "T"){
        $ind1 = 3;
        $ind2 = 1;
      }
    }elsif ($n_final == 7){
      if     (($class eq "H1") or ($class eq "S1")){
        $ind1 = 5;
        $ind2 = 4;
      }elsif (($class eq "H2") or ($class eq "S2")){
        $ind1 = 2;
        $ind2 = 1;
      }elsif ($class eq "T"){
        $ind1 = 2;
        $ind2 = 4;
      }
    }elsif ($n_final == 9){
      if     (($class eq "H1") or ($class eq "S1")){
        $ind1 = 5;
        $ind2 = 6;
      }elsif (($class eq "H2") or ($class eq "S2")){
        $ind1 = 2;
        $ind2 = 3;
      }elsif ($class eq "T"){
        $ind1 = 2;
        $ind2 = 6;
      }
    }elsif ($n_final ==11){
      if     (($class eq "H1") or ($class eq "S1")){
        $ind1 = 1;
        $ind2 = 6;
      }elsif (($class eq "H2") or ($class eq "S2")){
        $ind1 = 4;
        $ind2 = 3;
      }elsif ($class eq "T"){
        $ind1 = 1;
        $ind2 = 3;
      }
    }else{
       warn "ERROR: phi = $phi is out of limits.";
    }
    $class = $ind1.$cl.$ind2;

}
