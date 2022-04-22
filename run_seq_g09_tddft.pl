#!/usr/bin/perl -w

# Input section ----------------------------------------
$finp="gaussian.inp";
$fcom="gaussian.com";
$fout="gaussian.log";
$tmpout="tmp.out";
$tmpcom="tmp.com";
# ------------------------------------------------------

print "Starting program\n";
open(TC,$tmpcom) or die ":( tmpcom";
$_=<TC>;
chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
$nat=$_;
close(TC);
print "Number of atoms $nat\n";

open(MI,"method.inp") or die ":( method.inp";
$_=<MI>;
chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
$method=$_;
close(MI);

if ($method eq "TDDFT-G09-GE"){
  $dir1="TDDFT_GE";
}elsif($method eq "TDDFT-G09-EE"){
  $dir1="TDDFT_EE";
}
system("rm -f $dir1/gck.chk $dir1/$fout");

open(IN,">>geom.xyz") or die ":( geom.xyz";
open(TC,$tmpcom) or die ":( $tmpcom";
while(<TC>){
  print IN $_;
}
close(TC);
close(IN);

chg_inp();

chdir("$dir1");
print "Starting TDDFT jobs\n";
system("\$g09root/g09/bsd/g09.profile;\$g09root/g09/g09 < $fcom > $fout");
chdir("../");

print "Reading output\n";
rw_out();
#
sub chg_inp{
 open(TC,"$tmpcom") or die "Cannot open $tmpcom";
 $_=<TC>;$_=<TC>;
 for ($ind1=1;$ind1<=$nat;$ind1++) {
   $row[$ind1]=<TC>;
 } 
 close(TC);
 $check=0;
 open(GIN,"$dir1/$finp") or die "Cannot open $dir1/$finp";
 open(NEW,">$dir1/$fcom") or die "Cannot open $dir1/$fcom";
 while(<GIN>){
   if (/Title1:/){
     print NEW $_;
     $_=<GIN>;
     print NEW $_;
     $_=<GIN>;
     print NEW $_;
     for ($ind1=1;$ind1<=$nat;$ind1++) {
       $_=<GIN>;
       print NEW $row[$ind1];
     } 
     $check=1;
   }else{
     print NEW $_;
   }
 }
 close(GIN);
 if ($check == 0){
   die "\n 'Title1:' pattern not found in $dir1/$finp. Check the documentation.\n\n";
 }
}
#
sub rw_out{
# Read energies
  print "Reading energies\n";
  system("rm -f $tmpout");
  open(GDO,">$tmpout") or die "Cannot open $tmpout.";
  open(GO,"$dir1/$fout") or die ":( $dir1/$fout";
  print GDO "Energies\n";
  while(<GO>){
    if ($method eq "TDDFT-G09-GE"){
      if (/SCF Done:/){
         chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
         @g=split(/\s+/,$_);
         $egs=$g[4];
         printf GDO " %9.7F\n",$egs;
      }
      if (/Total Energy,/){
         chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
         @g=split(/\s+/,$_);
         $egs=$g[4];
         printf GDO " %9.7F\n",$egs;
      }
    }elsif($method eq "TDDFT-G09-EE"){
      if (/Total Energy,/){
         chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
         @g=split(/\s+/,$_);
         $egs=$g[4];
         printf GDO " %9.7F\n",$egs;
      }
    }
  }
  close(GO);
# Read gradients
  print "Reading gradients\n";
  r_grad();
  close(GDO);
}
#
sub r_grad{
  $ng=0;
  open(GD,"$dir1/$fout") or die "Cannot open $dir1/$fout";
  while(<GD>){
    if (/Forces \(/){
      $ng++;
      $_=<GD>;$_=<GD>;
      print GDO "Gradient State$ng\n";
      for ($ind1=1;$ind1<=$nat;$ind1++) {
        $_=<GD>;
        chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
        @g=split(/\s+/,$_);
        printf GDO "%15.9F %15.9F %15.9F\n",-$g[2],-$g[3],-$g[4];
      }
    }
  }
  close(GD);
}
#
