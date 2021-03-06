module spherepack_precision

    use, intrinsic :: iso_fortran_env, only: &
        INT32

    ! Explicit typing only
    implicit none

    ! Everything is private unless stated otherwise
    private
    public :: wp, ip
    public :: PI, TWO_PI
    public :: pimach

    !-----------------------------------------------
    ! Dictionary: precision constants
    !-----------------------------------------------
    integer,   parameter :: ip = INT32
    integer,   parameter :: sp = selected_real_kind(p=6, r=37)
    integer,   parameter :: dp = selected_real_kind(p=15, r=307)
    integer,   parameter :: qp = selected_real_kind(p=33, r=4931)
    integer,   parameter :: wp = dp
    real (wp), parameter :: PI = acos(-1.0_wp)
    real (wp), parameter :: TWO_PI = 2.0_wp * PI
    !-----------------------------------------------


contains


    pure function pimach(dum) result (return_value)
        !-----------------------------------------------
        ! Dummy arguments
        !-----------------------------------------------
        real (wp), optional, intent (in) :: dum
        real (wp)                        :: return_value
        !-----------------------------------------------

        !return_value = 3.141592653589793238462643383279502884197169399375105820974_wp
        return_value = acos(-1.0_wp)

    end function pimach



end module spherepack_precision
