#!/usr/bin/perl -w

# %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
# Output converter for molecular dynamics analysis
#         Gunther Zechmann, July 2005
# %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

# analysing the torsional mode with Moldyn may give
# discontinuities of Pi and/or 2*Pi of the torsion
# as a function of time. This should be fixed with
# this script. Futhermore, it adds one column at the
# end of the file in order to indicate the current
# surface the system is moving on.

$pi=3.14159265358979;
$file="prop.3";        # input file for the modes
$file2="prop.2";       # input file for the current surface
$th=$pi/2;             # threshold
$maxangle = 4;         # maximum of (absolute) angle of torsion in units of pi
$n=0;                  # dummy

open (IN, $file)             || die "Cannot open $file";
open (IN2, $file2)           || die "Cannot open $file2";
open (OUT, ">$file".".mod")  || die "Cannot open $file".".mod";

while (<IN>) {
  @line=split(" ",$_);
  
  if ($line[1] == "0.00") {
  
    # the first line of each trajectory we have to modify
    # manually, from the second line on we can do it by
    # comparison with the previous one.
    @line1 = @line;
    # @line1=@line1[2..5];  # the four torsional angles (cis, 2x trans, cis)
    # the cis angles might be close to a discontinuity, so let's check
    if ($line1[2] gt $th) {
      $line1[2] -= 2*$pi;
    }
    if ($line1[5] gt $th) {
      $line1[5] -= 2*$pi;
    }
  
  } else {
  
    # compare $line[2] to $line[5]:
    for ($tmp = 1; $tmp <= $maxangle; $tmp++) {
      # fixes the problem that there may be discontinuities
      # of Pi as well as of 2*Pi.
      $n=2;
      foreach $i (@line[2..5]) {
        if (abs($i-$line1[$n]) gt $th) {
          #if ($line1[0] eq "6") {
          #  if ($line1[1] eq "12.50") {
          #    print "@line1\n";
          #    print "@line\n";
          #  }
          #}
          if ($line1[$n]-$i gt 0) {
            # we're jumping from Pi to 0
            $i += $pi;
          } elsif ($line1[$n]-$i lt 0) {
            # we're jumping from 0 to Pi
            $i -= $pi;
          }
        } # if abs...
        $n++;
      } # foreach
    } # for 1..2
  
    # before switching to the next line we have
    # to assign the new array to the old one
    @line1=@line;
    
  } # if 1st line  

  # get the surface
  $s1 = <IN2>;
  @surf=split(" ", $s1);
  
printf OUT " %3d %7.2f   %10.7f   %10.7f   %10.7f   %10.7f   %10.7f   %10.7f %2d\n", @line1, $surf[3];
} # while (<IN>)

close (IN);
close (IN2);
close (OUT);
