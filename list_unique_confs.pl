#!/usr/bin/perl -w
# Look at final_output and lists the unique CC2 main conformations.

@collection=0;
$lg=47;
open(IC,"initcond.log") or die ":( initcond.log";
open(LOG,">unique.log") or die ":( unique.log";
open(UQ,">list-unique.log") or die ":( list-unique.log";

while(<IC>){
  if (/occ. orb.  index spin/){
    $_=<IC>;
    $_=<IC>;
    $str=substr($_,0,$lg);
    print LOG "$str\n";
    $exist="F";
    foreach(@collection){
      #print "Comparing /$str/ with /$_/\n";
      if ($str eq $_){
        $exist="T";
      }
    }
    if ($exist eq "F"){
      push(@collection,$str);
    }
  }
}
close(IC);
$i=0;
foreach(@collection){
  print UQ "$i:    $_\n";
  $i++;
}
# count
$total=0;
open(UQ,"list-unique.log") or die ":( list-unique.log";
while(<UQ>){
   ($grb,$str)=split(/:/,$_);
   chomp($str);$str =~ s/^\s*//;$str =~ s/\s*$//;
   $grb =~ s/^\s*//;$grb =~ s/\s*$//;
   if ($grb != 0){
     $number=qx(grep -c "$str" unique.log);
     print "$str   :  $number";
     $total=$total+$number;
   }
}
close(UQ);
print "Total = $total\n";
