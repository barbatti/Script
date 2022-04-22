#!/usr/bin/perl -w
# This program reads the occupation from mcscfls file and
# writes it to the molden file.

$ncol=8;

$LTD="LISTINGS";
$MDD="MOLDEN";
$mcf="mcscfls.sp";
$mld="molden_mo_mc.sp";
$mla="molden_mo_mc.sp.aux";
$mln="molden_mo_mc_sp.molden";
$log="add_occ.log";

open(LOG,">$log") or die ":( $log";

find_mcf();

$fdd="fdd";
$qvv="qvv";

if (!-s $LTD){die ":( $LTD"};
if (!-s $MDD){die ":( $MDD"};
if (!-s "$LTD/$mcf"){die ":( $LTD/$mcf"};
if (!-s "$MDD/$mld"){die ":( $MDD/$mld"};

number_of_basis();
eingenvalue($fdd,"\n","e");
@efdd=@eingenv;
eingenvalue($qvv,"timer: motran","c");
@eqvv=@eingenv;
occupations();
change_egv_molden();
change_occ_molden();
delete_line_after_GTO();

system("rm -f $MDD/$mla $LTD/mcscfls.aux");

# ---------------------------------------------------------

sub find_mcf{

  if (-s "$LTD/mcscfls.sp"){
    $mcf="mcscfls.sp";
  }else{
    $mcf="mcscfls.aux";
    if (-s "$LTD/mcscfls.all"){
      create_mcf();
    }else{
      die "Cannot find mcscf listing file.";
    }
  }

}
# ---------------------------------------------------------
sub create_mcf{
  open(MC,"$LTD/mcscfls.all") or die ":( $LTD/mcscfls.all";
  while(<MC>){
    if (/iteration number/){
       chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
       @g=split(/\s+/,$_);
       $niter=$g[3];
    }
  }
  close(MC);
  open(MC,"$LTD/mcscfls.all") or die ":( $LTD/mcscfls.all";
  open(MA,">$LTD/$mcf") or die ":( $LTD/$mcf";
  $niter_new=0;
  while(<MC>){
    if (/iteration number/){
       chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
       @g=split(/\s+/,$_);
       $niter_new=$g[3];
    }
    if ($niter_new == $niter){
      chomp;
      print MA "$_\n";
    }
  }
  close(MC);
  close(MA);
}
# ---------------------------------------------------------
sub number_of_basis{
 open(OF,"$LTD/$mcf") or die ":( $LTD/$mcf";
 while(<OF>){
   if (/ Total number of basis functions:/){
      chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
      @g=split(/\s+/,$_);
      $bfs=$g[5];
   }
   if (/Total number of electrons:/){
      chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
      @g=split(/\s+/,$_);
      $nel=$g[4];
   }
   if (/Number of active electrons:/){
      chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
      @g=split(/\s+/,$_);
      $nae=$g[4];
   }
   if (/Number of active orbitals:/){
      chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
      @g=split(/\s+/,$_);
      $nao=$g[4];
   }
 }
 close(OF);
 $nfdd=($nel-$nae)/2;     # Number of double occupieds
 $nqvv=$bfs-($nfdd+$nao); # Number of virtuals
 print LOG "Number of basis functions: $bfs\n";
 print LOG "Number of electrons: $nel\n";
 print LOG "Number of active electrons: $nae\n";
 print LOG "Number of active orbitals: $nao\n";
 print LOG "Number of doubly occupied orbitals: $nfdd\n";
 print LOG "Number of virtual orbitals: $nqvv\n";
}
# ---------------------------------------------------------
sub eingenvalue{
 ($string,$str_end,$type)=@_;
 #print "Looking for $string\n";
 open(OF,"$LTD/$mcf") or die ":( $LTD/$mcf";
 while(<OF>){
   if (/$string/){
      $nelem=0;
      while(<OF>){
        if ($type eq "e"){
          if ($_ ne "$str_end"){
            find_eingv();
          }else{
            last;
          }
        }elsif($type eq "c"){
          if ($_ !~ /$str_end/){
            find_eingv();
          }else{
            last;
          }
        }
      }
   }
 }
 close(OF);
 #print "N. elements in $string = $nelem\n";
}
# ---------------------------------------------------------
sub find_eingv{
 my ($i,$j);
 chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
 @g=split(/\s+/,$_);
 $npartial=@g;
 for ($i=0;$i<=$npartial-1;$i++){
   $j=$nelem+$i;
   $eingenv[$j]=$g[$i];
 }
 $nelem=$nelem+$npartial;
}
# ---------------------------------------------------------
sub occupations{
 $i0=0;
 open(OF,"$LTD/$mcf") or die ":( $LTD/$mcf";
 while(<OF>){
   if (/occ\(/){
      chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
      @g=split(/\s+/,$_);
      for ($i=0;$i<=$ncol-1;$i++){
        $j=$i0+$i;
        if ($j<$bfs){
          $occ[$j]=$g[$i+1];
        }
      }
      $i0=$i0+8;
   }
 }
 close(OF); 
}
# ---------------------------------------------------------
sub change_egv_molden{
 $i=0;
 open(MDO,"$MDD/$mld") or die ":( $MDD/$mld";
 open(MDN,">$MDD/$mla") or die ":( $MDD/$mla";
 while(<MDO>){
   if (/Ene=/){
      if ($i <= $nfdd-1){
        $ene = $efdd[$i];
      }elsif($i < $bfs-$nqvv){
        $ene = 0.0000;
      }elsif($i >= $bfs-$nqvv){
        $ene = $eqvv[$i-$bfs+$nqvv];
      }
      printf MDN " Ene= %20.10f \n",$ene;
      printf LOG " Ene= %20.10f \n",$ene;
      $i++;
   }else{
      print MDN $_;
   }
 }
 close(MDN);
 close(MDO);
}
# ---------------------------------------------------------
sub change_occ_molden{
 $i=0;
 open(MDO,"$MDD/$mla") or die ":( $MDD/$mla";
 open(MDN,">$MDD/$mln") or die ":( $MDD/$mln";
 while(<MDO>){
   if (/Occup=/){
      print MDN " Occup=   $occ[$i]\n";
      print LOG " Occup=   $occ[$i]\n";
      $i++;
   }else{
      print MDN $_;
   }
 }
 close(MDN);
 close(MDO);
}
# ---------------------------------------------------------
sub delete_line_after_GTO{
 system("mv $MDD/$mln $MDD/$mla");
 open(MDO,"$MDD/$mla") or die ":( $MDD/$mla";
 open(MDN,">$MDD/$mln") or die ":( $MDD/$mln";
 while(<MDO>){
   if (/GTO/){
      print MDN $_;
      $_=<MDO>;
      $aux_line=$_;
      chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
      if ($_ eq ""){
         print LOG "Blank line after [GTO] was deleted\n";
      }else{
         print MDN $aux_line;
      }
   }else{
      print MDN $_;
   }
 }
 close(MDN);
 close(MDO);
}

