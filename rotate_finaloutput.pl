#!/usr/bin/perl -w
# Given a final_output file and a xyz reference file, 
# this script rotates each initial condition to superimpose it with the reference.
# Atoms must have the same orde in both files.
# The result is written to final_output.new file.
# Velocities are not tranformed. They may not make sense afterwards.
#
# Mario Barbatti, Feb 2010
#
use lib join('/',$ENV{"NX"},"CPAN") ;
use colib_perl;
$mld     = $ENV{"NX"};
$au2ang  =units("au2ang");
$pycaller="~plasserf/bin/programs/py_caller";

$fo="final_output";
$log="rotate_finaloutput.log";
open(LOG,">$log") or die "Cannot write to $log\n";

input_info();
check_files();
rotate();

print "Results are written to $fo.new \n\n";
print LOG "Results are written to $fo.new \n\n";
close(LOG);

# =======================================================================================
sub input_info{
  print "What is the name of the xyz reference structure? (geom.xyz) ";
  $ref=get_answer("geom.xyz");
  if (!-s $ref){
    die "Reference file does not exist or is empty. Check input and run again.\n";
  }else{
    print LOG "Reference file: $ref\n";
  }
}
# =======================================================================================
sub check_files{
  # check final_output
  if (!-s $fo){
    die "$fo does not exist or is empty. Check input and run again.\n";
  }else{
    print LOG "$fo was found\n";
  }
  # check number of atoms
  $nat=num_at();
  if ($nat == 0){
     die "Number of atoms in $fo is zero. Check file and run again.\n";
  }else{
     print LOG "Number of atoms in $fo = $nat\n";
  }  
  # check number of atoms in reference
  open(RF,"$ref") or die "Cannot read $ref";
  $_=<RF>;
  chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
  close(RF);
  $natref=$_;
  print LOG "Number of atoms in $ref = $natref\n";
  # check consistency between number of atoms
  if ($nat != $natref){
    die "Number of atoms in $fo ($nat) and in $ref ($natref) are different. Fix it and run again.\n";
  }else{
    print LOG "Number of atoms: $nat \n";
  }
  # check atoms order (only label)
  open(RF,"$ref") or die "Cannot read $ref";
  $_=<RF>;
  $_=<RF>;
  for ($i=0;$i<=$nat-1;$i++){
    $_=<RF>;
    chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
    @g=split(/\s+/,$_);
    $lref[$i]=uc($g[0]);
  }
  close(RF);
  open(FO,"$fo") or die "Cannot read $fo";
  while(<FO>){
    if (/Geometry in/){
      for ($i=0;$i<=$nat-1;$i++){
        $_=<FO>;
        chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
        @gfo=split(/\s+/,$_);
        $lfo[$i]=uc($gfo[0]);
      }
      last;
    }
  }
  close(FO);
  for ($i=0;$i<=$nat-1;$i++){
    print LOG "Atom ",$i+1,": REF: $lref[$i]    final_output: $lfo[$i]\n";
    if ($lref[$i] ne $lfo[$i]){
       die "At least one label in the reference does not match final_output. Check it and run again.\n";
    }
  }
  print LOG "$ref and $fo seems to have the same sequence of atoms.\n";
}
# =======================================================================================
sub rotate{
  $fout="$fo.new";
  open(FN,">$fout") or die "Cannot write $fout";
  open(FO,"$fo") or die "Cannot read $fo";
  print "Please, wait ";
  $nc=0;
  while(<FO>){
    if (/Geometry in/){
      print FN "$_";
      print LOG "card $nc:\n";
      print "...";
      $nc++;
      # write auxiliary XYZ geom file 
      open(GA,">geom-aux.xyz") or die "Cannot write geom-aux.xyz";
      print GA " $nat\n\n";
      for ($i=0;$i<=$nat-1;$i++){
         $_=<FO>;
         chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
         ($symbol,$grb,$x,$y,$z,$grb)=split(/\s+/,$_);
         $x=$x*$au2ang;
         $y=$y*$au2ang;
         $z=$z*$au2ang;
         printf GA ("%7s  %15.6f  %15.6f   %15.6f\n", $symbol,$x,$y,$z);
      }
      close(GA);
      # sumperimpose
      system("rm -f SI_geom-aux.xyz");
      system("$pycaller superimpose.py $ref geom-aux.xyz >>$log");
      # back to NX format
      $ind=0;
      if (-s "geom"){
        system("mv geom geom.old");
        print LOG "An pre-existent geom file was renamed to geom.old\n";
        $ind=1;
      }
      system("$mld/xyz2nx < SI_geom-aux.xyz");
      # read new geometry and write it
      open(NG,"geom");
      while(<NG>){
        print FN "$_";  
      }
      close(NG);
      # clean up
      system("rm -f geom-aux.xyz SI_geom-aux.xyz");
      if ($ind == 1){
        system("mv geom.old geom");
        print LOG "geom.old was renamed back to geom\n";
      }else{
        system("rm -f geom");
      }
    }else{
      print FN "$_";
    }
  }
  close(FO);  
  close(FN);
  print "...\n";
}
# =======================================================================================
sub get_answer{
  my ($ans,$def);
  ($def)=@_;
  $_=<STDIN>;
  chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
  if ($_ eq ""){
    $ans=$def;
  }else{
    $ans=$_;
  }
  return $ans;
}
# =======================================================================================
sub num_at{
  my ($na);
  $na = 0;
  open(FO,"$fo") or die "Cannot read $fo \n";
  while (<FO>){
    if (/Geometry in/){
       while (<FO>){
          $na++;
          if (/Velocity in/){
            $na=$na-1;
            last;
          }
       }
       last;
    }
  }
  close(FO);
  return $na;
}
# =======================================================================================
