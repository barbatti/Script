#!/usr/bin/perl -w

print "Computes definition of Pulay's coordinates using Columbus.\n";
print "Usage: internal_coord.pl [geom], where [geom] is geometry file\n";
print "in Columbus/NX format. (Default = geom)\n\n";

$col = $ENV{"COLUMBUS"}; 

if (-s "geom_temporary"){
  system("rm -f geom_temporary");
}

if (!defined $col){
  die "\$COLUMBUS variable not defined. \n";
}else{
  print "COLUMBUS = $col\n";
}

if (defined $ARGV[0]){
  $geom = $ARGV[0];
}else{
  $geom = "geom";
}

if (!-s $geom){
  die "$geom does not exist or is empty. \n";
}

$ind=0;
if (-s "geom"){
  if ($geom ne "geom"){
    system("mv -f geom geom_temporary");
  }
}else{
  $ind=1;
}
system("cp -f $geom geom"); 

open(IN,">sete");
print IN "7";
close(IN);
system("$col/makintc.x < sete");
system("$col/intc.x  >> intcls");

if (-s "geom_temporary"){
  system("mv -f geom_temporary geom");
}
system("rm -f sete intcls bummer icoordtyp  intcin  intcky");
if ($ind==1){
  system("rm -f geom");
}

if (!-s "intcfl"){
  print "Something went wrong: internal coordinate definition was not generated!\n";
}else{
  print "Internal coordinate definition written to intcfl.\n";
}

