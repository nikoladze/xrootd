#!/bin/bash

############################################################################  
# Little scriptlet to fetch and install an autotools development environment
#
# Author: Derek Feichtinger <derek.feichtinger@psi.ch>
# Initial Version: 2007-06-02
#
# Version info: $Id$
############################################################################  

BUILDDIR=`pwd`/autotools-build
INSTALLDIR=`pwd`/install

VAUTOCONF=2.60
VAUTOMAKE=1.10
VLIBTOOL=1.5.22

WGETSRC="http://ftp.gnu.org/gnu/"

prompt=1

unset WGET

usage() {
cat <<EOF
Name: getAutotools.sh - fetch and install an autotools development environment

Synopsis: getAutotools.sh [options]

   Options:
       -a autoconf version (default: $VAUTOCONF)
       -m automake version (default: $VAUTOMAKE)
       -l libtool version (default: $VLIBTOOL)
       -b build directory (default: $BUILDDIR)
       -i install directory (default: $INSTALLDIR)
       -f do not prompt before installing

Author: Derek Feichtinger <derek.feichtinger@psi.ch>
EOF
}

testfor() {
    p=`which $1`
    status=$?
    if test 0"$status" -ne 0; then
	echo "Error: Could not find $1 in PATH" >&2
	exit 1
    fi
    echo "$p"
    echo "################################# $p" >&2
}

build_install() {
    product=`expr $1 : '\([^-]*\)'`
    if test x"$1" = x; then
	echo "Error: build_install() called without argument" >&2
	exit 1
    fi
    if test ! -e $1.tar; then
	if test ! -e $1.tar.gz; then
	    test -z $WGET && WGET=`testfor wget`
	    $WGET $WGETSRC/$product/$1.tar.gz
	    if test ! -e $1.tar.gz; then
		echo "Error: Failed to fetch tarball: $WGETSRC/$1.tar.gz" >&2
		exit 1
	    fi
	fi
	gunzip $1.tar.gz
    fi
    tar xvf $1.tar
    cd $1
    ./configure --prefix=$INSTALLDIR
    make install
    status=$?
    if test 0"$status" -ne 0; then
	echo "Error: make install of $1 failed" >&2
	exit 1
    fi	
    if test ! -x $INSTALLDIR/bin/$product; then
	echo "Error: Check for installed product failed: $INSTALLDIR/bin/$product" >&2
	exit 1
    fi
}



TEMP=`getopt -o a:b:m:l:hi:f --long help -n 'getAutotools' -- "$@"`
if [ $? != 0 ] ; then usage ; echo "Terminating..." >&2 ; exit 1 ; fi
#echo "TEMP: $TEMP"
eval set -- "$TEMP"

while true; do
    case "$1" in
        --help|-h)
            usage
            exit
            ;;
        -a)
            VAUTOCONF="$2"
            shift 2
            ;;
        -m)
            VAUTOMAKE="$2"
            shift 2
            ;;
        -l)
            VLIBTOOL="$2"
            shift 2
            ;;
        -b)
            BUILDDIR="$2"
            shift 2
            ;;
        -i)
            INSTALLDIR="$2"
            shift 2
            ;;
	-f)
	    prompt=0
	    shift
	    ;;
        --)
            shift;
            break;
            ;;
        *)
            echo "Internal error!"
            exit 1
            ;;
    esac
done



AUTOCONF=autoconf-$VAUTOCONF
AUTOMAKE=automake-$VAUTOMAKE
LIBTOOL=libtool-$VLIBTOOL

if test 0"$prompt" -eq 1; then
    cat <<EOF
INSTALLATION SETTINGS:

       autoconf version  : $VAUTOCONF
       automake version  : $VAUTOMAKE
       libtool version   : $VLIBTOOL
       build directory   : $BUILDDIR
       install directory : $INSTALLDIR

Is this ok?   (Y/n)
EOF
    read a
    if test x"$a" != xy -a x"$a" != xY; then
	usage
	exit 0
    fi
fi


mkdir -p $BUILDDIR
cd $BUILDDIR

export PATH=$INSTALLDIR/bin:$PATH
for n in $AUTOCONF $AUTOMAKE $LIBTOOL; do
    build_install $n
done

echo "############################################################"
echo "In order to use this autotools environment you need to"
echo "export PATH=$INSTALLDIR/bin:\$PATH"
 
