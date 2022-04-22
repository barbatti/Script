      program liic
      ! LIIC: Linearly interpolated internal coordinate
 
      implicit real*8 (a-h,o-z)

      real*8, dimension(:), allocatable :: x,y,xini,xlast

      open(unit= 9,file="liic.inp", status="unknown")
      open(unit=10,file="intgeom.ini", status="unknown")
      open(unit=11,file="intgeom.last",status="unknown")
      open(unit=12,file="aux",       status="unknown")
      open(unit=13,file="aux2",      status="unknown")

      read(9,*) Nat,Np,k
      Nic = 3*Nat-6

      ! Allocate
      allocate (xini(Nic),xlast(Nic),x(Nic),y(Nic),STAT=istat)
      if (istat /= 0)  STOP "*** Not enough memory ***"

      ! Read geom initial and final
      do n = 1,Nic
         read(10,*) xini(n) 
         read(11,*) xlast(n)
      enddo

      ! Interpolate
      do n = 1,Nic
        x(n)=xini(n)+dfloat(k)/dfloat(Np)*(xlast(n)-xini(n))
        write(12,'(f14.8)') x(n)
        !y(n)=dfloat(k)/dfloat(Np)*(xlast(n)-xini(n))
        !write(13,'(f14.8)') y(n)
        y(n)=1.D0/dfloat(Np+1)*(xlast(n)-xini(n))
        write(13,'(f14.8)') y(n)
      enddo

      end program liic

