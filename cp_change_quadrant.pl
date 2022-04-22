#!/usr/bin/perl -w
# Give a list of phy-theta CP parameters, this program reduce the data to the same quadrant. 
# 1 - from (phy<180,theta<90)->(phy>180,theta>90):
#   theta'= 180-theta
#   phy'  = 180+phy
# 2 - from (phy>180,theta>90)->(phy<180,theta<90):
#   theta = 180-theta'
#   phy   = phy'-180
# 3 - from (phy>180)->(phy<180)
# in all cases, points in the other quadrants are not transformed.
# Run: ./cp_change_quadrant.pl
# The input is in the format of t-cp.dat file (output of cp-traj.pl).
#-------------------------------------------------------------------------- 
# Input:
print STDOUT "Type of transformation: \n";
print STDOUT "1 - (phy<180,theta<90)->(phy>180,theta>90) (Eg E2->2E) \n";
print STDOUT "2 - (phy>180,theta>90)->(phy<180,theta<90) (Eg 2E->E2) \n";
print STDOUT "3 - (phy>180)->(phy<180) (Eg B36->36B) \n";
print STDOUT "4 - (phy<=180)->(phy>=180) (Eg 36B->B36) (not really tested...) \n";
print STDOUT "Enter option (1,2,3,4) [Default - 3]: ";
$_=<STDIN>;
chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
#if (//){
#  $option=3;
#}else{
  $option=$_;
#}
print STDOUT "File name (\"phy theta\" format, in degrees) [Default - t-cp.dat]: \n";
$_=<STDIN>;
chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
if (//){
  $file="t-cp.dat";
}else{
  $file=$_;
}
print "Selected option: $option\n";
if (!-s $file){die "File $file does not exist or is empty!";}
#-------------------------------------------------------------------------- 
#
open(IN,$file) or die ":( $file";
open(OUT,">cp-out.dat") or die ":( cp-out.dat";
while(<IN>){
  chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
  ($n,$q,$theta,$phy,$conf)=split(/\s+/,$_);
  if ($n=~/^-?\d+$/){
  if ($option == 1){
    option1();
  }elsif($option==2){
    option2();
  }elsif($option==3){
    option3();
  }elsif($option==4){
    option4();
  }
  boeyens($theta_p,$phy_p);
  printf OUT "%5d %6.3f   %6.1f %6.1f %4s   %6.1f %6.1f %4s \n",$n,$q,$phy,$theta,$conf,$phy_p,$theta_p,$class;
  }
}
#
sub option1{
  $phy_p   = $phy;
  $theta_p = $theta;
  if (($phy < 180) and ($theta < 90)){
     $phy_p   = 180+$phy;
     $theta_p = 180-$theta;
  }
}
#
sub option2{
  $phy_p   = $phy;
  $theta_p = $theta;
  if (($phy > 180) and ($theta > 90)){
     $phy_p   =$phy-180;
     $theta_p = 180-$theta;
  }
}
#
sub option3{
  $phy_p   = $phy;
  $theta_p = $theta;
  if ($phy < 15){
     $phy_p   =$phy-180;
     $theta_p = 180-$theta;  
  }
  if ($phy > 195){
     $phy_p   =$phy-180;
     $theta_p = 180-$theta;
  }
}
#
sub option4{
  $phy_p   = $phy;
  $theta_p = $theta;
#  if (($phy > -15) and ($phy < 0)){
#     $phy_p   =$phy+180;
#     $theta_p = 180-$theta;
#  }
#  if (($phy > 345) and ($phy < 360)){
#     $phy_p   =$phy+180;
#     $theta_p = 180-$theta;
#  }
  if (($phy > 15) and ($phy < 195)){
     $phy_p   =$phy+180;
     $theta_p = 180-$theta;
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


