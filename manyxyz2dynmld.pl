#!/usr/bin/perl -w

#=====================================================
# Enter file names here:
# Eg. @files=(file1,file2);
@files=(0 .. 18);
#=====================================================

$q="Delete initial files afterwards? (y/n, default:n)";
$delete=question($q,"n");

open(OUT,">merged.xyz") or die "Cannot write merged.xyz!";
foreach(@files){
  $file_name=$_;
  print "...$file_name\n";
  open(INP,$file_name) or die "Cannot read $file_name!";
  while(<INP>){
    print OUT $_; 
  }
  close(INP);
  if ($delete eq "y"){
    system("rm -f $file_name");
  }
}
close(OUT);

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

