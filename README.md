## Pratical code development with Python and C/Fortran

In scientific computing, Python has a deserved reputation for being slow at number crunching. However,  it is extremely useful for scripting and pre/post processing. We can combine the best of both worlds by writing computationally intensive code in Fortran or C, and defining interfaces in Python to access it for input and output. However, this process can be a little exotic, and many usual tools we use for code development break across this "great divide" between native code and Python.

I have developed two tutorials to teach myself how to do this stuff, and to pass along the knowledge to other members of my lab.

The first tutorial explains how f2py can be used to generate interfaces between a Fortran codebase and Python, even inside a complicated build process. 
The `build_process_tutorial.md` file walks you through the workflow we have developed over the years at the University of Michigan [MDOLab](mdolab.engin.umich.edu).
The tutorial is a very simplified example derived from the real-world [ADflow](github.com/mdolab/adflow) CFD flow solver build process.
The build processes are nearly identical.

The second tutorial explains how you can debug mixed Python and Fortran code using Visual Studio Code, the VSCode native Python debugger, and the GNU debugger `gdb`. Find it at `debug_tutorial.md`.