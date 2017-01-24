#!/bin/bash

PACKAGE_LIST=(libxml2-dev
)

function install_packages() {
	
	for(( i=0; i<${#PACKAGE_LIST[@]} ; ++i )) ; do
		echo -n "Checking ["$((i+1))"/${#PACKAGE_LIST[@]}]:{${PACKAGE_LIST[$i]}} => "
		if [[ -z $(dpkg -l | grep ${PACKAGE_LIST[$i]} | awk '{print $2, $3}') ]]; then
			echo -n "Installing [${PACKAGE_LIST[$i]}]..."
			apt-get install -y ${PACKAGE_LIST[$i]} 2>&1 > /dev/null
			if [[ $? -eq 0 ]]; then
				echo "Success..."
			else
				echo "Failed..."
			fi
		else
			echo "Installed..."
		fi
	done
}


function build_envytools() {
	cd envytools
	mkdir build
	cd build
	cmake -DCMAKE_INSTALL_PREFIX=$(readlink -f ../../build) ..
	make && make install
	cd ../../
}

function build_libdrm_pscnv() {
	cd libdrm_pscnv
	./autogen.sh --prefix=$(readlink -f ../build) --enable-nouveau-experimental-api
	make && make install
	cd ..
}

function build_pscnv() {
	export PATH=$(readlink -f build/bin):$PATH
	cd pscnv
	mkdir build
	cd build
	CXXFLAGS=-I$(readlink -f ../../build/include/libdrm) CFLAGS=-I$(readlink -f ../../build/include/libdrm) cmake -DCMAKE_INSTALL_PREFIX=$(readlink -f ../../build) -DCMAKE_SYSROOT=$(readlink -f ../../build) ..
	make && make install
	cd ../../
}


function main() {
	install_packages
	build_envytools
	build_libdrm_pscnv
	build_pscnv
}

main


