!
!     * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
!     *                                                               *
!     *                  copyright (c) 1998 by UCAR                   *
!     *                                                               *
!     *       University Corporation for Atmospheric Research         *
!     *                                                               *
!     *                      all rights reserved                      *
!     *                                                               *
!     *                      SPHEREPACK version 3.2                   *
!     *                                                               *
!     *       A Package of Fortran Subroutines and Programs           *
!     *                                                               *
!     *              for Modeling Geophysical Processes               *
!     *                                                               *
!     *                             by                                *
!     *                                                               *
!     *                  John Adams and Paul Swarztrauber             *
!     *                                                               *
!     *                             of                                *
!     *                                                               *
!     *         the National Center for Atmospheric Research          *
!     *                                                               *
!     *                Boulder, Colorado  (80307)  U.S.A.             *
!     *                                                               *
!     *                   which is sponsored by                       *
!     *                                                               *
!     *              the National Science Foundation                  *
!     *                                                               *
!     * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
!
!
!
! ... file vshifte.f contains code and documentation for subroutine vshifte
!     and its initialization subroutine vshifti
!
! ... required files
!
!     type_HFFTpack.f
!
!     subroutine vshifte(ioff, nlon, nlat, uoff, voff, ureg, vreg, 
!    +                   wsave, lsave, work, lwork, ierror)
!
! *** purpose
!
!     subroutine vshifte does a highly accurate 1/2 grid increment shift
!     in both longitude and latitude of equally spaced vector data on the
!     sphere. data is transferred between the nlon by nlat "offset grid"
!     in (uoff, voff) (which excludes poles) and the nlon by nlat+1 "regular
!     grid" in (ureg, vreg) (which includes poles).  the transfer can go from
!     (uoff, voff) to (ureg, vreg) or vice versa (see ioff).  the grids which
!     underly the vector fields are described below.  the north and south
!     pole are at 0.5*pi and-0.5*pi radians respectively.
!     uoff and ureg are the east longitudinal vector data components.  voff
!     and vreg are the latitudinal vector data components.
!
!     subroutine sshifte can be used to shift scalar data on the sphere.
!     notice that scalar and vector quantities are fundamentally different
!     on the sphere.  for example, vectors are discontinuous and multiple
!     valued at the poles.  scalars are continuous and single valued at the
!     poles. erroneous results would be produced if one attempted to shift
!     vector fields with subroutine sshifte applied to each component of
!     of the vector.
!
! *** grid descriptions
!
!     let dlon = (pi+pi)/nlon and dlat = pi/nlat be the uniform grid
!     increments in longitude and latitude
!
!     offset grid
!
!     the "1/2 increment offset" grid (long(j), lat(i)) on which uoff(j, i)
!     and voff(j, i) are given (ioff=0) or generated (ioff=1) is
!
!          long(j) =0.5*dlon + (j-1)*dlon  (j=1, ..., nlon)
!
!     and
!
!          lat(i) = -0.5*pi + 0.5*dlat + (i-1)*dlat (i=1, ..., nlat)
!
!     the data in (uoff, voff) is "shifted" one half a grid increment in both
!     longitude and latitude and excludes the poles.  each uoff(j, 1), voff(j, 1)
!     is given at latitude -pi/2+dlat/2.  uoff(j, nlat), voff(j, nlat) is
!     given at pi/2-dlat/2 (1/2 a grid increment away from the poles).
!     uoff(1, i), voff(1, i) is given at longitude dlon/2.  each uoff(nlon, i), 
!     voff(nlon, i) is given at longitude 2*pi-dlon/2.
!
!     regular grid
!
!     let dlat, dlon be as above.  then the nlon by nlat+1 grid on which
!     ureg(j, i), vreg(j, i) are generated (ioff=0) or given (ioff=1) is
!
!          lone(j) = (j-1)*dlon (j=1, ..., nlon)
!
!      and
!
!          late(i) = -0.5*pi + (i-1)*dlat (i=1, ..., nlat+1)
!
!     values in ureg, vreg include the poles and start at zero degrees
!     longitude and at the south pole this is the "usual" equally spaced
!     grid in geophysical coordinates.
!
! *** remark
!
!     subroutine vshifte can be used in conjunction with subroutine trvsph
!     when transferring vector data from an equally spaced "1/2 increment
!     offset" grid to a gaussian or equally spaced grid (which includes poles)
!     of any resolution.  this problem (personal communication with dennis
!     shea) is encountered in geophysical modeling and data analysis.
!
! *** method
!
!     fast fourier transform software from spherepack2 and trigonometric
!     identities are used to accurately "shift" periodic vectors half a
!     grid increment in latitude and longitude.  latitudinal shifts are
!     accomplished by setting periodic 2*nlat vectors over the pole for each
!     longitude.  vector values must be negated on one side of the pole
!     to maintain periodicity prior to the 2*nlat shift over the poles.
!     when nlon is odd, the 2*nlat latitudinal shift requires an additional
!     longitude shift to obtain symmetry necessary for full circle shifts
!     over the poles.  finally longitudinal shifts are executed for each
!     shifted latitude.
!
! *** argument description
!
! ... ioff
!
!     ioff = 0 if values on the offset grid in (uoff, voff) are given and
!              values on the regular grid in (ureg, vreg) are to be generated.
!
!     ioff = 1 if values on the regular grid in (ureg, vreg) are given and
!              values on the offset grid in (uoff, voff) are to be generated.
!
! ... nlon
!
!     the number of longitude points on both the "offset" and "regular"
!     uniform grid in longitude (see "grid description" above).  nlon
!     is also the first dimension of uoff, voff, ureg, vreg.  nlon determines
!     the grid increment in longitude as dlon = 2.*pi/nlon.  for example, 
!     nlon = 144 for a 2.5 degree grid.  nlon can be even or odd and must
!     be greater than or equal to 4.  the efficiency of the computation
!     is improved when nlon is a product of small primes.
!
! ... nlat
!
!     the number of latitude points on the "offset" uniform grid.  nlat+1
!     is the number of latitude points on the "regular" uniform grid (see
!     "grid description" above).  nlat is the second dimension of uoff, voff.
!     nlat+1 must be the second dimension of ureg, vreg in the program
!     calling vshifte.  nlat determines the grid in latitude as pi/nlat.
!     for example, nlat = 36 for a five degree grid.  nlat must be at least 3.
!
! ... uoff
!
!     a nlon by nlat array that contains the east longitudinal vector
!     data component on the offset grid described above.  uoff is a
!     given input argument if ioff=0.  uoff is a generated output
!     argument if ioff=1.
!
! ... voff
!
!     a nlon by nlat array that contains the latitudinal vector data
!     component on the offset grid described above.  voff is a given
!     input argument if ioff=0.  voff is a generated output argument
!     if ioff=1.
!
! ... ureg
!
!     a nlon by nlat+1 array that contains the east longitudinal vector
!     data component on the regular grid described above.  ureg is a given
!     input argument if ioff=1.  ureg is a generated output argument
!     if ioff=0.
!
! ... vreg
!
!     a nlon by nlat+1 array that contains the latitudinal vector data
!     component on the regular grid described above.  vreg is a given
!     input argument if ioff=1.  vreg is a generated output argument
!     if ioff=0.
!
! ... wsav
!
!     a real saved work space array that must be initialized by calling
!     subroutine vshifti(ioff, nlon, nlat, wsav, ier) before calling vshifte.
!     wsav can then be used repeatedly by vshifte as long as ioff, nlon, 
!     and nlat do not change.  this bypasses redundant computations and
!     saves time.  undetectable errors will result if vshifte is called
!     without initializing wsav whenever ioff, nlon, or nlat change.
!
! ... lsav
!
!     the length of the saved work space wsav in the routine calling vshifte
!     and sshifti.  lsave must be greater than or equal to 2*(2*nlat+nlon+16).
!
! ... work
!
!     a real unsaved work space
!
! ... lwork
!
!     the length of the unsaved work space in the routine calling vshifte
!     if nlon is even then lwork must be greater than or equal to
!
!          2*nlon*(nlat+1)
!
!     if nlon is odd then lwork must be greater than or equal to
!
!          nlon*(5*nlat+1)
!
! ... ier
!
!     indicates errors in input parameters
!
!     = 0 if no errors are detected
!
!     = 1 if ioff is not equal to 0 or 1
!
!     = 2 if nlon < 4
!
!     = 3 if nlat < 3
!
!     = 4 if lsave < 2*(nlon+2*nlat)+32
!
!     = 5 if lwork < 2*nlon*(nlat+1) for nlon even or
!            lwork < nlon*(5*nlat+1) for nlon odd
!
! *** end of vshifte documentation
!
!     subroutine vshifti(ioff, nlon, nlat, lsav, wsav, ier)
!
!     subroutine vshifti initializes the saved work space wsav
!     for ioff and nlon and nlat (see documentation for vshifte).
!     vshifti must be called before vshifte whenever ioff or nlon
!     or nlat change.
!
! ... ier
!
!     = 0 if no errors with input arguments
!
!     = 1 if ioff is not 0 or 1
!
!     = 2 if nlon < 4
!
!     = 3 if nlat < 3
!
!     = 4 if lsav < 2*(2*nlat+nlon+16)
!
! *** end of vshifti documentation
!
module module_vshifte

    use spherepack_precision, only: &
        wp, & ! working precision
        ip, & ! integer precision
        PI

    use type_HFFTpack, only: &
        HFFTpack

    ! Explicit typing only
    implicit none

    ! Everything is private unless stated otherwise
    public :: vshifte
    public :: vshifti

