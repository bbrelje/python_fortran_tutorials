# set a breakpoint on the line below
import primes
# attach gdb to the running process

# set a breakpoint somewhere in primes.f95 to step into the Fortran
sieve_array = primes.primes.pysieve(100)
prime_numbers = primes.primes.pylogical_to_integer(sieve_array, sum(sieve_array))
# set a breakpoint on the line below to prove you can step back out of Fortran
print(prime_numbers)