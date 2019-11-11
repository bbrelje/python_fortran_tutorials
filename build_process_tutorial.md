# Building Python native extensions with f2py
### Author: Ben Brelje, University of Michigan MDOLab

In scientific computing, we find ourselves writing high-performance native Fortran and C code, but wish to make our work accessible to an audience which is converging on Python as the scripting language of choice. Unfortunately, wrapping Fortran and C in Python can be a pretty complicated task. However, the f2py tool makes this somewhat easier.

The purpose of this tutorial is to show how to wrap a simple Fortran library as a Python native extension. This workflow is very similar to the process we use at the Univ. of Michigan MDOLab to build complex software (such as the ADflow adjoint CFD solver). In fact, most of the build files in this demonstration are copied line-for-line from ADflow and the folder structure exactly mirrors it.  

## Prerequisites
- A Linux system. This is tested on Ubuntu 18.04 with a pretty clean install.
- Working Fortran and C compilers (I am using gfortran 7 and gcc 7).
- Python and numpy installed (you need numpy for f2py - I'm using numpy v 1.17).
    - For this tutorial my Python executible is /usr/bin/python3, or just `python3` for short. 
    - You will likely need to customize the config.mk file for your particular Python configuration.
- Basic knowledge of Fortran 90 (or 2003 or 2008).
    - Including how to compile and link multiple source files into a shared library
- Basic knowledge of the GNU `make` utility.

## A brief introduction to f2py
Python is an interpreted language, but the most common implementation of the interpreter is written natively in C. Therefore, Python has the ability to import objects, functions, data, etc. from other C libraries as native Python objects. The advantage of doing this is increased speed compared to writing pure Python, and the advantage is particularly apparent for scientific computing.

### The Python C API is a pain
There is a [C API](https://docs.python.org/3.7/c-api/index.html) for creating native Python objects from C code. However, it is very labor intensive to write wrappers using the native API from scratch, and it is very easy for the wrapper to get out of sync with the rest of your codebase. Furthermore, if your source code is in Fortran, you have to worry about all the C/Fortran interoperability issues at the same time. Finally, the NumPy Python array data types are powerful but can be difficult to deal with directly in the C API.

### f2py makes it less of a pain
The Fortran to Python interface generator known as f2py ([website](https://docs.scipy.org/doc/numpy/f2py/)) is an open-source project associated with the NumPy project and is designed to make it much simpler to integrate high-performance compiled code into Python.

f2py is basically a command line utility. You will obtain a copy automatically when you install NumPy (`pip install numpy`). It should automatically be added to the path and be usable from the shell (`f2py <your command>`), or it can be accessed as a Python module as well (`python -m numpy.f2py <your command>`). I find the second method reduces the chance of human error since it ensures that your f2py matches your active Python installation.

### f2py usage
f2py can basically be used in three ways. Two of these modes are illustrated in this [fantastic tutorial](https://www.numfys.net/howto/F2PY/) and the third one is more advanced (we illustrate it in this tutorial). Formal documentation can be accessed at the [SciPy doc site](https://docs.scipy.org/doc/numpy/f2py/usage.html#command-f2py).

#### Auto-build from source (easy way)
First, `f2py -c <your fortran source>.f90` can automagically compile and link a native Python shared object library (a .so file accessed with an `import xxxx` Python statement). The tutorial calls this the "simple way". It is probably useful for initial experimentation but complicated software may need more granular control of the compile and link processes.

#### Generate signature file then auto-build (moderately easy way)
Second, `f2py <your fortran sources>.f90 -m <mymodulename> -h <mymodulename>.pyf` scans Fortran source files and generates something called a *signature file* (with a .pyf extension). Signature files are a formal, structured statement of the inputs, outputs, and namespace that your Python native module will have access to. 

 `f2py ... -h ...` generates a very comprehensive signature which will probably contain more subroutines and variables than your Python wrap will need - you can remove these manually from the .pyf file. Then, build using something like `f2py -c <mymodulename>.pyf <your fortran sources>.f90` as illustrated in [the tutorial](https://www.numfys.net/howto/F2PY). This is only marginally harder than Option 1 and gives you more control over the contents of the Python module.

#### Generate C API wrapper for manual build (hard way)
Finally, invoking `f2py <mymodule>.pyf` without a `-h` or `-c` flag generates special C and Fortran source files containing the actual Python C API wrapper code. The C wrapper output will be named `<modulename>module.c` and you may also end up with a `<modulename>-f2pywrappers2.f90` file. These rarely, if ever, be manually edited. These should be compiled using your C and Fortran compiler, then linked together into a `<modulename>.so` file. 
- Note: Compiling and linking manually always requires compiling and linking the `.../numpy/f2py/src/fortranobject.c` in as well (this is not well-documented).

Experiment with f2py using [this tutorial](https://www.numfys.net/howto/F2PY) before you proceed onward.



## Organizing the code
For a project with mixed Fortran, C, and Python code, the build process is bound to be complicated. You can minimize the pain by organizing your code in a logical way. At the MDOLab, we have settled on a folder layout which has become standard across all of our projects with native extensions.

### The src folder
The bulk of our Fortran (and, if applicable, C) code lives in subfolders of the `./src` folder. We tend to place logically related functionality in the same subfolder (for example, `./src/solvers/solvercode.f90`).

We have a `./src/f2py` folder dedicated to the Fortran wrapping process. The .pyf signature file for the project is located here, along with any utilities related to post-processing the signature file (more on this later). Any modules, subroutines, or data included in the .pyf signature will be acessible from Python (it is usually a small subset of all the subroutines in the modules).

We also have a `./src/build` subfolder which contains:
    1) GNU make files defining the build process in a reasonably universal way (under version control)
    2) Temporary build files (.o, .mod, .a, .so, and others) which are generated during the build process and are **not** under version control).

### The config folder
Users often need to specify parameters used during the build process. 
For example, a user may prefer to use Intel compilers instead of GNU, or they may wish to pass specific compiler preprocessor macros in as `-D` flags.
We do this by defining a `config.mk` file. 
All that happens in this file is that various environment variables are set to user-defined values. 

We supply pre-configured files in the `config/defaults` subfolder with labels for particular architectures (such as LINUX) and compilers (such as GFORTRAN), since the compiler flags will vary from Intel to GNU to PGI. 

The user copies their file of choice from the `config/defaults` subfolder to `config/config.mk` where it gets picked up by the build process.

### The root folder
The root folder contains a crucial file: the `Makefile`. 
The GNU make utility reads this file which defines the entire build (and in some cases, test) process.
The user invokes it by entering the root folder and supplying `make` at the command line. 
`make clean` is configured to wipe out temporary build files in the `src/build` folder.
I have this project configured to only generate a .pyf signature file when `make pyf` is invoked - this is uncommon in other projects.

I will explain more about the build process in the next section.

## The build process
The general trajectory of the build process is:
- Generate custom Python C API wrapper files using f2py (`<modulename>module.c` and `<modulename>-f2pywrappers2.f90` files)
- *Compile* all Fortran/C extension source files (`.F90`, `.F95`, `.c`) into binaries (`.o` files)
- *Combine* the user-defined binaries (`.o`) into a static archive (`.a` file)
- *Link* the user-defined binaries in with the compiled Python C API wrapper to produce a shared libary (`.so` file) that can be imported by Python 
- Verify that the `.so` file can be imported into Python (successful build)

Here is a verbal description of how the process happens. There are of course many more details which you can find in the scripts themselves.

1) User begins with the termal in the root folder of the checked-out repository. User invokes `make` which runs the GNU make utility, using the `Makefile` in the root directory. 
    - If no other argument follows `make`, the "default" target checks to see whether `./config/config.mk` exists. If it does, it copies it into the root directory.
    - `config.mk` in the root directory is a "magic" file to the GNU `make` utility. The environment variables set in `config.mk` are available to the downstream build process and include things like compiler settings that are specific to the user's situation.
2) The `make` default target calls the `make project` target, which sets the environment variables in `config.mk` and navigates to `src/build` where it runs `make` again. This time, the `make` utility follows the script in `src/build/Makefile` which is where the heart of the build process is defined.

3) The `src/build/Makefile` begins with more environment variable setting. 
- Many environment variables were previously set in `config.mk`
- PROJECT_NAME defines what the name of the Python module will be (in this case, since the sample code has to do with finding prime numbers, `PROJECT_NAME = primes`)
- Several other files in `src/build` are "included" in the `Makefile`
    - `fileList` contains an exhaustive list of Fortran and C source files that need to be compiled
    - `directoryList` contains an exhaustive list of the folders where the files in fileList can be found (relative to `src`)
    - `rules` defines the compiler commands that should be used to compile various types of source files (e.g., rules are different for f77 vs f90 files)
- OFILES is a complete list of what the compiled binary files will be (every Fortran and C file with a `.o` extension)

4) By default, `make` enters at the "default" build target, which immediately redirects to `all`. 
- `all`, in turn, runs a parallel make of the `python` target
- `python` target depends on `lib` target
- `lib` target depends on `sources` target
- `sources` target depends on `DEP_FILE` target
Therefore, the "first" thing that happens in the chain is creating the dependencies file.