contains

    subroutine vshifte(ioff, nlon, nlat, uoff, voff, ureg, vreg, &
        wsav, lsav, wrk, lwrk, ier)

        integer ioff, nlon, nlat, n2, nr, nlat2, nlatp1, lsav, lwrk, ier
        integer i1, i2, i3
        real uoff(nlon, nlat), voff(nlon, nlat)
        real ureg(nlon, *), vreg(nlon, *)
        real wsav(lsav), wrk(lwrk)
        !
        !     check input parameters
        !
        ier = 1
        if (ioff*(ioff-1)/=0) return
        ier = 2
        if (nlon < 4) return
        ier = 3
        if (nlat < 3) return
        ier = 4
        if (lsav < 2*(2*nlat+nlon+16)) return
        nlat2 = nlat+nlat
        nlatp1 = nlat+1
        n2 = (nlon+1)/2
        ier = 5
        if (2*n2 == nlon) then
            if ( lwrk < 2*nlon*(nlat+1)) return
            nr = n2
            i1 = 1
            i2 = 1
            i3 = i2+nlon*nlatp1
        else
            if ( lwrk < nlon*(5*nlat+1)) return
            nr = nlon
            i1 = 1
            i2 = i1+nlat2*nlon
            i3 = i2+nlatp1*nlon
        end if
        ier = 0
        if (ioff==0) then
            !
            !     shift (uoff, voff) to (ureg, vreg)
            !
            call vhftoff(nlon, nlat, uoff, ureg, wsav, nr, nlat2, &
                nlatp1, wrk(i1), wrk(i2), wrk(i2), wrk(i3))
            call vhftoff(nlon, nlat, voff, vreg, wsav, nr, nlat2, &
                nlatp1, wrk(i1), wrk(i2), wrk(i2), wrk(i3))
        else
            !
            !     shift (ureg, vreg) to (uoff, voff)
            !
            call vhftreg(nlon, nlat, uoff, ureg, wsav, nr, nlat2, &
                nlatp1, wrk(i1), wrk(i2), wrk(i2), wrk(i3))
            call vhftreg(nlon, nlat, voff, vreg, wsav, nr, nlat2, &
                nlatp1, wrk(i1), wrk(i2), wrk(i2), wrk(i3))
        end if

    end subroutine vshifte

    subroutine vhftoff(nlon, nlat, uoff, ureg, wsav, nr, &
        nlat2, nlatp1, rlatu, rlonu, rlou, wrk)
        !
        !     generate ureg from uoff (a vector component!)
        !

        integer nlon, nlat, nlat2, nlatp1, n2, nr, j, i, js, isav
        real uoff(nlon, nlat), ureg(nlon, nlatp1)
        real rlatu(nr, nlat2), rlonu(nlatp1, nlon), rlou(nlat, nlon)
        real wsav(*), wrk(*)
        isav = 4*nlat+17
        n2 = (nlon+1)/2
        !
        !     execute full circle latitude shifts for nlon odd or even
        !
        if (2*n2 > nlon) then
                 !
                 !     odd number of longitudes
                 !
            do i=1, nlat
                do j=1, nlon
                    rlou(i, j) = uoff(j, i)
                end do
            end do
            !
            !       half shift in longitude
            !
            call vhifth(nlat, nlon, rlou, wsav(isav), wrk)
                !
                !       set full 2*nlat circles in rlatu using shifted values in rlonu
                !
            do j=1, n2-1
                js = j+n2
                do i=1, nlat
                    rlatu(j, i)      = uoff(j, i)
                    rlatu(j, nlat+i) = -rlou(nlat+1-i, js)
                end do
            end do
            do j=n2, nlon
                js = j-n2+1
                do i=1, nlat
                    rlatu(j, i)      = uoff(j, i)
                    rlatu(j, nlat+i) = -rlou(nlat+1-i, js)
                end do
            end do
            !
            !       shift the nlon rlat vectors one half latitude grid
            !
            call vhifth(nlon, nlat2, rlatu, wsav, wrk)
                    !
                    !       set in ureg
                    !
            do j=1, nlon
                do i=1, nlat+1
                    ureg(j, i) =  rlatu(j, i)
                end do
            end do
        else
                !
                !     even number of longitudes (no initial longitude shift necessary)
                !     set full 2*nlat circles (over poles) for each longitude pair (j, js)
                !     negating js vector side for periodicity
                !
            do j=1, n2
                js = n2+j
                do i=1, nlat
                    rlatu(j, i)      = uoff(j, i)
                    rlatu(j, nlat+i) =-uoff(js, nlatp1-i)
                end do
            end do
            !
            !       shift the n2=(nlon+1)/2 rlat vectors one half latitude grid
            !
            call vhifth(n2, nlat2, rlatu, wsav, wrk)
            !
            !       set ureg, vreg shifted in latitude
            !
            do j=1, n2
                js = n2+j
                ureg(j, 1) =   rlatu(j, 1)
                ureg(js, 1) = -rlatu(j, 1)
                do i=2, nlatp1
                    ureg(j, i) =  rlatu(j, i)
                    ureg(js, i) =-rlatu(j, nlat2-i+2)
                end do
            end do
        end if
        !
        !     execute full circle longitude shift
        !
        do j=1, nlon
            do i=1, nlatp1
                rlonu(i, j) = ureg(j, i)
            end do
        end do
        call vhifth(nlatp1, nlon, rlonu, wsav(isav), wrk)
        do j=1, nlon
            do i=1, nlatp1
                ureg(j, i) = rlonu(i, j)
            end do
        end do
    end subroutine vhftoff
    subroutine vhftreg(nlon, nlat, uoff, ureg, wsav, nr, nlat2, &
        nlatp1, rlatu, rlonu, rlou, wrk)
        !
        !     generate uoff vector component from ureg
        !

        integer nlon, nlat, nlat2, nlatp1, n2, nr, j, i, js, isav
        real uoff(nlon, nlat), ureg(nlon, nlatp1)
        real rlatu(nr, nlat2), rlonu(nlatp1, nlon), rlou(nlat, nlon)
        real wsav(*), wrk(*)
        isav = 4*nlat+17
        n2 = (nlon+1)/2
        !
        !     execute full circle latitude shifts for nlon odd or even
        !
        if (2*n2 > nlon) then
            !
            !     odd number of longitudes
            !
            do i=1, nlatp1
                do j=1, nlon
                    rlonu(i, j) = ureg(j, i)
                end do
            end do
            !
            !       half shift in longitude in rlon
            !
            call vhifth(nlatp1, nlon, rlonu, wsav(isav), wrk)
                !
                !       set full 2*nlat circles in rlat using shifted values in rlon
                !
            do j=1, n2
                js = j+n2-1
                rlatu(j, 1) = ureg(j, 1)
                do i=2, nlat
                    rlatu(j, i) = ureg(j, i)
                    rlatu(j, nlat+i) =-rlonu(nlat+2-i, js)
                end do
                rlatu(j, nlat+1) = ureg(j, nlat+1)
            end do
            do j=n2+1, nlon
                js = j-n2
                rlatu(j, 1) = ureg(j, 1)
                do i=2, nlat
                    rlatu(j, i) = ureg(j, i)
                    rlatu(j, nlat+i) =-rlonu(nlat+2-i, js)
                end do
                rlatu(j, nlat+1) = ureg(j, nlat+1)
            end do
            !
            !       shift the nlon rlat vectors one halflatitude grid
            !
            call vhifth(nlon, nlat2, rlatu, wsav, wrk)
            !
            !       set values in uoff
            !
            do j=1, nlon
                do i=1, nlat
                    uoff(j, i) = rlatu(j, i)
                end do
            end do
        else
                !
                !     even number of longitudes (no initial longitude shift necessary)
                !     set full 2*nlat circles (over poles) for each longitude pair (j, js)
                !
            do j=1, n2
                js = n2+j
                rlatu(j, 1) = ureg(j, 1)
                do i=2, nlat
                    rlatu(j, i) = ureg(j, i)
                    rlatu(j, nlat+i) =-ureg(js, nlat+2-i)
                end do
                rlatu(j, nlat+1) = ureg(j, nlat+1)
            end do
            !
            !       shift the n2=(nlon+1)/2 rlat vectors one half latitude grid
            !
            call vhifth(n2, nlat2, rlatu, wsav, wrk)
                !
                !       set values in uoff
                !
            do j=1, n2
                js = n2+j
                do i=1, nlat
                    uoff(j, i) =  rlatu(j, i)
                    uoff(js, i) =-rlatu(j, nlat2+1-i)
                end do
            end do
        end if
        !
        !     execute full circle longitude shift for all latitude circles
        !
        do j=1, nlon
            do i=1, nlat
                rlou(i, j) = uoff(j, i)
            end do
        end do
        call vhifth(nlat, nlon, rlou, wsav(isav), wrk)
        do j=1, nlon
            do i=1, nlat
                uoff(j, i) = rlou(i, j)
            end do
        end do
    end subroutine vhftreg

    subroutine vshifti(ioff, nlon, nlat, lsav, wsav, ier)

        integer :: lsav
        !
        !     initialize wsav for vshifte
        !
        integer ioff, nlat, nlon, nlat2, isav, ier
        real wsav(lsav)
        real dlat, dlon, dp
        ier = 1
        if (ioff*(ioff-1)/=0) return
        ier = 2
        if (nlon < 4) return
        ier = 3
        if (nlat < 3) return
        ier = 4
        if (lsav < 2*(2*nlat+nlon+16)) return
        ier = 0
        !
        !     set lat, long increments
        !
        dlat = pi/nlat
        dlon = (pi+pi)/nlon
        !
        !     set left or right latitude shifts
        !
        if (ioff==0) then
            dp = -0.5*dlat
        else
            dp = 0.5*dlat
        end if

        nlat2 = nlat+nlat

        call vhifthi(nlat2, dp, wsav)
        !
        !     set left or right longitude shifts
        !
        if (ioff==0) then
            dp = -0.5*dlon
        else
            dp = 0.5*dlon
        end if

        isav = 4*nlat + 17

        call vhifthi(nlon, dp, wsav(isav))

    end subroutine vshifti

    subroutine vhifth(m, n, r, wsav, work)

        type (HFFTpack) :: hfft
        integer m, n, n2, k, l
        real r(m, n), wsav(*), work(*), r2km2, r2km1
        n2 = (n+1)/2
        !
        !     compute fourier coefficients for r on shifted grid
        !
        call hfft%forward(m, n, r, m, wsav(n+2), work)

        do l=1, m
            do k=2, n2
                r2km2 = r(l, k+k-2)
                r2km1 = r(l, k+k-1)
                r(l, k+k-2) = r2km2*wsav(n2+k) - r2km1*wsav(k)
                r(l, k+k-1) = r2km2*wsav(k) + r2km1*wsav(n2+k)
            end do
        end do
        !
        !     shift r with fourier synthesis and normalization
        !
        call hfft%backward(m, n, r, m, wsav(n+2), work)

        do l=1, m
            do k=1, n
                r(l, k) = r(l, k)/n
            end do
        end do

    end subroutine vhifth

    subroutine vhifthi(n, dp, wsav)
        !
        !     initialize wsav for subroutine vhifth
        !
        use type_HFFTpack, only: &
            HFFTpack



        type (HFFTpack) :: hfft
        integer n, n2, k
        real wsav(*), dp


        n2 = (n+1)/2

        do k=2, n2
            wsav(k) = sin((k-1)*dp)
            wsav(k+n2) = cos((k-1)*dp)
        end do

        call hfft%initialize(n, wsav(n+2))

    end subroutine vhifthi

end module module_vshifte
