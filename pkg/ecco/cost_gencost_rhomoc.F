C $Header: /u/gcmpack/MITgcm/pkg/ecco/cost_gencost_transp.F,v 1.4 2015/11/12 13:22:14 atn Exp $
C $Name:  $

#include "ECCO_OPTIONS.h"

      subroutine cost_gencost_rhomoc(mythid)

c     ==================================================================
c     SUBROUTINE cost_gencost_rhomoc
c     ==================================================================
c
c     o Evaluate cost function contributions from AMOC defined:
c       
c       AMOC = max_k { cumsum_k { zonally integrated meridional volume transport } }
c       
c     o mybar loads trVol from barfile, which is masked by S/W edge mask
c       these masks denote the latitude line for taking zonal integral
c
c     ==================================================================
c     SUBROUTINE cost_gencost_rhomoc
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

cts std for ecco ---
      integer nrecloc, localrec, ioUnit
      character*(MAX_LEN_FNAM) mybarfile

      integer kgen, kg3
      integer bi,bj
      integer i,j,k
      integer itlo,ithi
      integer jtlo,jthi
      integer imin, imax
      integer jmin, jmax
      integer irec
      integer il
      integer kmax

      logical doglobalread
      logical ladinit
      character*(MAX_LEN_MBUF) msgbuf
      character*(128) fname0

      logical exst

      _RL mybar     (1-olx:snx+olx,1-oly:sny+oly,nr,nsx,nsy)

      _RL dummyRL, gencost_mskTemporal
      _RS dummyRS(1)

cts------

cts- for dens space calcs
      integer kmaxdepth, knmaxdense, Nlayers
      integer kgv(sNx+1,sNy+1)
      _RL TatU, TatV, SalV, RhoV
      _RL layers_G(Nlayers)
      _RL layers_VFlux(1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nlayers,nSx,nSy)
      _RL Vflux_bar(Nlayers)
      _RL petawatt, Kelvin2Celsius
      _RL sum
      _RL     eosJMDCFw_1
      _RL     eosJMDCFw_2
      _RL     eosJMDCFw_3
      _RL     eosJMDCFw_4
      _RL     eosJMDCFw_5
      _RL     eosJMDCFw_6
      _RL     eosJMDCSw_1
      _RL     eosJMDCSw_2
      _RL     eosJMDCSw_3
      _RL     eosJMDCSw_4
      _RL     eosJMDCSw_5
      _RL     eosJMDCSw_6
      _RL     eosJMDCSw_7
      _RL     eosJMDCSw_8
      _RL     eosJMDCSw_9

      _RL tmpCumSumTile(Nlayers,nSx,nSy),tmpNumTile(nSx,nSy)
      _RL tmpCumSumGlo(Nlayers),tmpNumGlo
      _RL myTempMax

      parameter( petawatt = 1. _d +15 )
      parameter( Kelvin2Celsius = 2.7315 _d 02 )
C coefficients nonlinear equation of state in p-coord. for
C density of fresh water at the surface ref. level p = 0
      parameter ( eosJMDCFw_1 =  999.842594 _d 0 )
      parameter ( eosJMDCFw_2 =    6.793952 _d -2 )
      parameter ( eosJMDCFw_3 =   -9.095290 _d -3 )
      parameter ( eosJMDCFw_4 =    1.001685 _d -4 )
      parameter ( eosJMDCFw_5 =   -1.120083 _d -6 )
      parameter ( eosJMDCFw_6 =    6.536332 _d -9 )
C density of sea water at at the surface ref. level p = 0
      parameter ( eosJMDCSw_1 =    8.244930 _d -1 )
      parameter ( eosJMDCSw_2 =   -4.089900 _d -3 )
      parameter ( eosJMDCSw_3 =    7.643800 _d -5 )
      parameter ( eosJMDCSw_4 =   -8.246700 _d -7 )
      parameter ( eosJMDCSw_5 =    5.387500 _d -9 )
      parameter ( eosJMDCSw_6 =   -5.724660 _d -3 )
      parameter ( eosJMDCSw_7 =    1.022700 _d -4 )
      parameter ( eosJMDCSw_8 =   -1.654600 _d -6 )
      parameter ( eosJMDCSw_9 =    4.831400 _d -4 )

