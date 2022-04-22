#!/usr/bin/perl -w

  print "\n Select jobs to be killed (comma separated list, e.g., 6-9,11,13): ";
  $_=<STDIN>;
  chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
  @list=make_num_sequence($_);

  print " The following jobs will be killed: @list\n";
  print " Do you want to continue? (y/n)";
  $_=<STDIN>;
  chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
  $order=$_;
  if ($order eq "y"){ 
    foreach (@list){
      $r=`qdel $_`;
      print "Killing job $_ --> $r";
    }
  }else{
    print " Noting was done.\n";
  }

#------------------------------------------------------------------------------
sub make_num_sequence{
#
# Takes a positive integer sentence like "1,5-7,10-13,9,15"
# and returns: (1,5,6,7,9,10,11,12,13,15).
# Returns error if sentence contains A-Z characters.
# Redundancies are eliminated.
# Initial sentence do not need to be sorted.
#
# Usage:
# $line="1,5-7,10-13,9,15";
# @my_sequence=make_num_sequence($line);
#
my ($line,@vector,$i,@a,$k,@s,$last_seen);
  ($line)=@_;
  chomp($line);
  $line=~s/\s+//g;                    # elimilate spaces
  if ($line =~ /[A-Z]/){
    die "ND\n";                       # check whether it contain A-Z charac.
  }
  @vector=split(/,/,$line);           # split at comma
  $i=0;
  foreach(@vector){
    if (/-/){
      @s=split(/-/,$_);               # split at dash
      for ($k=$s[0];$k<=$s[1];$k++){
        $a[$i]=$k;                    # accumulates sequence
        $i++;
      }
    }else{
      $a[$i]=$_;                      # accumulates sequence
      $i++;
    }
  }
  @a=sort{$a<=>$b} @a;                # sort numerical array
  $last_seen=-1.1;
  $i=0;
  foreach(@a){                        # eliminate redundancies
    if ($_ != $last_seen){
      $vector[$i]=$_;
      $i++;
    }
    $last_seen=$_;
  }
  return @vector;                     # return sequence
}
#------------------------------------------------------------------------------
