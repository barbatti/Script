#!/usr/bin/perl -w
# This script replaces the submission script in the TRAJECTORIES directory.

@list=(103,113,123,139,143,144,148,157,158,15,16,17,19,1,20,21,24,26,28,3,46,48,54,57,62,64,81,8,96,98);

$pmd="pmold";
print " Submission script (Default: pmold): ";
$_=<STDIN>;
chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
if ($_ ne ""){
  $pmd=$_;
}
if (!-s $pmd) {die "Cannot find $pmd!";}

findname();
print " Batch type: <$batch>\n";

$name = "title";
print " Job title (Default: title): ";
$_=<STDIN>;
chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
if ($_ ne ""){
  $name=$_;
}

## .. Make the magic ..................................................
foreach(@list){
$i=$_;
   open(PM,$pmd) or die "Cannot open $pmd";
   open(PA,">$pmd.aux") or die "Cannot open $pmd.aux";
   while(<PM>) {
      $test4 = index($_,$batch);
      if ($test4 >= 0) {
         print PA "$batch $name.$i \n";
         print " Changing Traj. $i\n";
      }else{
         print PA $_;
      }
   }
   system("mv -f $pmd.aux TRAJ$i/$pmd");
}

# ....................................................................
sub findname{
  my ($srch,@field);
  $srch="";

  open(SF,$pmd) || die "Cannot open $pmd";

  while(<SF>){
    chomp;
    $srch="-N";
    if (/$srch/i) {
      @field = split(/$srch/,$_);
      $batch = "$field[0]-N";
      last;
    }
  }
}

