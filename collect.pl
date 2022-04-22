#!/usr/bin/perl

# %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
# Molecular dynamics analysis
#        Collect data
# Mario Barbatti, June 2005.
# %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

$mld  = $ENV{"NX"};        # NX environment
use lib join('/',$ENV{"COLUMBUS"},"CPAN") ;
$cbus  = $ENV{"COLUMBUS"};                    # Columbus environment

$AN = "ANALYSIS";

# Define files
$trj   = "../TRAJ";
$res   = "RESULTS";
$en    = "en.dat";
$do    = "dyn.out";
$in    = "intec";
$pp    = "prop";
$pi    = "$pp.inp";
$pn    = "$pp.n";
$pa    = "$pp.aux";
$pb    = "$pp.aux-b";

# Initial parameters
 open(CT, $pn)                                  || die "Cannot open $pn!";
 @prmt=<CT>;
 close(CT);
 foreach $w (@prmt)
 {
  chop($w);
  ($itrj,$jtrj,$tmin,$tmax,$dt,$proptype,$nstat,$nic,$bmat,$nat,@iclist)=split(/,/,$w);
 }
$tmin=$tmin*1;
$tmax=$tmax*1;

# Collect data for trajectory ntraj
open(NT,"trajaux")                              || die "Cannot open trajaux";
$ntraj = <NT>;
chomp($ntraj);
$ntraj = $ntraj*1;
close(NT);

# Data will be collected up to time tmxccol
$tmxcol = $tmax;
mxtime();

# PROPTYPE = 1: Energy analysis

if ($proptype == 1) {

  $t = $tmin;
  open(DO,"$trj"."$ntraj/$res/$do")               || warn "Cannot open $trj"."$ntraj/$res/$do.";
  open(PAX,">>$pa")                               || die  "Cannot open $pa to write.";
  while (<DO>) {

    if ($t < $tmxcol){
      chomp($_);
      if (/Molecular dynamics on/) {                             # Get surface
        (@g)=split(/\s+/,$_);
        $surf = $g[6];
      }
      if (/%/) {                                                 # Get time and energies
        ($g9,$t,@energies)=split(/\s+/,$_);
        $ns = $surf + 1;
        print PAX "$ntraj  $t $energies[$ns]  @energies \n";
      }
    } else {
      last;
    }

  }
  close(DO);
  close(PAX);
}

# PROPTYPE = 2: Wave function analysis

if ($proptype == 2) {

  $t = $tmin;
  open(DO,"$trj"."$ntraj/$res/$do")               || warn "Cannot open $trj"."$ntraj/$res/$do.";
  open(PAX,">>$pa")                               || die  "Cannot open $pa to write.";
  while (<DO>) {

     if ($t < $tmxcol){
      chomp($_);
      if (/Molecular dynamics on/) {                    # Get surface and time
        (@g)=split(/\s+/,$_);
        $surf = $g[6];
        $t    = $g[9];
        if ($t == 0) {
          $surf_prev = $surf;
        }
      }
      if (/Wave function/) {                            # Get wave functioncoefficients
        (@wave)=split(/\s+/,$_);
        $Re[0]=$wave[5];
        $Im[0]=$wave[6];
        for ($istat = 1; $istat <= $nstat-1; $istat++) {
          $_ = <DO>;
          chomp($_);
          (@wave)=split(/\s+/,$_);
          $Re[$istat]=$wave[5];
          $Im[$istat]=$wave[6];
        }
        print PAX "$ntraj  $t $surf_prev $surf $surf_prev.$surf @Re @Im \n";
        $surf_prev = $surf;
      }
    } else {
      last;
    }

  }
  close(DO);
  close(PAX);
}

# PROPTYPE = 3: Internal coordinates analysis

