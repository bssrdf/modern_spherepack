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
! ... file idivec.f
!
!     this file includes documentation and code for
!     subroutine idivec          i
!
! ... files which must be loaded with idivec.f
!
!     type_SpherepackAux.f, type_HFFTpack.f, vhsec.f, shaec.f
!
!
!
!     subroutine idivec(nlat, nlon, isym, nt, v, w, idvw, jdvw, a, b, mdab, ndab, 
!    +                  wvhsec, lvhsec, work, lwork, pertrb, ierror)
!
!     given the scalar spherical harmonic coefficients a and b, precomputed
!     by subroutine shaec for a scalar array dv, subroutine idivec computes
!     an irrotational vector field (v, w) whose divergence is dv - pertrb.
!     w is the east longitude component and v is the colatitudinal component.
!     pertrb is a constant which must be subtracted from dv for (v, w) to
!     exist (see the description of pertrb below).  usually pertrb is zero
!     or small relative to dv.  the vorticity of (v, w), as computed by
!     vortec, is the zero scalar field.  v(i, j) and w(i, j) are the
!     velocity components at colatitude
!
!            theta(i) = (i-1)*pi/(nlat-1)
!
!     and longitude
!
!            lambda(j) = (j-1)*2*pi/nlon.
!
!     the
!
!            divergence[v(i, j), w(i, j)]
!
!          = [d(w(i, j)/dlambda + d(sint*v(i, j))/dtheta]/sint
!
!          = dv(i, j) - pertrb
!
!     and
!
!            vorticity(v(i, j), w(i, j))
!
!         =  [dv/dlambda - d(sint*w)/dtheta]/sint
!
!         =  0.0
!
!     where sint = sin(theta(i)).  required associated legendre polynomials
!     are recomputed rather than stored as they are in subroutine idives.
!
!     input parameters
!
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
!     nlon   the number of distinct londitude points.  nlon determines
!            the grid increment in longitude as 2*pi/nlon. for example
!            nlon = 72 for a five degree grid. nlon must be greater than
!            3.  the efficiency of the computation is improved when nlon
!            is a product of small prime numbers.
!
!
!     isym   this has the same value as the isym that was input to
!            subroutine shaec to compute the arrays a and b from the
!            scalar field dv.  isym determines whether (v, w) are
!            computed on the full or half sphere as follows:
!
!      = 0
!
!           dv is not symmetric about the equator. in this case
!           the vector field (v, w) is computed on the entire sphere.
!           i.e., in the arrays  v(i, j), w(i, j) for i=1, ..., nlat and
!           j=1, ..., nlon.
!
!      = 1
!
!           dv is antisymmetric about the equator. in this case w is
!           antisymmetric and v is symmetric about the equator. w
!           and v are computed on the northern hemisphere only.  i.e., 
!           if nlat is odd they are computed for i=1, ..., (nlat+1)/2
!           and j=1, ..., nlon.  if nlat is even they are computed for
!           i=1, ..., nlat/2 and j=1, ..., nlon.
!
!      = 2
!
!           dv is symmetric about the equator. in this case w is
!           symmetric and v is antisymmetric about the equator. w
!           and v are computed on the northern hemisphere only.  i.e., 
!           if nlat is odd they are computed for i=1, ..., (nlat+1)/2
!           and j=1, ..., nlon.  if nlat is even they are computed for
!           i=1, ..., nlat/2 and j=1, ..., nlon.
!
!
!     nt     nt is the number of divergence and vector fields.  some
!            computational efficiency is obtained for multiple fields.
!            the arrays a, b, v, and w can be three dimensional and pertrb
!            can be one dimensional corresponding to an indexed multiple
!            array dv.  in this case, multiple vector synthesis will be
!            performed to compute each vector field.  the third index for
!            a, b, v, w and first for pertrb is the synthesis index which
!            assumes the values k = 1, ..., nt.  for a single synthesis set
!            nt = 1.  the description of the remaining parameters is
!            simplified by assuming that nt=1 or that a, b, v, w are two
!            dimensional and pertrb is a constant.
!
!     idvw   the first dimension of the arrays v, w as it appears in
!            the program that calls idivec. if isym = 0 then idvw
!            must be at least nlat.  if isym = 1 or 2 and nlat is
!            even then idvw must be at least nlat/2. if isym = 1 or 2
!            and nlat is odd then idvw must be at least (nlat+1)/2.
!
!     jdvw   the second dimension of the arrays v, w as it appears in
!            the program that calls idivec. jdvw must be at least nlon.
!
!     a, b    two or three dimensional arrays (see input parameter nt)
!            that contain scalar spherical harmonic coefficients
!            of the divergence array dv as computed by subroutine shaec.
!     ***    a, b must be computed by shaec prior to calling idivec.
!
!     mdab   the first dimension of the arrays a and b as it appears in
!            the program that calls idivec (and shaec). mdab must be at
!            least min(nlat, (nlon+2)/2) if nlon is even or at least
!            min(nlat, (nlon+1)/2) if nlon is odd.
!
!     ndab   the second dimension of the arrays a and b as it appears in
!            the program that calls idivec (and shaec). ndab must be at
!            least nlat.
!
!
!  wvhsec    an array which must be initialized by subroutine vhseci.
!            once initialized, 
!            wvhsec can be used repeatedly by idivec as long as nlon
!            and nlat remain unchanged.  wvhsec must not be altered
!            between calls of idivec.
!
!
!  lvhsec    the dimension of the array wvhsec as it appears in the
!            program that calls idivec. define
!
!               l1 = min(nlat, nlon/2) if nlon is even or
!               l1 = min(nlat, (nlon+1)/2) if nlon is odd
!
!            and
!
!               l2 = nlat/2        if nlat is even or
!               l2 = (nlat+1)/2    if nlat is odd
!
!            then lvhsec must be at least
!
!            4*nlat*l2+3*max(l1-2, 0)*(nlat+nlat-l1-1)+nlon+15
!
!
!     work   a work array that does not have to be saved.
!
!     lwork  the dimension of the array work as it appears in the
!            program that calls idivec. define
!
!               l1 = min(nlat, nlon/2) if nlon is even or
!               l1 = min(nlat, (nlon+1)/2) if nlon is odd
!
!            and
!
!               l2 = nlat/2                  if nlat is even or
!               l2 = (nlat+1)/2              if nlat is odd
!
!            if isym = 0 then lwork must be at least
!
!               nlat*(2*nt*nlon+max(6*l2, nlon) + 2*nt*l1 + 1)
!
!            if isym = 1 or 2 then lwork must be at least
!
!               l2*(2*nt*nlon+max(6*nlat, nlon)) + nlat*(2*l1*nt+1)
!
!     **************************************************************
!
!     output parameters
!
!
!     v, w   two or three dimensional arrays (see input parameter nt) that
!           contain an irrotational vector field whose divergence is
!           dv-pertrb at the colatitude point theta(i)=(i-1)*pi/(nlat-1)
!           and longitude point lambda(j)=(j-1)*2*pi/nlon.  w is the east
!           longitude component and v is the colatitudinal component.  the
!           indices for w and v are defined at the input parameter isym.
!           the curl or vorticity of (v, w) is the zero vector field.  note
!           that any nonzero vector field on the sphere will be multiple
!           valued at the poles [reference swarztrauber].
!
!   pertrb  a nt dimensional array (see input parameter nt and assume nt=1
!           for the description that follows).  dv - pertrb is a scalar
!           field which can be the divergence of a vector field (v, w).
!           pertrb is related to the scalar harmonic coefficients a, b
!           of dv (computed by shaec) by the formula
!
!                pertrb = a(1, 1)/(2.*sqrt(2.))
!
!
!
!           the unperturbed scalar field dv can be the divergence of a
!           vector field only if a(1, 1) is zero.  if a(1, 1) is nonzero
!           (flagged by pertrb nonzero) then subtracting pertrb from
!           dv yields a scalar field for which a(1, 1) is zero.
!
!    ierror = 0  no errors
!           = 1  error in the specification of nlat
!           = 2  error in the specification of nlon
!           = 3  error in the specification of isym
!           = 4  error in the specification of nt
!           = 5  error in the specification of idvw
!           = 6  error in the specification of jdvw
!           = 7  error in the specification of mdab
!           = 8  error in the specification of ndab
!           = 9  error in the specification of lvhsec
!           = 10 error in the specification of lwork
! **********************************************************************
!                                                                              
!
module module_idivec

    use spherepack_precision, only: &
        wp, & ! working precision
        ip ! integer precision

    use module_vhsec, only: &
        vhsec

    ! Explicit typing only
    implicit none

    ! Everything is private unless stated otherwise
    private
    public :: idivec

contains

    subroutine idivec(nlat, nlon, isym, nt, v, w, idvw, jdvw, a, b, mdab, ndab, &
        wvhsec, lvhsec, work, lwork, pertrb, ierror)

        real (wp) :: a
        real (wp) :: b
        integer (ip) :: ibi
        integer (ip) :: ibr
        integer (ip) :: idvw
        integer (ip) :: idz
        integer (ip) :: ierror
        integer (ip) :: imid
        integer (ip) :: is
        integer (ip) :: isym
        integer (ip) :: iwk
        integer (ip) :: jdvw
        integer (ip) :: l1
        integer (ip) :: l2
        integer (ip) :: liwk
        integer (ip) :: lvhsec
        integer (ip) :: lwmin
        integer (ip) :: lwork
        integer (ip) :: lzimn
        integer (ip) :: mdab
        integer (ip) :: mmax
        integer (ip) :: ndab
        integer (ip) :: nlat
        integer (ip) :: nlon
        integer (ip) :: nt
        real (wp) :: pertrb
        real (wp) :: v
        real (wp) :: w
        real (wp) :: work
        real (wp) :: wvhsec
        dimension v(idvw, jdvw, nt), w(idvw, jdvw, nt), pertrb(nt)
        dimension a(mdab, ndab, nt), b(mdab, ndab, nt)
        dimension wvhsec(lvhsec), work(lwork)
        !
        !     check input parameters
        !
        ierror = 1
        if (nlat < 3) return
        ierror = 2
        if (nlon < 4) return
        ierror = 3
        if (isym < 0 .or. isym > 2) return
        ierror = 4
        if (nt < 0) return
        ierror = 5
        imid = (nlat+1)/2
        if ((isym == 0 .and. idvw<nlat) .or. &
            (isym /= 0 .and. idvw<imid)) return
        ierror = 6
        if (jdvw < nlon) return
        ierror = 7
        mmax = min(nlat, (nlon+1)/2)
        if (mdab < min(nlat, (nlon+2)/2)) return
        ierror = 8
        if (ndab < nlat) return
        ierror = 9
        idz = (mmax*(nlat+nlat-mmax+1))/2
        lzimn = idz*imid
        l1 = min(nlat, (nlon+1)/2)
        l2 = (nlat+1)/2
        lwmin=4*nlat*l2+3*max(l1-2, 0)*(nlat+nlat-l1-1)+nlon+15
        if (lvhsec < lwmin) return

        ierror = 10
        !
        !     verify unsaved work space length
        !
        associate( mn => mmax*nlat*nt )

            associate( &
                non_zero_case => nlat*(2*nt*nlon+max(6*imid, nlon))+2*mn+nlat, &
                zero_case => imid*(2*nt*nlon+max(6*nlat, nlon))+2*mn+nlat &
                )
                if (isym /= 0 .and. lwork < non_zero_case ) then
                    return
                end if

                if (isym == 0 .and. lwork < zero_case ) then
                    return
                end if
            end associate

            ierror = 0
            !
            !     set work space pointers
            !
            ibr = 1
            ibi = ibr + mn
            is = ibi + mn
            iwk = is + nlat
            liwk = lwork-2*mn-nlat

            call idvec1(nlat, nlon, isym, nt, v, w, idvw, jdvw, work(ibr), work(ibi), &
                mmax, work(is), mdab, ndab, a, b, wvhsec, lvhsec, work(iwk), &
                liwk, pertrb, ierror)

        end associate


    contains

        subroutine idvec1(nlat, nlon, isym, nt, v, w, idvw, jdvw, br, bi, mmax, &
            sqnn, mdab, ndab, a, b, wvhsec, lvhsec, wk, lwk, pertrb, ierror)

            real (wp) :: a
            real (wp) :: b
            real (wp) :: bi
            real (wp) :: br
            real (wp) :: ci(mmax, nlat, nt)
            real (wp) :: cr(mmax, nlat, nt)
            real (wp) :: fn
            integer (ip) :: idvw
            integer (ip) :: ierror
            integer (ip) :: isym
            integer (ip) :: ityp
            integer (ip) :: jdvw
            integer (ip) :: k
            integer (ip) :: lvhsec
            integer (ip) :: lwk
            integer (ip) :: m
            integer (ip) :: mdab
            integer (ip) :: mmax
            integer (ip) :: n
            integer (ip) :: ndab
            integer (ip) :: nlat
            integer (ip) :: nlon
            integer (ip) :: nt
            real (wp) :: pertrb
            real (wp) :: sqnn
            real (wp) :: v
            real (wp) :: w
            real (wp) :: wk
            real (wp) :: wvhsec
            dimension v(idvw, jdvw, nt), w(idvw, jdvw, nt), pertrb(nt)
            dimension br(mmax, nlat, nt), bi(mmax, nlat, nt), sqnn(nlat)
            dimension a(mdab, ndab, nt), b(mdab, ndab, nt)
            dimension wvhsec(lvhsec), wk(lwk)
            !     preset coefficient multiplyers in vector
            !
            do n=2, nlat
                fn = real(n - 1, kind=wp)
                sqnn(n) = sqrt(fn * (fn + 1.0_wp))
            end do
            !
            !     compute multiple vector fields coefficients
            !
            do k=1, nt
                !
                !     set divergence field perturbation adjustment
                !
                pertrb(k) = a(1, 1, k)/(2.*sqrt(2.))
                !
                !     preset br, bi to 0.0
                !
                do n=1, nlat
                    do m=1, mmax
                        br(m, n, k) = 0.0_wp
                        bi(m, n, k) = 0.0_wp
                    end do
                end do
                !
                !     compute m=0 coefficients
                !
                do n=2, nlat
                    br(1, n, k) = -a(1, n, k)/sqnn(n)
                    bi(1, n, k) = -b(1, n, k)/sqnn(n)
                end do
                !
                !     compute m>0 coefficients
                !
                do m=2, mmax
                    do n=m, nlat
                        br(m, n, k) = -a(m, n, k)/sqnn(n)
                        bi(m, n, k) = -b(m, n, k)/sqnn(n)
                    end do
                end do
            end do
            !
            !     set ityp for vector synthesis with curl=0
            !
            select case (isym)
                case (0)
                    ityp = 1
                case (1)
                    ityp = 4
                case (2)
                    ityp = 7
            end select
            !
            !     vector sythesize br, bi into irrotational (v, w)
            !
            call vhsec(nlat, nlon, ityp, nt, v, w, idvw, jdvw, br, bi, cr, ci, &
                mmax, nlat, wvhsec, lvhsec, wk, lwk, ierror)

        end subroutine idvec1

    end subroutine idivec

end module module_idivec
