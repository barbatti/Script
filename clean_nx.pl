#!/usr/bin/perl -w

print "Which NX path?";
$_=<STDIN>;
chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
$nxpath=$_;

print "The following NX will be cleaned: \n$nxpath\n";
print "Confirm? (y/n) ";
$_=<STDIN>;
chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
$answer=$_;

if ($answer eq "y"){
 @list=(
"IC-SICH4-CASSCF/",
"IC-SICH4-RICC2/",
"IC-SICH4-TDDFT/",
"MD-CNH4-CASSCF-AD/",
"MD-CNH4-CASSCF-NAD/",
"MD-CNH4-CASSCF-NAD-2/",
"MD-CNH4-CASSCF-NAD-CIOVERLAP/",
"MD-CNH4-CASSCF-NAD-LOCDIAB/",
"MD-OCNH3_H2O-NAD-QMMM/",
"MD-SICH4-RICC2/",
"MD-SICH4-TDDFT/",
"MD-SICH4-TDDFT-NAD/",
"MD-SICH4-TDDFT-THERM_1/"
);

 foreach(@list){
   $r=`rm -rf $nxpath/test-nx/$_`;
   print "$_ -> $r\n";
   $r=`rm -rf $nxpath/test-nx/STANDARD-RESULTS/$_`;
   print "$_ -> $r\n";
 }
}else{
 print "Nothing was done.\n";
}
