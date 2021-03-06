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
! ... file vlapec.f
!
!     this file includes documentation and code for
!     subroutine vlapec          i
!
! ... files which must be loaded with vlapec.f
!
!     type_SpherepackAux.f, type_HFFTpack.f, vhaec.f, vhsec.f
!
!
!     subroutine vlapec(nlat, nlon, ityp, nt, vlap, wlap, idvw, jdvw, br, bi, cr, ci, 
!    +mdbc, ndbc, wvhsec, lvhsec, work, lwork, ierror)
!
!
!     subroutine vlapec computes the vector laplacian of the vector field
!     (v, w) in (vlap, wlap) (see the definition of the vector laplacian at
!     the output parameter description of vlap, wlap below).  w and wlap
!     are east longitudinal components of the vectors.  v and vlap are
!     colatitudinal components of the vectors.  br, bi, cr, and ci are the
!     vector harmonic coefficients of (v, w).  these must be precomputed by
!     vhaec and are input parameters to vlapec.  the laplacian components
!     in (vlap, wlap) have the same symmetry or lack of symmetry about the
!     equator as (v, w).  the input parameters ityp, nt, mdbc, nbdc must have
!     the same values used by vhaec to compute br, bi, cr, and ci for (v, w).
!     vlap(i, j) and wlap(i, j) are given on the sphere at the colatitude
!
!            theta(i) = (i-1)*pi/(nlat-1)
!
!     for i=1, ..., nlat and east longitude
!
!            lambda(j) = (j-1)*2*pi/nlon
!
!     for j=1, ..., nlon.
!
!
!     input parameters
!
!     nlat   the number of colatitudes on the full sphere including the
!            poles. for example, nlat = 37 for a five degree grid.
!            nlat determines the grid increment in colatitude as
!            pi/(nlat-1).  if nlat is odd the equator is located at
!            grid point i=(nlat+1)/2. if nlat is even the equator is
!            located half way between points i=nlat/2 and i=nlat/2+1.
!            nlat must be at least 3. note: on the half sphere, the
!            number of grid points in the colatitudinal direction is
!            nlat/2 if nlat is even or (nlat+1)/2 if nlat is odd.
!
!     nlon   the number of distinct longitude points.  nlon determines
!            the grid increment in longitude as 2*pi/nlon. for example
!            nlon = 72 for a five degree grid. nlon must be greater
!            than zero. the axisymmetric case corresponds to nlon=1.
!            the efficiency of the computation is improved when nlon
!            is a product of small prime numbers.
!
!     ityp   this parameter should have the same value input to subroutine
!            vhaec to compute the coefficients br, bi, cr, and ci for the
!            vector field (v, w).  ityp is set as follows:
!
!            = 0  no symmetries exist in (v, w) about the equator. (vlap, wlap)
!                 is computed and stored on the entire sphere in the arrays
!                 vlap(i, j) and wlap(i, j) for i=1, ..., nlat and j=1, ..., nlon.
!
!
!            = 1  no symmetries exist in (v, w) about the equator. (vlap, wlap)
!                 is computed and stored on the entire sphere in the arrays
!                 vlap(i, j) and wlap(i, j) for i=1, ..., nlat and j=1, ..., nlon.
!                 the vorticity of (v, w) is zero so the coefficients cr and
!                 ci are zero and are not used.  the vorticity of (vlap, wlap)
!                 is also zero.
!
!
!            = 2  no symmetries exist in (v, w) about the equator. (vlap, wlap)
!                 is computed and stored on the entire sphere in the arrays
!                 vlap(i, j) and wlap(i, j) for i=1, ..., nlat and j=1, ..., nlon.
!                 the divergence of (v, w) is zero so the coefficients br and
!                 bi are zero and are not used.  the divergence of (vlap, wlap)
!                 is also zero.
!
!            = 3  w is antisymmetric and v is symmetric about the equator.
!                 consequently wlap is antisymmetric and vlap is symmetric.
!                 (vlap, wlap) is computed and stored on the northern
!                 hemisphere only.  if nlat is odd, storage is in the arrays
!                 vlap(i, j), wlap(i, j) for i=1, ..., (nlat+1)/2 and j=1, ..., nlon.
!                 if nlat is even, storage is in the arrays vlap(i, j), 
!                 wlap(i, j) for i=1, ..., nlat/2 and j=1, ..., nlon.
!
!            = 4  w is antisymmetric and v is symmetric about the equator.
!                 consequently wlap is antisymmetric and vlap is symmetric.
!                 (vlap, wlap) is computed and stored on the northern
!                 hemisphere only.  if nlat is odd, storage is in the arrays
!                 vlap(i, j), wlap(i, j) for i=1, ..., (nlat+1)/2 and j=1, ..., nlon.
!                 if nlat is even, storage is in the arrays vlap(i, j), 
!                 wlap(i, j) for i=1, ..., nlat/2 and j=1, ..., nlon.  the
!                 vorticity of (v, w) is zero so the coefficients cr, ci are
!                 zero and are not used. the vorticity of (vlap, wlap) is
!                 also zero.
!
!            = 5  w is antisymmetric and v is symmetric about the equator.
!                 consequently wlap is antisymmetric and vlap is symmetric.
!                 (vlap, wlap) is computed and stored on the northern
!                 hemisphere only.  if nlat is odd, storage is in the arrays
!                 vlap(i, j), wlap(i, j) for i=1, ..., (nlat+1)/2 and j=1, ..., nlon.
!                 if nlat is even, storage is in the arrays vlap(i, j), 
!                 wlap(i, j) for i=1, ..., nlat/2 and j=1, ..., nlon.  the
!                 divergence of (v, w) is zero so the coefficients br, bi
!                 are zero and are not used. the divergence of (vlap, wlap)
!                 is also zero.
!
!
!            = 6  w is symmetric and v is antisymmetric about the equator.
!                 consequently wlap is symmetric and vlap is antisymmetric.
!                 (vlap, wlap) is computed and stored on the northern
!                 hemisphere only.  if nlat is odd, storage is in the arrays
!                 vlap(i, j), wlap(i, j) for i=1, ..., (nlat+1)/2 and j=1, ..., nlon.
!                 if nlat is even, storage is in the arrays vlap(i, j), 
!                 wlap(i, j) for i=1, ..., nlat/2 and j=1, ..., nlon.
!
!            = 7  w is symmetric and v is antisymmetric about the equator.
!                 consequently wlap is symmetric and vlap is antisymmetric.
!                 (vlap, wlap) is computed and stored on the northern
!                 hemisphere only.  if nlat is odd, storage is in the arrays
!                 vlap(i, j), wlap(i, j) for i=1, ..., (nlat+1)/2 and j=1, ..., nlon.
!                 if nlat is even, storage is in the arrays vlap(i, j), 
!                 wlap(i, j) for i=1, ..., nlat/2 and j=1, ..., nlon.  the
!                 vorticity of (v, w) is zero so the coefficients cr, ci are
!                 zero and are not used. the vorticity of (vlap, wlap) is
!                 also zero.
!
!            = 8  w is symmetric and v is antisymmetric about the equator.
!                 consequently wlap is symmetric and vlap is antisymmetric.
!                 (vlap, wlap) is computed and stored on the northern
!                 hemisphere only.  if nlat is odd, storage is in the arrays
!                 vlap(i, j), wlap(i, j) for i=1, ..., (nlat+1)/2 and j=1, ..., nlon.
!                 if nlat is even, storage is in the arrays vlap(i, j), 
!                 wlap(i, j) for i=1, ..., nlat/2 and j=1, ..., nlon.  the
!                 divergence of (v, w) is zero so the coefficients br, bi
!                 are zero and are not used. the divergence of (vlap, wlap)
!                 is also zero.
!
!
!     nt     nt is the number of vector fields (v, w).  some computational
!            efficiency is obtained for multiple fields.  in the program
!            that calls vlapec, the arrays vlap, wlap, br, bi, cr and ci
!            can be three dimensional corresponding to an indexed multiple
!            vector field.  in this case multiple vector synthesis will
!            be performed to compute the vector laplacian for each field.
!            the third index is the synthesis index which assumes the values
!            k=1, ..., nt.  for a single synthesis set nt=1.  the description
!            of the remaining parameters is simplified by assuming that nt=1
!            or that all arrays are two dimensional.
!
!   idvw     the first dimension of the arrays vlap and wlap as it appears
!            in the program that calls vlapec.  if ityp=0, 1, or 2  then idvw
!            must be at least nlat.  if ityp > 2 and nlat is even then idvw
!            must be at least nlat/2. if ityp > 2 and nlat is odd then idvw
!            must be at least (nlat+1)/2.
!
!   jdvw     the second dimension of the arrays vlap and wlap as it appears
!            in the program that calls vlapec. jdvw must be at least nlon.
!
!
!   br, bi    two or three dimensional arrays (see input parameter nt)
!   cr, ci    that contain vector spherical harmonic coefficients
!            of the vector field (v, w) as computed by subroutine vhaec.
!            br, bi, cr and ci must be computed by vhaec prior to calling
!            vlapec.  if ityp=1, 4, or 7 then cr, ci are not used and can
!            be dummy arguments.  if ityp=2, 5, or 8 then br, bi are not
!            used and can be dummy arguments.
!
!    mdbc    the first dimension of the arrays br, bi, cr and ci as it
!            appears in the program that calls vlapec.  mdbc must be
!            at least min(nlat, nlon/2) if nlon is even or at least
!            min(nlat, (nlon+1)/2) if nlon is odd.
!
!    ndbc    the second dimension of the arrays br, bi, cr and ci as it
!            appears in the program that calls vlapec. ndbc must be at
!            least nlat.
!
!    wvhsec  an array which must be initialized by subroutine vhseci.
!            once initialized, wvhsec
!            can be used repeatedly by vlapec as long as nlat and nlon
!            remain unchanged.  wvhsec must not be altered between calls
!            of vlapec.
!
!    lvhsec  the dimension of the array wvhsec as it appears in the
!            program that calls vlapec.  let
!
!               l1 = min(nlat, (nlon+2)/2) if nlon is even or
!               l1 = min(nlat, (nlon+1)/2) if nlon is odd
!
!            and
!
!               l2 = nlat/2        if nlat is even or
!               l2 = (nlat+1)/2    if nlat is odd.
!
!            then lvhsec must be at least
!
!            4*nlat*l2+3*max(l1-2, 0)*(nlat+nlat-l1-1)+nlon+15

