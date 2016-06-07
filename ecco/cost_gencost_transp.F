C $Header: /u/gcmpack/MITgcm/pkg/ecco/cost_gencost_transp.F,v 1.4 2015/11/12 13:22:14 atn Exp $
C $Name:  $

#include "ECCO_OPTIONS.h"

      subroutine cost_gencost_transp(mythid)

c     ==================================================================
c     SUBROUTINE cost_gencost_transp
c     ==================================================================
c
c     o Evaluate cost function contributions of section transport.
c
c     ==================================================================
c     SUBROUTINE cost_gencost_boxmean
c     ==================================================================

      implicit none

c     == global variables ==

#include "EEPARAMS.h"
#include "SIZE.h"
#include "PARAMS.h"
#include "GRID.h"
#ifdef ALLOW_CAL
# include "cal.h"
#endif
#ifdef ALLOW_ECCO
# include "ecco.h"
#endif

c     == routine arguments ==
      integer mythid

#ifdef ALLOW_GENCOST_CONTRIBUTION

c     == local variables ==

c      integer nnzobs, nnzbar
c      parameter (nnzbar = Nr, nnzobs = Nr)
      integer nrecloc, localrec, ioUnit
c      integer localstartdate(4)

c      _RL myobs     (1-olx:snx+olx,1-oly:sny+oly,nr,nsx,nsy)
      _RL mybar     (1-olx:snx+olx,1-oly:sny+oly,nr,nsx,nsy)
c      _RL localdif  (1-olx:snx+olx,1-oly:sny+oly,nr,nsx,nsy)
c      _RL difmask   (1-olx:snx+olx,1-oly:sny+oly,nr,nsx,nsy)
c      _RL localweight(1-olx:snx+olx,1-oly:sny+oly,nr,nsx,nsy)
c      _RL localtmp   (1-olx:snx+olx,1-oly:sny+oly,nr,nsx,nsy)

      _RL dummy,gencost_mskTemporal,facNum
      _RS dummyRS(1)
c- facNum is 1 divided by the number of tiles in SIZE dot h
c      parameter  ( facNum = 1./float(nPx) )
c      _RL localperiod
c      _RL spminloc, spmaxloc, spzeroloc

      _RL tmpSumTile(nSx,nSy),tmpNumTile(nSx,nSy)
      _RL tmpSumGlo,tmpNumGlo
      _RL mySumGlo

      character*(MAX_LEN_FNAM) mybarfile
c      character*(MAX_LEN_FNAM) myobsfile

      integer kgen, kg3
      integer bi,bj
      integer i,j,k
      integer itlo,ithi
      integer jtlo,jthi
      integer imin, imax
      integer jmin, jmax
      integer irec
      integer il
c      integer icount,icount_transp
c      logical dosumsq, dovarwei, doreadobs

c      integer preproc_i(NGENPPROC)
c      _RL preproc_r(NGENPPROC)
c      character*(MAX_LEN_FNAM) preproc(NGENPPROC)
c      character*(MAX_LEN_FNAM) preproc_c(NGENPPROC)


      logical doglobalread
      logical ladinit
      character*(MAX_LEN_MBUF) msgbuf
      character*(128) fname1, fname0

      logical exst

c     == external functions ==

      integer  ilnblnk
      external ilnblnk

c     == end of interface ==

      jtlo = mybylo(mythid)
      jthi = mybyhi(mythid)
      itlo = mybxlo(mythid)
      ithi = mybxhi(mythid)
      imin = 1
      imax = sNx
      jmin = 1 
      jmax = sNy


      write(msgbuf,'(A)') 'Inside cost_gencost_transp:'
      CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                    SQUEEZE_RIGHT, myThid )


      do kgen=1,NGENCOST
        kg3 = gencost_pointer3d(kgen)

c-- detect the relevant gencost indices
        if ( (gencost_name(kgen)(1:6).EQ.'transp').AND.
     &     (using_gencost(kgen)) ) then
          il=ilnblnk(gencost_barfile(kgen))
          write(msgbuf,'(A,i4,A,A)') 'Cost ',kgen,
     &    ': ',gencost_barfile(kgen)(1:il)
          CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                        SQUEEZE_RIGHT, myThid )


c=============== PART 0: initilization ===================

