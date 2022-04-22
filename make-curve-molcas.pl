#!/usr/bin/perl -w
#
# After generating DISPLACEMENT directory using disp.pl routine in COLUMBUS,
# this routine can be used to copy files and generate input for MOLCAS jobs.
# File molcas.template containing MOLCAS inpput should be provided.
# The routine create in each DISPLACEMENT/CALC* directory a complete input
# composed by molcas.inp, INPORB (optional), and pmolcas (optional batch script).
# geom2molcas and compose-molcas.pl are used.
# Mario Barbatti, Sept 2007
#
$DIR="/home/barbatti/PERL_FILES";

if (!-s "molcas.template"){
  die "molcas.template does not exist or is empty!";
}

print " Coordinate number [default = 1]:";
$_=<STDIN>;
chomp;
$_ =~ s/^\s*//;         # remove leading blanks
$_ =~ s/\s*$//;         # remove trailing blanks
if ($_ eq ""){
  $c = 1;
}else{
  $c=$_;
}

print " Initial displacement [default = 0]:";
$_=<STDIN>;
chomp;
$_ =~ s/^\s*//;         # remove leading blanks
$_ =~ s/\s*$//;         # remove trailing blanks
if ($_ eq ""){
  $id = 0;
}else{
  $id=$_;
}

print " Final displacement [default = 10]:";
$_=<STDIN>;
chomp;
$_ =~ s/^\s*//;         # remove leading blanks
$_ =~ s/\s*$//;         # remove trailing blanks
if ($_ eq ""){
  $fd = 10;
}else{
  $fd=$_;
}

print " Job name [default = jmc]:";
$_=<STDIN>;
chomp;
$_ =~ s/^\s*//;         # remove leading blanks
$_ =~ s/\s*$//;         # remove trailing blanks
if ($_ eq ""){
  $name = "jmc";
}else{
  $name=$_;
}

if (!-s "DISPLACEMENT"){
  die "DISPLACEMENT directory does not exist!";
}

for ($i=$id;$i<=$fd;$i++){
  if (!-s "DISPLACEMENT/CALC.c$c.d$i"){
    die "DISPLACEMENT/CALC.c$c.d$i does not exist!";
  }else{
    system("cp -f INPORB molcas.template pmolcas DISPLACEMENT/CALC.c$c.d$i/.");
    chdir("DISPLACEMENT/CALC.c$c.d$i");
    if (!-s "geom"){
      die "geom does not exist or is empty!";
    }
    if (-s "pmolcas"){
      change_pmolcas();
    }
    system("$DIR/compose-molcas.pl");
    chdir("../../");
  }
}
#...............................................
sub change_pmolcas{
   system("mv -f pmolcas pmolcas-temp");
   open(PMT,"pmolcas-temp") or die ":( pmolcas-temp";
   open(PM,">pmolcas") or die ":( pmolcas";
   while(<PMT>){
      if (/-N/){
         ($before)=split(/-N/,$_);
         $before =~ s/\s*$//;         # remove trailing blanks
         print PM "$before -N $name.$i \n";
      }else{
         print PM $_;
      }
   }
   close(PM);
   close(PMT);
   system("rm -f pmolcas-temp");
}
