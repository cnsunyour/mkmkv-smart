# 🎯 音轨语言自动设置功能

## 功能说明

自动检测视频的音轨语言，并将语言信息写入文件元数据。

**支持格式**:
- ✅ **MKV 文件**: 直接修改元数据，不重新编码
- ✅ **其他格式** (MP4, AVI 等): 自动转换为 MKV 并设置语言信息

## 使用方法

### 基本用法

```bash
# 检测并设置音轨语言
mkmkv-smart --detect-audio-language --set-audio-language ~/Videos

# 干运行（预览结果，不实际修改）
mkmkv-smart --detect-audio-language --set-audio-language --dry-run ~/Videos
```

### 参数说明

| 参数 | 说明 | 必需 |
|------|------|------|
| `--detect-audio-language` | 启用音频语言检测 | ✅ |
| `--set-audio-language` | 自动设置检测到的语言信息 | ✅ |
| `--audio-model` | 指定模型（tiny/base/small/medium/large）| ❌ |
| `--dry-run` | 干运行模式，不实际修改文件 | ❌ |

## 输出示例

### 干运行模式
```
音频语言检测模式
✓ 将自动设置检测到的音轨语言信息
使用模型: small

检测: movie.mkv
  音轨 0: ja (置信度: 98.75%)
  → 将设置音轨语言: jpn (日本語)
```

### 实际执行
```
音频语言检测模式
✓ 将自动设置检测到的音轨语言信息
使用模型: small

检测: movie.mkv
  音轨 0: ja (置信度: 98.75%)
  ✓ 已设置音轨语言: jpn (日本語)

检测: video.mp4
  音轨 0: en (置信度: 96.32%)
  → 转换为 MKV 格式...
  ✓ 已转换并设置音轨语言: eng (English)
  输出文件: video.mkv

成功检测 2 个视频的音轨语言
已设置 2 个视频的音轨语言信息
```

## 技术细节

### 语言代码转换

Whisper 返回 ISO 639-1 (2字母)，自动转换为 ISO 639-2 (3字母)。对于无法映射的语言，直接传递 ISO 639-3 代码：

| 检测结果 | 设置代码 | 格式 | 轨道名称 |
|----------|----------|------|----------|
| ja | jpn | ISO 639-2 | 日本語 |
| en | eng | ISO 639-2 | English |
| zh | chi | ISO 639-2 | 中文 |
| yue | chi | ISO 639-2 (方言映射) | 粵語 |
| ko | kor | ISO 639-2 | 한국어 |
| fr | fre | ISO 639-2 | Français |
| de | ger | ISO 639-2 | Deutsch |
| fil | fil | ISO 639-3 (直接传递) | Filipino |
| ast | ast | ISO 639-3 (直接传递) | Asturian |
| es | spa | Español |
| ru | rus | Русский |

**中文方言支持**:
- **粤语** (yue): 自动识别并设置为 "粵語"
- **吴语** (wuu): 自动识别并设置为 "吳語"
- **闽南语** (nan): 自动识别并设置为 "閩南語"

**注意**: Whisper 模型可能将粤语识别为 "zh" (普通话)。如需准确识别粤语，建议使用专门训练的粤语模型或手动指定。

### 设置内容

修改 MKV 文件的以下元数据：

1. **语言代码** (Language): 优先使用 ISO 639-2 格式（如 jpn, eng, chi），对于无法映射的语言使用 ISO 639-3（如 fil, ast）
2. **轨道名称** (Name): 语言原生名称（如 "日本語", "Filipino"）
3. **IETF 标签** (Language IETF BCP 47): 自动设置（如 zh → zh-Hans, en → en-US）
   - 中文自动映射为 zh-Hans（简体）
   - 英文自动映射为 en-US（美式）
   - 日文自动映射为 ja-JP
   - 韩文自动映射为 ko-KR
   - 已有区域标签的代码保持不变并规范化大小写（如 en-gb → en-GB，zh-hans → zh-Hans）

