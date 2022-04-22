#!/usr/bin/perl -w
# Reorder a dyn.mld file using log of get_geom_in_dyn.pl program:
#TRAJ:     1  TIME:   678.00 (fs)  PES_I:   2 PES_F:   1 DE:     0.31 (eV) -> POSITIVE MATCH:     1 
#TRAJ:     2  TIME:   238.00 (fs)  PES_I:   2 PES_F:   1 DE:     0.21 (eV) -> POSITIVE MATCH:     2 
#

#$nxlog="/home3/barbatti/DYNAMICS/CYTOSINE/DYN/all_states/TRAJECTORIES_FIRST_ANALYSIS";
$fin ="dyn.mld";
$fout="dyn-reordered.mld";
$flog="get_geom_in_dyn.log";
$ft  ="time.dat";
$fm  ="conformation.dat";
open(FT,">$ft") or die ":( $ft";
open(FM,">$fm") or die ":( $fm";

initialize();

time_array();

time_reorder();

# ======================================================================================================
sub initialize{

# Number of atoms
open(IN,$fin) or die ":( $fin";
$_=<IN>;
chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
close(IN);
$nat=$_;

# Number of snapshots in dyn.mld
open(IN,$fin) or die ":( $fin";
$nlines=0;
while(<IN>){
  $nlines++;
}
close(IN);
$shots=$nlines/($nat+2);

# Number of structutes in get_geom log:
open(IG,$flog) or die ":( $flog";
while(<IG>){
  if (/POSITIVE MATCH:/){
    chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
    @g=split(/\s+/,$_);
  }
}
close(IG);
$matches=$g[15];

# Check consistency
if ($matches != $shots){
  die " Number of macthes ($matches) is not equal number of shots ($shots)";
}else{
  print " Number of macthes ($matches) is equal number of shots ($shots)\n";
}

}

# ======================================================================================================

sub time_array{
  print " Starting reordering ... \n";
  $tref=1000000;
  open(IG,$flog) or die ":( $flog";
  while(<IG>){
    if (/POSITIVE MATCH:/){
      chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
      @g=split(/\s+/,$_);
      $t[$g[15]-1]=$g[3];   # t(positive match-1)=time
      $traj[$g[15]-1]=$g[1];
      #$pesi[$g[15]-1]=$g[6];
      #$pesf[$g[15]-1]=$g[8];
    }
  }
  close(IG);
  print "Time array:@t\n";
}

# ======================================================================================================

sub time_reorder{
  my ($i);
  $trefmax=100000;
  for ($j=0;$j<=$shots-1;$j++){
    $tref=$trefmax;
    $i=0;
    foreach(@t){
      if ($_<$tref){
        #print ">>>>>> $_\n";
        $tref=$_;
        $imin=$i;
      }
      $i++;
    }
    print FT " $t[$imin]\n";
    #print FM " $traj[$imin] $t[$imin]\n";
    print_geom_imin();
    find_print_conf();
    $t[$imin]=$trefmax;
  }
}

# ======================================================================================================

sub print_geom_imin{
  my($i);
  print " Printing shot $imin corresponding to time $t[$imin].\n";
  open(FO,">>$fout") or die ":( $fout";
  open(IN,"$fin") or die ":( $fin";
  $i=0;
  $initial_line=($imin)*($nat+2)+1;
  $final_line=$initial_line+$nat+1;
  print " IL = $initial_line   FL = $final_line\n";
  while(<IN>){
    $i++;
    if (($i >= $initial_line) and ($i <= $final_line)){
      print FO "$_";
    }
  }
  close(IN);
  close(FO);  
}

# ======================================================================================================

sub find_print_conf{
#  $nxlog="$adress/TRAJ$traj($imin)/RESULTS/nx.log";
#  if (-s $nxlog){
#    open(NL,$nxlog) or warn ":( $nxlog";
#    while(<NL>){
#      if (/\bdt\b/){
#        chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
#        ($grb,$grb,$dt)=split(/\s+/,$_);
#        last;        
#      }
#    }
#    $t_before=$t[$imin]-$dt;  
#    while(<NL>){
#      if (/, TIME/){
#        chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
#        ($grb,$grb,$grb,$grb,$time_step)=split(/\s+/,$_);
#        if ($ime_step == $time_before){
#          last; 
#        }
#      }
#    }  
#    while(<NL>){
#      if (/ ENERG/){
#        # Find conformations for pes_i and pes_f
#      }
#    }
#    close(NL);
#  }else{
#    $conf="=====  not found  ====";
#  }
  $conf="not found";
  if (-s "history"){
    open(HT,"history") or die ":( history";
    while(<HT>){
      chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
      @h=split(/\s+/,$_);
      if ($h[0] == $traj[$imin]){
         if ($h[1] == $t[$imin]){
           print FM "@h\n";
           $conf="found";
           last;
         }
      }
    }
    close(HT);
    if ($conf eq "not found"){
      print FM "$traj[$imin]  $t[$imin]  not found\n";
    }
  }else{
    print FM "Cannot find history. Did you run stat_on_csf program before?\n";
  }
}

# ======================================================================================================

