#!/usr/bin/perl -w
# Read time tags in nx.log like:
# Starting run_cioverlap_turbo.pl  at Sat Sep 24 15:30:34 CEST 2016
# Finished run_cioverlap_turbo.pl  successfuly at Sat Sep 24 15:30:34 CEST 2016
# and compute time difference.
#
use Time::Local;
use Date::Parse;
open(OUT,">get_times_in_traj.out") or die ":( get_times_in_traj.out.";

$finp="nx.log";
$prog=question("Read times for which program? (default: run_cioverlap_turbo.pl)","run_cioverlap_turbo.pl");
$mxstp=question("Read up to which time step? (default: 10000)",10000);
$tstp = 0;
$a=0;
$sum=0;
$n=0;
open(IN,$finp) or die "Cannot find $finp! Program dies here.\n";
while(<IN>){
  if (/Starting/){
    if (/$prog/){
      chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
      $line=$_;
      ($ds,$year)=time_tag($line);
      $ts=str2time ($ds) ;
      #$ts=convert($ds);  ## This is an alternative version
      while(<IN>){
         if (/Finished/){
           if (/$prog/){
             chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
             $line=$_;
             ($df,$year)=time_tag($line);
             $tf=str2time ($df) ;
             #$tf=convert($df);
             $dtfs=$tf-$ts;
             print OUT " $n   $ts  $tf   $dtfs\n";
             $sum=$sum+$dtfs;
             $n++;
             last;
           }
         }
      }
    }
  }elsif (/FINISHING STEP/){
    chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
    @h=split(/\s+/,$_);
    $tstp=$h[4];
  }
  if ($tstp >= $mxstp){
     last;
  }
}
close(IN);
$mean=$sum/$n;
print OUT "\n SUM = $sum   MEAN = $mean\n";

close(OUT);

# ===================================================================================
sub time_tag{
  my ($line)=@_;
  ($a,$b)=split(/ at /,$line);
  @g=split(/\s+/,$b);
  $year = $g[5];
  $ds = "$g[1] $g[2] $g[3]";
  return $ds,$year;
}

# ===================================================================================
# Convert your date strings to Unix/perl style time in seconds
# The main problems you have here are:
# * parsing the date formats
# * converting the month string to a number from 1 to 11
sub convert
{
    my $dstring = shift;

    my %m = ( 'Jan' => 0, 'Feb' => 1, 'Mar' => 2, 'Apr' => 3,
            'May' => 4, 'Jun' => 5, 'Jul' => 6, 'Aug' => 7,
            'Sep' => 8, 'Oct' => 9, 'Nov' => 10, 'Dec' => 11 );

    if ($dstring =~ /(\S+)\s+(\d+)\s+(\d{2}):(\d{2}):(\d{2})/)
    {
        my ($month, $day, $h, $m, $s) = ($1, $2, $3, $4, $5);
        my $mnumber = $m{$month}; # production code should handle errors here

        timelocal( $s, $m, $h, $day, $mnumber, $year - 1900 );
    }
    else
    {
        die "Format not recognized: ", $dstring, "\n";
    }
}

# ===================================================================================
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
  print OUT " $q  $answer \n";
  return $answer;
}
