# Compiling ADCIRC with NetCDF

Compiling ADCIRC with support for NetCDF output on takanami is a fairly involved process that can often end up taking you down the dependency and compatibility rabbit-hole. This guide will take you through the whole process that I used to successfully build ADCIRC and all of the necessary supporting libraries.

Note that I have only attempted this process on takanami, but will be testing on taifu as soon as necessary.

* [Compilers](#compilers) - Building of the PGI compilers required for ADCIRC
* [Dependencies](#dependencies) - Building of the various dependencies required for NetCDF support in ADCIRC
* [ADCIRC](#adcirc) - Building of ADCIRC with NetCDF support

## Compilers

The very first step in getting ADCIRC build with NetCDF is ensuring that you are able to access the appropriate compilers. Everything we're about to build must be compiled using the same set of compilers, otherwise you'll run into errors. On takanami, we use the PGI compilers. Unfortunately, the version that is installed globally for us to use is outdated and has a [bug](http://www.pgroup.com/userforum/viewtopic.php?t=3278&start=0&postdays=0&postorder=asc&highlight=&sid=ddadfd9e77e22b689480864e1987ca84) that prevents us from compiling one of the dependencies. This leaves us with two options, aside from buying a new professional license and having ITECS update everything. Either build the PGI Community Edition in your own directory space, add the one that I built to your path. The second option I haven't tested out, and I predict there will be permissions issues the first time we test it. Because the second option is actually the last step of the first option, we'll go through building PGI first. If you aren't building, just skip to that section.

### Build the PGI Community Edition

1. Download the [PGI Community Edition](http://www.pgroup.com/products/community.htm) for Linux x86-64 to a directory in your file space on takanami. For the sake of this example, we'll use ```/home/atdyer/pgi/```

2. Navigate to the directory and unzip the file using:
```bash
cd /home/atdyer/pgi/
tar -xzv pgilinux-XXXX-x86_64.tar.gz
```

3. Create a directory in which to place the built PGI compilers. For this example we'll create a directory called ```build```
```bash
mkdir build
```

4. Run the install script
```bash
./install
```

5. Follow the prompts from the install script.
    * Choose Single system install
    * When prompted for an installation directory, use the build directory you just created: ```/home/atdyer/pgi/build/```
    * Use the spacebar to scroll down through all the agreement documents, and accept all of them
    * When asked to update/create links in the 2017 directory, say no
    * When asked if you want to install Open MPI on your system, say yes
    * When asked if you want to enable NVIDIA GPU support, say no
    * When asked if you want to configure a license key, say no
    * When asked if you want files to be read only, say no
    
### Add PGI to your path

Now that the PGI compilers have been built, we need to add the directories in which they reside to the system path. This allows the system to find all of the necessary executables and libraries when you attempt to run the compilers.

On takanami, you'll need to edit your ```.bashrc``` file to include these directories. However, ITECS has it set up so that you have a personalized ```.bashrc``` file called ```.mybashrc``` that you should use instead, as it will persist if changes are ever made to the system.

So, in a text editor open the ```~/.mybashrc``` file and add the following lines to the end (substituting out the ```/home/atdyer/pgi/build/``` portion if you built in a different directory):

```bash
export LD_LIBRARY_PATH=/home/atdyer/pgi/build/linux86-64/17.4/lib:/home/atdyer/pgi/build/linux86-64/2017/mpi/openmpi/lib:$LD_LIBRARY_PATH;
export PGI=/home/atdyer/pgi/build;
export PATH=/home/atdyer/pgi/build/linux86-64/17.4/bin:/home/atdyer/pgi/build/linux86-64/17.4/mpi/openmpi/bin:$PATH;
export MANPATH=$MANPATH:/home/atdyer/pgi/build/linux86-64/17.4/man:/home/atdyer/pgi/build/linux86-64/17.4/mpi/openmpi/man;
export LM_LICENSE_FILE=$LM_LICENSE_FILE:/home/atdyer/pgi/build/license.dat
```

Once complete, save the file and log out of takanami, and then log back in. You should now be able to run the commands ```pgfortran``` and ```mpif90``` and get the output ```pgfortran-Warning-No files to process```.

## Dependencies

Now that we have the appropriate compilers, the following will need to be built:
* **ADCIRC**, which depends on:
* **NetCDF**, which depends on:
* **HDF5**, which depends on:
* **zlib**

Luckily for you, I have put together a script that will build zlib, HDF5, and NetCDF for you. This script, called ```build-adcirc-netcdf-dependencies.sh``` is located in the ```scripts/``` directory of this repository.

### Set up the script

Download this script and make sure it is executable using the command

```bash
chmod +x build-adcirc-netcdf-dependencies.sh
```

Open up the script using a text editor and edit the variable ```DEPENDENCY_DIR``` to point to the directory that you'd like to contain all of the dependencies.

If you'd like to or need to change the version of any of the libraries, note that the naming convention comes from the actual file download names from each library's respective download website. Scroll down to see a ```wget``` command to understand how it is used. Ensure that the URL that is build in that command will actually point to an existing downloadable file before changing the version.

### Run the script

> Note that if you have just built the PGI compilers and added them to your ```~/.mybashrc``` file, you'll need to log out of and back into takanami before running this script

Save your changes to the script and run the script using:
```bash
./build-adcirc-netcdf-dependencies.sh
```

Note that this can be a fairly lengthy process (10-15 minutes in my experience), so go get some coffee.

Once the script finishes, verify the process has completed by looking in the ```$DEPENDENCY_DIR/install/bin``` directory for a program called ```nc-config``` and a program called ```nf-config```. If these files exist, you're good to go. If not, something went wrong.

Note that the directory ```$DEPENDENCY_DIR/install``` is the so-called 'installation directory' that we'll be referring to in the next steps.

### Add dependencies to the system path

Once the script has finished, you'll see a message telling you to finish installation by adding a line to your ```~/.mybashrc``` file. You can do this by copy-pasting that line to the end of the ```~/.mybashrc``` file, or you can combine it with the line that includes the PGI compilers.

Again, you'll need to log out and log back in to takanami in order for the changes to take effect.

### Final check

Once you've logged back in, run the command
```bash
echo ${LD_LIBRARY_PATH}
```
and you should see paths to the ```/lib``` directories for the ADCIRC dependencies, the PGI compilers, and OpenMPI. If you do, you're all set and ready to build ADCIRC.

## ADCIRC

Finally, to build ADCIRC we first need to make some changes to the compiler settings. The ```make``` settings that come with ADCIRC are mostly complete, but we need to make some modifications because we built things in a custom location.

In your ADCIRC directory, navigate to the ```/work``` directory and open up the ```cmplrflags.mk``` file in a text editor. Scroll down a bit and you'll see a long list of commented out compilers. At the end of that list add the following lines

```make
compiler=takanami
#
#
# Compiler flags for takanami pgi
ifeq ($(compiler),takanami)
  DEPDIR        :=  /home/atdyer/adcirc/dependencies/install
  PPFC          :=  pgfortran
  FC            :=  pgfortran
  PFC           :=  mpif90
  FFLAGS1       :=  $(INCDIRS) -fastsse -mcmodel=medium -Mextend -I$(DEPDIR)/include
  FFLAGS2       :=  $(FFLAGS1)
  FFLAGS3       :=  $(FFLAGS1)
  DA            :=  -DREAL8 -DLINUX -DCSCA
  DP            :=  -DREAL8 -DLINUX -DCSCA -DCMPI
  DPRE          :=  -DREAL8 -DLINUX
  IMODS         :=  -I
  CC            :=  gcc
  CCBE          :=  $(CC)
  CFLAGS        :=  $(INCDIRS) -O2 -mcmodel=medium -DLINUX -I$(DEPDIR)/include
  CLIBS         :=
  FLIBS         :=  -L$(DEPDIR)/lib -lnetcdff -lnetcdf
  MSGLIBS       :=
  $(warning (INFO) Corresponding machine found in cmplrflags.mk.)
  ifneq ($(FOUND),TRUE)
     FOUND := TRUE
  else
     MULTIPLE := TRUE
  endif
endif
```

On the line that sets the ```DEPDIR``` directory, change the value to the location where you installed the ADCIRC dependencies. Save and close the file.

Finally, compile ADCIRC using the following command:

```bash
make adcirc padcirc adcprep NETCDF=enable NETCDF4=enable NETCDF4_COMPRESSION=enable
```

Again, making sure to point NETCDFHOME towards the installation directory. Once make has finished, you should have the ```adcirc```, ```padcirc```, and ```adcprep``` executables in the work directory.
