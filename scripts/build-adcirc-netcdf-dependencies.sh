#!/bin/bash

# Set the top level directory where all libraries will be built
DEPENDENCY_DIR=/home/tristan/Desktop/dependencies

# Set the versions of each library
ZLIB_VERSION=zlib-1.2.11
HDF5_VERSION=hdf5-1.10.1
NETCDF_VERSION=netcdf-4.4.1.1
NETCDF_FORTRAN_VERSION=netcdf-fortran-4.4.4


###############################################################
###              Leave everything else alone                ###
###############################################################

# Top level directories
DOWNLOAD_DIR=$DEPENDENCY_DIR/downloads/
BUILD_DIR=$DEPENDENCY_DIR/builds/
INSTALL_DIR=$DEPENDENCY_DIR/install/

# Dependency directories
ZLIB_SRC_DIR=$DOWNLOAD_DIR/zlib/
ZLIB_BUILD_DIR=$BUILD_DIR/zlib/

HDF5_SRC_DIR=$DOWNLOAD_DIR/hdf5/
HDF5_BUILD_DIR=$BUILD_DIR/hdf5/

NETCDF_SRC_DIR=$DOWNLOAD_DIR/netcdf/
NETCDF_BUILD_DIR=$BUILD_DIR/netcdf/
NETCDF_FORTRAN_BUILD_DIR=$BUILD_DIR/netcdf-fortran/

build_directory_structure () {

	if [ ! -d $DEPENDENCY_DIR/downloads ] ; then mkdir -p $DEPENDENCY_DIR/downloads ; fi
	if [ ! -d $DEPENDENCY_DIR/builds ] ; then mkdir -p $DEPENDENCY_DIR/builds ; fi
	if [ ! -d $DEPENDENCY_DIR/libraries ] ; then mkdir -p $DEPENDENCY_DIR/libraries ; fi

}

build_zlib () {

	if [ ! -d $ZLIB_SRC_DIR ] ; then mkdir -p $ZLIB_SRC_DIR ; fi
	if [ ! -d $ZLIB_BUILD_DIR ] ; then mkdir -p $ZLIB_BUILD_DIR ; fi
	
	if [ ! -d $ZLIB_SRC_DIR/$ZLIB_VERSION ] ; then
	
		# Make sure the file has been downloaded
		if [ ! -e $ZLIB_SRC_DIR/$ZLIB_VERSION.tar.gz ] ; then
		
			# Download zlib
			wget -P $ZLIB_SRC_DIR https://zlib.net/$ZLIB_VERSION.tar.gz
			
		fi
		
		# Unzip
		tar -xzf $ZLIB_SRC_DIR/$ZLIB_VERSION.tar.gz --directory $ZLIB_SRC_DIR
		
	fi
	
	# Configure the code
	cd $ZLIB_BUILD_DIR
	$ZLIB_SRC_DIR/$ZLIB_VERSION/configure --prefix=$INSTALL_DIR
	
	# Build the code using as many jobs as possible
	make -j
	make install

}

build_hdf5 () {

	if [ ! -d $HDF5_SRC_DIR ] ; then mkdir -p $HDF5_SRC_DIR ; fi
	if [ ! -d $HDF5_BUILD_DIR ] ; then mkdir -p $HDF5_BUILD_DIR ; fi
	
	if [ ! -d $HDF5_SRC_DIR/$HDF5_VERSION ] ; then
	
		# Make sure the file has been downloaded
		if [ ! -e $HDF5_SRC_DIR/$HDF5_VERSION.tar.gz ] ; then
		
			# Download hdf5
			wget -P $HDF5_SRC_DIR https://support.hdfgroup.org/ftp/HDF5/current/src/$HDF5_VERSION.tar.gz
			
		fi
		
		# Unzip
		tar -xzf $HDF5_SRC_DIR/$HDF5_VERSION.tar.gz --directory $HDF5_SRC_DIR
	
	fi
	
	# Configure the code
	cd $HDF5_BUILD_DIR
	$HDF5_SRC_DIR/$HDF5_VERSION/configure --prefix=$INSTALL_DIR --with-zlib=$INSTALL_DIR --enable-fortran
	
	# Build the code using as many jobs as possible
	make -j
	make install

}

build_netcdf () {

	if [ ! -d $NETCDF_SRC_DIR ] ; then mkdir -p $NETCDF_SRC_DIR ; fi
	if [ ! -d $NETCDF_BUILD_DIR ] ; then mkdir -p $NETCDF_BUILD_DIR ; fi
	if [ ! -d $NETCDF_FORTRAN_BUILD_DIR ] ; then mkdir -p $NETCDF_FORTRAN_BUILD_DIR ; fi

	if [ ! -d $NETCDF_SRC_DIR/$NETCDF_VERSION ] ; then

		# Make sure the file has been downloaded
		if [ ! -e $NETCDF_SRC_DIR/$NETCDF_VERSION.tar.gz ] ; then
		
			# Download netcdf
			wget -P $NETCDF_SRC_DIR ftp://ftp.unidata.ucar.edu/pub/netcdf/$NETCDF_VERSION.tar.gz

		fi
		
		# Unzip
		tar -xzf $NETCDF_SRC_DIR/$NETCDF_VERSION.tar.gz --directory $NETCDF_SRC_DIR

	fi

	if [ ! -d $NETCDF_SRC_DIR/$NETCDF_FORTRAN_VERSION ] ; then

		# Make sure the file has been downloaded
		if [ ! -e $NETCDF_SRC_DIR/$NETCDF_FORTRAN_VERSION.tar.gz ] ; then

			# Download netcdf fortran
			wget -P $NETCDF_SRC_DIR ftp://ftp.unidata.ucar.edu/pub/netcdf/$NETCDF_FORTRAN_VERSION.tar.gz

		fi

		# Unzip
		tar -xzf $NETCDF_SRC_DIR/$NETCDF_FORTRAN_VERSION.tar.gz --directory $NETCDF_SRC_DIR

	fi
	
	# Make sure all environment variables set properly
	export LD_LIBRARY_PATH=$INSTALL_DIR/lib${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}
	export CPPFLAGS=-I$INSTALL_DIR/include
	export LDFLAGS=-L$INSTALL_DIR/lib

	# Configure the code
	cd $NETCDF_BUILD_DIR
	$NETCDF_SRC_DIR/$NETCDF_VERSION/configure --prefix=$INSTALL_DIR --disable-dap

	# Build the code using as many jobs as possible
	make -j
	make install

	# Configure the fortran code
	cd $NETCDF_FORTRAN_BUILD_DIR
	$NETCDF_SRC_DIR/$NETCDF_FORTRAN_VERSION/configure --prefix=$INSTALL_DIR 

	# Build the code using as many jobs as possible
	make -j
	make install

	
}

print_message () {

	echo
	echo
	echo
	echo -------------------------------------------------------------------
	echo 
	echo   Finished building ADCIRC dependencies (maybe. check for errors)
	echo 
	echo -------------------------------------------------------------------
	echo 
	echo   To finish installation, add the following line to the end of
	echo   your ~/.mybashrc file:
	echo   export LD_LIBRARY_PATH=$INSTALL_DIR/lib:\$LD_LIBRARY_PATH
	echo
	echo -------------------------------------------------------------------
	echo

}

build_directory_structure
build_zlib
build_hdf5
build_netcdf
print_message