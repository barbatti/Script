#!/usr/bin/perl -w

my %sum_col1 = ();
my %sum_col2 = ();
my %sum_col3 = ();
my %sum_col4 = ();
my %sum_col5 = ();
my %npoints = ();

$time_min = 0.0;
$time_max = 0.0;

$i = 0;

open(PS,"prop.3") or die ":( prop.3";

while(<PS>){
   chomp;
   $_=~ s/^\s*//;
   ($ntraj,$time,$col1,$col2,$col3,$col4,$col5)=split(/\s+/,$_);
   $time = $time*1;
   $col1 = abs($col1);
   $col2 = abs($col2);
   $col3 = abs($col3);
   $col4 = abs($col4);
   $col5 = abs($col5);
   $sum_col1{$time} = $sum_col1{$time} + $col1;
   $sum_col2{$time} = $sum_col2{$time} + $col2;
   $sum_col3{$time} = $sum_col3{$time} + $col3;
   $sum_col4{$time} = $sum_col4{$time} + $col4;
   $sum_col5{$time} = $sum_col5{$time} + $col5;
   $npoints{$time}++;
   print STDOUT "time = $time npoints = $npoints{$time} \n";
   print STDOUT "ntraj = $ntraj time = $time col1 = $col1  sum1 = $sum_col1{$time} \n";
   print STDOUT "ntraj = $ntraj time = $time col2 = $col2  sum2 = $sum_col2{$time} \n";
   print STDOUT "ntraj = $ntraj time = $time col3 = $col3  sum2 = $sum_col3{$time} \n";
   print STDOUT "ntraj = $ntraj time = $time col4 = $col4  sum2 = $sum_col4{$time} \n";
   print STDOUT "ntraj = $ntraj time = $time col5 = $col5  sum2 = $sum_col5{$time} \n";
  # if ($time_min > $time){
  #    $time_min = $time;
  # }
   if ($time_max < $time){
      $time_max = $time;
   }
   if ($i == 0){
     $time_min = $time;
   }
   if ($i == 1){
     $time_new = $time;
     $dt = abs( $time_new - $time_old);
   }
   $list[$i]=$time;
   $i++;
   print STDOUT "\n tmin = $time_min  tmax = $time_max  dt = $dt \n";
}

open(OP,">p3-out.dat") or die ":(";
#foreach $t(@list){
for ($t=$time_min;$t<=$time_max;$t=$t+$dt){
   print STDOUT "time = $t npoints = $npoints{$t} \n";
   $average1 = $sum_col1{$t}/$npoints{$t};
   $average2 = $sum_col2{$t}/$npoints{$t};
   $average3 = $sum_col3{$t}/$npoints{$t};
   $average4 = $sum_col4{$t}/$npoints{$t};
   $average5 = $sum_col5{$t}/$npoints{$t};
   print OP "$t $average1 $average2 $average3 $average4 $average5 \n";
}
close (OP);

close(PS);
