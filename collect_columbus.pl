#!/usr/bin/perl -w

$LT="LISTINGS";

input_option();
if ($method eq "MCSCF"){
  $label="$LT/transls";
  $k=2;
  $key="MCSCF";
}elsif($method eq "MRCI"){
  $label="$LT/trncils";
  $k=3;
  $key="CI";
}else{
  die "Unknown method $method \n\n ";
}
read_transmomin($method);
read_energy();
read_os();
print_data();

#==============================================================

sub input_option{
  $_=$ARGV[0];
  $method=uc($_);
  if (($method ne "MCSCF") and ($method ne "MRCI")){
    die "Usage: collect-columbus.pl <MCSCF or MRCI> \n\n";
  }
  print "Collecting data for $method\n";
}
#==============================================================

sub read_transmomin{
  my ($method,@g,$i);
  ($method)=@_;
  $i=0;
  if (!-s "transmomin"){
    die "Cannot find transmomin or it is empty.\n\n";
  }
  open(TM,"transmomin") or die "Cannot open transmomin";
  while(<TM>){
    if (/$key/){
      while(<TM>){
        chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
        if ($_=~/C/){
          last;
        }
        @g=split(/\s+/,$_);
        $d1[$i]=$g[0];
        $s1[$i]=$g[1];
        $d2[$i]=$g[2];
        $s2[$i]=$g[3];
        $i++;
      }
      last;
    }
  }
  close(TM);
  $nlines=@s1;
  print "Reading $nlines transitions:\n";
  for ($i=0;$i<$nlines;$i++){
    print "DRT $d1[$i] state $s1[$i] -> DRT $d2[$i] state $s2[$i]\n"; 
  }
}
#==============================================================

sub read_energy{
  my (@g,$i);

  for ($i=0;$i<$nlines;$i++){
    $file="$label.FROMdrt$d1[$i].state$s1[$i]TOdrt$d2[$i].state$s2[$i]";
    print "Reading $file\n";
    open(FL,"$file") or die "Cannot open $file";
    while(<FL>){
      if (/eV/){
        chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
        @g=split(/\s+/,$_);
        $e[$i]=$g[2];
        last;
      }
    }
    close(LT);
  }
  for ($i=0;$i<$nlines;$i++){
    print "Transition energy $i: $e[$i] eV\n";
  }

}
#==============================================================

sub read_os{
  my (@g,$i);

  for ($i=0;$i<$nlines;$i++){
    $file="$label.FROMdrt$d1[$i].state$s1[$i]TOdrt$d2[$i].state$s2[$i]";
    open(FL,"$file") or die "Cannot open $file";
    while(<FL>){
      if (/Osc/){
        chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
        @g=split(/\s+/,$_);
        $os[$i]=$g[$k];
        last;
      }
    }
    close(LT);
  }
  for ($i=0;$i<$nlines;$i++){
    print "Oscilator strength $i: $os[$i]\n";
  }

}
#==============================================================

sub print_data{
  open(CC,">collect-collumbus") or die "Cannot write collect-columbus";
  for ($i=0;$i<$nlines;$i++){
    print CC "$e[$i]  $os[$i]\n";
  }
  close(CC);
}