c-- local variables
        nrecloc=gencost_nrec(kgen)
        doglobalread = .false.
        ladinit = .false. 
        dummy = gencost_dummy(kgen)
        nrecloc=gencost_nrec(kgen)
        il=ilnblnk(gencost_barfile(kgen))
        write(mybarfile,'(2a,i10.10)') 
     &    gencost_barfile(kgen)(1:il),'.',eccoiter
c model mask[W,S]: already included in transp calc in ecco_phys


c=============== PART 1: main loop ===================
        do irec = 1,nrecloc

c-- Read barfile
#ifdef ALLOW_AUTODIFF
          call active_read_xyz( mybarfile, mybar, irec,
     &                       doglobalread, ladinit,
     &                       eccoiter, mythid,
     &                       dummy )
#else
          call READ_REC_XYZ_RL( mybarfile, mybar, irec, 
     &                       1, mythid )
#endif /* ALLOW_AUTODIFF */ 

c-- Temporal mask
          il = ilnblnk(gencost_errfile(kgen))
          write(fname0(1:128),'(2A)') 
     &      gencost_errfile(kgen)(1:il),'T'
          inquire( file=fname0(1:il+1), exist=exst )

          if ( (.NOT.exst).OR.(gencost_errfile(kgen).EQ.' ')
     &          ) then

           write(msgBuf,'(3A)') '**Warning: temporal msk file: ',
     &       fname0(1:il+1), ' not found, using 1/nrecloc'        
           CALL PRINT_MESSAGE(msgBuf, standardMessageUnit, 
     &         SQUEEZE_RIGHT, myThid ) 

           gencost_mskTemporal=nrecloc
           gencost_mskTemporal=1. _d 0 / gencost_mskTemporal
          else

           write(msgBuf,'(3A,I2)') 'Using temporal msk from file: ',
     &          fname0(1:il+1), ' nrecloc: ', nrecloc
           CALL PRINT_MESSAGE(msgBuf, standardMessageUnit,
     &          SQUEEZE_RIGHT, myThid )

           ioUnit = 0           
           call MDS_READVEC_LOC(fname0,cost_iprec,ioUnit,'RL',
     &          1, gencost_mskTemporal, dummyRS, 0, 0, irec, myThid )
          endif
c-- Compute cost

          if ( myProcId .EQ. 0 ) num_gencost(1,1,kgen)=
     &      num_gencost(1,1,kgen)+gencost_mskTemporal

c-- keep total at each irec to print out for time-series
c-- local sum across tiles

          DO bj = jtlo,jthi
            DO bi = itlo,ithi
              tmpSumTile(bi,bj) = 0. _d 0
              tmpNumTile(bi,bj) = 0. _d 0
              do k = 1,nr
                do j = jmin,jmax
                  do i = imin,imax
c sum for display of time series
                    tmpSumTile(bi,bj)=tmpSumTile(bi,bj) +
     &              mybar(i,j,k,bi,bj)*gencost_mskTemporal

                    tmpNumTile(bi,bj)=
     &              tmpNumTile(bi,bj)+1. _d 0

c sum for actual cost function
                    objf_gencost(bi,bj,kgen)=objf_gencost(bi,bj,kgen)+
     &              mybar(i,j,k,bi,bj)*gencost_mskTemporal
                  enddo
                enddo
              enddo
            ENDDO
          ENDDO 

c-- Compute global sum for time series
          tmpSumGlo = 0. _d 0
          tmpNumGlo = 0. _d 0
          il=ilnblnk(gencost_barfile(kgen))
          CALL GLOBAL_SUM_TILE_RL( tmpSumTile, tmpSumGlo, myThid )
          CALL GLOBAL_SUM_TILE_RL( tmpNumTile, tmpNumGlo, myThid )
          WRITE(msgBuf,'(2A,I3,A,1PE21.14,1PE21.14)')
     &        'globalsum transp ',gencost_barfile(kgen)(1:il),
     &        irec,' ',tmpSumGlo,tmpNumGlo
          CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                          SQUEEZE_RIGHT, myThid )

        enddo ! irec=1->nrecloc

c-- sum that is actually be used in cost function
          mySumGlo = 0. _d 0
          CALL GLOBAL_SUM_TILE_RL( objf_gencost(1,1,kgen),
     &      mySumGlo, myThid )
          WRITE(msgBuf,'(A,1PE21.14)') 'transp fc: ', mySumGlo
          CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                        SQUEEZE_RIGHT, myThid )
        
        endif ! gencost_name(kgen)=transp
      enddo ! kgen=1->NGENCOST

#endif /* ALLOW_GENCOST_CONTRIBUTION */

      end
