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
        -s 2,3,4,5 \
        --sub-charset 2:UTF-8 --language 2:en --track-name "2:English" --default-track-flag 2:no \
        --sub-charset 3:UTF-8 --language 3:en --track-name "3:English[CC]" --default-track-flag 3:no \
        --sub-charset 4:UTF-8 --language 4:zh-Hans --track-name "4:简体中文" \
        --sub-charset 5:UTF-8 --language 5:zh-Hant --track-name "5:繁體中文" --default-track-flag 5:no \
        "$file" \
        --track-order 0:0,0:1,0:4,0:5,0:2,0:3
    fi
  done < <(find -s "$source_dir" -name "*.mp4")
)
