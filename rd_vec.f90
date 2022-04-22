      program rd_vec
      implicit real*8 (a-h,o-z) 
      real*8, dimension(:)  , allocatable :: c
 
      open(unit=1,file='rd.inp',status='unknown')
      read(1,*) norb

      allocate (c(norb),STAT=istat)
      if (istat /= 0) STOP "*** Not enough memory ***"

      open(unit=2,file='INPORB',access='append')
      
      ncol = 4
      col_n= dble(ncol)

      floatnumat=dfloat(norb)/col_n
      nlines=ceiling(floatnumat)

      nrem=ncol*nlines-norb

      write(*,*) nlines

      do i = 1,norb
        write(2,'(A,I5)') "* ORBITAL    1",i
        if (nrem == 0) then
          do j = 1,nlines
            read(1,*) (c(k),k=(j-1)*ncol+1,(j-1)*ncol+4)
            write(2,'(4E18.12)') (c(k),k=(j-1)*ncol+1,(j-1)*ncol+4)
          enddo
        else
          do j = 1,nlines-1
            read(1,*) (c(k),k=(j-1)*ncol+1,(j-1)*ncol+4)
            write(2,'(4E18.12)') (c(k),k=(j-1)*ncol+1,(j-1)*ncol+4)
          enddo
          read(1,*) (c(k),k=(j-1)*ncol+1,(j-1)*ncol+nrem)
          write(2,'(4E18.12)') (c(k),k=(j-1)*ncol+1,(j-1)*ncol+nrem)
        endif
      enddo

      end program
