#!/usr/bin/perl -w
# Find ethyledene structures at the end of ethylene dynamics.
# Use: ./find_ethylidene-v2.pl <nstep> [enter]
# <nstep> is how many steps after hopping to S0 analysis should be done.
# If <nstep> is not given, use last point of trajectory.
#
# MB 2020-12-27

$traji=1;
$trajf=500;
$state=1;
$nat=6;
$eps=0.01;
$thres=3.77945; # au (3.77945 au = 2 Angstrom)
$zci=1.96;

$nstep = -1;
if (@ARGV != 0){
  $nstep = $ARGV[0];
}

open(OUT,">ethylidene_count-v3.log");

$found = 0;
$total_etd=0;
$total_eth=0;
$total_H=0;
$total_2H=0;
$total_3H=0;
$total_4H=0;
$total_CH4=0;
$total_exc=0;
for ($n=$traji;$n<=$trajf;$n++){
  $file="TRAJ$n/RESULTS/dyn.out";
  find_last_step();
  if ($nstep != -1){
    find_nstep();
  }
  check_st();
  if ( abs($st - $state) >= $eps ){
     $total_exc++;
  }
  if ( abs($st - $state) < $eps ){
    get_geom();
    check_struct();
  }
}
$total=$total_etd+$total_eth+$total_H+$total_2H+$total_3H+$total_4H+$total_CH4+$total_exc;
$ftotal_etd=$total_etd/$found;
$ftotal_eth=$total_eth/$found;
$ftotal_H=$total_H/$found;
$ftotal_2H=$total_2H/$found;
$ftotal_3H=$total_3H/$found;
$ftotal_4H=$total_4H/$found;
$ftotal_CH4=$total_CH4/$found;
$ftotal_exc=$total_exc/$found;
$err_etd=$zci*sqrt($ftotal_etd*(1-$ftotal_etd)/$found);
$err_eth=$zci*sqrt($ftotal_eth*(1-$ftotal_eth)/$found);
$err_H  =$zci*sqrt($ftotal_H*(1-$ftotal_H)/$found);
$err_2H =$zci*sqrt($ftotal_2H*(1-$ftotal_2H)/$found);
$err_3H =$zci*sqrt($ftotal_3H*(1-$ftotal_3H)/$found);
$err_4H =$zci*sqrt($ftotal_4H*(1-$ftotal_4H)/$found);
$err_CH4 =$zci*sqrt($ftotal_CH4*(1-$ftotal_CH4)/$found);
$err_exc =$zci*sqrt($ftotal_exc*(1-$ftotal_exc)/$total);
print "TOTAL EXCITED:     ",sprintf("%3d",$total_exc)," :",sprintf("%5.0f",$ftotal_exc*100)," +/-",sprintf("%3.0f",$err_exc*100),"\n";
print "TOTAL ETHYLENES:   ",sprintf("%3d",$total_eth)," :",sprintf("%5.0f",$ftotal_eth*100)," +/-",sprintf("%3.0f",$err_eth*100),"\n";
print "TOTAL ETHYLIDENES: ",sprintf("%3d",$total_etd)," :",sprintf("%5.0f",$ftotal_etd*100)," +/-",sprintf("%3.0f",$err_etd*100),"\n";
print "TOTAL 1H DISS:     ",sprintf("%3d",$total_H)," :",sprintf("%5.0f",$ftotal_H*100)," +/-",sprintf("%3.0f",$err_H*100),"\n";
print "TOTAL 2H DISS:     ",sprintf("%3d",$total_2H)," :",sprintf("%5.0f",$ftotal_2H*100)," +/-",sprintf("%3.0f",$err_2H*100),"\n";
print "TOTAL 3H DISS:     ",sprintf("%3d",$total_3H)," :",sprintf("%5.0f",$ftotal_3H*100)," +/-",sprintf("%3.0f",$err_3H*100),"\n";
print "TOTAL 4H DISS:     ",sprintf("%3d",$total_4H)," :",sprintf("%5.0f",$ftotal_4H*100)," +/-",sprintf("%3.0f",$err_4H*100),"\n";
print "TOTAL CH4:         ",sprintf("%3d",$total_CH4)," :",sprintf("%5.0f",$ftotal_CH4*100)," +/-",sprintf("%3.0f",$err_CH4*100),"\n";
print "Total:             $total   Found nstep condition in : $found trajectories\n";
print OUT "TOTAL EXCITED:     ",sprintf("%3d",$total_exc)," :",sprintf("%5.0f",$ftotal_exc*100)," +/-",sprintf("%3.0f",$err_exc*100),"\n";
print OUT "TOTAL ETHYLENES:   ",sprintf("%3d",$total_eth)," :",sprintf("%5.0f",$ftotal_eth*100)," +/-",sprintf("%3.0f",$err_eth*100),"\n";
print OUT "TOTAL ETHYLIDENES: ",sprintf("%3d",$total_etd)," :",sprintf("%5.0f",$ftotal_etd*100)," +/-",sprintf("%3.0f",$err_etd*100),"\n";
print OUT "TOTAL 1H DISS:     ",sprintf("%3d",$total_H)," :",sprintf("%5.0f",$ftotal_H*100)," +/-",sprintf("%3.0f",$err_H*100),"\n";
print OUT "TOTAL 2H DISS:     ",sprintf("%3d",$total_2H)," :",sprintf("%5.0f",$ftotal_2H*100)," +/-",sprintf("%3.0f",$err_2H*100),"\n";
print OUT "TOTAL 3H DISS:     ",sprintf("%3d",$total_3H)," :",sprintf("%5.0f",$ftotal_3H*100)," +/-",sprintf("%3.0f",$err_3H*100),"\n";
print OUT "TOTAL 4H DISS:     ",sprintf("%3d",$total_4H)," :",sprintf("%5.0f",$ftotal_4H*100)," +/-",sprintf("%3.0f",$err_4H*100),"\n";
print OUT "TOTAL CH4:         ",sprintf("%3d",$total_CH4)," :",sprintf("%5.0f",$ftotal_CH4*100)," +/-",sprintf("%3.0f",$err_CH4*100),"\n";
print OUT "Total:             $total   Found nstep condition in : $found trajectories\n";
close(OUT);