!            (see ierror=9 below).
!
!     work   a work array that does not have to be saved.
!
!     lwork  the dimension of the array work as it appears in the
!            program that calls vlapec. define
!
!               l2 = nlat/2                    if nlat is even or
!               l2 = (nlat+1)/2                if nlat is odd
!               l1 = min(nlat, (nlon+2)/2) if nlon is even or
!               l1 = min(nlat, (nlon+1)/2) if nlon is odd
!
!
!            if ityp .le. 2 then
!
!               nlat*(2*nt*nlon+max(6*l2, nlon)) + nlat*(4*nt*l1+1)
!
!            or if ityp .gt. 2 let
!
!               l2*(2*nt*nlon+max(6*nlat, nlon)) + nlat*(4*nt*l1+1)
!
!            will suffice as a minimum length for lwork
!            (see ierror=10 below)
!
!     **************************************************************
!
!     output parameters
!
!
!    vlap,   two or three dimensional arrays (see input parameter nt) that
!    wlap    contain the vector laplacian of the field (v, w).  wlap(i, j) is
!            the east longitude component and vlap(i, j) is the colatitudinal
!            component of the vector laplacian.  the definition of the
!            vector laplacian follows:
!
!            let cost and sint be the cosine and sine at colatitude theta.
!            let d( )/dlambda  and d( )/dtheta be the first order partial
!            derivatives in longitude and colatitude.  let del2 be the scalar
!            laplacian operator
!
!                 del2(s) = [d(sint*d(s)/dtheta)/dtheta +
!                             2            2
!                            d (s)/dlambda /sint]/sint
!
!            then the vector laplacian opeator
!
!                 dvel2(v, w) = (vlap, wlap)
!
!            is defined by
!
!                 vlap = del2(v) - (2*cost*dw/dlambda + v)/sint**2
!
!                 wlap = del2(w) + (2*cost*dv/dlambda - w)/sint**2
!
!  ierror    a parameter which flags errors in input parameters as follows:
!
!            = 0  no errors detected
!
!            = 1  error in the specification of nlat
!
!            = 2  error in the specification of nlon
!
!            = 3  error in the specification of ityp
!
!            = 4  error in the specification of nt
!
!            = 5  error in the specification of idvw
!
!            = 6  error in the specification of jdvw
!
!            = 7  error in the specification of mdbc
!
!            = 8  error in the specification of ndbc
!
!            = 9  error in the specification of lvhsec
!
!            = 10 error in the specification of lwork (lwork < lwkmin)
!
!
! **********************************************************************
!                                                                              
!     end of documentation for vlapec
!
! **********************************************************************
!
module module_vlapec

    use spherepack_precision, only: &
        wp, & ! working precision
        ip ! integer precision

    use module_vhsec, only: &
        vhsec

    ! Explicit typing only
    implicit none

    ! Everything is private unless stated otherwise
    private
    public :: vlapec

