# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 项目概述

这是一个用于批量合并视频文件和字幕到 MKV 容器的 Bash 脚本集合。主要使用 `mkvmerge` 工具（来自 mkvtoolnix）进行媒体封装。

**核心功能**:
- 自动检测和匹配字幕文件的语言代码
- 智能文件名匹配：支持视频和字幕文件名不完全一致的场景
- 智能字幕优先级排序：自动将简体中文、繁体中文、英文字幕排在前三位
- 支持多种字幕顺序和音轨调整
- 干运行模式：预览匹配结果和执行命令，无需实际执行
- 智能处理文件名中的特殊字符和空格
- 跨平台支持（macOS 和 Linux）

**脚本对比**:

| 脚本 | 匹配方式 | 使用场景 | 预处理需求 |
|------|---------|---------|-----------|
| `mkmkv.sh` | 精确前缀匹配 | 文件名规范，追求速度 | 需要手动统一文件名 |
| `mkmkv_smart.sh` | 智能相似度匹配 | 文件名不规范，杂乱命名 | 无需预处理 ✅ |
| `mkmkv_*.sh` | 固定顺序 | 特定字幕顺序需求 | 需要手动统一文件名 |

## 常用命令

### 安装
```bash
make install  # 安装到 ~/.local/bin/mkmkv
```

### 运行脚本
```bash
# 智能匹配脚本（推荐，无需手动改名）
./mkmkv_smart.sh [源目录] [目标目录] [mkvmerge额外参数]
./mkmkv_smart.sh --dry-run [源目录]  # 干运行：预览匹配结果
./mkmkv_smart.sh -n [源目录]         # 干运行简写

# 主脚本（精确匹配，需要文件名前缀一致）
./mkmkv.sh [源目录] [目标目录] [mkvmerge额外参数]

# 特定字幕顺序的脚本
./mkmkv_繁简英.sh [源目录] [目标目录]
./mkmkv_英简繁.sh [源目录] [目标目录]
./mkmkv_英繁简.sh [源目录] [目标目录]
./mkmkv_英英简繁.sh [源目录] [目标目录]

# 音轨调整脚本
./mkmkv_调整音轨.sh
```

### Python 工具 (mkmkv-smart)

**安装**:
```bash
# 开发模式安装
pip install -e .
# 或正式安装
pip install .
```

**基本用法**:
```bash
mkmkv-smart <源目录> [输出目录] [选项]
```

**命令行参数**:
- `源目录`: 包含视频和字幕文件的目录（必需）
- `输出目录`: 输出 MKV 文件的目录（可选，默认为源目录）
- `--dry-run`, `-n`: 干运行模式，仅显示匹配结果和将要执行的命令
- `--threshold <值>`: 设置匹配相似度阈值（0-100，默认 30）
- `--method <方法>`: 设置匹配算法（token_sort, token_set 等）
- `--config <文件>`: 指定配置文件路径
- `--track-order <顺序>`: **新增** 指定轨道顺序，格式为 `文件编号:轨道编号`

**轨道顺序参数 (--track-order)**:

格式：`文件编号:轨道编号,文件编号:轨道编号,...`
- `0` = 视频文件
- `1+` = 字幕文件（按添加顺序）

示例：
```bash
# 视频轨0, 音轨1, 第1个字幕, 第2个字幕
--track-order 0:0,0:1,1:0,2:0

# 仅视频轨和音轨（不包含字幕）
--track-order 0:0,0:1

# 调整音轨顺序（先次音轨，再主音轨）
--track-order 0:0,0:2,0:1,1:0
```

**使用示例**:
```bash
# 基本使用
mkmkv-smart ~/Downloads ~/Movies

# 干运行：预览匹配结果
mkmkv-smart --dry-run ~/Downloads

# 自定义相似度阈值
mkmkv-smart ~/Downloads ~/Movies --threshold 50

# 指定轨道顺序（视频轨0，音轨1，简体字幕，英文字幕）
mkmkv-smart ~/Downloads ~/Movies --track-order 0:0,0:1,1:0,2:0

# 使用配置文件
mkmkv-smart ~/Downloads --config ~/.config/mkmkv-smart.yaml
```

**特性对比**:

| 特性 | Bash 版本 | Python 版本 |
|------|----------|------------|
| 智能文件名匹配 | ✅ | ✅ |
| 自动语言代码检测 | ✅ | ✅ |
| 字幕优先级排序 | 手动配置 | ✅ 自动 |
| 轨道顺序控制 | `mkmkv_调整音轨.sh` | ✅ `--track-order` |
| 配置文件支持 | ❌ | ✅ |
| 测试覆盖率 | ❌ | ✅ 275+ 测试 |
| 安全性 | 基础 | ✅ 增强 |

### 使用示例

**场景 1: 杂乱命名（智能匹配）**
```bash
# 文件结构（视频和字幕文件名不完全一致）
Movie.2024.1080p.BluRay.x264.mp4
Movie.2024.zh-Hans.srt
Movie.zh-Hant.srt

# 先预览匹配结果
./mkmkv_smart.sh --dry-run ~/Downloads

# 确认无误后执行
./mkmkv_smart.sh ~/Downloads ~/Movies
```

**场景 2: 规范命名（精确匹配）**
```bash
# 文件结构（文件名前缀一致）
Movie.2024.mp4
Movie.2024.zh-Hans.srt
Movie.2024.en.srt

# 直接执行
./mkmkv.sh ~/Downloads ~/Movies
```

### 代码质量检查
```bash
shellcheck mkmkv.sh  # 静态分析 Bash 脚本
```

## 架构设计

### 核心组件

**mkmkv.sh (精确匹配脚本)**
- 包含完整的语言代码映射表（350+ 语言/区域变体）
- 智能字幕语言检测：通过正则表达式从文件名提取语言代码
- 预定义语言优先级：`preset_lang_codes` 数组控制字幕排序
- 字幕类型支持：空（普通）、CC、SDH
- 安全过滤机制：防止命令注入（检查第三方参数中的危险字符）
- **要求**：视频和字幕文件名必须有相同的前缀

**mkmkv_smart.sh (智能匹配脚本)** ⭐ 新增
- 继承 `mkmkv.sh` 的所有语言检测功能
- **文件名规范化**: 自动去除分辨率、编码、来源等标签
- **Jaccard 相似度算法**: 计算文件名相似度（0-100%）
- **智能匹配阈值**: 默认 30%，可在脚本中调整
- **干运行模式**: `--dry-run` 或 `-n` 参数预览匹配
- **无需预处理**: 自动处理文件名不一致的情况

**智能匹配算法** (mkmkv_smart.sh:40-110):

1. **文件名规范化** (normalize_filename 函数):
   ```bash
   # 输入: Movie.2024.1080p.BluRay.x264.mp4
   # 输出: movie 2024

   步骤:
   - 转小写: ${filename,,}
   - 去扩展名: ${filename%.*}
   - 去除标签: sed 清理 1080p, BluRay, x264 等
   - 统一分隔符: . - _ → 空格
   - 压缩空格: tr -s ' '
   ```

2. **相似度计算** (string_similarity 函数):
   ```bash
   # Jaccard 相似度 = 交集词数 / 并集词数 × 100

   示例:
   视频: "movie 2024"           → {movie, 2024}
   字幕: "movie 2024 zh hans"   → {movie, 2024, zh, hans}

   交集: {movie, 2024}           → 2 个
   并集: {movie, 2024, zh, hans} → 4 个
   相似度: 2/4 × 100 = 50%
   ```

3. **匹配策略**:
   - 遍历所有字幕文件，计算与视频文件的相似度
   - 相似度 ≥ 30% 才认为匹配
   - 同一语言有多个字幕时，选择相似度最高的
   - 按预定义语言优先级排序

4. **干运行模式**:
   - 显示规范化后的文件名
   - 显示每个匹配字幕的相似度百分比
   - 显示完整的 mkvmerge 命令（格式化输出）
   - 不实际执行命令

**字幕匹配逻辑** (mkmkv.sh:454-481):
1. 使用正则表达式匹配文件名模式：`[.-_]([a-z]{2,3}([-_][a-z0-9]{2,})?)([.-_\[](cc|sdh|forced)\]?)?\.(srt|ass)$`
2. 提取语言代码和字幕类型（cc/sdh/forced）
3. 验证语言代码是否在 `lang_map` 中存在
4. 自动清理 SRT 文件中的 HTML 标签（使用 sed）

