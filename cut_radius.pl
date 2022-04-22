#!/usr/bin/perl -w

$natcore=15;
$natsolv= 3;
$radius = 5;

open(OUT,">reduced_geom.xyz") or die "reduced_geom.xyz";
open(IN,"dyn.xyz") or die ":( dyn.xyz";

$k=1;
while(<IN>){

print "STRUCTURE $k\n";
$k++;

chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
$nattot=$_;
$_=<IN>;

$nsolv=($nattot-$natcore)/$natsolv;

open(M1,">m1.xyz") or die ":( m1.xyz";
print M1 "$natcore\n\n";
for ($i=1;$i<=$natcore;$i++){
  $_=<IN>;
  print M1 $_; 
}
close(M1);

$nfs=0;
open(AS,">allsolvs") or die ":( allsolvs";
for ($i=1;$i<=$nsolv;$i++){
  open(M2,">m2.xyz") or die ":( m2.xyz";
  print M2 "$natsolv\n\n";
  for ($j=1;$j<=$natsolv;$j++){
    $_=<IN>;
    print M2 $_;
  }
  close(M2);
  run_cmdist();
  if ($dist <= $radius){
    open(M2,"m2.xyz") or die ":( m2.xyz";
    $_=<M2>;
    $_=<M2>;
    while(<M2>){
      print AS $_;
    }
    close(M2);
    $nfs++;
  }
}
close(AS);

$natftot=$natcore+$nfs*$natsolv;

print OUT "$natftot\n\n";

open(M1,"m1.xyz") or die ":( m1.xyz";
$_=<M1>;
$_=<M1>;
while(<M1>){
  print OUT $_;
}
close(M1);

open(AS,"allsolvs") or die ":( allsolvs";
while(<AS>){
  print OUT $_;
}
close(AS);

}

close(OUT);

system("rm -f allsolvs m1.xyz m2.xyz dist_two_frags.out");

sub run_cmdist{
  system("short-dist_two_frags.pl");

  open(IND,"dist_two_frags.out") or die ":( dist_two_frags.out"; 
  while(<IND>){
    if (/Distance between center of masses/){
       chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
       @g=split(/\s+/,$_);
       $dist=$g[6];
       last;
    }
  }
  close(IND);
}
