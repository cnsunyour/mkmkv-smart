# AGENTS.md - 智能体协作规范

## 构建命令

### 核心命令
```bash
# 安装到 ~/.local/bin/mkmkv
make install
```

### 运行脚本
```bash
# 主脚本（推荐，自动匹配字幕语言）
./mkmkv.sh [源目录] [目标目录] [mkvmerge额外参数]

# 特定字幕顺序的脚本（繁体/简体/英文）
./mkmkv_繁简英.sh [源目录] [目标目录]

# 调整音轨脚本
./mkmkv_调整音轨.sh
```

**注意**: 项目使用 shellcheck 进行代码审查。运行 `shellcheck mkmkv.sh` 检查脚本。

---

## 代码风格规范

### Shebang 行
- 所有脚本统一使用 `#!/usr/bin/env bash`（跨平台可移植性）

### 注释规范
- **语言**: 使用中文注释
- **内容**: 描述意图而非实现细节
- **位置**: 复杂逻辑前需加注释说明
- **示例**:
  ```bash
  # 检查是否安装了 mkvmerge
  # 如果没有安装，退出脚本
  if ! command -v mkvmerge &>/dev/null; then
    echo "mkvmerge not found, please install mkvtoolnix"
    exit
  fi
  ```

### 命名约定
- **变量**: 全小写 + 下划线（`source_dir`, `target_dir`, `lang_valid`）
- **关联数组**: 使用 `declare -A` 定义
- **常规数组**: 使用括号初始化（`preset_lang_codes=(zh en)`）
- **常量**: 全大写（仅项目约定，当前未强制）

### 缩进与格式
- **缩进**: 2 空格
- **行宽**: 无硬性限制，但建议不超过 120 字符
- **命令续行**: 使用反斜杠（`\`），推荐在管道或长参数列表使用

### 引号使用
- **变量引用**: 统一使用双引号（`"$variable"`），防止路径含空格问题
- **文件路径**: 必须使用双引号（`"$file"`, `"$source_dir"`）
- **字符串常量**: 根据需求选择单/双引号

### 错误处理
- **依赖检查**: 使用 `command -v` 检查命令是否存在
- **参数验证**: 检查目录/文件是否存在（`[ -d "$1" ]`, `[ -f "$file" ]`）
- **错误输出**: 使用 `echo` 输出错误信息，使用 `exit` 退出
- **静默重定向**: 使用 `&>/dev/null` 抑制不需要的输出
- **错误统计**: 记录处理成功/失败数量，输出汇总信息
- **退出码**: 失败时返回 `exit 1`，成功时返回 `exit 0`

### 跨平台兼容性
- **macOS vs Linux**: 检查 `uname` 区分 Darwin（`[ "$(uname)" == "Darwin" ]`）
- **find 命令**: macOS 使用 `-s` 参数排序结果
- **Bash 版本**: 检查 `BASH_VERSION`，主脚本支持 5.2+ 新特性
- **sed 命令**: macOS 使用 `sed -i ''`，Linux 使用 `sed -i`

### IFS（内部字段分隔符）处理
```bash
# 保存并恢复 IFS，处理含空格的文件名
oldIFS=$IFS
IFS=$'\n'
# ... 处理代码 ...
IFS=$oldIFS
```

### 语言代码规范
- 使用标准 ISO 639-1/ISO 3166-1 代码（`zh-Hans`, `en`, `zh-TW`）
- 统一小写处理（`${lang,,}`）进行大小写不敏感匹配
- 支持的区域变体：`zh-CN`, `zh-HK`, `zh-MO`, `zh-TW`, `zh-SG`

### 文件名匹配
- 使用 `find -s -maxdepth 1` 限制当前目录
- 排除隐藏文件：`! -iname ".*"`
- 支持通配符：`*.mp4`, `*.srt`, `*.ass`
- 使用 `iname` 进行大小写不敏感匹配

### mkvmerge 参数规范
- **输出**: `-o` 指定目标文件
- **字幕编码**: `--sub-charset N:UTF-8`
- **语言**: `--language N:lang_code`
- **轨道名称**: `--track-name N:"名称"`（使用中英双语）
- **默认轨道**: `--default-track-flag N:yes/no`（每个文件仅一个默认字幕）
- **轨道顺序**: `--track-order` 控制轨道顺序

### 变量替换与字符串操作
- **路径处理**: 使用参数扩展（`${filename%.*}` 去扩展名）
- **小写转换**: `${var,,}`（需要 Bash 4.0+）
- **大小写转换**: `${var^^}` 转大写
- **特殊字符转义**: 需要转义 `[`, `]`, `*`, `?` 等 glob 字符

### 条件判断
- **多条件**: 使用 `&&`, `||` 连接
- **字符串比较**: 使用 `==`, `!=`, `=~`（正则匹配）
- **空值检查**: `[ "$var" == "" ]`
- **数组包含**: 使用字符串替换技巧（`"${arr[@]/$val}" != "${arr[@]}"`）

### 正则表达式匹配
```bash
if [[ "$var" =~ regex ]]; then
  # 使用 $BASH_REMATCH 获取匹配组
  matched="${BASH_REMATCH[1]}"