# %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
sub find_last_step{
  $fstep=0;
  open(IN,$file) or warn "Cannot open $file";
  while(<IN>){
    if (/STEP/){
      chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
      chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
      ($gb,$fstep,$gb,$gb,$gb,$gb,$st)=split(/\s+/,$_);
    }
  }
  close(IN);
  #print OUT "DEBUG: Last step of TRAJ $n is $fstep\n";
}
# %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
sub find_nstep{
  $fstep=0;
  open(IN,$file) or warn "Cannot open $file";
  $count=0;
  while(<IN>){
    if (/STEP/){
      chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
      chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
      ($gb,$kstep,$gb,$gb,$gb,$gb,$st)=split(/\s+/,$_);
      if ($st == $state){
	$count++;
	if ($count == $nstep){
	   $fstep = $kstep;
	   last;
	}
      }elsif($st != $state){
	      # $count = 0;
      }
    }
  }
  close(IN);
  if ($fstep != 0){
    $found++;
  }
  #print OUT "DEBUG: Last step of TRAJ $n is $fstep\n";
}
# %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
sub check_st{
  $st = 0;
  open(IN,$file) or warn "Cannot open $file";
  while(<IN>){
     if (/STEP/){
       chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
       ($gb,$step,$gb,$gb,$gb,$gb,$st)=split(/\s+/,$_);
       if ( abs($step-$fstep) < $eps ){
	  last;
       }
     }
  }
}
# %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
sub get_geom{
  open(IN,$file) or warn "Cannot open $file";
  while(<IN>){
     if (/STEP/){
       chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
       ($gb,$step,$gb,$gb,$gb,$gb,$st)=split(/\s+/,$_);
       # print OUT "DEBUG: TRAJ $n STEP $step FSTEP $fstep\n";
       if ( abs($step-$fstep) < $eps ){
         print OUT "TRAJ $n STEP $fstep\n";
         while(<IN>){
           if (/New geometry/){
	     for ($i=0;$i<=$nat-1;$i++){
	       $_=<IN>;
               chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
	       ($gb,$gb,$x[$i],$y[$i],$z[$i])=split(/\s+/,$_);
	       printf OUT "%9.3f %9.3f %9.3f \n",$x[$i],$y[$i],$z[$i];
             }
	   }    
	 }
       }
     }
  }
  close(IN); 
}
# %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
sub check_struct{
  $H_in_C1=0;
  $H_in_C2=0;

  $dC1H1=dist(0,2);
  $dC2H1=dist(1,2);
  if ($dC1H1 < $dC2H1){
    if ($dC1H1 < $thres){
      $H_in_C1++;
    }
  }else{
    if ($dC2H1 < $thres){
      $H_in_C2++;
    }
  }    

  $dC1H2=dist(0,3);
  $dC2H2=dist(1,3);
  if ($dC1H2 < $dC2H2){
    if ($dC1H2 < $thres){
      $H_in_C1++;
    }
  }else{
    if ($dC2H2 < $thres){
      $H_in_C2++;
    }
  }

  $dC1H3=dist(0,4);
  $dC2H3=dist(1,4);
  if ($dC1H3 < $dC2H3){
    if ($dC1H3 < $thres){
      $H_in_C1++;
    }
  }else{
    if ($dC2H3 < $thres){
      $H_in_C2++;
    }
  }

  $dC1H4=dist(0,5);
  $dC2H4=dist(1,5);
  if ($dC1H4 < $dC2H4){
    if ($dC1H4 < $thres){
      $H_in_C1++;
    }
  }else{
    if ($dC2H4 < $thres){
      $H_in_C2++;
    }
  }
  #
  print OUT "H_in_C1 = $H_in_C1 H_in_C2 = $H_in_C2: ";
  # Ethyledene
  $ethd=0;
  if ( ($H_in_C1 == 3) and ($H_in_C2 == 1) ){
    $ethd=1;
    print OUT "1.1\n";
  }elsif( ($H_in_C2 == 3) and ($H_in_C1 == 1) ){
    $ethd=1;
    print OUT "1.2\n";
  }
  $total_etd = $total_etd + $ethd;
  # Ethylene
  $ethn=0;
  if ( ($H_in_C1 == 2) and ($H_in_C2 == 2) ){
    $ethn=1;
    print OUT "2.1\n";
  }
  $total_eth = $total_eth + $ethn;
  # H Diss
  $hdiss=0;
  if ( ($H_in_C1 == 3) and ($H_in_C2 == 0) ){
    $hdiss=1;
    print OUT "3.1\n";
  }elsif( ($H_in_C2 == 3) and ($H_in_C1 == 0) ){
    $hdiss=1;
    print OUT "3.2\n";
  }elsif( ($H_in_C1 == 2) and ($H_in_C2 == 1)){
    $hdiss=1; 
    print OUT "3.3\n";
  }elsif( ($H_in_C2 == 2) and ($H_in_C1 == 1)){
    $hdiss=1; 
    print OUT "3.4\n";
  }
  $total_H = $total_H + $hdiss;
  # 2H Diss
  $h2diss=0;
  if ( ($H_in_C1 == 2) and ($H_in_C2 == 0) ){
    $h2diss=1;
    print OUT "4.1\n";
  }elsif( ($H_in_C2 == 2) and ($H_in_C1 == 0) ){
    $h2diss=1;
    print OUT "4.2\n";
  }elsif( ($H_in_C1 == 1) and ($H_in_C2 == 1) ){
    $h2diss=1;
    print OUT "4.3\n";
  }
  $total_2H = $total_2H + $h2diss;
  # 3H Diss
  $h3diss=0;
  if ( ($H_in_C1 == 1) and ($H_in_C2 == 0) ){
    $h3diss=1;
    print OUT "5.1\n";
  }elsif( ($H_in_C2 == 1) and ($H_in_C1 == 0) ){
    $h3diss=1;
    print OUT "5.2\n";
  }
  $total_3H = $total_3H + $h3diss;
  # 4H Diss
  $h4diss=0;
  if ( ($H_in_C1 == 0) and ($H_in_C2 == 0) ){
    $h4diss=1;
    print OUT "6.1\n";
  }
  $total_4H = $total_4H + $h4diss;
  # CH4
  $ch4=0;
  if ( ($H_in_C1 == 4) and ($H_in_C2 == 0) ){
    $ch4=1;
    print OUT "7.1\n";
  }elsif( ($H_in_C2 == 4) and ($H_in_C1 == 0) ){
    $ch4=1;
    print OUT "7.2\n";
  }
  $total_CH4 = $total_CH4 + $ch4;
}
# %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
sub dist{
  my ($d,$ic,$ih);
  ($ic,$ih)=@_;
  $d = sqrt( ($x[$ic]-$x[$ih])**2 + ($y[$ic]-$y[$ih])**2 + ($z[$ic]-$z[$ih])**2 );
  return $d;
}
# %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
