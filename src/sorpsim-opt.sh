!/bin/sh
# Linux users: if you use a custom build of qwt, you may want to
# use this script to launch sorpsim-opt. Modify the path here
# to point to your libqwt.so.
export LD_LIBRARY_PATH=/usr/local/qwt-6.1.3/lib
./sorpsim-opt

