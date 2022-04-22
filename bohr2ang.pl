#!/usr/bin/perl
#
#   Program to converts "symbol x y z" in au to xyz format.
#
   use lib join('/',$ENV{"NX"},"CPAN") ;
   use colib_perl;
   $au2ang=units("au2ang");
   if (defined $ARGV[0]){
     $file = $ARGV[0];
     if (!-s $file){
       die "$file does not exist or is empty.";
     }
   }
   open (FILE, $file) or die "Failed to open file: $file\n";
   $i=0;
   while (<FILE>)
    {
      $i++;
      chomp; s/^ *//; 
      ($symbol[$i],$x[$i],$y[$i],$z[$i])=split(/\s+/,$_,5); 
      $natom=$i; 
    }
    $fout="geom-chm.xyz";
    open (OUT,">$fout")or die" Failed to open file: $fout\n";  
    print {OUT}" $natom\n\n";
    for ($i=1; $i<=$natom; $i++)
    {
      $x[$i]=$x[$i]*$au2ang;
      $y[$i]=$y[$i]*$au2ang;
      $z[$i]=$z[$i]*$au2ang;
      printf {OUT}("%7s  %15.6f  %15.6f   %15.6f\n", $symbol[$i],$x[$i],$y[$i],$z[$i]);
    }
   close OUT;
   close FILE;
