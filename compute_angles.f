c
c The following FORTRAN90 program calculates dihedral, twist and 
c pyramidalization angles. Note that it was originally written 
c with double bonded systems in mind. The pyramidalization and 
c twist angles are defined within. The required input is a molecular 
c structure in XYZ form at,[basename].xyz, and the program is run 
c by typing 'compute_angle [basename]'. All other input is acquired 
c interactively. 
c 
c By Jason Quenneville
c Downloaded from 
c http://mtz01-a.stanford.edu/resources/theses/quenneville/JQ_Thesis.htm
c on Jun 25, 2014
c

      program CalcAngle

      implicit real*8(a-h,o-z)

      character*256 filein,cjunk
      character*1,dimension(:),allocatable::catype
      real*8,dimension(:,:),allocatable::cc
      integer iatom(6)

      pi=4.0d0*atan(1.0d0)
      rad2deg=180.0d0/pi

      call getarg(1,filein)

      filein=trim(filein)//'.xyz'
      open(10,file=trim(filein),access='sequential',
     & form='formatted')
      read(10,*)natoms
      allocate (catype(natoms),cc(natoms,3))
      read(10,*)cjunk
      do iat=1,natoms
        read(10,*)catype(iat),(cc(iat,i),i=1,3)
      enddo
 
  100 write(6,*)' '
      write(6,*)
     & '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
      write(6,*)' '
      write(6,*)'Enter:' 
      write(6,*)' '
      write(6,*)' 1 ...for twist angle'
      write(6,*)' 2 ...for pyramidalization angle'
      write(6,*)' 3 ...for dihedral angle'
      write(6,*)' 4 ...for bond angle'
      write(6,*)' '
      write(6,*)' 5 ...to quit'
      write(6,*)' '
      read *,ichoice
      write(6,*)' '
      write(6,*)' '

      if (ichoice.eq.5) goto 500
      if (ichoice.eq.1) goto 200
      if (ichoice.eq.3) goto 300
      if (ichoice.eq.4) goto 400
      write(6,*)'This routine calculates pyramidalization angles.'
      write(6,*)' '
      write(6,*)'         2nd'
      write(6,*)'        /'
      write(6,*)' 4th=1st'
      write(6,*)'        \'
      write(6,*)'         3rd'
      write(6,*)' '
      write(6,*)
     & 'Enter the numbers corresponding to the 4 atoms involved'
      write(6,*)' in the order shown above.'
      write(6,*)
     & ' (i.e., the 1st atom is the pyramidalized atom)'
      write(6,*)' '
      write(6,*)'(example input: "# # # #")'
      write(6,*)' '
      read *,iatom1,iatom2,iatom3,iatom4

      call CalcPyrAngle(natoms,cc,angle,
     & iatom1,iatom2,iatom3,iatom4)

      write(6,'(a,f7.3)')'Pyramidalization Angle = ',angle*rad2deg

      if (ichoice.eq.2) goto 100

  200 write(6,*)'This routine calculates twist angles.'
      write(6,*)' '
      write(6,*)' 3rd         5rd'
      write(6,*)'    \       /'
      write(6,*)'     1st=2nd'
      write(6,*)'    /       \'
      write(6,*)' 4th         6th'
      write(6,*)' '
      write(6,*)
     & 'Enter the numbers corresponding to the 6 atoms involved.'
      write(6,*)' '
      write(6,*)'(input format: "# # # # # #")'
      write(6,*)' '
      read *,(iatom(i),i=1,6)

      call CalcTwistAngle(cc,natoms,angle,iatom) 

      write(6,*)' '
      write(6,'(a,f7.3)')'Twist Angle = ',angle

      goto 100

  300 write(6,*)
     & 'Define the dihedral angle with the numbers of the atoms:'
      read *,iatom1,iatom2,iatom3,iatom4
      call
     & CalcDihedral(cc,natoms,angle,iatom1,iatom2,iatom3,iatom4)
      write(6,*)' '
      write(6,'(a,f7.3)')
     & 'Dihedral angle = ',180.d0-(angle*rad2deg)

      goto 100

  400 write(6,*)
     & 'Define the bond angle with the numbers of the atoms:'
      read *,iatom1,iatom2,iatom3

      call CalcBondAngle(cc,natoms,angle,iatom1,iatom2,iatom3)

      write(6,*)' '
      write(6,'(a,f7.3)')'Bond angle = ',angle*rad2deg

      goto 100

  500 end

cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c The following subroutine calculates a twist angle defined with six atoms

      subroutine CalcTwistAngle(cc,natoms,twistangle,iatom)

      implicit real*8(a-h,o-z)

      real*8 cc(natoms,3),rij1(natoms,natoms)
      integer iatom(6)

      pi=4.0d0*atan(1.0d0)
      rad2deg=180.0d0/pi
      twistangle=0.0d0

      do i=3,4
        do j=5,6
          call CalcDihedral(cc,natoms,angle,iatom(i),iatom(1),
     &         iatom(2),iatom(j))
          angledeg=angle*rad2deg
          if (i.eq.3 .and. j.eq.6) angledeg=180.d0-angledeg
          if (i.eq.4 .and. j.eq.5) angledeg=180.d0-angledeg
          twistangle=angledeg/4.+twistangle
        enddo
      enddo

      end 

cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c The following subroutine calculates dihedral angles of four atoms

      subroutine CalcDihedral(cc,natoms,angle,iatom1,iatom2,
     & iatom3,iatom4)

      implicit real*8(a-h,o-z)

      real*8 cc(natoms,3),d1(3),d2(3),d3(3),cp32(3),cp21(3)

      pi=4.0d0*atan(1.0d0)

      do i=1,3
        d1(i)=cc(iatom2,i)-cc(iatom1,i)
        d2(i)=cc(iatom3,i)-cc(iatom2,i)
        d3(i)=cc(iatom4,i)-cc(iatom3,i)
      enddo

      call CrossProduct(d3,d2,cp32)
      call CrossProduct(d2,d1,cp21)

      call DotProduct(cp32,cp21,dp1)
      call DotProduct(cp32,cp32,dp2)
      call DotProduct(cp21,cp21,dp3)

      cosangle=-dp1/sqrt(dp2*dp3)
      angle=dacos(cosangle)

      return

      end 

cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c The following subroutine calculates the bond angle formed by three atoms

      subroutine CalcBondAngle(cc,natoms,angle,iatom1,iatom2,
     & iatom3)

      implicit real*8(a-h,o-z)

      real*8 cc(natoms,3)

      pi=4.0d0*atan(1.0d0)

      dl1=cc(iatom1,1)-cc(iatom2,1)
      dl2=cc(iatom3,1)-cc(iatom2,1)
      dm1=cc(iatom1,2)-cc(iatom2,2)
      dm2=cc(iatom3,2)-cc(iatom2,2)
      dn1=cc(iatom1,3)-cc(iatom2,3)
      dn2=cc(iatom3,3)-cc(iatom2,3)

      d1=sqrt(dl1*dl1+dm1*dm1+dn1*dn1)
      d2=sqrt(dl2*dl2+dm2*dm2+dn2*dn2)

      dl1=dl1/d1 
      dl2=dl2/d2
      dm1=dm1/d1
      dm2=dm2/d2
      dn1=dn1/d1
      dn2=dn2/d2

      cosangle=dl1*dl2+dm1*dm2+dn1*dn2
      angle=dacos(cosangle)

      return

      end 

cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c This routine calculates the vector describing the plane 
c defined by three atoms involved in pyramidalization 
c (e.g., H-C-H in ethylene)
c
c (see CalcPyramVec.f for more definitive information) 
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
      subroutine CalcPyrAngle(natoms,ccold,angle,
     & iatom1,iatom2,iatom3,iatom4)

      implicit real*8(a-h,o-z)

      real*8 cc(natoms,3),ccold(natoms,3),PyrVec(3),
     & cc2(3),cc3(3),cc4(3),Aprime(3)

      xchange=-ccold(iatom1,1)
      ychange=-ccold(iatom1,2)
      zchange=-ccold(iatom1,3)

      do iatom=1,natoms
        cc(iatom,1)=ccold(iatom,1)+xchange
        cc(iatom,2)=ccold(iatom,2)+ychange
        cc(iatom,3)=ccold(iatom,3)+zchange
      enddo

      do i=1,3
        cc2(i)=cc(iatom2,i)
        cc3(i)=cc(iatom3,i)
        cc4(i)=cc(iatom4,i)
      enddo
       call CalcPyrVec(cc4,cc2,cc3,PyrVec)

