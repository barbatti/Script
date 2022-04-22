#!/usr/bin/perl -w
# For one trajectory calculates the time spent between the first stamp like:
# "Starting runai.pl at Thu May  1 14:52:40 CEST 2008"
# and the last stamp like:
# "Finished runai.pl successfuly at Thu May  1 15:22:42 CEST 2008"
# in nx.log file
# Run it in TRAJi directory.
#
# Mario Barbatti, May 2008
use Time::Local;
get_strings();

#$sti="Starting runai.pl at Thu May  1 14:52:40 CEST 2008";
scalar_t($sti);
get_localtime($scalartime);
$time_ini=$time;

#$stf="Finished runai.pl successfuly at Thu May  1 15:22:42 CEST 2008";
scalar_t($stf);
get_localtime($scalartime);
$time_end=$time;

$dt=$time_end-$time_ini;
print "  $dt seconds \n";

# ---------------------------------------------------------------------------
sub get_strings{
  $file="RESULTS/nx.log";
  if (!-s $file){
     $file="moldyn.log";
     if (! -s $file){
        die "Cannot find either moldyn.log or RESULTS/nx.log.";
     }
  }
  open(FL,$file) or die ":( $file";
  while(<FL>){
     if (/Starting ru/){
        $sti=$_;
        last;
     }
  }
  close(FL);
  open(FL,$file) or die ":( $file";
  while(<FL>){
     if (/Finished ru/){
        $stf=$_;
     }
  }
}
# ---------------------------------------------------------------------------
sub scalar_t{
   my ($st,$g);
  ($st)=@_;
  ($g,$_)=split(/ at/,$st);
  chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
  $scalartime=$_;
}
# ---------------------------------------------------------------------------
sub get_localtime{
  my($scalartime,$sec,$min,$hours,$mday,$mon,$wday,$year,$k,@g,@wd,@mo);
  ($scalartime)=@_;

  @g=split(/\s+/,$scalartime);

  @wd=qw(Sun Mon Tue Wed Thu Fri Sat);
  $k=0;
  foreach(@wd){
    if ($g[0] eq $_){
      $wday=$k; 
    }
    $k++;
  }

  @mo=qw(Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec);
  $k=0;
  foreach(@mo){
    if ($g[1] eq $_){
      $mon=$k;
    }
    $k++;
  }

  $mday=$g[2];
 
  ($hours,$min,$sec)=split(/:/,$g[3]);

  $year=$g[5]-1900;

  $time=timelocal($sec,$min,$hours,$mday,$mon,$year);

}
