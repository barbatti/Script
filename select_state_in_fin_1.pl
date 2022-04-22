#!/usr/bin/perl -w
#

log_files();

input_data();

read_initcond();

select_cards();

# =======================================================================================
sub log_files{
 $i=1;
 $log="select_state_in_fin.log";
 $out="select_state_in_fin.out";
 $dir="SELECT-$i";
 while (-s $dir){
   $i++;
   $dir="SELECT-$i";
 }
 mkdir $dir;
 open(LOG,">$dir/$log") or die "$dir/$log";
 open(OUT,">$dir/$out") or die "$dir/$out";
}

# =======================================================================================
sub input_data{
 print "Enter pattern to be searched (Eg:/29 a       29       \\|   30 a       30/):\n";
 $_=<STDIN>;
 chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
 $pattern=$_;
 print LOG "PATTERN = $pattern\n";

 $ilog="initcond.log";
 open(IL,$ilog) or die ":( $ilog";
 while(<IL>){
   # method
   if (/PROG    =/){
     chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
     ($g,$g,$prog)=split(/\s+/,$_);
     print LOG "PROG = $prog\n";
   }
   # nis
   if (/NIS     =/){
     chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
     ($g,$g,$nis)=split(/\s+/,$_);
     print LOG "NIS  = $nis\n\n";
   }
   # nfs 
   if (/NFS     =/){
     chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
     ($g,$g,$nfs)=split(/\s+/,$_);
     print LOG "NFS  = $nfs\n\n";
     last;
   }
 }
 close(IL);
}

# =======================================================================================
sub read_initcond{
 open(IL,$ilog) or warn ":(  $ilog";
 $card0 = "n";
 while(<IL>){
   if (/Starting vertical energy calculation./){
     $card0 = "y";
   }
 }
 close(IL);

 open(IL,$ilog) or die ":( $ilog";
 if ($card0 eq "y"){
   while(<IL>){
     if (/Starting vertical energy calculation./){
       last;
     }
   }
 }
 $ind=0;
 while(<IL>){
   # state
   if (/Information about the excited states:/){
     $found = "n";
     $ind++;
     if ($prog == 2.0){
        for_cc2();
     }
   }
 }
 close(IL);
 close(OUT);
}
# =======================================================================================
sub print_info{
     if ($found eq "y"){
        print OUT "$ind  $state  $weight\n";
        print LOG "$nst $ind  $state  $coeff  $weight\n";
     }else{
        print LOG "$nst $ind  not found   0   0\n";
     }
}
# =======================================================================================
sub for_cc2{
  $nst=0;
  while(<IL>){
    if (/state:/){
      $nst++;
      chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
      @g=split(/\s+/,$_);
      $state=$g[6]+1;
      $_=<IL>;$_=<IL>;$_=<IL>;$_=<IL>;
      if ($_ =~ /$pattern/){
        $found = "y";
        chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
        @g=split(/\s+/,$_);
        $coeff =$g[9];
        $weight=$g[10];
      }
      print_info(); 
      $found = "n";
      if ($nst == $nfs-1){
        last;
      }
    }
  }  
}
# =======================================================================================
sub select_cards{
  if ($nfs > $nis){
    for ($i=$nis+1;$i<=$nfs;$i++){
      push(@state_vec,$i);
    }
  }else{
    for ($i=$nfs;$i<=$nis-1;$i++){
      push(@state_vec,$i);
    }
  }

  print LOG "States to be searched: @state_vec\n";

  foreach(@state_vec){
    $ind_st=$_;

    $fin="final_output.$nis.$ind_st";
    print LOG "Starting state $ind_st, file: $fin\n";
    open(FI,"$fin") or warn ":( $fin";
    open(FIN,">>$dir/$fin") or die ":( $dir/$fin";

    open(OUT,"$dir/$out") or die ":( $dir/$out";
    while(<OUT>){
      chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
      ($ind,$state,$weight)=split(/\s+/,$_);
      if ($state == $ind_st){
        while(<FI>){
          if (/Initial condition =/){
             chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
             @g=split(/\s+/,$_);
             $card=$g[3];
             if ($card == $ind){
               print LOG "Card $card of state $state was found.\n";
               print FIN " $_\n";
               while(<FI>){
                 print FIN $_;
                 if (/Oscillator strength:/){
                   print FIN "\n\n";
                   last;
                 }
               }
               last;
             }
          }
        }
      }      
    }
    close(OUT);

    close(FIN); 
    close(FI);
  }
  system("cp -f $dir/$fin $dir/final_output");
}
# =======================================================================================
