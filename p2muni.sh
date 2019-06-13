#!/bin/sh
#
# generate unified spike files for all files on command line
#

if [ $# = 0 ]; then
  cat <<EOF
generate unified spike files from p2m files
 usage: [-f] $(basename $0) ...p2mfiles...
 -f option indicates force conversion (overwrites existing .uni files) 
EOF
  exit 0
fi

force=0
if [ $1 = '-f' ]; then
  force=1;
  shift
fi

#(find $* -printf "p2muni('%h/%f',$force);\n"; echo quit)
#(find $* -printf "p2muni('%h/%f',$force);\n"; echo quit) | matlab -nodisplay -nojvm
(echo "flist = { ...";
    find $* -printf "'%h/%f' ...\n";
    echo "}; p2muni(flist, $force); quit") | matlab-nh -nodisplay -nojvm
