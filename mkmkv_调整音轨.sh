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
    temp_output="${file}.tmp"
    if mkvmerge --quiet \
      -o "$temp_output" \
      "$file" \
      --track-order 0:0,0:1,0:3,0:2 2>&1; then
      mv "$temp_output" "$file"
      success=$((success + 1))
    else
      rm -f "$temp_output"
      failed=$((failed + 1))
      echo "  错误: 处理失败"
    fi
  fi
done < <(find $find_param "$source_dir" -maxdepth 1 -type f -name "*.mkv")

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
