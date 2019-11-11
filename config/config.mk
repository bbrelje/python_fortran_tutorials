# ----------------------------------------------------------------------
# Config file for Gfortran
# ----------------------------------------------------------------------

# ------- Define a possible parallel make (use PMAKE = make otherwise)--
PMAKE = make -j 4

# ------- Define the MPI Compilers--------------------------------------
FF90 = gfortran # or ifort
CC   = gcc # or icc

# ------- Define Precision Flags ---------------------------------------
# Options for Integer precision flags: -DUSE_LONG_INT
# Options for Real precision flags: -DUSE_SINGLE_PRECISION, -DUSE_QUADRUPLE_PRECISION
# Default (nothing specified) is 4 byte integers and 8 byte reals

FF90_INTEGER_PRECISION_FLAG =
FF90_REAL_PRECISION_FLAG    =
CC_INTEGER_PRECISION_FLAG   =
CC_REAL_PRECISION_FLAG      =

# ------- Define Compiler Flags ----------------------------------------
FF90_FLAGS = -fPIC -g  -O0 # Change these flags for Intel
C_FLAGS   = -fPIC -g  -O0 # Change these flags for Intel

# ------- Define Archiver  and Flags -----------------------------------
AR       = ar
AR_FLAGS = -rvs

# ------- Define Linker Flags ------------------------------------------
LINKER       = $(FF90)
LINKER_FLAGS =

# Combine flags from above -- don't modify here
FF90_PRECISION_FLAGS = $(FF90_INTEGER_PRECISION_FLAG)$(FF90_REAL_PRECISION_FLAG)
CC_PRECISION_FLAGS   = $(CC_INTEGER_PRECISION_FLAG) $(CC_REAL_PRECISION_FLAG)

# Define potentially different python, python-config and f2py executables:
PYTHON = python3
#PYTHON = python
PYTHON-CONFIG = python3-config
#PYTHON-CONFIG = python-config
F2PY = python3 -m numpy.f2py 
#F2PY = python -m numpy.f2py