if ($proptype == 3) {

  if ($bmat == 1) {                                                 # Run BMAT

    $t = $tmin;
    $in = "intec_new";
    open(IN,">$trj"."$ntraj/$res/$in") || die  "Cannot open $trj"."$ntraj/$res/$in to write.";
    open(DO,"$trj"."$ntraj/$res/$do")  || warn "Cannot open $trj"."$ntraj/$res/$do.";

    while (<DO>) {

      if ($t < $tmxcol){

        if (/Molecular dynamics on/) {                              # Get time
          (@g)=split(/\s+/,$_);
          $t    = $g[9];
        }

        if (/geometry:/) {                                          # Get geometry
          open(GM,">geom")                         || die  "Cannot open geom to write.";
          for ($igeo = 1; $igeo <= $nat; $igeo++) {
            $_ = <DO>;
            print GM "$_";
          }
          close(GM);
          system("$cbus/cart2int.x < cart2intin > cart2int.ls");      # Run cart2int
          open(IG,"intgeom")                       || die  "Cannot open intgeom.";
          print IN "Time $t \n      internal coordinates \n \n";      # Write intec_new
          $intnum = 1;
          while (<IG>) {
            print IN " $intnum  $_ ";
            $intnum++;
          }
          close(IG);
        }                                                      # end  if (/geometry:

      } else {
        last;
      }

    }                                                                # end  while (<DO>) { ...

  }                                                                  # end  if ($bmat == 1 ...

  close(DO);
  close(IN);

# ........... Just to delete a blank space before "Time" ...
open(INN,">$trj"."$ntraj/$res/$in.n")               || die "Cannot open $in.n";
open(IN, "$trj"."$ntraj/$res/$in")                  || die "Cannot open $in";
$dir_complete = "$trj"."$ntraj/$res/";
while(<IN>) {
  chomp $_;
  if (/ Time/) {
    (@v1)=split(/\s+/,$_);
    print INN "Time  $v1[2] \n" ;
  } else {
    print INN "$_ \n";
  }
}
close(IN);
close(INN);

system("cp -f $dir_complete/$in.n $dir_complete/$in");
system("rm -f $dir_complete/$in.n");
# ........................................................

open(IN,"$trj"."$ntraj/$res/$in")                 || warn "Cannot open $trj"."$ntraj/$res/$in.";
open(PAX,">>$pa")                                 || die  "Cannot open $pa to write.";
  while (<IN>) {
  chomp($_);
    if (/Time/) {                                                    # Get time
    ($garb3,$t)=split(/\s+/,$_);
      $_  = <IN>;                                                    # jump two garbage lines...
      $_  = <IN>; 
      $jic    = 0;
      while ($jic < $nic) {
        $_= <IN>;
        chomp($_);
        ($garb3,$indcount,$icoord)=split(/\s+/,$_);
        if ($indcount == $iclist[$jic]) {
        $ic_collect[$jic] = $icoord ;
        $jic = $jic + 1;
        }
      }
    print PAX "$ntraj $t @ic_collect \n";  
    }
  }

}

# PROPTYPE = 4: Internal forces analysis

if ($proptype == 4) {

  $t = $tmin;
  open(IN,"$trj"."$ntraj/$res/$in")        || warn "Cannot open $trj"."$ntraj/$res/$in.";
  open(PAX,">>$pa")                        || die  "Cannot open $pa to write.";

  while (<IN>) {
    if ($t <= $tmxcol){
      chomp($_);
      if (/Time/) {                                        # Get time
        ($garb3,$t)=split(/\s+/,$_);
        $_  = <IN>;                                        # jump two garbage lines...
        $_  = <IN>;
        $jic    = 0;
        while ($jic < $nic) {
          $_= <IN>;
          chomp($_);
          ($garb3,$indcount,$icoord,$fcoord)=split(/\s+/,$_);
          if ($indcount == $iclist[$jic]) {
            $ic_collect[$jic] = $fcoord ;
            $jic = $jic + 1;
          }
        }
        print PAX "$ntraj $t @ic_collect \n";
      }
    } else {
      last;
    }
  }

}

sub mxtime{
# Read diag.log and return tmxcol
  $diag = "../diag.log";
  if (-s $diag){
    $nt = 0;
    open(DG,$diag) or die "Cannot open $diag to read!";
    while(<DG>){
       chomp;
       if (/TRAJECTORY/){        # get traj number
         ($grb,$nt)=split(/\s+/,$_);
         chop($nt);
       }
       if ($nt == $ntraj){
         while(<DG>){
            if (/Suggestion/){   # get tmxcol
              chomp;
              ($grb,$grb,$grb,$grb,$grb,$grb,$tmxcol)=split(/\s+/,$_);
              print STDOUT "\nTraj. $nt: only data up to $tmxcol fs will be used. \n";
              last;
            }
         }
       last;
       }
    }
    close(DG);
  }
}
