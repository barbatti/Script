#!/usr/bin/perl -w
# This program reads the occupation from mcscfls file and
# writes it to the molden file.

$ncol=8;

$LTD="LISTINGS";
$MDD="MOLDEN";
$mcf="mcscfls.sp";
$mld="molden_mo_mc.sp";
$mla="molden_mo_mc.sp.aux";
$mln="molden_mo_mc.sp.new";

$fdd="fdd";
$qvv="qvv";

if (!-s $LTD){die ":( $LTD"};
if (!-s $MDD){die ":( $MDD"};
if (!-s "$LTD/$mcf"){die ":( $LTD/$mcf"};
if (!-s "$MDD/$mld"){die ":( $MDD/$mld"};

number_of_basis();
eingenvalue($fdd,"\n","e");
$nfdd=$nelem;
#print "$nfdd\n";
@efdd=@eingenv;
eingenvalue($qvv,"timer: motran","c");
$nqvv=$nelem;
#print "$nqvv\n";
@eqvv=@eingenv;
occupations();
change_egv_molden();
change_occ_molden();

system("rm -f $MDD/$mla");

# ---------------------------------------------------------
sub number_of_basis{
 open(OF,"$LTD/$mcf") or die ":( $LTD/$mcf";
 while(<OF>){
   if (/ Total number of basis functions:/){
      chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
      @g=split(/\s+/,$_);
      $bfs=$g[5];
   }
 }
 close(OF);
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
   #print "$string: eingenvalue $j = $eingenv[$j]\n";
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
          #print "$j   $occ[$j]\n";
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
      $i++;
   }else{
      print MDN $_;
   }
 }
 close(MDN);
 close(MDO);
}