cts - max depth from ECCOv4 setup
      parameter( Nlayers = 15 )
      parameter ( kmaxdepth = 50 )

      DATA layers_G / 21, 21.5, 22, 22.5, 23, 23.5,
     & 24, 24.5, 25, 25.5, 26, 26.5, 27, 27.5, 28 /
cts ------------

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


      write(msgbuf,'(A)') 'Inside cost_gencost_rhomoc ...'
      CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                    SQUEEZE_RIGHT, myThid )

      do kgen=1,NGENCOST
        kg3 = gencost_pointer3d(kgen)

c-- detect the relevant gencost indices
        if ( (gencost_name(kgen)(1:4).EQ.'amoc').AND.
     &     (using_gencost(kgen)) ) then
          il=ilnblnk(gencost_barfile(kgen))
          write(msgbuf,'(A,i4,A,A)') 'Cost ',kgen,
     &    ': ',gencost_barfile(kgen)(1:il)
          CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                        SQUEEZE_RIGHT, myThid )


c=============== PART 0: initilization ===================

c-- local variables

        doglobalread = .false.
        ladinit = .false. 
        dummyRL = gencost_dummy(kgen)
        nrecloc=gencost_nrec(kgen)
        il=ilnblnk(gencost_barfile(kgen))
        write(mybarfile,'(2a,i10.10)') 
     &    gencost_barfile(kgen)(1:il),'.',eccoiter

        nrecloc=gencost_nrec(kgen)


c=============== PART 1: main loop ===================
        do irec = 1,nrecloc

c-- Read barfile
#ifdef ALLOW_AUTODIFF
          call active_read_xyz( mybarfile, mybar, irec,
     &                       doglobalread, ladinit,
     &                       eccoiter, mythid,
     &                       dummyRL )
#else
          call READ_REC_XYZ_RL( mybarfile, mybar, irec, 
     &                       1, mythid )
#endif /* ALLOW_AUTODIFF */ 

c-- Initialize after read
          DO bj = jtlo,jthi
            DO bi = itlo,ithi
              do k = 1, Nr
                tmpCumSumTile(k,bi,bj) = 0. _d 0
                Vflux_bar(k) = 0. _d 0
                do j = 1,sNy+1
                  do i = 1,sNx+1
                    layers_VFlux(i,j,k,bi,bj) = 0. _d 0
                    kgv(i,j) = Nlayers
                  enddo
                enddo
              enddo
              tmpNumTile(bi,bj) = 0. _d 0
            ENDDO
          ENDDO

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

           write(msgBuf,'(2A)') 'Using temporal msk from file: ',
     &          fname0(1:il+1)
           CALL PRINT_MESSAGE(msgBuf, standardMessageUnit,
     &          SQUEEZE_RIGHT, myThid )

           ioUnit = 0           
           call MDS_READVEC_LOC(fname0,cost_iprec,ioUnit,'RL',
     &          1, gencost_mskTemporal, dummyRS, 0, 0, irec, myThid )
          endif

c=============== PART 2: Cost Computation ===================
c-- Compute cost only if nonzero temporal mask

          if ( gencost_mskTemporal .ne. 0 ) then 

          if ( myProcId .EQ. 0 ) num_gencost(1,1,kgen)=
     &      num_gencost(1,1,kgen)+gencost_mskTemporal


           do bj=myByLo(myThid),myByHi(myThid)
            do bi=myBxLo(myThid),myBxHi(myThid)
             do j=1,sNy
              do i=1,sNx
               do k = 1, Nr

c=============== PART 2.1: Compute T,S,rho ===================
c This directly follows Yavor's density space amoc function
c 

