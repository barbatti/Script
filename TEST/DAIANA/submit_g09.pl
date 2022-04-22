#!/usr/bin/perl -w

#  Script to submitt conf1, ...

$name="conf";

$psub = "qg09bkall";

for ($i=25;$i<=1000;$i=$i+25){
 print " submitting $psub $name$i\n";
 system("$psub $name$i");
}