c       write(6,*) 'Test 3',PyrVec(1),PyrVec(2),PyrVec(3)

c A' = -A
      do i=1,3 
        Aprime(i)=-cc(iatom4,i)
      enddo

      call DotProduct(Aprime,Aprime,dpAA)
      Aprime=Aprime/sqrt(dpAA)

c       write(6,*) 'Test 3',PyrVec(1),PyrVec(2),PyrVec(3)
c       write(6,*) 'Test 4',Aprime(1),Aprime(2),Aprime(3)

      call DotProduct(Aprime,PyrVec,dpAPv)

c     Mario
      call DotProduct(Aprime,cc2,testsig)
      write(6,*) ' Test >>> ',testsig
      if (testsig .lt. 0.000) dpAPv=-1.D0*dpAPv

c      write(6,*) 'Test 5',dpAPv

      angle=dacos(dpAPv)

      return

      end

cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c 
c This routine computes the vector describing the plane 
c defined by three atoms involved in pyramidalization 
c (e.g., H-C-H in ethylene) 
c 
c The pyramidalization angle is defined as the angle between 
c a vector A and a plane defined by vectors B and C 
c 
c e.g., for ethylene... 
c 
c Carbon1 is the origin 
c A defines the Carbon1-Carbon2 bond 
c B and C define the two (pyramidalized) Carbon1-H bonds 
c 
c A, B, and C are assumed unnormalized 
c 
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
      subroutine CalcPyrVec(A,B,C,PyrVec)

      implicit real*8(a-h,o-z)

      real*8 A(3),B(3),C(3),Aprime(3),Bprime(3),Cprime(3)
      real*8 PyrVec(3)

      call DotProduct(B,B,dpBB)

      Bprime=B/sqrt(dpBB)

      call DotProduct(C,C,dpCC)

      Cprime=C/sqrt(dpCC)

c A' = -A
      Aprime=-A

      call DotProduct(Aprime,Aprime,dpAA)
      Aprime=Aprime/sqrt(dpAA)

c C' is a vector orthogonal to B and in the plane defined by B
c and C

      call DotProduct(Bprime,Cprime,dpBC)
      Cprime=Cprime-dpBC*Bprime

      call DotProduct(Cprime,Cprime,dpCC)
      Cprime=Cprime/sqrt(dpCC) 

c       write(6,*) 'Test ',Cprime(1),Cprime(2),Cprime(3)

c The pyramidalization vector has the same x-component as A',
c but is now in the same plane as B and C

      call DotProduct(Aprime,Bprime,dpAB)
      call DotProduct(Aprime,Cprime,dpAC)

      PyrVec=dpAB*Bprime+dpAC*Cprime

c       write(6,*) 'Test 1',PyrVec(1),PyrVec(2),PyrVec(3)

      call DotProduct(PyrVec,PyrVec,dpPvPv)
      PyrVec=PyrVec/sqrt(dpPvPv)

c       write(6,*) 'Test 2',PyrVec(1),PyrVec(2),PyrVec(3)

      return

      end 

cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c The following calculates the cross product of two vectors

      subroutine CrossProduct(Vec1,Vec2,CrossProd)

      implicit real*8(a-h,o-z)

      real*8 Vec1(3),Vec2(3),CrossProd(3)

      CrossProd(1)=Vec1(2)*Vec2(3)-Vec1(3)*Vec2(2)
      CrossProd(2)=-(Vec1(1)*Vec2(3)-Vec1(3)*Vec2(1))
      CrossProd(3)=Vec1(1)*Vec2(2)-Vec1(2)*Vec2(1)

      eps=1D-6
      
      if (CrossProd(1) .eq. 0.0) CrossProd(1)=eps 
      if (CrossProd(2) .eq. 0.0) CrossProd(2)=eps 
      if (CrossProd(3) .eq. 0.0) CrossProd(3)=eps 

      return

      end 

cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c The following calculates the dot product of two vectors

      subroutine DotProduct(Vec1,Vec2,DotProd)

      implicit real*8(a-h,o-z)

      real*8 Vec1(3),Vec2(3),eps

      eps=1D-6

      DotProd=Vec1(1)*Vec2(1)+Vec1(2)*Vec2(2)+Vec1(3)*Vec2(3)

      if (DotProd .eq. 0.0) DotProd=eps 

      return

      end
 
