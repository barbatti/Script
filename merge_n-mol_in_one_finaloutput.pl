#!/usr/bin/perl -w
# You have final_output for two or more molecules.
# Each one has the same number of initial conditions.
# You want to merge them to create a supermolecule.
# This what is done by this script.
# Attention: it does not take care of necessary aligments or spurious overlaps!
#
# Mario Barbatti, Feb 2010.
#

$fo="final_output";

input_info();
check_files();
merge_files();

# ================================================================================
sub input_info{
  print "How many final_output files should be merged? (2) ";
  $n_files=get_answer("2");
  if ($n_files < 2){
    die "Number of file must be larger or equal two.\n";
  }else{
    print "Number of files to be merged: $n_files\n";
  }
}
# ================================================================================
sub check_files{
  # for each file
  $nat[0]=0;
  $ncard[0]=0;
  for ($i=1;$i<=$n_files;$i++){
    # check existence
    if (!-s "$fo.$i"){
       die "File $fo.$i does not exist or is empty. Check input files and run again.\n";
    }else{
       print "Found file $fo.$i\n";
    }
    # check number of atoms
    $nat[$i]=num_at($i);
    if ($nat[$i] == 0){
       die "Number of atoms in $fo.$i is zero. Check file and run again.\n";
    }else{
       print "Number of atoms in $fo.$i = $nat[$i]\n";
    }
    # check number of cards
    $ncard[$i]=0;
    open(FO,"$fo.$i") or die "Cannot read $fo.$i \n";
    while(<FO>){
      if (/Initial condition =/){
         chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
         @g=split(/\s+/,$_);
         $ncard[$i]=$g[3];
      }
    }
    close(FO);
    if ($ncard[$i] == 0){
      die "Cannot find initial conditions in $fo.$i. Check file and run again.\n";
    }else{
      print "Number of initial conditions in $fo.$i = $ncard[$i]\n";
    }
  }
  # check consistency of number of cards
  for ($i=2;$i<=$n_files;$i++){
    if ($ncard[$i] != $ncard[$i-1]){
      die "$fo.$i and $fo.",$i-1," have different number of initial conditions. Check files and run again.\n";
    }
  }
}
# ================================================================================
sub merge_files{
  use FileHandle;
  open(FM,">$fo.merged") or die "Cannot write $fo.merged \n";
  for ($i=1;$i<=$n_files;$i++){
    $FO[$i] = new FileHandle;
    $FO[$i]->open("$fo.$i") or die "Cannot read $fo.$i \n";
  }

  $a1=$FO[1];
  while(<$a1>){
    if (/Geometry in/){
       # write geometry 1
       print FM "$_";
       for ($n=1;$n<=$nat[1];$n++){
          $_=<$a1>;
          print FM "$_";
       }
       # append other geometries
       for ($i=2;$i<=$n_files;$i++){
          $a2=$FO[$i];
          while(<$a2>){
            if (/Geometry in/){
              for ($n=1;$n<=$nat[$i];$n++){
                 $_=<$a2>;
                 print FM "$_";
              }
              last;
            }
          }
       }
    }elsif(/Velocity in/){
       print FM "$_";
       # write velocity 1
       for ($n=1;$n<=$nat[1];$n++){
          $_=<$a1>;
          print FM "$_";
       }
       # append other velocities
       for ($i=2;$i<=$n_files;$i++){
          $a2=$FO[$i];
          while(<$a2>){
            if (/Velocity in/){
              for ($n=1;$n<=$nat[$i];$n++){
                 $_=<$a2>;
                 print FM "$_";
              }
              last;
            }
          }
       }
    }else{
       print FM "$_";
    } 
  }

  for ($i=1;$i<=$n_files;$i++){
    $FO[$i]->close;
  }
  close(FM);
}
#  ================================================================================
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
# ================================================================================
sub num_at{
  my ($na,$i);
  ($i)=@_;
  $na = 0;
  open(FO,"$fo.$i") or die "Cannot read $fo.$i \n";
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
# ================================================================================
