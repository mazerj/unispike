#!/bin/sh
#
# generate multiple .s2 files from single metarf file
#

if [ $# = 0 ]; then
  cat <<EOF
generate .s2 spike2 files from p2m files
 usage: vmoffset meta-pypefile
 vmoffset indicates offset in mv
EOF
  exit 0
fi

vmoff=$1
mf=$2
echo "xmeta('$mf', $vmoff); quit" | matlab-nh -nodisplay -nojvm
