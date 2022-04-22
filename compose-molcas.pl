#!/usr/bin/perl -w

# Create mocal input based on a template and on COLUMBUS geom file
$DIR="/ns80th/nas/users/barbatti/PERL_FILES/";

if (-s "geom"){
  system("$DIR/geom2molcas defcol nr");
}else{
  die "geom file does not exist or is empty!";
}
if (!-s "molcas.template"){
  die "molcas.template file does not exist or is empty!";
}

read_geom_molcas();

read_write_template();

#..................................................
sub read_geom_molcas{
 open(IN,"geom.molcas") or die ":( geom.molcas!";
 $i=0;
 $s[0]=0;
 while(<IN>){
   chomp;
   $_ =~ s/^\s*//;         # remove leading blanks
   $_ =~ s/\s*$//;         # remove trailing blanks 
   $i++;
   ($s[$i],$x[$i],$y[$i],$z[$i])=split(/\s+/,$_);
 }
 #$nat=$i;
 close(IN);
}
#..................................................
sub read_write_template{
 open(IN,"molcas.template") or die ":( molcas.template";
 open(OUT,">molcas.inp") or die ":( molcas.inp";
 while(<IN>){
   $line=$_;
   chomp;
   $_ =~ s/^\s*//;         # remove leading blanks
   $_ =~ s/\s*$//;         # remove trailing blanks
   ($symb)=split(/\s+/,$_);
   $i=0;
   foreach(@s){
     
     if ($symb eq $_){
       $line=sprintf("%7s  %15.6f  %15.6f   %15.6f / Angstrom\n",$s[$i],$x[$i],$y[$i],$z[$i]);
       last;
     }
     $i++;
   }
   print OUT $line; 
 }
 close(OUT);
 close(IN);
}
