      Subroutine RECT(Z,N,N1,N2,N3,N4)
c
c     this subroutine is taken from ives,d.c. and
c     r.m.zacharias "conformal mapping and orthogonal grid generation"
c     aiaa-87-2057.
c
c     The only modification is the addition of the "tracking_error"
c     warning message.  This allows matlab to gracefully exit a call
c     to RECT that is going badly.
c
      Implicit Double Precision (A-H,O-Z)
      Complex*16 Z(1), Z0, ZD
      Double Precision R(40000), T(40000)
      PI = 4.D0 * DATAN(1.D0)
      Do 70 I = 1, N
        IM = N - MOD(N-I+1,N)
        IP = 1 + MOD(I,N)
        ZD = (Z(IM)-Z(I)) / (Z(IP)-Z(I))
        ALPHA = DATAN2(DIMAG(ZD),DREAL(ZD))
        If (ALPHA.LT.0) ALPHA = ALPHA + PI + PI
        PWR = PI / ALPHA
        If (I.EQ.N1.OR.I.EQ.N2.OR.I.EQ.N3.OR.I.EQ.N4) Then
          ZD = (Z(IM)-Z(I)) / CDABS(Z(IM)-Z(I))
          Do 10 J = 1, N
            Z(J) = DCMPLX(0.D0,1.D0) * Z(J) / ZD
   10     Continue
          PWR = PWR / 2.
        End If
        H1IN = 100.
        H1AX = -100.
        TP = 0.
        Do 40 J = 2, N
          ZD = Z(MOD(J+I-2,N)+1) - Z(I)
          R(J) = CDABS(ZD)
          T(J) = DATAN2(DIMAG(ZD),DREAL(ZD)) - PI - PI - PI - PI - PI -
     *        PI
          Do 20 K = 1, 7
            If (DABS(T(J)-TP).LT.PI) Go To 30
            T(J) = T(J) + PI + PI
   20     Continue
         call mexErrMsgTxt ( 'warning - tracking error ' )
		 return
c        pause ' warning - tracking error '
c        Call CRASH(TTYOUT,4,0)
   30     TP = T(J)
          H1AX = DMAX1(H1AX,T(J)*PWR)
          H1IN = DMIN1(H1IN,T(J)*PWR)
   40   Continue
        PWR = DMIN1(PWR,1.98D0*PI*PWR/(H1AX-H1IN))
        Z(I) = DCMPLX(0.D0,0.D0)
        Do 50 J = 2, N
          Z(MOD(J+I-2,N)+1) = R(J) ** PWR * 
     *        CDEXP(DCMPLX(0.D0,T(J)*PWR))
   50   Continue
        ZD = 1. / (Z(N2)-Z(N1))
        Z0 = Z(N1)
        Do 60 J = 1, N
          Z(J) = (Z(J)-Z0) * ZD
   60   Continue
   70 Continue
      Return
      End
