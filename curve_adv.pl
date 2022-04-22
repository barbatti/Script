#!/usr/bin/perl -w

print "Enter Method: ";
$_=<STDIN>;
chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
$method=$_;
print "Enter number of states: ";
$_=<STDIN>;
chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
$ns=$_;

open(CI,">curvein") or die ":( curvein";
print CI "$method $ns\n";
close(CI);

system("\$COLUMBUS/curve.pl > curve.out");

open(CO,"curve.out") or die ":( curve.out";
while(<CO>){
  if (/Distances:/){
    $n=0;
    while(<CO>){
       chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
       if (/==/){
         $nmax = $n-1;
         last;
       }
       $d[$n]=$_;
       $n++;
    }
  }
}
close(CO);

for ($n=0;$n<=$nmax;$n++){
 $e[$n]="";
}
for ($i=1;$i<=$ns;$i++){
  open(CO,"curve.out") or die ":( curve.out";
  while(<CO>){
    if ((/MCSCF ENERGY:/) and (/$i/)){
       for ($n=0;$n<=$nmax;$n++){
         $_=<CO>;
         chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
         $e[$n]=$e[$n]." ".$_;
       }
    }
    if ((/CI ENERGY:/) and (/$i/)){
       for ($n=0;$n<=$nmax;$n++){
         $_=<CO>;
         chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
         $e[$n]=$e[$n]." ".$_;
       }
    }
    if ((/CI\+Q ENERGY:/) and (/$i/)){
       for ($n=0;$n<=$nmax;$n++){
         $_=<CO>;
         chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
         $e[$n]=$e[$n]." ".$_;
       }
    }
  }
  close(CO);
}

open(OUT,">energy.dat") or die ":( energy.dat";
for ($n=0;$n<=$nmax;$n++){
  printf OUT "%3d %9.4f $e[$n]\n",$n,$d[$n];
}
close(OUT);
