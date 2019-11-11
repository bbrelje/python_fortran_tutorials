# Master makefile. The actual makefile you want is:
# src/build/Makefile

default:
# Check if the config.mk file is in the config dir.
	@if [ ! -f "config/config.mk" ]; then \
	echo "Before compiling, copy an existing config file from the "; \
	echo "config/defaults/ directory to the config/ directory and  "; \
	echo "rename to config.mk. For example:"; \
	echo " ";\
	echo "  cp config/defaults/config.LINUX_GFORTRAN.mk config/config.mk"; \
	echo " ";\
	else make project;\
	fi;

clean:
# Clear out byproducts from the build directory
	rm -fr src/*/*.mod
	rm -fr src/build/*.o
	rm -fr src/build/*.a
	rm -fr src/build/*.so
	rm -fr src/build/*.dep
	rm -fr src/build/*.f90
	rm -fr src/build/*.c
	rm -fr src/f2py/*.autogen
	#rm -fr src/f2py/*.pyf
	rm -fr *~ config.mk;
	rm -fr *~ primes.so


project:
# Actually build the project
	ln -sf config/config.mk config.mk;
	(cd src/build/ && make)

pyf:
# Generate a new pyf signature file
	ln -sf config/config.mk config.mk;
	(cd src/build/ && make pyf)