**特殊字符转义** (mkmkv.sh:439-449):
- Bash 5.2+ 使用参数扩展 `${matchname//[\[\]\*\?]/\\&}`
- Bash 5.2 以下逐个转义 `[`, `]`, `*`, `?`
- 目的：安全地在 find 命令中使用文件名作为 glob 模式

**命令构建模式** (mkmkv.sh:512-556):
- 使用数组而非字符串拼接（避免 eval 风险）
- 动态构建 mkvmerge 参数列表
- 确保每个 MKV 文件仅有一个默认字幕轨道

### 跨平台兼容性

**平台检测** (mkmkv.sh:403-407):
```bash
if [ "$(uname)" == "Darwin" ]; then
  find_param="-s"  # macOS 需要 -s 参数排序
else
  find_param=""    # Linux 不需要
fi
```

**关键差异**:
- macOS: `find -s` 排序结果，`sed -i ''` 原地编辑
- Linux: `find` 默认行为，`sed -i` 原地编辑
- Bash 版本：建议 5.2+，最低支持 4.0+
- **sed 正则**: macOS 的 BSD sed 不支持 `\s`（空白符），使用 `tr -s ' '` 替代

### IFS 处理模式

处理含空格的文件名 (mkmkv.sh:426):
```bash
IFS=$'\n'  # 设置为换行符
# ... 处理代码 ...
# 无需手动恢复，函数结束时自动恢复
```

**重要**: 智能匹配脚本中的相似度计算函数需要临时恢复 IFS：
```bash
string_similarity() {
  # 保存和恢复 IFS，避免影响 read -ra 分词
  local old_ifs="$IFS"
  IFS=$' \t\n'
  read -ra words1 <<< "$str1"
  IFS="$old_ifs"
}
```

### 错误处理策略

- **依赖检查**: 启动时验证 mkvmerge 是否存在
- **参数验证**: 检查目录/文件存在性，标准化路径
- **统计机制**: 使用临时文件传递 total/success/failed 计数（子进程间通信）
- **退出码**: 有失败文件时返回 1，全部成功返回 0

## 关键实现细节

### 语言代码规范
- 使用 ISO 639-1 / ISO 3166-1 标准（如 `zh-Hans`, `zh-TW`, `en-US`）
- 所有比较前转为小写：`${lang,,}`（大小写不敏感）
- 支持中文区域变体：`zh-CN`, `zh-HK`, `zh-MO`, `zh-TW`, `zh-SG`

### mkvmerge 参数规范
```bash
--sub-charset N:UTF-8                    # 字幕编码
--language N:lang_code                   # ISO 语言代码
--track-name N:"名称"                    # 轨道名称（支持中英双语）
--default-track-flag N:yes/no            # 默认轨道标记
--track-order 0:0,0:1,0:2...            # 轨道顺序控制
```

### 添加新语言支持
在 `lang_map` 关联数组中添加条目：
```bash
declare -A lang_map=(
  ["xx"]="Language Name"
  ["xx-YY"]="Language Name (Country)"
)
```

### 字幕优先级排序

**Python 版本 (mkmkv-smart)**：
- 内置智能优先级排序，无需手动配置
- 自动顺序：
  1. **简体中文** (优先级 0)：`zh-hans`, `zh-cn`, `zh`, `chs`, `chi`, `zho`, `sc`, `cn`
  2. **繁体中文** (优先级 1)：`zh-hant`, `zh-tw`, `zh-hk`, `zh-mo`, `cht`, `tc`, `tw`, `hk`
  3. **英文** (优先级 2)：`en`, `en-us`, `en-gb`, `en-au`, `en-ca`, `eng`
  4. **其他语言** (优先级 999)：按原顺序排列
- 实现位置：`cli.py:_get_language_priority()`
- 大小写不敏感

**Bash 版本 (mkmkv.sh)**：
编辑 `mkmkv.sh` 或 `mkmkv_smart.sh` 中的 `preset_lang_codes` 数组：
```bash
preset_lang_codes=(zh zh-hans en ...)  # 从左到右优先级递减
```

