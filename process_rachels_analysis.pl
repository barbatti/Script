#!/usr/bin/perl -w
# This program processes the output of Rachel's state analysis.
# It writes convoluted f x E, CT x E, and DOS x E files.
# For each of these three quantities, the convolution is made 
# with help of the program spectrum_convolution.pl.
# The inputs for spectrum_convolution.pl are defined in the code
# below (see USER INPUTS). Normalization of the results can be
# done with variabvle $norm:
# $norm = n - no normalization
#         y - normalize area to 1
#         m - normalize maximum to 1 
# Besides convolution, this program also sorts the results 
# according to the state class.
#
# Mario Barbatti, July 2012

if (@ARGV<1){
  $f_ips="contributions";
}else{
  $f_ips = $ARGV[0];
}

$aux="aux-inp";

$q=" Suffix (default = no suffix):";
$suf=question($q,"");

# .......................USER INPUTS..........................
# Inputs for f run
  $label="f_x_E";
  $colx=2;
  $coly=3;
  $l_shape=1;
  $DE=0.4;
  $dx=0.005;
  $auto_domain="y";
  $conv="n";
  $norm="m"; 
  run_spect_conv();

# Inputs for CT run
  $label="CT_x_E";
  $colx=2;
  $coly=4;
  $l_shape=1;
  $DE=0.05;
  $dx=0.005;
  $auto_domain="y";
  $conv="n";
  $norm="m";
  run_spect_conv();

# Inputs for DOS run
  $label="dos_x_E";
  $colx=2;
  $coly=0;
  $l_shape=1;
  $DE=0.05;
  $dx=0.005;
  $auto_domain="y";
  $conv="n";
  $norm="m";
  run_spect_conv();
# ............................................................

# Reorder E levels
  reorder_E();

system("rm -f $aux");

#==============================================================
sub run_spect_conv{
  write_aux_inp();
  print_inp();
  exec_spect();
  if ($norm eq "y"){
    normalize();
  }elsif($norm eq "m"){
    norm_max();
  }
}
#==============================================================
sub write_aux_inp{
  open(IN,$f_ips) or die ":( $f_ips";
  open(OUT,">$aux") or die ":( $aux";
  $ind=0;
  while(<IN>){
    if (/Class/){
      $ind=1;
    }
    if ($ind==1){
      print OUT "$_";
    }
  }
  close(OUT);
  close(IN);
}
#==============================================================
sub print_inp{
  open(IN,">inp") or die ":( inp";
  print IN "$colx\n";
  print IN "$coly\n";
  print IN "$l_shape\n";
  print IN "$DE\n";
  print IN "$dx\n";
  print IN "$auto_domain\n";
  print IN "$conv\n\n";
  close(IN); 
}
#==============================================================
sub exec_spect{
 system("spectrum_convolution.pl $aux < inp > /dev/null 2>&1");
 system("mv spect_conv.dat $label-$suf.dat");
 system("rm -f inp");
}
#==============================================================
sub normalize{
  my ($i,@x,@f,$N);
  # .............. Trapezoidal integration ....................
  open(IN,"$label-$suf.dat") or die ":( $label-suf.dat";
  $_=<IN>;
  $i=0;
  $sum=0.0;
  while(<IN>){
    chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
    ($x[$i],$f[$i])=split(/\s+/,$_);
    $sum=$sum+2.0*$f[$i];
    $i++;    
  }  
  close(IN);
  $N=$i-1;
  $sum=$sum-$f[0]-$f[$N];
  $integ=($x[$N]-$x[0])/(2*$N)*$sum;
  print STDOUT "Integral: $integ\n";
  # ...........................................................
  open(OUT,">$label-$suf.aux") or die "$label-$suf.dat";
  for ($i=0 ; $i<=$N ; $i++){
    printf OUT "%12.4f   %16.8f\n",$x[$i],$f[$i]/$integ;
  }
  close(OUT);
  system("mv -f $label-$suf.aux $label-$suf.dat");
}
#==============================================================
sub norm_max{
  my ($i,@x,@f,$N);
  open(IN,"$label-$suf.dat") or die ":( $label-suf.dat";
  $_=<IN>;
  $i=0;
  $fmax = 0;
  while(<IN>){
    chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
    ($x[$i],$f[$i])=split(/\s+/,$_);
    if ($f[$i] > $fmax){
      $fmax = $f[$i];
    }
    $i++;    
  }  
  close(IN);  
  if ($fmax <= 0.0001){
    $fmax = 1;
  }
  $N=$i-1;
  open(OUT,">$label-$suf.aux") or die "$label-$suf.dat";
  for ($i=0 ; $i<=$N ; $i++){
    printf OUT "%12.4f   %16.8f\n",$x[$i],$f[$i]/$fmax;
  }
  close(OUT);
  system("mv -f $label-$suf.aux $label-$suf.dat");
}
#==============================================================
sub reorder_E{
# CTA->B,CTB->A,DELOC,LOC(A),LOC(B)
  my ($aux1,$cta,$ctb,$del,$lca,$lcb,@h);
  open(IN,"$aux") or die ":( $aux";
  $_=<IN>;
  $cta="";
  $ctb="";
  $del="";
  $lca="";
  $lcb="";
  while(<IN>){
    chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
    (@h)=split(/\s+/,$_);
    $aux1=sprintf("  0     %10.4f  %9s\n",$h[1],$h[8]);
    if ($h[8] eq "CTA->B"){
      $cta=$cta.$aux1;
    }
    if ($h[8] eq "CTB->A"){
      $ctb=$ctb.$aux1;
    }
    if ($h[8] eq "deloc"){
      $del=$del.$aux1;
    }
    if ($h[8] eq "loc(A)"){
      $lca=$lca.$aux1;
    }
    if ($h[8] eq "loc(B)"){
      $lcb=$lcb.$aux1;
    }
  }
  close(IN);
  if ($cta eq ""){
    $cta=sprintf("  0     %10.4f  %9s\n",0,"CTA->B");
  }
  if ($ctb eq ""){
    $ctb=sprintf("  0     %10.4f  %9s\n",0,"CTB->A");
  }
  if ($del eq ""){
    $del=sprintf("  0     %10.4f  %9s\n",0,"deloc");
  }
  if ($lca eq ""){
    $lca=sprintf("  0     %10.4f  %9s\n",0,"loc(A)");
  }
  if ($lcb eq ""){
    $lcb=sprintf("  0     %10.4f  %9s\n",0,"loc(B)");
  }
  open(OUT,">sorted_E-$suf.dat") or die ":( sorted_E-$suf.dat";
  print OUT $cta;
  print OUT $ctb;
  print OUT $del;
  print OUT $lca;
  print OUT $lcb;
  close(OUT);
}
#==============================================================
sub question{
  my ($q,$def,$answer);
  ($q,$def)=@_;
  print STDOUT " $q";
  $_=<STDIN>;
  chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
  if ($_ eq ""){
    $answer = $def;
  }else{
    $answer=$_;
  }
  return $answer;
}
#==============================================================

