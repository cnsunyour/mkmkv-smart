#!/usr/bin/env bash

if ! command -v mkvmerge &>/dev/null; then
  echo "mkvmerge not found, please install mkvtoolnix"
  exit 1
fi

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

# 统计变量
total=0
success=0
failed=0

find_param=""
if [ "$(uname)" == "Darwin" ]; then
  find_param="-s"
fi

while IFS= read -r file; do
  [ -z "$file" ] && continue
  if [ -f "$file" ]; then
    total=$((total + 1))
    filename=$(basename "$file")
    echo "[$total] 处理: $filename"
    if mkvmerge --quiet \
      -o "$target_dir"/"${filename%.*}".mkv \
      -s 2,3,4 \
      --sub-charset 2:UTF-8 --language 2:en --track-name 2:English --default-track-flag 2:no \
      --sub-charset 3:UTF-8 --language 3:zh-Hans --track-name 3:简体中文 \
      --sub-charset 4:UTF-8 --language 4:zh-Hant --track-name 4:繁體中文 --default-track-flag 4:no \
      "$file" \
      --track-order 0:0,0:1,0:3,0:4 2>&1; then
      success=$((success + 1))
    else
      failed=$((failed + 1))
      echo "  错误: 处理失败"
    fi
  fi
done < <(find $find_param "$source_dir" -maxdepth 1 -type f -name "*.mp4")

echo ""
echo "======================================"
echo "处理完成:"
echo "  总计: $total 个文件"
echo "  成功: $success 个文件"
echo "  失败: $failed 个文件"
echo "======================================"

if [ $failed -gt 0 ]; then
  exit 1
fi
exit 0
