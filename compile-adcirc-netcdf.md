# Compiling ADCIRC with NetCDF

Compiling ADCIRC with support for NetCDF output on takanami is a fairly involved process that can often end up taking you down the dependency and compatibility rabbit-hole. This guide will take you through the whole process that I used to successfully build ADCIRC and all of the necessary supporting libraries.

Note that I have only attempted this process on takanami, but will be testing on taifu as soon as necessary.

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

Download this script and make sure it is executable using the command

```bash
chmod +x build-adcirc-netcdf-dependencies.sh
```

Open up the script using a text editor, as you'll need to set the following variables:
* 
