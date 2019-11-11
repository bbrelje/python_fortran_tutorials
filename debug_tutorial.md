# Debugging Fortran extensions within Python using VSCode
The purpose of this tutorial is to demonstrate how to debug the challenging situation of Python native extensions built using Fortran/f2py.

## Prerequisites
- Make sure you are on a Linux system. This is tested on Ubuntu 18.04 with a pretty clean install.
- Make sure you have python and numpy installed (need numpy for f2py)
- Make sure you have gdb (the GNU Debugger) installed
- Make sure you have a recent version of Microsoft Visual Studio Code (I am using v1.38, Aug 2019)
- Note that for this tutorial my Python executible is /usr/bin/python3. I used python3 in place of `python` in all the commands below but you probably don't need to.

## Configure Visual Studio Code
- Enter the Extensions menu (CTRL+SHIFT+X)
- Install "Python" extension (Python code highlighting, linting, and debugger)
- Install "Modern Fortran" extension (Fortran code highlighting)
- Install "Fortran Breakpoint Support" extension
- Select correct Python interpreter in bottom left corner (Blue bar, should have a drop down menu of Python interpreters)
    - I am using the SYSTEM python3 on Ubuntu. Not tested using Anaconda yet

## Build the f2py tutorial extension
- The example Fortran code is taken from [this simple tutorial](https://www.numfys.net/howto/F2PY/)
- I adapted it to mirror the MDOLab build process
- Refer to the `build_process_tutorial.md` file for an explanation of how f2py interacts with this build process.
- Build the f2py extension by:
    - navigate to the root directory
    - run `make clean` 
    - run `make`
    - If successful, you should see "Module primes was successfully imported" near the bottom of the build output
- ***NOTE***: the `config.mk` file in this project is set up with **optimization turned off** (`-O0`) and **debug symbols on** (`-g`).

## Debuger configuration in VSCode
- Please note that the `.vscode/launch.json` file is configured properly to use the Python and gdb debuggers for this tutorial.
- To use this debug setup on other projects, you will need to copy the `launch.json` settings into your source folder.
- Examine the `launch.json` file in the `.vscode` folder
- Under Attach C/C++/Fortran (GDB) ensure that:
    - "program" path matches your chosen Python interpreter executable
    - "miDebuggerPath" matches gdb location on your system (can find out using `which gdb`)

## Debugging Time
- Set a breakpoint anywhere within the subroutine code of `src/modules/logtoint.f95` (e.g. line 16) and also in `src/modules/sieve.f95` (e.g. line 15).
- Open `demo_script.py` in the root directory and set the two breakpoints per the comments. 
    - It is crucial that you set a breakpoint on the first line at least. You need the interpreter to pause so you can attach the gdb debugger to the running process.
    - Set breakpoints by clicking to the left of the line numbers in the text editor. If you don't see them, ensure you have the Fortran Breakpoint extension installed in VScode
- Open the Debug sidebar (CTRL+SHIFT+D)
- There should be a drop down menu labeled "Debug" at the top of the sidebar with a little play button next to it. Select `Python` from that drop down list, ensure the demo_script.py file is open in the main window, and click the triangle play button to start debugging Python
    - You should hit the first breakpoint that the Python debugger should pause. If not, check your Python debugger configuration using the many tutorials out there.
- Now we need to attach the gdb debugger to the running process. In the Debug sidebar, select `Attach C/C++/Fortran...` and click the play button
    - A menu will appear with all the currently running processes on your machine. Type `python` in that window to narrow it down to the running Python processes. Select the one that has a Python executible followed by a long vscode-related file path. That is your debug process.
    - You'll be prompted for a sudo password in the console in order to attach the debugger
- Assuming that worked, you now have both a Python and a Fortran debugger running on the same process. 
- In the top of the main window, you should see player controls for both Debuggers. 
    - Hit play/continue on the Python debugger. 
    - You should immediately hit a Fortran breakpoint in gdb and the Fortran source window should open, highlighting the correct line. 
        - If you didn't you probably forgot to set Fortran breakpoints in the `.f95` files. See first line of this section.
        - Otherwise, maybe the debugger got attached to the wrong Python process.
    - You should see variable values in the Debug sidebar. 
        - If not, or if it says something about "optimized" you probably forgot to turn compiler optimizations off. 
    - Play around with the gdb controls
        - Step through slowly and watch the local variable values change in the debug window
        - Eventually hit continue (you may need to turn off the Fortran breakpoint to move on quickly if the breakpoint is in a loop)
    - You should hit your second breakpoint (in the Python debugger) at the end of the Python file proving you can step out back into Python


### A simpler way to debug (with less power)
Alternatively, you can launch Python in GDB directly without the two step attach process.
However, you will NOT be able to step through Python line by line. 
You will ONLY hit your compiled code breakpoints (in the Fortran/C).

- Set up the Fortran breakpoints as in the first instruction of the previous section.
- Open the `demo_script.py` file in the active text editor window in VSCode
- Open the Debug menu (CTRL+SHIFT+D)
- Select "Launch Python in GDB directly" from the drop down menu at the top (next to the play button)
- Hit the play button
- This will launch Python on top of GDB directly. Since GDB cannot directly interpret Python code, it will basically speed right through until it hits your Fotran breakpoints
- You should hit the breakpoints in `sieve.f95` and `logtoint.f95` and be able to see variable values in the locals window in the debug sidebar

Please let me know if you have suggestions for this tutorial at bbrelje (at) umich.edu. 