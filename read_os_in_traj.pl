#!/usr/bin/perl -w
  $BASEDIR=`pwd`;
  chomp($BASEDIR);
  $myperl="/home3/barbatti/PERL_FILES/";

  print "Target state (1)";
  $target_state=get_answer("1");
  print "Collecting oscillator strength between current state and state $target_state.\n";

  print "Initial trajectory (1)";
  $traji=get_answer("1");
  print "Initial trajectory $traji.\n";

  print "Final trajectory (10)";
  $trajf=get_answer("10");
  print "Final trajectory $trajf.\n";

  open(OUT,">os-trajs.dat") or die ":( os-trajs.dat";
  open(OUT1,">os-trajs_1.dat") or die ":( os-trajs_1.dat";
  for ($i=$traji;$i<=$trajf;$i++){
    if (-s "TRAJ$i/RESULTS/"){
      print "... STARTING TRAJECTORY $i ...\n";
      chdir("TRAJ$i/RESULTS/");
      $max_time=mxtime($i);
      open(INP,">inp_read_os") or die ":( inp";
      print INP "$target_state\n";
      print INP "$max_time\n";
      print "... Max time: $max_time\n";
      close(INP);
      system("$myperl/read_os_in_prop.pl < inp_read_os");
      system("rm -f inp_read_os");
      if (-s "os.dat"){
         open(OS,"os.dat") or die ":( os.dat";
         while(<OS>){
            printf OUT "%4d  $_",$i; 
            chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
            ($time,$g,$g,$os)=split(/\s+/,$_);
            print OUT1 "$time  $os\n"; 
         }
         close(OS);
         print OUT "\n";
      }
      chdir("$BASEDIR");
    }
  }
  close(OUT);
  close(OUT1);

# =================================================================================

sub mxtime{
  my ($i,$max_time,$traj,$time);
  ($i)=@_;
  $max_time="";
  if (-s "$BASEDIR/time_list"){
    open(TL,"$BASEDIR/time_list") or die ":( $BASEDIR/time_list";
    while(<TL>){
       chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
       ($traj,$time)=split(/\s+/,$_);
       if ($traj == $i){
         $max_time=$time;
       }
    }
    close(TL);
  }
  return $max_time;
}

# =================================================================================

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