C ------ Find theta and S at the southern V point
c               TatV =
c     &          0.25 _d 0 * (theta(i,j-1,k,bi,bj)+theta(i,j,k,bi,bj)) +
c     &          0.25 _d 0 * (theta(i,j-1,k+1,bi,bj)+theta(i,j,k+1,bi,bj))
                TatV = theta(i,j,k,bi,bj)
c     &          - Kelvin2Celsius
                 WRITE(msgBuf,'(A,1E14.6)')
     &            'S/R: The interpolated TatV=',
     &            TatV
                CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                       SQUEEZE_RIGHT, myThid )
                SalV = salt(i,j,k,bi,bj)
                 WRITE(msgBuf,'(A,1E14.6)')
     &            'S/R: The interpolated SalV=',
     &            SalV
                 CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                       SQUEEZE_RIGHT, myThid )

C density of freshwater at the surface reference level p=0
                 RhoV =
     &          + eosJMDCFw_2*TatV
     &          + eosJMDCFw_3*TatV**2
     &          + eosJMDCFw_4*TatV**3
     &          + eosJMDCFw_5*TatV**4
     &          + eosJMDCFw_6*TatV**5
C density of sea water at the surface reference level p=0
                IF (SalV .NE. 0.) THEN
                RhoV =  RhoV
     &          + SalV*(
     &              eosJMDCSw_1
     &              + eosJMDCSw_2*TatV
     &              + eosJMDCSw_3*TatV**2
     &              + eosJMDCSw_4*TatV**3
     &              + eosJMDCSw_5*TatV**4
     &              )
     &                + SalV * SQRT(SalV) * (
     &              eosJMDCSw_6
     &              + eosJMDCSw_7*TatV
     &              + eosJMDCSw_8*TatV**2
     &              )
     &          + eosJMDCSw_9*SalV*SalV
                ELSE
                 RhoV = 0.
                ENDIF

                WRITE(msgBuf,'(A,3I4,1E14.6)')
     &            'S/R: Based on eos RhoV=',
     &            i,j,k,RhoV
                CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                     SQUEEZE_RIGHT, myThid )


c=============== PART 2.2: Determine density binning ===================
c This directly follows Yavor's density space amoc function
c which closely follows what's in the layers package
c 
                IF (RhoV .GE. layers_G(Nlayers)) THEN
C                our point is in the least dense bin or lighter
                 kgv(i,j) = Nlayers
                ELSE IF (RhoV .LT. layers_G(2)) THEN
C                our point is in the densest bin or denser
                 kgv(i,j) = 1
                ELSE IF ( (RhoV .GE. layers_G(kgv(i,j)))
     &           .AND. (RhoV .LT. layers_G(kgv(i,j)+1)) ) THEN
C                our point is in the correct bin
                ELSE IF (RhoV .GE. layers_G(kgv(i,j))) THEN
C                we look for the correct bin by getting denser
                 DO WHILE (RhoV .GE. layers_G(kgv(i,j)+1))
                  kgv(i,j) = kgv(i,j) + 1
                 ENDDO
C                See note in the draft code
                ELSE IF (RhoV .LT. layers_G(kgv(i,j))) THEN
C                we look for the correct bin by getting lighter
                 DO WHILE (RhoV .LT. layers_G(kgv(i,j)))
                  kgv(i,j) = kgv(i,j) - 1
                 ENDDO
C                See note in the draft code
                ELSE
C                We output an error message
                 WRITE(msgBuf,'(A,4I4,1E14.6)')
     &            'S/R cost_atl: Couldnt find a bin for RhoV=',
     &            i,j,k,kgv(i,j),RhoV
                 CALL PRINT_ERROR( msgBuf, myThid )
                 STOP 'ABNORMAL END: S/R COST'
                END IF ! RhoV Binning
                
                WRITE(msgBuf,'(A,4I4,1E14.6)')
     &            'S/R cost_atl: Bin lower',
     &            kgv(i,j)
                CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                     SQUEEZE_RIGHT, myThid )

