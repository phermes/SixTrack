      program checkf110
      use, intrinsic :: iso_fortran_env, only : output_unit
      implicit none
      double precision prob(60),prob1(60)
      integer line,word,i
      logical diff,diffs
      logical hasInputFile
! Now compare the closed orbit in 53-60 as well
      do i=1,60
        prob(i) = 0
        prob1(i) = 0
      enddo
      line=0
      diff=.false.
      diffs=.false.
      
      hasInputFile = .false.
      INQUIRE(file="fort.20",EXIST=hasInputFile)
      if (.not. hasInputFile) then
         write(*,'(a,a)') "Error in checkf110 - file 'fort.20'"//       &
     &        " was not found"
         flush(output_unit)
         stop 1
      endif
      hasInputFile = .false.
      INQUIRE(file="fort.21",EXIST=hasInputFile)
      if (.not. hasInputFile) then
         write(*,'(a,a)') "Error in checkf110 - file 'fort.21'"//       &
     &        " was not found"
         flush(output_unit)
         stop 2
      endif
      
      open(20,status='OLD', file="fort.20")
      open(21,status='OLD', file="fort.21")
      
    1 read (20,end=100,err=98) prob
      line=line+1
      read (21,end=99,err=97) prob1
      if (diffs) diff=.true.
      diffs=.false.
      do word=1,51
        if (prob(word).ne.prob1(word)) diffs=.true.
      enddo 
      do word=53,60
        if (prob(word).ne.prob1(word)) diffs=.true.
      enddo 
      if (diffs) then
        write (*,*)
        write (*,*) "DIFF fort.10, line",line
        do word=1,51
          if (prob(word).ne.prob1(word)) then
            write (*,*) "DIFF",word,prob(word),prob1(word)
          else
            write (*,*) "checkf110_SAME",word,prob(word)
          endif
        enddo
        do word=53,60
          if (prob(word).ne.prob1(word)) then
            write (*,*) "DIFF",word,prob(word),prob1(word)
          else
            write (*,*) "checkf110_SAME",word,prob(word)
          endif
        enddo
        write (*,*)
      else
        write (*,*) "checkf110_SAME fort.10, line",line
      endif
      go to 1
 99   continue
      write (*,*) "Comparing VERSION ",prob(52)," to ",prob1(52)
      write (*,*) "DIFF I/O error, wrong no of lines!! line no ",line
      flush(output_unit)
      stop
 98   continue
      write (*,*) "Comparing VERSION ",prob(52)," to ",prob1(52)
      write (*,*) "DIFF I/O error!! fort.20 line no ",line
      flush(output_unit)
      stop
 97   continue
      write (*,*) "Comparing VERSION ",prob(52)," to ",prob1(52)
      write (*,*) "DIFF I/O error!! fort.21 line no ",line
      flush(output_unit)
      stop
 100  continue
      if (line.eq.0) go to 99
      write (*,*) "Comparing VERSION ",prob(52)," to ",prob1(52)
      if (diff) then
        write (*,*) "DIFF after comparing ",line ,"lines"
      else
        write (*,*) "checkf110_SAME after comparing ",line ,"lines"
      endif
      end
