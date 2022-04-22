!     This program performs the projection of the gradient along
!     some arbitrary direction.
!     Author: M. Barbatti (Oct 2007)
!
!     Name list variables:                 Default:
!       f_grad - initial gradient file     cartgrd
!       f_vec  - direction vector file     vector
!     Internal variables:
!       Nat    - number of atoms
!       g      - gradient
!       v      - direction vector
!       u      - unit vector along v
!       gpp    - Perpendicular gradient projection
!       gpl    - Parallel gradient projection
!
      module prec_mod
        implicit none
        integer, parameter :: dpr    = kind(1.d0)
      end module prec_mod
!
      program proj_grad
      use prec_mod
      implicit real(kind=dpr) (a-h,o-z)
      real(kind=dpr), dimension(:,:), allocatable :: g,v,u,gpp,gpl
      character(len=120) :: f_grad,f_vec
!
      open(unit=9,file='proj_grad.log',status='unknown')
      write(9,*) "==========================================="
      write(9,*) "                PROJ_GRAD                  "
      write(9,*) "==========================================="
      write(9,*) ""
!
!     Namelist
      namelist /proj/ f_grad,f_vec
      f_grad='cartgrd'
      f_vec='vector'
      open(1,file='proj_grad.inp',form='formatted',status='old')
      rewind 1
      read(1,NML=proj)
      close(1)
      write(9,*) "Original gradient: ",trim(f_grad)
      write(9,*) "Direction vector: ",trim(f_vec)
!
      call check_files(Nat)
      write(9,*) "Files checked."
      write(9,*) "Number of atoms: ",Nat
      write(9,*) ""
!
!     Allocate
      allocate (g(Nat,3),v(Nat,3),u(Nat,3),gpp(Nat,3),gpl(Nat,3),STAT=istat)
      if (istat /= 0)  STOP "*** Not enough memory ***"
!
      call read_files(Nat,g,v)
!
      call projection(Nat,g,v,u,gpp,gpl)
!
      call write_projection(Nat,g,v,u,gpp,gpl)
!
      contains
!
! .......................................................................
!
      subroutine check_files(Nat)
!
!     Number of atoms, check files, check consistency
! 
      implicit real(kind=dpr) (a-h,o-z)
      !character f_grad,f_vec
!
      Nat=0
      open(unit=8,file=f_grad,status='old',iostat=ist)
      if (ist > 0) STOP "Prepare gradient file first!"
      IOStatus=0
      do while (IOStatus == 0)
        read(8,*,IOSTAT=IOStatus)
        if (IOStatus /= 0) EXIT
        Nat=Nat+1
      enddo
      close(8)
!
      Nat2=0
      open(unit=2,file=f_vec,status='old',iostat=ist)
      if (ist > 0) STOP "Prepare vector file first!"
      IOStatus=0
      do while (IOStatus == 0)
        read(2,*,IOSTAT=IOStatus)
        if (IOStatus /= 0) EXIT
        Nat2=Nat2+1
      enddo
      close(2)
!
      if (Nat /= Nat2) STOP  &
      "Dimensions of gradient and of vector must be the same!"
!
      endsubroutine
!
! .......................................................................
!
      subroutine read_files(Nat,g,v)
      implicit real(kind=dpr) (a-h,o-z)
      real(kind=dpr),dimension(Nat,3) :: g,v
!     Read files
!
!     Read gradient
      open(unit=8,file=f_grad,status='old')
      do i=1,Nat
        read(8,*) (g(i,j),j=1,3)
      enddo
      close(8)
!   
!     Read vector
      open(unit=8,file=f_vec,status='old')
      do i=1,Nat
        read(8,*) (v(i,j),j=1,3)
      enddo
      close(8)
!
      end subroutine
!
! ....................................................................... 
!
      subroutine projection(Nat,g,v,u,gpp,gpl)
      implicit real(kind=dpr) (a-h,o-z)
      real(kind=dpr),dimension(Nat,3) :: g,v,u,gpp,gpl
!
      call dotproduct(Nat,v,v,v2)
      call dotproduct(Nat,g,v,gdotv)
      u=v/sqrt(v2)
      gpl=gdotv*v/v2
      gpp=g-gpl    
!
      end subroutine
!
! ....................................................................... 
!
      subroutine dotproduct(Nat,a,b,s)
      implicit real(kind=dpr) (a-h,o-z)
      real(kind=dpr),dimension(Nat,3) :: a,b
!
      s=0.0_dpr
      do k1=1,Nat
        do k2=1,3
          s=s+a(k1,k2)*b(k1,k2)
        enddo
      enddo 
!
      end subroutine
!
! ....................................................................... 
!
      subroutine write_projection(Nat,g,v,u,gpp,gpl)
      implicit real(kind=dpr) (a-h,o-z)
      real(kind=dpr),dimension(Nat,3) :: g,v,u,gpp,gpl
!
      write(9,*) "Original gradient:"
      do i=1,Nat
        write(9,'(3E15.6)') (g(i,j),j=1,3)
      enddo
      call dotproduct(Nat,g,g,s)
      g_norm=dsqrt(s)
      write(9,'(A35,F8.5)') " Norm of the gradient:             ",g_norm
      write(9,*) ""
!
      write(9,*) "Direction vector:"
      do i=1,Nat
        write(9,'(3E15.6)') (v(i,j),j=1,3)
      enddo
      call dotproduct(Nat,v,v,s)
      v_norm=dsqrt(s)
      write(9,'(A35,F8.5)') " Norm of the direction vector:     ",v_norm
      write(9,*) ""
!
      write(9,*) "Unitary vector along v:"
      do i=1,Nat
        write(9,'(3E15.6)') (u(i,j),j=1,3)
      enddo
      call dotproduct(Nat,u,u,s)
      u_norm=dsqrt(s)
      write(9,'(A35,F8.5)') " Norm of the unitary vector:       ",u_norm
      write(9,*) ""
! 
      write(9,*) "Perpendicular gradient projection:"
      do i=1,Nat
        write(9,'(3E15.6)') (gpp(i,j),j=1,3)
      enddo
      call dotproduct(Nat,gpp,gpp,s)
      gpp_norm=dsqrt(s)
      write(9,'(A35,F8.5)') " Norm of the perpendicular vector: ",gpp_norm
      write(9,*) ""
!
      write(9,*) "Parallel gradient projection:"
      do i=1,Nat
        write(9,'(3E15.6)') (gpl(i,j),j=1,3)
      enddo
      call dotproduct(Nat,gpl,gpl,s)
      gpl_norm=dsqrt(s)
      write(9,'(A35,F8.5)') " Norm of the parallel vector:      ",gpl_norm
!
      write(9,*) ""
      call dotproduct(Nat,gpp,gpl,dp)
      write(9,'(A35,F8.5)') " Dot product parallel.perpend.:    ",dp
!
      open(unit=7,file='pp_grad',status='unknown')
      open(unit=8,file='pl_grad',status='unknown')
      do i=1,Nat
        write(7,'(3E15.6)') (gpp(i,j),j=1,3)
        write(8,'(3E15.6)') (gpl(i,j),j=1,3)
      enddo
      close(7)
      close(8)
!
      write(9,*) ""
      write(9,*) "Perpendicular projection was written to pp_grad."
      write(9,*) "Parallel projection was written to pl_grad."
      write(9,*) ""
      write(9,*) "==========================================="
      write(9,*) "      NORMAL TERMINATION OF PROJ_GRAD      "
      write(9,*) "==========================================="
!
      end subroutine
!
! ....................................................................... 
!
      end program proj_grad