c=============== PART 2.3: Compute vol flux in density space  ===================
c 
                layers_VFlux(i,j,kgv(i,j),bi,bj) =
     &           layers_VFlux(i,j,kgv(i,j),bi,bj)
                 + mybar(i,j,kgv(i,j),bi,bj)

                WRITE(msgBuf,'(A,1E14.6)')
     &           'S/R: In this iteration layers_VFlux=',
     &           layers_VFlux(i,j,kgv(i,j),bi,bj)
                enddo   ! k=1,Nr

c=============== PART 2.4: Take cumulative sum through layers  ===================
c Take cumulative sum of my layers_vflux from surface down
c i.e. compute the streamfunction (assuming mybar = trvol) 
c 
                do kn = 1, Nlayers
                 Vflux_bar(kn) = Vflux_bar(kn)
     &            + layers_VFlux(i,j,kn,bi,bj)

                 tmpCumSumTile(kn,bi,bj)=
     &            tmpCumSumTile(kn,bi,bj) +
     &            mybar(i,j,kn,bi,bj)*gencost_mskTemporal

                 tmpNumTile(bi,bj)=
     &            tmpNumTile(bi,bj)+1. _d 0

                 if( kn .gt. 1 ) then 
                    tmpCumSumTile(kn,bi,bj)=tmpCumSumTile(kn,bi,bj) +
     &                tmpCumSumTile(kn+1,bi,bj)
                 endif
                enddo ! k=1,Nlayers
               enddo ! i = 1,sNx
              enddo ! j= 1,sNy
             enddo ! bi = mybxlo->mybxhi
            enddo ! bj = mybylo->mybyhi

c-- Compute global sum at each level
            do k = 1,Nlayers
              tmpCumSumGlo(k) = 0. _d 0
              CALL GLOBAL_SUM_TILE_RL(tmpCumSumTile(k,1,1),
     &            tmpCumSumGlo(k),  myThid )
            enddo 

c=============== PART 2.5: Get max val ===================
c-- Find maximum in global cumulative sum

CADJ STORE myTempMax = tapelev_init, key = 1
CADJ STORE kmax = tapelev_init, key = 1
            myTempMax = tmpCumSumGlo(1)
            kmax = 1

            do k = 2, Nlayers
CADJ STORE myTempMax = tapelev_init, key = k
CADJ STORE kmax = tapelev_init, key = k
              if( myTempMax < tmpCumSumGlo(k) ) then
                myTempMax = tmpCumSumGlo(k)
                kmax = k
              endif
            enddo 

            WRITE(msgBuf,'(2A,I3,A,1PE21.14,A,I2)')
     &          'amoc cost ',gencost_barfile(kgen)(1:il),
     &          irec,' ', myTempMax, 'kmax: ',kmax
            CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                            SQUEEZE_RIGHT, myThid )

c=============== PART 2.6: Save to obj ===================
c-- Add AMOC contribution to actual objective function variable
c   Note: using global values, so only want to store in 
c         one processors obj function value

            if ( myProcId .EQ. 0 ) objf_gencost(1,1,kgen)=
     &        objf_gencost(1,1,kgen)+myTempMax 

c============= Done with cost computation =====================

            else ! mskTemporal == 0

            WRITE(msgBuf,'(A,I3,A,I3)') 
     &            'gencost_mskTemporal = 0, irec: ',irec, ' / ', 
     &            nrecloc
            CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                            SQUEEZE_RIGHT, myThid )


            endif ! mskTemporal /=0 
            enddo ! irec=1->nrecloc

c-- Print out what actually is used as cost function
            WRITE(msgBuf,'(A,1PE21.14)') 'amoc fc: ', 
     &            objf_gencost(1,1,kgen)
            CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                          SQUEEZE_RIGHT, myThid )

          endif ! gencost_name(kgen)=amoc
        enddo ! kgen=1->NGENCOST

#endif /* ALLOW_GENCOST_CONTRIBUTION */

      end