fi
```

### 循环结构
- **遍历数组**: `for item in "${array[@]}"`
- **遍历关联数组**: `for key in "${!assoc_array[@]}"`
- **索引循环**: `for ((i=0; i<${#array[@]}; i++))`
- **文件遍历**: 配合 `find` 命令使用

### 调试与日志
- **进度显示**: 显示当前处理的文件计数（`[1] 处理: filename.mp4`）
- **静默模式**: mkvmerge 使用 `--quiet` 减少输出
- **错误信息**: 明确指出问题原因（如 `lang $tmp_srt_lang is unknown.`）
- **汇总信息**: 处理完成后显示总计、成功、失败的文件数量

---

## 文件结构

- `mkmkv.sh`: 主脚本，智能匹配字幕语言
- `mkmkv_繁简英.sh`: 固定字幕顺序（繁体/简体/英文）
- `mkmkv_英简繁.sh`: 英文/简体/繁体顺序
- `mkmkv_英繁简.sh`: 英文/繁体/简体顺序
- `mkmkv_英英简繁.sh`: 双英文字幕 + 中文字幕
- `mkmkv_调整音轨.sh`: 音轨调整脚本
- `Makefile`: 安装配置
- `.gitignore`: 忽略编译产物和可执行文件

---

## 依赖检查

### 必需工具
- **mkvmerge** (mkvtoolnix): MKV 文件合并工具
  - 检查: `command -v mkvmerge`
  - 安装: `brew install mkvtoolnix` (macOS)
- **bash**: 版本 4.0+ 推荐使用 5.2+

### 可选工具
- **shellcheck**: Bash 脚本静态分析（开发时推荐）
- **sed**: 文本处理（用于清理字幕标签）

---

## 常见任务

### 添加新语言支持
在 `lang_map` 关联数组中添加条目：
```bash
declare -A lang_map=(
  ["xx"]="Language Name"
  ["xx-YY"]="Language Name (Country)"
)
```

### 添加新字幕类型
在 `subtitle_types` 数组和 `subtitle_type_names` 关联数组中添加：
```bash
subtitle_types=('' 'cc' 'sdh' 'newtype')
declare -A subtitle_type_names=(['sdh']='CC' ['newtype']='Type')
```

### 修改默认字幕规则
在 `mkmkv.sh` 中修改 `preset_lang_codes` 数组，调整优先级顺序。

### macOS 兼容性修复
- `find` 命令添加 `-s` 参数
- `sed -i` 改为 `sed -i ''`
- 特殊字符转义（Bash 5.2 前后处理方式不同）

---

## 安全注意事项
- **不执行任意命令**: 动态拼接的命令需谨慎使用 `eval`
- **路径验证**: 所有路径参数需验证存在性，使用 `$(cd "$dir" && pwd)` 标准化
- **文件名转义**: 正确处理含空格、特殊字符的文件名
- **错误退出**: 使用 `exit` 确保错误时停止执行
- **参数过滤**: 检查第三参数及之后的参数，过滤危险字符（分号、反引号、$、管道、重定向、反斜杠）
- **临时文件**: 使用临时文件避免直接修改原文件（如字幕清理）
- **数组执行**: 优先使用数组方式执行命令，避免 eval 的安全风险
