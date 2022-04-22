#!/usr/bin/perl -w
# For each point in the dynamics, read geom in dyn.out and calls Columbus
# to get oscillator strengths. Then, properties is written.
# Mario Barbatti 2021-01-29
#
use lib join( '/', $ENV{"NX"}, "lib" );
use colib_perl;
use Cwd;
$mdle = "recompute:";
$BASEDIR = &getcwd();

#open(IN,"inp-rec") or die "Missing inp-rec!";
#$_=<IN>;
#chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
#$itraj=$_;
#$_=<IN>;
#chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
#$ftraj=$_;
#close(IN);

#print "TRAJ I:";
#$_=<STDIN>;
#chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
#$itraj = $_;

#print "TRAJ F:";
#$_=<STDIN>;
#chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
#$ftraj = $_;

$itraj = $ARGV[0];
$ftraj = $ARGV[1];

$mocoeff = "mocoef_mc.sp";
#$kt=1;

if (!-s "$BASEDIR/JOB_TEMPLATE"){
  die "JOB_TEMPLATE does not exist. Create it and run again.\n";
}

read_mycontrol();

for ($i=$itraj;$i<=$ftraj;$i++){
	#print "TRAJ = $i\n";
  open(PP,">$BASEDIR/TRAJ$i/RESULTS/properties");
  execdir();
  # get_mocoef_list();
  read_traj();
  close(PP);
  system("rm -rf $BASEDIR/TEMP$i");
}

# ==========================================================================
sub read_mycontrol{
  open(IN,"$BASEDIR/TRAJ$itraj/RESULTS/nx.log") or warn "Cannot read TRAJ$i/RESULTS/nx.log!\n";
  while(<IN>){
    if (/Nat /i){
       chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
       ($grb,$grb,$nat)=split(/\s+/,$_);
    }
    if (/Nstat /i){
       chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
       ($grb,$grb,$nstat)=split(/\s+/,$_);
    }
    if (/prog /i){
       chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
       ($grb,$grb,$prog)=split(/\s+/,$_);
       last;
    }
  }
  close(IN);
  #print "NAT   = $nat\n";
  #print "NSTAT = $nstat\n";
  #print "PROG  = $prog\n";
  #print "BASEDIR = $BASEDIR\n";
}
# ==========================================================================
sub execdir{
  if (-s "$BASEDIR/TEMP$i"){
    system("rm -rf $BASEDIR/TEMP$i");
  }
  system("mkdir $BASEDIR/TEMP$i");
  if (-s "$BASEDIR/JOB_TEMPLATE"){
     system("cp -f $BASEDIR/JOB_TEMPLATE/* $BASEDIR/TEMP$i/.");
  }
}
# ==========================================================================
#sub get_mocoef_list{
#  $k = 0;
#  opendir my $dir, "$BASEDIR/TRAJ$i/DEBUG" or die "Cannot open directory: $!";
#  my @files = readdir $dir;
#  closedir $dir;
#  foreach(@files){
#    if (/COL./){
#      ($grb,$mc[$k])=split(/COL./,$_);
#      $k++;
#    }
#  }
#  @mcf = sort {$a <=> $b} @mc;
#  #foreach(@mcf){
#  #  print "$_\n";
#  #}
#}
# ==========================================================================
sub read_traj{
  open(IN,"$BASEDIR/TRAJ$i/RESULTS/dyn.out") or warn "Cannot read TRAJ$i/dyn.out!\n";
  while(<IN>){
    if (/STEP /){
       chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
       (@garb)=split(/\s+/,$_);
       $istep   =$garb[1];
       $nstatdyn=$garb[6];
       $t       =sprintf("%.4f",$garb[9]);
       #print "TRAJ $i Step $istep State $nstatdyn Time $t fs\n";
       print PP "\n TIME (fs): $t    STEP: $istep    CURRENT STATE: $nstatdyn \n";
       #1. GEOM
       while(<IN>){
         if (/ geometry:/){
	   system("rm -f $BASEDIR/TEMP$i/geom");
           open(OUT,">$BASEDIR/TEMP$i/geom") or warn "Cannot write TEMP$i/geom\n";
	   for ($na=0;$na<=$nat-1;$na++){
	      $_=<IN>;
	      print OUT $_;
	      #print $_;
	   }
	   close(OUT);
	   last;
	 }
       }
       #2. MOCOEF
       #foreach(@mcf){
       #  if ($_ <= $t){
       #    $point=sprintf("%.4f",$_);
       #    system("cp -f $BASEDIR/TRAJ$i/DEBUG/COL.$point/$mocoeff.gz $BASEDIR/TEMP$i/.");
       #    last;
       #  }elsif(-s "$BASEDIR/TEMP$i/MOCOEF/$mocoeff"){
       #    system("cp -f $BASEDIR/TEMP$i/MOCOEF/$mocoeff $BASEDIR/TEMP$i/mocoef");
       # }
       #}
       #
       #2. MOCOEF
       if(-s "$BASEDIR/TEMP$i/MOCOEF/$mocoeff"){
         system("cp -f $BASEDIR/TEMP$i/MOCOEF/$mocoeff $BASEDIR/TEMP$i/mocoef");
       }

       #3. PREPARE
       chdir("$BASEDIR/TEMP$i");
       if (-s $mocoeff){
         system("rm -f mocoef");
	 system("gunzip $mocoeff.gz");
       }
       system("rm -rf GEOMS/ GRADIENTS/ LISTINGS/ MOCOEFS/ MOLDEN/ RESTART/ WORK/ COSMO/ runls runc.error curr_iter");
       #4. EXCECUTE
       system("\$COLUMBUS/runc -m 500 > runls 2> /dev/null");
       #5. Read
       read_write_oos();
       chdir("../");
    }
  }
  close(IN);
}
# ==========================================================================
sub read_write_oos{
# Read and write oscllator strengths
  for ( $is = 2; $is <= $nstat; $is++ )
  {
    for ( $js = 1; $js <= $is - 1; $js++ )
    {
      $file1 = "LISTINGS/trncils\.FROMdrt1\.state$is" . "TOdrt1\.state$js";
      $file2 = "LISTINGS/trncils\.FROMdrt1\.state$js" . "TOdrt1\.state$is";
      $file3 = "LISTINGS/transls\.FROMdrt1\.state$is" . "TOdrt1\.state$js";
      $file4 = "LISTINGS/transls\.FROMdrt1\.state$js" . "TOdrt1\.state$is";
      if ( ( -s $file1 ) or ( -s $file2 ) or ( -s $file3 ) or ( -s $file4 ) )
      {
        $value = osc_strength( $mdle, $is, $js, $prog );
        ( $OOS, $dx, $dy, $dz ) = split( /,/, $value );
	#printf_STDOUT($istep,$kt," Oscillator strength (%d,%d) = %9.6f \n",$is,$js,$OOS);
        printf PP
          " Trans. dipole components (x,y,z) e*bohr: %12.6f %12.6f %12.6f \n",
          $dx, $dy, $dz;
        printf PP " Oscillator strength (%d,%d) = %9.6f \n", $is, $js, $OOS;
      }
    }
  } ## end for ( $is = 2; $is <= $nstat...
  #print_STDOUT("\n",$istep,$kt);
} ## end sub read_write_oos
# ==========================================================================
