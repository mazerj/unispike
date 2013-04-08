#!/bin/sh
#
# generate .s2 spike2 files for all files on command line
#

if [ $# = 0 ]; then
  cat <<EOF
generate .s2 spike2 files from p2m files
 usage: [-f] $(basename $0) vmoffset ...p2mfiles...
 -f option indicates force conversion (overwrites existing .uni files) 
 vmoffset indicates offset in mv
EOF
  exit 0
fi

force=0
if [ $1 = '-f' ]; then
  force=1;
  shift
fi

vmoff=$1; shift

(echo "flist = { ...";
    find $* -printf "'%h/%f' ...\n";
    echo "}; p2mS2(flist, $force, $vmoff); quit") | matlab-nh -nodisplay -nojvm
