module sieve_module
    implicit none
    contains 
    subroutine sieve(is_prime, n_max)
    ! =====================================================
    ! Uses the sieve of Eratosthenes to compute a logical
    ! array of size n_max, where .true. in element i
    ! indicates that i is a prime.
    ! =====================================================
        integer, intent(in)   :: n_max
        logical, intent(out)  :: is_prime(n_max)
        integer :: i
        is_prime = .true.
        is_prime(1) = .false.
        do i = 2, int(sqrt(real(n_max)))
            if (is_prime (i)) is_prime (i * i : n_max : i) = .false.
        end do
        return
    end subroutine
end module sieve_module