contains

    subroutine vlapec(nlat, nlon, ityp, nt, vlap, wlap, idvw, jdvw, br, bi, &
        cr, ci, mdbc, ndbc, wvhsec, lvhsec, work, lwork, ierror)

        real (wp) :: bi
        real (wp) :: br
        real (wp) :: ci
        real (wp) :: cr
        integer (ip) :: ibi
        integer (ip) :: ibr
        integer (ip) :: ici
        integer (ip) :: icr
        integer (ip) :: idvw
        integer (ip) :: idz
        integer (ip) :: ierror
        integer (ip) :: ifn
        integer (ip) :: imid
        integer (ip) :: ityp
        integer (ip) :: iwk
        integer (ip) :: jdvw
        integer (ip) :: l1
        integer (ip) :: l2
        integer (ip) :: liwk
        integer (ip) :: lvhsec
        integer (ip) :: lwkmin
        integer (ip) :: lwmin
        integer (ip) :: lwork
        integer (ip) :: lzimn
        integer (ip) :: mdbc
        integer (ip) :: mmax
        integer (ip) :: mn
        integer (ip) :: ndbc
        integer (ip) :: nlat
        integer (ip) :: nlon
        integer (ip) :: nt
        real (wp) :: typ
        real (wp) :: vlap
        real (wp) :: wlap
        real (wp) :: work
        real (wp) :: wvhsec
        dimension vlap(idvw, jdvw, nt), wlap(idvw, jdvw, nt)
        dimension br(mdbc, ndbc, nt), bi(mdbc, ndbc, nt)
        dimension cr(mdbc, ndbc, nt), ci(mdbc, ndbc, nt)
        dimension wvhsec(lvhsec), work(lwork)
        ierror = 1
        if (nlat < 3) return
        ierror = 2
        if (nlon < 1) return
        ierror = 3
        if (ityp<0 .or. ityp>8) return
        ierror = 4
        if (nt < 0) return
        ierror = 5
        imid = (nlat+1)/2
        if ((ityp<=2 .and. idvw<nlat) .or. &
            (ityp>2 .and. idvw<imid)) return
        ierror = 6
        if (jdvw < nlon) return
        ierror = 7
        mmax = min(nlat, (nlon+1)/2)
        if (mdbc < mmax) return
        ierror = 8
        if (ndbc < nlat) return
        ierror = 9
        idz = (mmax*(nlat+nlat-mmax+1))/2
        lzimn = idz*imid
        !
        !     check saved work space
        !
        l1 = min(nlat, (nlon+1)/2)
        l2 = (nlat+1)/2
        lwmin = 4*nlat*l2+3*max(l1-2, 0)*(nlat+nlat-l1-1)+nlon+15
        if (lvhsec < lwmin) return
        !
        !     verify unsaved work space length
        !
        ierror = 10
        mn = mmax*nlat*nt
        if (ityp<3) then
            !       no symmetry
            if ( typ==0) then
                !       br, bi, cr, ci nonzero
                lwkmin = nlat*(2*nt*nlon+max(6*imid, nlon)+1)+4*mn
            else
                !       br, bi or cr, ci zero
                lwkmin = nlat*(2*nt*nlon+max(6*imid, nlon)+1)+2*mn
            end if
        else
            !     symmetry about equator
            if ( typ==3 .or. ityp==6) then
                !       br, bi, cr, ci nonzero
                lwkmin = imid*(2*nt*nlon+max(6*nlat, nlon))+4*mn+nlat
            else
                !       br, bi or cr, ci zero
                lwkmin = imid*(2*nt*nlon+max(6*nlat, nlon))+2*mn+nlat
            end if
        end if
        if (lwork < lwkmin) return
        ierror = 0
        !
        !     set work space pointers for vector laplacian coefficients
        !
        select case (ityp)
            case (0)
                ibr = 1
                ibi = ibr+mn
                icr = ibi+mn
                ici = icr+mn
            case (3)
                ibr = 1
                ibi = ibr+mn
                icr = ibi+mn
                ici = icr+mn
            case (6)
                ibr = 1
                ibi = ibr+mn
                icr = ibi+mn
                ici = icr+mn
            case (1)
                ibr = 1
                ibi = ibr+mn
                icr = ibi+mn
                ici = icr
            case (4)
                ibr = 1
                ibi = ibr+mn
                icr = ibi+mn
                ici = icr
            case (7)
                ibr = 1
                ibi = ibr+mn
                icr = ibi+mn
                ici = icr
            case default
                ibr = 1
                ibi = 1
                icr = ibi+mn
                ici = icr+mn
        end select
        ifn = ici + mn
        iwk = ifn + nlat
        liwk = lwork-4*mn-nlat
        call vlapec1(nlat, nlon, ityp, nt, vlap, wlap, idvw, jdvw, work(ibr), &
            work(ibi), work(icr), work(ici), mmax, work(ifn), mdbc, ndbc, br, bi, &
            cr, ci, wvhsec, lvhsec, work(iwk), liwk, ierror)


    contains

        subroutine vlapec1(nlat, nlon, ityp, nt, vlap, wlap, idvw, jdvw, brlap, &
            bilap, crlap, cilap, mmax, fnn, mdb, ndb, br, bi, cr, ci, wsave, lwsav, &
            wk, lwk, ierror)

            real (wp) :: bi
            real (wp) :: bilap
            real (wp) :: br
            real (wp) :: brlap
            real (wp) :: ci
            real (wp) :: cilap
            real (wp) :: cr
            real (wp) :: crlap
            real (wp) :: fn
            real (wp) :: fnn
            integer (ip) :: idvw
            integer (ip) :: ierror
            integer (ip) :: ityp
            integer (ip) :: jdvw
            integer (ip) :: k
            integer (ip) :: lwk
            integer (ip) :: lwsav
            integer (ip) :: m
            integer (ip) :: mdb
            integer (ip) :: mmax
            integer (ip) :: n
            integer (ip) :: ndb
            integer (ip) :: nlat
            integer (ip) :: nlon
            integer (ip) :: nt
            real (wp) :: vlap
            real (wp) :: wk
            real (wp) :: wlap
            real (wp) :: wsave
            dimension vlap(idvw, jdvw, nt), wlap(idvw, jdvw, nt)
            dimension fnn(nlat), brlap(mmax, nlat, nt), bilap(mmax, nlat, nt)
            dimension crlap(mmax, nlat, nt), cilap(mmax, nlat, nt)
            dimension br(mdb, ndb, nt), bi(mdb, ndb, nt)
            dimension cr(mdb, ndb, nt), ci(mdb, ndb, nt)
            dimension wsave(lwsav), wk(lwk)
            !
            !     preset coefficient multiplyers
            !
            do n=2, nlat
                fn = real(n - 1)
                fnn(n) = -fn*(fn + 1.0)
            end do
            !
            !     set laplacian coefficients from br, bi, cr, ci
            !
            select case (ityp)
                case (0)
                    !
                    !     all coefficients needed
                    !
                    do k=1, nt
                        do n=1, nlat
                            do m=1, mmax
                                brlap(m, n, k) = 0.0
                                bilap(m, n, k) = 0.0
                                crlap(m, n, k) = 0.0
                                cilap(m, n, k) = 0.0
                            end do
                        end do
                        do n=2, nlat
                            brlap(1, n, k) = fnn(n)*br(1, n, k)
                            bilap(1, n, k) = fnn(n)*bi(1, n, k)
                            crlap(1, n, k) = fnn(n)*cr(1, n, k)
                            cilap(1, n, k) = fnn(n)*ci(1, n, k)
                        end do
                        do m=2, mmax
                            do n=m, nlat
                                brlap(m, n, k) = fnn(n)*br(m, n, k)
                                bilap(m, n, k) = fnn(n)*bi(m, n, k)
                                crlap(m, n, k) = fnn(n)*cr(m, n, k)
                                cilap(m, n, k) = fnn(n)*ci(m, n, k)
                            end do
                        end do
                    end do
                case (3)
                    !
                    !     all coefficients needed
                    !
                    do k=1, nt
                        do n=1, nlat
                            do m=1, mmax
                                brlap(m, n, k) = 0.0
                                bilap(m, n, k) = 0.0
                                crlap(m, n, k) = 0.0
                                cilap(m, n, k) = 0.0
                            end do
                        end do
                        do n=2, nlat
                            brlap(1, n, k) = fnn(n)*br(1, n, k)
                            bilap(1, n, k) = fnn(n)*bi(1, n, k)
                            crlap(1, n, k) = fnn(n)*cr(1, n, k)
                            cilap(1, n, k) = fnn(n)*ci(1, n, k)
                        end do
                        do m=2, mmax
                            do n=m, nlat
                                brlap(m, n, k) = fnn(n)*br(m, n, k)
                                bilap(m, n, k) = fnn(n)*bi(m, n, k)
                                crlap(m, n, k) = fnn(n)*cr(m, n, k)
                                cilap(m, n, k) = fnn(n)*ci(m, n, k)
                            end do
                        end do
                    end do
                case (6)
                    !
                    !     all coefficients needed
                    !
                    do k=1, nt
                        do n=1, nlat
                            do m=1, mmax
                                brlap(m, n, k) = 0.0
                                bilap(m, n, k) = 0.0
                                crlap(m, n, k) = 0.0
                                cilap(m, n, k) = 0.0
                            end do
                        end do
                        do n=2, nlat
                            brlap(1, n, k) = fnn(n)*br(1, n, k)
                            bilap(1, n, k) = fnn(n)*bi(1, n, k)
                            crlap(1, n, k) = fnn(n)*cr(1, n, k)
                            cilap(1, n, k) = fnn(n)*ci(1, n, k)
                        end do
                        do m=2, mmax
                            do n=m, nlat
                                brlap(m, n, k) = fnn(n)*br(m, n, k)
                                bilap(m, n, k) = fnn(n)*bi(m, n, k)
                                crlap(m, n, k) = fnn(n)*cr(m, n, k)
                                cilap(m, n, k) = fnn(n)*ci(m, n, k)
                            end do
                        end do
                    end do
                case (1)
                    !
                    !     vorticity is zero so cr, ci=0 not used
                    !
                    do k=1, nt
                        do n=1, nlat
                            do m=1, mmax
                                brlap(m, n, k) = 0.0
                                bilap(m, n, k) = 0.0
                            end do
                        end do
                        do n=2, nlat
                            brlap(1, n, k) = fnn(n)*br(1, n, k)
                            bilap(1, n, k) = fnn(n)*bi(1, n, k)
                        end do
                        do m=2, mmax
                            do n=m, nlat
                                brlap(m, n, k) = fnn(n)*br(m, n, k)
                                bilap(m, n, k) = fnn(n)*bi(m, n, k)
                            end do
                        end do
                    end do
                case (4)
                    !
                    !     vorticity is zero so cr, ci=0 not used
                    !
                    do k=1, nt
                        do n=1, nlat
                            do m=1, mmax
                                brlap(m, n, k) = 0.0
                                bilap(m, n, k) = 0.0
                            end do
                        end do
                        do n=2, nlat
                            brlap(1, n, k) = fnn(n)*br(1, n, k)
                            bilap(1, n, k) = fnn(n)*bi(1, n, k)
                        end do
                        do m=2, mmax
                            do n=m, nlat
                                brlap(m, n, k) = fnn(n)*br(m, n, k)
                                bilap(m, n, k) = fnn(n)*bi(m, n, k)
                            end do
                        end do
                    end do
                case (7)
                    !
                    !     vorticity is zero so cr, ci=0 not used
                    !
                    do k=1, nt
                        do n=1, nlat
                            do m=1, mmax
                                brlap(m, n, k) = 0.0
                                bilap(m, n, k) = 0.0
                            end do
                        end do
                        do n=2, nlat
                            brlap(1, n, k) = fnn(n)*br(1, n, k)
                            bilap(1, n, k) = fnn(n)*bi(1, n, k)
                        end do
                        do m=2, mmax
                            do n=m, nlat
                                brlap(m, n, k) = fnn(n)*br(m, n, k)
                                bilap(m, n, k) = fnn(n)*bi(m, n, k)
                            end do
                        end do
                    end do
                case default
                    !
                    !     divergence is zero so br, bi=0 not used
                    !
                    do k=1, nt
                        do n=1, nlat
                            do m=1, mmax
                                crlap(m, n, k) = 0.0
                                cilap(m, n, k) = 0.0
                            end do
                        end do
                        do n=2, nlat
                            crlap(1, n, k) = fnn(n)*cr(1, n, k)
                            cilap(1, n, k) = fnn(n)*ci(1, n, k)
                        end do
                        do m=2, mmax
                            do n=m, nlat
                                crlap(m, n, k) = fnn(n)*cr(m, n, k)
                                cilap(m, n, k) = fnn(n)*ci(m, n, k)
                            end do
                        end do
                    end do
            end select
            !
            !     sythesize coefs into vector field (vlap, wlap)
            !
            call vhsec(nlat, nlon, ityp, nt, vlap, wlap, idvw, jdvw, brlap, bilap, &
                crlap, cilap, mmax, nlat, wsave, lwsav, wk, lwk, ierror)

        end subroutine vlapec1

    end subroutine vlapec

end module module_vlapec
