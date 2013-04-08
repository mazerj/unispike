#!/bin/sh

# NOTE: this is only for .plx files -- not tucker davis tanks...

# for each .plx file, find the corresponding .p2m file and then
# generate a .uni file, if it doesn't already exist

# start off by pulling any new data from the Plexon
#echo "SYNCING PLEXON DATA"
#sudo /auto/data/critters/PlexonData.sync

force=0
if [ "$1" = "-f" ]; then
  force=1
  shift
fi

# find all pype files first
find /auto/data/critters/*/20?? \
  -name '*[0-9][0-9][0-9][0-9].*.[0-9][0-9][0-9]*p2m*' >/tmp/$$

# now scan through the plexon files
echo "GENERATING MISSING .UNI FILES"
echo "START $(date)" >>tmplog

for i in $(find /auto/data/critters/PlexonData \
    -name '*.*.[0-9][0-9][0-9].plx'| grep -v " " | sort)
do
  ii=$(basename $(echo $i | sed s/.plx/.p2m/g))
  # look for matching p2m file(s). if there's
  # more than one it's really an error, by just
  # take the first for now..
  x=$(grep ${ii} /tmp/$$ | head -1)
  if [ "$x" = "" ]; then
    echo $(basename $0): missing matching p2m for $i
  elif [ $(echo $x | wc -w) -gt 1 ]; then
    echo $(basename $0): multiple matching p2m for $i
  else
    u=$(echo $x | sed s/.p2m/.uni/g)
    u=$(dirname $u)/.$(basename $u)

    if [ $force = 1 -o  ! -f $u ]; then
      if [ -f $u ]; then
        /bin/rm $u
      fi
      echo $(basename $0): executing p2muni $x
      p2muni $x | tee -a tmplog
    else
     echo $(basename $0): uni file exists for $i

    fi
  fi
done
echo "END $(date)" >>tmplog

/bin/rm /tmp/$$