### 调整智能匹配阈值

在 `mkmkv_smart.sh` 中修改相似度阈值（第 231 行）：
```bash
# 相似度阈值：30%
if [ "$similarity" -ge 30 ]; then
```

**阈值建议**:
- `50`: 严格匹配，适合文件名规范的场景
- `30`: 平衡模式（默认），处理部分匹配
- `20`: 宽松匹配，命名差异大但可能误匹配

### 调试智能匹配

如果匹配结果不符合预期：

1. **使用干运行模式查看相似度**:
   ```bash
   ./mkmkv_smart.sh --dry-run /path/to/videos
   ```
   查看输出中的 "相似度: XX%" 数值

2. **手动测试规范化结果**:
   ```bash
   # 在脚本中添加调试输出
   echo "规范化: $video_normalized"
   ```

3. **检查语言代码映射**:
   确保字幕文件的语言代码在 `lang_map` 中存在

4. **常见问题**:
   - 所有相似度都是 0%: 检查 IFS 设置
   - 未找到匹配: 降低阈值或检查文件名格式
   - 误匹配: 提高阈值

## 代码风格约定

- **Shebang**: 统一使用 `#!/usr/bin/env bash`
- **注释语言**: 中文，描述意图而非实现
- **变量命名**: 小写 + 下划线（`source_dir`, `lang_valid`）
- **缩进**: 2 空格
- **引号**: 变量和路径必须双引号（防止空格问题）
- **命令续行**: 使用反斜杠 `\`

## 安全注意事项

1. **参数过滤** (mkmkv.sh:393): 检查第三方参数，拒绝 `;`, `` ` ``, `$`, `|`, `&`, `>`, `\`
2. **路径标准化**: 使用 `$(cd "$dir" && pwd)` 获取绝对路径
3. **数组执行**: 优先使用 `"${array[@]}"` 而非字符串拼接
4. **临时文件**: 修改字幕前创建临时副本，成功后才覆盖原文件

## 依赖要求

**必需**:
- `mkvmerge` (mkvtoolnix): 媒体封装工具
  - macOS: `brew install mkvtoolnix`
  - Linux: `apt install mkvtoolnix` 或 `yum install mkvtoolnix`
- `bash`: 4.0+ (推荐 5.2+)

**可选**:
- `shellcheck`: Bash 静态分析工具（开发时推荐）
- `sed`: 文本处理（字幕标签清理）

## 推荐工作流

### 日常使用（杂乱命名）

```bash
# 1. 下载视频和字幕到同一目录
cd ~/Downloads/Movies

# 2. 预览匹配结果
mkmkv-smart --dry-run .

# 3. 检查输出中的相似度，确认匹配正确

# 4. 执行合并
mkmkv-smart . ~/Movies/Processed

# 5. 清理原始文件
rm *.mp4 *.srt
```

### 批量处理（规范命名）

```bash
# 如果文件名已经规范（如通过自动化工具下载）
mkmkv-smart ~/Downloads ~/Movies
```

### 自定义字幕顺序

```bash
# 需要固定的字幕顺序时
mkmkv-smart --track-order 0:0,0:1,1:0,2:0 ~/Downloads ~/Movies
```

## 故障排除

### 问题：智能匹配找不到字幕

**可能原因**:
1. 相似度低于阈值（30%）
2. 语言代码不在映射表中
3. 字幕文件名不符合语言代码格式

**解决方案**:
```bash
# 1. 使用干运行查看详情
./mkmkv_smart.sh --dry-run /path

# 2. 检查字幕文件名格式
# 正确: Movie.zh-Hans.srt
# 错误: Movie.chs.srt (chs 不是标准代码)

# 3. 降低阈值或手动重命名字幕文件
```

### 问题：相似度计算不准确

**可能原因**: 文件名包含过多无关信息

**解决方案**:
```bash
# 调整 normalize_filename 函数中的 sed 规则
# 添加更多需要过滤的标签
```

### 问题：误匹配到错误的字幕

**可能原因**: 阈值太低或多个文件相似度相同

**解决方案**:
```bash
# 提高阈值到 40% 或 50%
# 或使用精确匹配脚本 mkmkv.sh
```
