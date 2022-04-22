#!/usr/bin/perl -w
# Make the subtraction between two geom files.
#
   $file_fin="DISPLACEMENT/CALC.c1.d10/geom";
   $file_ini="DISPLACEMENT/CALC.c1.d0/geom";

   open (FILE, $file_ini) or die "Failed to open file: $file_ini\n";
   $i=0;
   while (<FILE>)
    {
      $i++;
      chomp;
      $_ =~ s/^\s*//;         # remove leading blanks
      $_ =~ s/\s*$//;         # remove trailing blanks
      ($symbol[$i],$charge[$i],$xi[$i],$yi[$i],$zi[$i])=split(/\s+/,$_);
      $charge[$i]=$charge[$i];
      $nati=$i;
    }
   close(FILE);
   open (FILE, $file_fin) or die "Failed to open file: $file_fin\n";
   $i=0;
   while (<FILE>)
    {
      $i++;
      chomp;
      $_ =~ s/^\s*//;         # remove leading blanks
      $_ =~ s/\s*$//;         # remove trailing blanks
      ($symbol[$i],$charge[$i],$xf[$i],$yf[$i],$zf[$i])=split(/\s+/,$_);
      $charge[$i]=$charge[$i];
      $natf=$i;
    }
   close(FILE);
   if ($nati != $natf){die "Inconsistent number of atoms in the two files!";}
   open (FILE, ">vector") or die "Failed to open file: vector\n";
   open (FX, ">vector.xyz") or die "Failed to open file: vector\n";
   print FX " $nati\n\n";
   for ($i=1;$i<=$nati;$i++){
     $x[$i]=$xf[$i]-$xi[$i];
     $y[$i]=$yf[$i]-$yi[$i];
     $z[$i]=$zf[$i]-$zi[$i];
     printf FILE " %14.8F %14.8F %14.8F\n",$x[$i],$y[$i],$z[$i];
     printf FX " %s %14.8F %14.8F %14.8F\n",$symbol[$i],$x[$i],$y[$i],$z[$i];
   }
   close(FX);
   close(FILE);