5) The dependencies file defines which Fortran sources need to be compiled before which other files. 
This can be caused by a chain of Fortran files `use module` statements - the first one in the chain needs to be compiled first.
The Makefile invokes `src/build/fort_depend.py` which is an MDOLab-developed utility to scan the Fortran sources and generate a `.dep` file.
The `.dep` file is then included in the `Makefile` to tell the utility how to order its compile sequence.

6) Once the `.dep` file is created, the `sources` target compiles all the Fortran and C source files. 
The `Makefile` syntax is confusing to the uninitiated, but the commands for how this is accomplished are defined in the `src/build/rules` file.
The sources are compiled in the order defined in the `.dep` file.

7) The `lib` target combines all the compiled `.o` files into a `.a` static archive file.

8) The `python` target also depends on the f2py .pyf file. If `src/f2py/<modulename>.pyf` doesn't exist, the `pyf` target will generate it automatically.

9) Finally, the `python` target can be run. The output of this phase is the completed `.so` shared object library and a verification test.
- First, the `make` utility needs to get `-I` and `-L` flags for various Python and NumPy headers and libraries, which it does automatically using the `python-config` utility.
- We also need a source file from the `f2py` source directory, which lives on the Pythonpath at an unknown location. We find it using the `src/f2py/get_f2py.py` file which is homegrown.
- Next, we preprocess the f2py pyf file which defines the Fortran/Python interface.
    - No upper case characters are allowed, so we verify none are present using the `checkPyfForUpperCase.py` file
    - Sometimes, our lab builds versions of codes with complex numbers enabled. We handle this using the `pyf_preprocessor.py` file but normally this should not change your `.pyf` much. It produces a `.pyf.autogen` file.
