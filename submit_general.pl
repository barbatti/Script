#!/usr/bin/perl -w

print "Submission command: ";
$_=<STDIN>;
chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
$psub = $_;

print "Directory name (eg. TRAJ10 = TRAJ): ";
$_=<STDIN>;
chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
$dir = $_;

print "Initial dir: ";
$_=<STDIN>;
chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
$id = $_;

print "Final dir: ";
$_=<STDIN>;
chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
$fd = $_;

for ($i=$id;$i<=$fd;$i++){
  change_dir();
}


#======================================================================================

sub change_dir{
  if (!-s "$dir$i"){
    die "$dir$i does not exist!";
  }else{
    chdir("$dir$i");
    system("$psub");
    chdir("../");
  }
}

