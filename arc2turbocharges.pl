#!/usr/bin/perl -w
# ========================================================================================================
# 
# Read arc file (Tinker), select Ns structures space by Ms steps after k_t thermalization steps.
# Write these structures in $point_charges format for turbomole (point_charges.dat).
# A number of atoms can be select from arc to not appear in point_charge.
# The charges are read from Tinker parameter file and rescaled by 1/Ns.
# The information in point_charge.dat can be used in ASEC methodology.
#
# Input arc2tpc.inp:
# arc       = name of arc file
# Ns        = number of structures
# Ms        = Number of steps between structures
# k_t       = Number of steps skiped before starting the collection
# skip_atom = List of atoms that will not appear in point charges (e.g. 5-7,9,15-20)
# par       = Tinker parameter file where chages should be read
#
# Run:
# >./arc2turbocharges.pl 
#
# Outputs:
# point_charges.dat     - point charges in Turbomole $point_charges format (x(au) y(au) z(au) q(au))
# arc2charges.log  - Log information
# point_charges.xyz     - The Ns structures in a multiple XYZ file
# point_charges.tnk     - The Ns structures in a Tinker XYZ file
#
# MB jul 2009
#
# ========================================================================================================
use lib join('/',$ENV{"NX"},"CPAN") ;
use colib_perl;

$log ="arc2charges.log";
$ainp="arc2tpc.inp";
$dat ="point_charges.dat";
$xyz ="point_charges.xyz";
$tnk ="point_charges.tnk";

open(LOG,">$log");

read_inputs();
read_arc();  

close(LOG);

# ========================================================================================================
sub read_inputs{
  not_found($ainp,"Prepare $ainp first. See instructions in the program source.");
  $arc        = getkeyword($ainp,"arc"      ,"");
  $Ns         = getkeyword($ainp,"Ns"       ,"");
  $Ms         = getkeyword($ainp,"Ms"       ,"");
  $k_t        = getkeyword($ainp,"k_t"      ,"");
  $skip_atom  = getkeyword($ainp,"skip_atom","");
  $par        = getkeyword($ainp,"par"      ,"");
  print LOG "Input Parameters:\n";
  print LOG "arc       = $arc\n";
  print LOG "Ns        = $Ns\n";
  print LOG "Ms        = $Ms\n";
  print LOG "k_t       = $k_t\n";
  print LOG "skip_atom = $skip_atom\n";
  print LOG "par       = $par\n\n";
  not_found($arc,"Cannot find $arc (Tinker arc) file.");
  not_found($par,"Cannot find $par (Tinker parameters) file.");
  @skip=make_num_sequence($skip_atom);
  print LOG "Atoms to skip: @skip \n";
  $skip=@skip;
}
# ========================================================================================================
sub not_found{
  my ($file,$message);
  ($file,$message)=@_;
  if (!-s $file){
     print     "$message \n";
     print LOG "$message \n";
     die;
  }
}
# ========================================================================================================
sub read_arc{
  $au2ang=units("au2ang");

  open(DAT,">$dat") or die ":( $dat";
  open(XYZ,">$xyz") or die ":( $xyz";
  open(TNK,">$tnk") or die ":( $tnk";

  open(ARC,$arc) or die ":( $arc";

  # read number of atoms
  $_=<ARC>;
  chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
  ($numat)=split(/\s+/,$_);
  $nat_eff=$numat-$skip;
  print LOG "Number of atoms in each structure: $numat\n";
  print LOG "Number of atoms that will be printed for each structure: $nat_eff\n\n";

  # read charges
  @found=0;
  for ($i=1;$i<=$numat;$i++){
    read_charge();
  }
  print LOG "\n";

  close(ARC);

  # read structures
  open(ARC,$arc) or die ":( $arc";
  $ind_stc=1;
  $ind_stp=1;
  $ind_col=0;
  while(<ARC>){
    if ($ind_stp == $k_t){
      $ind_stc=1;
    }
    for ($i=1;$i<=$numat;$i++){
       $_=<ARC>;
       collect_st();
       if ($collect eq "y"){
         if ($i == 1){
           print XYZ "$nat_eff\n\n";
           $ind_col++;
           print LOG "Collecting structure $ind_col\n";
           #print LOG ">>> $_";
         }
         chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
         ($ia,$sa,$x,$y,$z,$na)=split(/\s+/,$_);
         $xa=$x/$au2ang;
         $ya=$y/$au2ang;
         $za=$z/$au2ang;
         $qa=$charge{$na}/$Ns;
         printf DAT "%16.10f %16.10f %16.10f %12.7f\n",$xa,$ya,$za,$qa;
         printf XYZ "%s %16.10f %16.10f %16.10f\n",$sa,$x,$y,$z;
         print  TNK "$_\n";
         if ($i==$nat_eff){
            $ind_stc=0;
         }
       }       
    }
    $ind_stc++;
    $ind_stp++;
    if ($ind_col >= $Ns){
      last;
    }
  }

  close(ARC);

  print LOG "\nNumber of collected structures: $ind_col\n";

  close(DAT);
  close(XYZ);
  close(TNK);

}
# ========================================================================================================
sub collect_st{
  $collect = "n";
  #print LOG ">>>>  $ind_stp (>= $k_t)  :  $ind_stc (== $Ms)  :  $ind_col (< $Ns)\n";
  $answer=is_in_array($i,@skip);
  if (($ind_stp > $k_t) and 
      ($ind_stc == $Ms) and 
      ($ind_col <= $Ns) and
      ($answer eq "n")){
    $collect="y";
  }
}
# ========================================================================================================
sub read_charge{
  my ($q,$i,$na,$sa);
  $_=<ARC>;
  chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
  @g=split(/\s+/,$_);
  $na=$g[5];
  $sa=$g[1];
  $answer=is_in_array($na,@found);
  if ($answer eq "n"){
    open(PAR,$par) or die ":( $par";
    while(<PAR>){
      if (/Atomic Partial Charge Parameters/){
        while(<PAR>){
           if (/charge/){
             ($ia,$i,$q)=split(/\s+/,$_);
              if ($i == $na){
                 $charge{$na}=$q;
                 print LOG "Charge for atom $sa ($na) = $charge{$na}\n";
                 push(@found,$na);    
                 last;
              }
           }
        }
        last;
      }
    }
    close(PAR);
  }
  if ($found[0] == 0){
    shift(@found);
  }
}
# ========================================================================================================
sub is_in_array{
  my ($elem,@array,$answer);
  ($elem,@array)=@_;
  $answer = "n";
  foreach(@array){
    if ($_ == $elem){
       $answer = "y";
       last;
    }
  }
  return $answer;
}
# ========================================================================================================