- After this, we *finally* run f2py to generate the actual Python/Fortran interface source files. This produces two files: a C file (`<modulename>module.c`) as well as a Fortran file. 
    - We need to compile both of these, as well as the `fortranobject.c` file included in f2py, to binary `.o` files.
- At the very end, we link everything together into a `.so` file which is what Python reads and uses to access your code
- We also run a small test (`src/build/importTest.py`) to verify that the `.so` object we just created can be imported into Python. 
    - Usually, if it can't, there's some issue with not finding the correct shared libraries, or potentialy some kind of mismatch between the Python version, f2py, and the numpy/python shared library headers.

## This tutorial
I adapted [this excellent, simple tutorial](https://www.numfys.net/howto/F2PY) into the MDOLab folder structure in order to illustrate the build trajectory and directly demonstrate advanced f2py usage in a custom build process.
I split out the two subroutines into separate module files (located at `src/modules/*.f95`).
I then created a top-level module which `use`s the sub-modules (located at `src/primes/primes.f95`).
The only reason I did this was to create a non-trivial dependency for the compile process (visible in the `.dep` file).

I also edited the automatic `src/f2py/primes.pyf` f2py signature file slightly.
You can do a text diff between that file and `primes.pyf.raw` which is the raw output from the f2py signature generation utility.
I removed Python access to the submodule subroutines, since they are already accessivle through `primes.f95`. 

### Running the tutorial
1) Navigate to the root directory (same folder as this .md file)
2) Verify that `config/config.mk` matches your system (in particular, pay attention to the python and python-config settings)
2) Run `make clean` at the command line
3) Run `make` 
    - The output should say "Module primes was successfully imported" near the bottom
4) Run `python<3> demo_script.py` which should print a list of prime numbers to the console
5) Ta da!


Please let me know if you have suggestions for this tutorial at bbrelje (at) umich.edu. 