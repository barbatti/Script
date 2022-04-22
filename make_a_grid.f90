      program make_a_grid

      real t,x,x_min,x_max,dx,y,y_min,y_max,dy
      integer i,j,ixmx,jymx,IOstatus,k
      character(len=120) file_name
      integer, dimension(:,:), allocatable :: f

      write(*,*) "File name: "
      read(*,*) file_name
      
      write(*,*) "X increment "
      read(*,*) dx

      write(*,*) "Y increment "
      read(*,*) dy

      open(unit=10,file="grid.log",status='unknown') 
      write(10,*) "determining limits"
      write(*,*) "determining limits"

      k=0
      x_min=0.0
      y_min=0.0
      x_max=0.0
      y_max=0.0
      IOStatus=0
      open(unit=11,file=file_name,status='unknown') 
      do while (IOstatus == 0)
        read(11,*,IOSTAT=IOstatus) t,x,y
        if (x < x_min) x_min = x 
        if (y < y_min) y_min = y 
        if (x > x_max) x_max = x 
        if (y > y_max) y_max = y 
        k=k+1
        if (IOstatus /= 0) EXIT
      enddo
      close(11)

      ixmx=ceiling(abs(x_max-x_min)/dx)
      jymx=ceiling(abs(y_max-y_min)/dy)

      write(10,*) "dx = ",dx
      write(10,*) "dy = ",dy
      write(10,*) "x_min = ",x_min
      write(10,*) "y_min = ",y_min
      write(10,*) "x_max = ",x_max
      write(10,*) "y_max = ",y_max
      write(10,*) "i_max = ",ixmx
      write(10,*) "j_max = ",jymx
      write(10,*) "k = ",k

      allocate (f(ixmx,jymx),STAT=istat)
      if (istat /= 0)  STOP "*** Not enough memory ***"

      f=0

      write(10,*) "Reading file"
      write(*,*) "Reading file"
      
      IOstatus=0
      open(unit=11,file=file_name,status='unknown') 
      do while (IOStatus == 0)
        read(11,*,IOSTAT=IOstatus) t,x,y
        i=ceiling(abs(x-x_min)/dx)
        j=ceiling(abs(y-y_min)/dy)
        if (i == 0) i=1 
        if (j == 0) j=1 
        write(10,*) i,j,f(i,j)
        f(i,j)=f(i,j)+1
        if (IOstatus /= 0) EXIT
      enddo
      close(11)

      write(10,*) "Writing file"
      write(*,*) "Writing file"

      open(unit=11,file="grid.dat",status='unknown') 
      do i=1,ixmx
        do j=1,jymx
          x=(float(i)-1.0)*dx+0.0*dx/2.0+x_min
          y=(float(j)-1.0)*dy+0.0*dy/2.0+y_min
          write(11,'(F10.2,F12.4,I5)') x,y,f(i,j)
        enddo
      enddo
      close(11)

      close(10)

      end program 


