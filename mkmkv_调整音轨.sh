#!/usr/bin/env bash

if [ $# -ge 1 ] && [ -d $1 ]; then
  source_dir=$1
else
  source_dir=`pwd`
fi

if [ $# -ge 2 ]; then
  target_dir=$2
else
  target_dir=$source_dir
fi

oldIFS=$IFS
IFS=$'\n'

for file in `find -s $source_dir -name "*.mkv"`; do
  if [ -f $file ]; then
    filename=$(basename $file)
    mkvmerge \
      -o $target_dir/${filename%.*}.mkv \
      $file \
      --track-order 0:2,0:1
  fi
done

IFS=$oldIFS
