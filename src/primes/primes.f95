
module primes
    ! This module is a dumb way to demonstrate multi-layered Fortran modules
    ! with dependencies on other modules in separate files
    ! It's just a thin wrapper around subroutines in the two modules used below
    use log_to_int_module
    use sieve_module
    implicit none
    contains 
    subroutine pysieve(is_prime, n_max)
    ! =====================================================
    ! Uses the sieve of Eratosthenes to compute a logical
    ! array of size n_max, where .true. in element i
    ! indicates that i is a prime.
    ! =====================================================
        integer, intent(in)   :: n_max
        logical, intent(out)  :: is_prime(n_max)
        call sieve(is_prime, n_max)
        return
    end subroutine

    subroutine pylogical_to_integer(prime_numbers, is_prime, num_primes, n)
    ! =====================================================
    ! Translates the logical array from sieve to an array
    ! of size num_primes of prime numbers.
    ! =====================================================
        integer, intent(in)     :: n
        logical, intent(in)     :: is_prime(n)
        integer, intent(in)     :: num_primes
        integer, intent(out)    :: prime_numbers(num_primes)
        call logical_to_integer(prime_numbers, is_prime, num_primes, n)
    end subroutine
end module