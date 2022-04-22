      program datconv
      implicit real*8 (a-h,o-z)
      real*8, dimension(:)  , allocatable :: e

      open(unit= 7,file='en.dat',status='unknown')
      open(unit= 8,file='data.dat',    status='unknown')
      open(unit= 9,file='frame',       status='unknown')
      open(unit=10,file='datconv.inp', status='unknown')

      read(9,*) ifrm
      read(10,*) nstat,ifrmmax,iunit,emin

      allocate (e(nstat),STAT=istat)
      if (istat /= 0)  STOP "*** Not enough memory ***"

      if (iunit == 1) then
         cv=27.211396D0
      else
         cv= 1.D0
      endif
!!.......................................
!!     Specific of file to be analysed
!!      ifrmmax=201            !number of lines
!      its10=44               !line in which occurs 1-0 hopping
!!      emin=-329.270963743358 ! E0
!!.......................................

      do i=1,ifrmmax

         read(7,*) t,(e(n),n=1,nstat),e_curr

         ! check state
         do n=1,nstat
            if (abs(e(n)-e_curr) < 1D-6) then
               ncurr=n
            endif
         enddo

         if (i .ne. ifrm) then
            write(8,100) t,((-emin+e(n))*cv,n=1,nstat)
         else

!!........................................
!!     This block has the hystory of the 
!!     adiabatic dynamics.
!              if (ifrm .lt. its10) then
!              es=e1
!              else
!              es=e0
!              endif
         es=e(ncurr)
!........................................

         write(8,101) t,((-emin+e(n))*cv,n=1,nstat),(-emin+es)*cv

       endif

      enddo
   
      ifrm=ifrm+1
      backspace 9
      write(9,*) ifrm

  100 format(F8.1,16F14.6)
  101 format(F8.1,17F14.6)

      end
