#!/usr/bin/perl -w

 @a1=(1,2,3);
 @a2=(4,5,6);
 @a3=(7,8,9);
 
 @tot=(\@a1,\@a2,\@a3);

 for ($i=0;$i<=2;$i++){
   for ($j=0;$j<=2;$j++){
     print "$i  $j  $tot[$i][$j] \n";
   }
 }
