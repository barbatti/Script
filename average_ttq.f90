      program average_ttq

      ! From a list with (traj, step, Q) make average of Q over traj.  

      implicit none

      integer i_prv,ios,imax,nevent,n_step,lines,i,j,mxstep,itraj
      real*8 t,tmax,dt,Qaux,sumQ,average
      real*8,dimension(:,:),allocatable :: Q

      ! INPUTS
      tmax  = 200.D0
      dt    = 0.5D0
      mxstep= 1+int(tmax/dt)

      open(unit=7,file="list_ttq.dat",status="unknown")
      ios = 0
      lines=-1
      i_prv=0
      imax=0
      do while (ios == 0)
        read(7,*,iostat=ios) i
        if (i /= i_prv) then
          imax=imax+1
        endif
        i_prv=i
        lines=lines+1
      enddo  
      write(*,*) "Number of lines = ",lines
      close(7)
      write(*,*) "Number of trajectories = ",imax," Max. step =",mxstep
    
      allocate (Q(imax,mxstep))

      open(unit=7,file="list_ttq.dat",status="unknown")
      ios = 0
      Q = -1.D0
      i_prv=0
      i=0
      do while (ios == 0)   
        read(7,*,iostat=ios) itraj,t,Qaux
        if (itraj /= i_prv) then
          i=i+1
        endif
        i_prv=itraj
        j=1+int(t/dt)
        Q(i,j)=Qaux
        write(*,*) "i,j,Q(i,j) = ",i,j,Q(i,j)
      enddo
      close(7)

      write(*,*) ".... STARTING AVERAGE ....."

      open(unit=8,file="average.dat",status="unknown")
      do j=1,mxstep
        sumQ=0.D0
        nevent=0
        do i=1,imax
           if (Q(i,j) >= 0.D0) then
              sumQ=sumQ+Q(i,j)
              nevent=nevent+1
           endif
        enddo
        average=sumQ/nevent
        write(*,*) (j-1)*dt,average,nevent
        write(8,*) (j-1)*dt,average,nevent
      enddo

      end program average_ttq
