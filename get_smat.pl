#!/usr/bin/perl -w

$pi=3.14159265359;
$hbar=6.582119569E-1; #eV/fs
$c=27.21138386; # au->eV
$dt = 0.5;

$t  = 0.0;
open(INP2,"dyn.out") or die "dyn.out";
open(OUTE,">energ.dat") or die "energ.dat";
while(<INP2>){
  if (/% /){
     chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
     @g=split(/\s+/,$_);
     if ($t>=1){
       $e2[0]=$e1[0];
       $e2[1]=$e1[1];
     }
     if ($t>=0.5){
       $e1[0]=$e[0];
       $e1[1]=$e[1];
     }
     $e[0]=$g[4];
     $e[1]=$g[5];
     $de=($e[1]-$e[0])*$c;
     if ($t>=0.5){
       $grd[0]=grad($e1[0],$e[0],$dt);
       $grd[1]=grad($e1[1],$e[1],$dt);
       $dg=($grd[1]-$grd[0])*$c;
       if ($t>=1){
         $hss[0]=hess($e2[0],$e1[0],$e[0],$dt);
         $hss[1]=hess($e2[1],$e1[1],$e[1],$dt);
         $dh=($hss[1]-$hss[0])*$c;
         $plz=lz($de,$dh);
         $fba=ba($de,$dh);
         printf OUTE "%7.2f  %12.7f  %12.7f  %12.7f  %12.7f  %12.7f\n",$t,$de,$dg,$dh,$plz,$fba; 
       }
     }
     $t = $t + $dt;
  }
}
close(OUTE);
close(INP2);

open(INP3,"tprob") or die "tprob";
open(OUTP,">prob.dat") or die "prob.dat";
$_=<INP3>;
while(<INP3>){
  chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
  @g=split(/\s+/,$_);
  $t=$g[2]*$dt;
  if ($g[3] > 0){
    $prb=$g[3];
  }elsif($g[4] > 0){
    $prb=$g[4];
  }else{
    $prb=0.0;
  }
  printf OUTP "%7.2f  %12.7f\n",$t,$prb; 
}
close(OUTP);
close(INP3);

