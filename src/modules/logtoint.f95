
module log_to_int_module
    implicit none
    contains 
    subroutine logical_to_integer(prime_numbers, is_prime, num_primes, n)
        ! =====================================================
        ! Translates the logical array from sieve to an array
        ! of size num_primes of prime numbers.
        ! =====================================================
            integer                 :: i, j=0
            integer, intent(in)     :: n
            logical, intent(in)     :: is_prime(n)
            integer, intent(in)     :: num_primes
            integer, intent(out)    :: prime_numbers(num_primes)
            do i = 1, size(is_prime)
                if (is_prime(i)) then
                    j = j + 1
                    prime_numbers(j) = i
                end if
            end do
            return
        end subroutine
end module log_to_int_module
