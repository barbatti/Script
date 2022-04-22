#!/usr/bin/perl -w
#
$file=">out";
$dim=3;
$dr=$dim;
$dc=$dim;
$format="%7.3f";
@c=(1,2,3,4,5,6);

$sym_mat=make_sym_mat($dim,\@c);
$tri_mat=make_tri_mat($dim,\@c);
$tra_mat=transp_mat($dr,$dc,$tri_mat);
$norm=norm_mat($dim,$dim,$tri_mat);
$mul_mat=mult_mat($dim,$dim,$dim,$tri_mat,$tra_mat);
open(OUT,">$file") or die ":( $file";
print OUT "SYM:\n";
close(OUT);
print_mat($dim,$file,$format,$sym_mat);
open(OUT,">$file") or die ":( $file";
print OUT "TRI:\n";
close(OUT);
print_mat($dim,$file,$format,$tri_mat);
open(OUT,">$file") or die ":( $file";
print OUT "TRA:\n";
close(OUT);
print_mat($dim,$file,$format,$tra_mat);
open(OUT,">$file") or die ":( $file";
print OUT "MUL:\n";
close(OUT);
print_mat($dim,$file,$format,$mul_mat);
print "norm = $norm\n";

#======================================================
sub transp_mat{
# Transpose matrix
  my ($i,$j,$dim_r,$dim_c,$mat,@t_mat);
  ($dim_r,$dim_c,$mat)=@_;
  for ($i=0;$i<$dim_r;$i++){
    for ($j=0;$j<$dim_c;$j++){
      $t_mat[$i][$j]=$$mat[$j][$i];
    }
  }
  return \@t_mat;
}
#======================================================
sub mult_mat{
# Multiply matrices
  my ($i,$j,$k,$sum,$dim_A_r,$dim,$dim_B_c,$mat_A,$mat_B,@mat_C);
  ($dim_A_r,$dim,$dim_B_c,$mat_A,$mat_B)=@_;
  for ($i=0;$i<$dim_A_r;$i++){
    for ($j=0;$j<$dim_B_c;$j++){
       $sum=0;
       for ($k=0;$k<$dim;$k++){
         $sum=$sum+$$mat_A[$i][$k]*$$mat_B[$k][$j];
       }
       $mat_C[$i][$j]=$sum;
    }
  }
  return \@mat_C;
}
#======================================================
sub norm_mat{
  my ($i,$j,$sum,$dim_r,$dim_c,$mat,$norm);
  ($dim_r,$dim_c,$mat)=@_;
  $sum=0;
  for ($i=0;$i<$dim_r;$i++){
    for ($j=0;$j<$dim_c;$j++){
       $sum=$sum+$$mat[$i][$j]*$$mat[$i][$j];
    }
  }
  $norm=sqrt($sum);
  return $norm;
}
#======================================================
sub make_sym_mat{
# Transforms a vector(dim/2*(1+dim)) into a symmetric matrix(dim x dim)
  my ($i,$m,$n,$dim,$vec,@mat);
  ($dim,$vec)=@_;
  $length=$dim/2*(1+$dim);
  $vec_length=scalar(@$vec);
  if ($length != $vec_length){
    die "Wrong vector length for constructing symmetric matrix ($vec_length instead $length).\n";
  }
  $i=0;
  for ($m=0;$m<$dim;$m++){
    for ($n=0;$n<=$m;$n++){
       $mat[$n][$m]=$$vec[$i];
       $mat[$m][$n]=$$vec[$i];
       $i++;
    }
  }
  return \@mat;
}
#======================================================
sub make_tri_mat{
# Transforms a vector(dim/2*(1+dim)) into a lower triangular matrix(dim x dim).
# Use transp() to get upper triangular matrices.
  my ($i,$m,$n,$dim,$vec,@mat);
  ($dim,$vec)=@_;
  $length=$dim/2*(1+$dim);
  $vec_length=scalar(@$vec);
  if ($length != $vec_length){
    die "Wrong vector length for constructing matrix ($vec_length instead $length).\n";
  }
  $i=0;
  for ($m=0;$m<$dim;$m++){
    for ($n=0;$n<=$m;$n++){
       $mat[$n][$m]=0;
       $mat[$m][$n]=$$vec[$i];
       $i++;
    }
  }
  return \@mat;
}
#======================================================
sub print_mat{
  my ($i,$j,$dim,$file,$format,$mat);
  ($dim,$file,$format,$mat)=@_;
  open(OUT,">$file") or die ":( $file";
  print OUT "$dim  $dim\n";
  for ($i=0;$i<$dim;$i++){
    for ($j=0;$j<$dim;$j++){
     printf OUT "$format   ",$mat->[$i][$j];
    }
    print OUT "\n";
  }
  close(OUT);
}