$t  = 0.0;
open(INP,"sh.out") or die "sh.out";
open(OUTS,">smat.dat") or die "smat.dat";
open(OUTT,">tmat.dat") or die "tmat.dat";
open(OUTD,">dmat.dat") or die "dmat.dat";
open(OUTR,">rrmat.dat") or die "rrmat.dat";
open(OUTI,">irmat.dat") or die "irmat.dat";
open(OUTUR,">rumat.dat") or die "rumat.dat";
open(OUTUI,">iumat.dat") or die "iumat.dat";
while(<INP>){
  if (/v.h/){
     if ($t != 0.0){
       # read v.h
       chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
       @g=split(/\s+/,$_);
       $vdh=$g[1];
       # read  S matrix
       while(<INP>){
         if (/S-matrix,/){
           $_=<INP>; 
           ($sm[0][0],$sm[0][1])=split_m($_);
           $_=<INP>; 
           ($sm[1][0],$sm[1][1])=split_m($_);
           last;
         }
       }
       # read T matrix
       while(<INP>){
         if (/T Matrix/){
           $_=<INP>;
           ($tm[0][0],$tm[0][1])=split_m($_);
           $_=<INP>;
           ($tm[1][0],$tm[1][1])=split_m($_);
           last;
         }
       }
       # read diabatic Hamiltonian
       while(<INP>){
         if (/Diabatic Hamiltonian:/){
           $_=<INP>;
           ($dm[0][0],$dm[0][1])=split_m($_);
           $_=<INP>;
           ($dm[1][0],$dm[1][1])=split_m($_);
           last;
         }
       }
       # read Re(rotation matrix)
       while(<INP>){
         if (/Real part of/){
           $_=<INP>;
           ($rm[0][0],$rm[0][1])=split_m($_);
           $_=<INP>;
           ($rm[1][0],$rm[1][1])=split_m($_);
           last;
         }
       }
       # read Im(rotation matrix)
       while(<INP>){
         if (/Imaginary part of/){
           $_=<INP>;
           ($im[0][0],$im[0][1])=split_m($_);
           $_=<INP>;
           ($im[1][0],$im[1][1])=split_m($_);
           last;
         }
       }
       # compute U matrix
       for ($i=0;$i<=1;$i++){
         for ($j=0;$j<=1;$j++){
           $ru[$i][$j]=0.0;
           $iu[$i][$j]=0.0;
           for ($k=0;$k<=1;$k++){
             $ru[$i][$j]=$ru[$i][$j] + $tm[$i][$k]*$rm[$k][$j];
             $iu[$i][$j]=$iu[$i][$j] + $tm[$i][$k]*$im[$k][$j];
           }
         }
       }
       #print results
       printf OUTS "%7.2f  %12.7f  %14.9f  %14.9f  %14.9f  %14.9f\n",$t,$vdh,$sm[0][0],$sm[0][1],$sm[1][0],$sm[1][1]; 
       printf OUTT "%7.2f  %12.7f  %14.9f  %14.9f  %14.9f  %14.9f\n",$t,$vdh,$tm[0][0],$tm[0][1],$tm[1][0],$tm[1][1]; 
       printf OUTD "%7.2f  %12.7f  %14.9f  %14.9f  %14.9f  %14.9f\n",$t,$vdh,$dm[0][0],$dm[0][1],$dm[1][0],$dm[1][1]; 
       printf OUTR "%7.2f  %12.7f  %14.9f  %14.9f  %14.9f  %14.9f\n",$t,$vdh,$rm[0][0],$rm[0][1],$rm[1][0],$rm[1][1]; 
       printf OUTI "%7.2f  %12.7f  %14.9f  %14.9f  %14.9f  %14.9f\n",$t,$vdh,$im[0][0],$im[0][1],$im[1][0],$im[1][1]; 
       printf OUTUR "%7.2f  %12.7f  %14.9f  %14.9f  %14.9f  %14.9f\n",$t,$vdh,$ru[0][0],$ru[0][1],$ru[1][0],$ru[1][1]; 
       printf OUTUI "%7.2f  %12.7f  %14.9f  %14.9f  %14.9f  %14.9f\n",$t,$vdh,$iu[0][0],$iu[0][1],$iu[1][0],$iu[1][1]; 
     }
     $t = $t + $dt;
  }
}
close(OUTUR);
close(OUTUI);
close(OUTS);
close(OUTT);
close(OUTD);
close(INP);



sub split_m{
# 9.9559852E-01 2.7940061E-03
#-4.8206169E-03 9.8840909E-01
  my ($v,@u,$i);
  ($v)=@_;
  $u[0]=substr($v,0,14);
  chomp($u[0]); $u[0] =~ s/^\s*//;$u[0] =~ s/\s*$//;
  $u[1]=substr($v,14,14);
  chomp($u[1]); $u[1] =~ s/^\s*//;$u[1] =~ s/\s*$//;
  return $u[0],$u[1];
}

sub grad{
  my ($grd,@f,$dt);
  ($f[0],$f[1],$dt)=@_;
  $grd=($f[1]-$f[0])/$dt;
  return $grd;
}

sub hess{
  my ($hes,@f,$dt);
  ($f[0],$f[1],$f[2],$dt)=@_;
  $hes=($f[2]-2*$f[1]+$f[0])/($dt*$dt);
  return $hes;
}

sub lz{
 my ($de,$dh);
 ($de,$dh)=@_;
 $plz=exp(-$pi/$hbar*sqrt(abs($de**3/$dh)));
 return $plz;
}

sub ba{
 my ($de,$dh);
 ($de,$dh)=@_;
 $fba=sqrt(abs($dh/$de))/2;
 return $fba; 
}
