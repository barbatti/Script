#!/usr/bin/perl -w
# This script replaces the submission script in the TRAJECTORIES directory.

print " Enter initial trajectory: ";
$_=<STDIN>;
chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
$it=$_;

print " Enter final trajectory: ";
$_=<STDIN>;
chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
$ft=$_;

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
for ($i=$it;$i<=$ft;$i++){
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

