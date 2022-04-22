#!/usr/bin/perl -w
# Remove a set of trajectories.
# Be careful!
#
  use lib join('/',$ENV{"NX"},"lib") ;
  use colib_perl;

  print STDOUT "\n Give TRAJs to be deleted (comma separated list, e.g., 6-9,11,13): ";
  $_=<STDIN>;
  chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
  @list=make_num_sequence($_);
  if ($_ eq ""){
    $list[0]=0;
  }
  foreach(@list){
    $i=$_;
    if (-s "TRAJ$i"){
      print STDOUT "TRAJ$i: Deleting\n";
      system("rm -rf TRAJ$i");
    }else{
      print STDOUT "TRAJ$i: Not found\n";
    }
    if ($_ == 0){
      last;
    }
  }