### 验证结果

使用 `mkvinfo` 查看设置结果：

```bash
mkvinfo movie.mkv | grep -A 10 "Track type: audio"
```

输出示例：
```
|  + Track type: audio
|  + Language: jpn
|  + Name: 日本語
|  + Language (IETF BCP 47): ja-JP
```

## 限制说明

### 格式处理

**MKV 文件**:
- ✅ 直接修改元数据
- ✅ 不重新编码，速度快
- ✅ 原文件被修改

**非 MKV 文件** (MP4, AVI, MOV 等):
- ✅ 自动转换为 MKV 格式
- ✅ 转换时设置语言信息
- ✅ 生成新的 .mkv 文件
- ℹ️ 原文件保留不变
- ⚠️ 需要额外存储空间

### 依赖要求

- `mkvtoolnix`: 必须安装（包含 mkvpropedit 工具）
  ```bash
  # macOS
  brew install mkvtoolnix

  # Ubuntu/Debian
  sudo apt install mkvtoolnix
  ```

## 最佳实践

### 1. 批量处理视频

```bash
# 处理整个目录（MKV 和非 MKV 混合）
mkmkv-smart --detect-audio-language --set-audio-language ~/Downloads/Movies

# 非 MKV 文件会自动转换为 MKV 格式
# 输出: video.mp4 → video.mkv (带语言信息)

# 使用更大的模型提高准确率
mkmkv-smart --detect-audio-language --set-audio-language \
    --audio-model medium ~/Downloads/Movies
```

### 2. 处理非 MKV 文件

```bash
# MP4/AVI 等格式会自动转换
mkmkv-smart --detect-audio-language --set-audio-language ~/Videos

# 转换后：
# movie.mp4 (原文件保留)
# movie.mkv (新生成，带语言信息)

# 如果确认转换成功，可以删除原文件
rm ~/Videos/*.mp4
```

### 3. 先预览再执行

```bash
# 第一步：干运行查看结果
mkmkv-smart --detect-audio-language --set-audio-language \
    --dry-run ~/Videos

# 第二步：确认无误后执行
mkmkv-smart --detect-audio-language --set-audio-language ~/Videos
```

### 4. 配合字幕合并

```bash
# 同时处理音轨语言和字幕合并
mkmkv-smart --detect-audio-language --set-audio-language ~/Videos ~/Output
```

## 故障排除

### 问题 1: mkvpropedit 未安装

**错误信息**:
```
警告: mkvpropedit 未安装或不在 PATH 中
将只显示检测结果，不修改文件
```

**解决方案**:
```bash
# macOS
brew install mkvtoolnix

# Ubuntu/Debian
sudo apt install mkvtoolnix
```

### 问题 2: 设置失败

**症状**: 显示 "⚠ 设置音轨语言失败"

**可能原因**:
1. 文件权限不足
2. 文件正在被其他程序使用
3. MKV 文件损坏

**解决方案**:
```bash
# 检查文件权限
ls -l movie.mkv

# 检查文件是否损坏
mkvinfo movie.mkv
```

### 问题 3: 转换失败

**症状**: 显示 "⚠ 转换失败"

**可能原因**:
1. mkvtoolnix 未安装
2. 磁盘空间不足
3. 文件权限问题
4. 视频文件损坏

**解决方案**:
```bash
# 检查 mkvmerge 是否安装
which mkvmerge

# 如果未安装
brew install mkvtoolnix  # macOS
sudo apt install mkvtoolnix  # Ubuntu/Debian

# 检查磁盘空间
df -h

# 检查文件权限
ls -l video.mp4

# 手动测试转换
mkvmerge -o output.mkv video.mp4
```

### 问题 4: 转换后文件过大

**症状**: 转换后的 MKV 文件比原文件大

**原因**: MKV 容器开销，但音视频流未重新编码

**解决方案**: 这是正常现象，文件大小差异通常小于 1%

---

*文档版本: 1.1.0*
*最后更新: 2025-12-26*
