#!/usr/bin/perl -w
# Read Verlet log and write coordinates of each step to geom.istep

$verlet="runverlet.opt.txt";

n_atoms();
labels();
read_verlet();

# --------------------------------------------------------------------------
sub read_verlet{
  $n=0;
  open(IN,$verlet) or die ":( $verlet";
  while(<IN>){
    if (/coordinate/){
      open(OUT,">coord") or die ":( coord";
      print OUT "\$coord\n";
      for ($i=0;$i<=$nat-1;$i++){
        $_=<IN>;
        chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
        print OUT " $_  $label[$i]\n";
      }
      print OUT "\$user-defined bonds\n\$end\n";
      close(OUT);
      system("\$NX/tm2nx");
      system("mv geom geom.$n");
      $n++;
    }
  }
  close(IN);
}
# -------------------------------------------------------------------------- 
sub n_atoms{
  open(IN,$verlet) or die ":( $verlet";
  while(<IN>){
    if (/coordinates/){
      chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
      ($grb,$nat)=split(/\s+/,$_);
      $grb="";
      print "NAT = $nat\n";
      last;
    }
  }
  close(IN);
}
# --------------------------------------------------------------------------
sub labels{
  open(IN,$verlet) or die ":( $verlet";
  while(<IN>){
    if (/#Dynamics:/){
      for ($i=0;$i<=$nat-1;$i++){
        $_=<IN>;
        chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
        ($label[$i])=split(/\s+/,$_);
        print "LABEL $i = $label[$i]\n";
      }
    }
  }
  close(IN);
}
# --------------------------------------------------------------------------

