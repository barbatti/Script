#!/usr/bin/perl -w
# Find ethyledene structures at the end of ethylene dynamics.
# MB 2020-12-27

$traji=1;
$trajf=500;
$state=1;
$nat=6;
$eps=0.01;
$thres=3.77945; # au (3.77945 au = 2 Angstrom)

open(OUT,">ethyledene_count.log");

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
  if ( abs($st - $state) < $eps ){
    get_geom();
    check_struct();
  }else{
     $total_exc++;
  }
}
$total=$total_etd+$total_eth+$total_H+$total_2H+$total_3H+$total_4H+$total_CH4+$total_exc;
$ftotal_etd=$total_etd/$total;
$ftotal_eth=$total_eth/$total;
$ftotal_H=$total_H/$total;
$ftotal_2H=$total_2H/$total;
$ftotal_3H=$total_3H/$total;
$ftotal_4H=$total_4H/$total;
$ftotal_CH4=$total_CH4/$total;
$ftotal_exc=$total_exc/$total;
print "TOTAL ETHYLEDENES: $total_etd :", $ftotal_etd,"\n";
print "TOTAL ETHYLENES: $total_eth :", $ftotal_eth,"\n";
print "TOTAL 1H DISS: $total_H :",$ftotal_H,"\n";
print "TOTAL 2H DISS: $total_2H :",$ftotal_2H,"\n";
print "TOTAL 3H DISS: $total_3H :",$ftotal_3H,"\n";
print "TOTAL 4H DISS: $total_4H :",$ftotal_4H,"\n";
print "TOTAL CH4: $total_CH4 :",$ftotal_CH4,"\n";
print "TOTAL EXCITED: $total_exc :",$ftotal_exc,"\n";
print "Total: $total\n";
print OUT "TOTAL ETHYLEDENES: $total_etd\n";
print OUT "TOTAL ETHYLENES: $total_eth\n";
print OUT "TOTAL 1H DISS: $total_H\n";
print OUT "TOTAL 2H DISS: $total_2H\n";
print OUT "TOTAL 3H DISS: $total_3H\n";
print OUT "TOTAL 4H DISS: $total_4H\n";
print OUT "TOTAL CH4: $total_CH4\n";
print OUT "TOTAL EXCITED: $total_exc\n";
print OUT "Total: $total\n";
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
