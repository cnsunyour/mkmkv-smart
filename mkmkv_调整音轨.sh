#!/usr/bin/env bash

if [ $# -ge 1 ] && [ -d "$1" ]; then
  source_dir=$(cd "$1" && pwd)
else
  source_dir=$(pwd)
fi

if [ $# -ge 2 ] && [ -d "$2" ]; then
  target_dir=$(cd "$2" && pwd)
else
  target_dir="$source_dir"
fi

# 使用子shell隔离 IFS 修改
(
  IFS=$'\n'

  while IFS= read -r file; do
    [ -z "$file" ] && continue
    if [ -f "$file" ]; then
      filename=$(basename "$file")
      mkvmerge \
        -o "$target_dir"/"${filename%.*}".mkv \
        "$file" \
        --track-order 0:2,0:1
    fi
  done < <(find -s "$source_dir" -name "*.mkv")
)
