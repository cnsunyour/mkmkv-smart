# 🎯 嵌入字幕自动检测和保留功能

## 功能说明

合并外部字幕时，可以选择保留视频中的嵌入字幕，并自动检测未标记语言的嵌入字幕，将其语言代码和轨道名称设置为对应语言的原生名称。

**核心特性**:
- ✅ **保留嵌入字幕**: 合并外部字幕时不删除原有字幕
- ✅ **自动语言检测**: 检测语言代码为 'und' 或无轨道名称的嵌入字幕
- ✅ **原生名称设置**: 使用语言的原生名称（如 "日本語" 而非 "日语"）
- ✅ **仅处理 MKV**: 仅支持 MKV 格式视频文件

## 使用方法

### 基本用法

```bash
# 合并外部字幕时保留嵌入字幕
mkmkv-smart --keep-embedded-subtitles ~/Videos ~/Output

# 结合自动语言检测（默认启用）
mkmkv-smart --keep-embedded-subtitles ~/Videos ~/Output

# 干运行预览
mkmkv-smart --keep-embedded-subtitles --dry-run ~/Videos
```

### 参数说明

| 参数 | 说明 | 必需 |
|------|------|------|
| `--keep-embedded-subtitles` | 保留嵌入字幕并自动检测未标记语言 | ✅ |
| `--dry-run` | 干运行模式，预览操作 | ❌ |

注：语言检测通过配置文件 `language_detection.enabled` 控制，默认启用。

## 工作流程

### 1. 检测嵌入字幕

系统自动执行：
1. 扫描 MKV 视频文件中的字幕轨道
2. 识别语言代码为 'und' 或没有轨道名称的字幕
3. 提取字幕内容到临时文件

### 2. 语言识别

对于未标记语言的字幕：
1. 使用 langdetect 库分析字幕文本
2. 获取语言代码（如 'ja', 'en', 'zh'）
3. 转换为 ISO 639-2 格式（如 'jpn', 'eng', 'chi'），或直接传递 ISO 639-3（如 'fil', 'ast'）
4. 获取语言的原生名称（如 '日本語', 'English', '中文', 'Filipino'）

### 3. 设置元数据

自动更新字幕轨道：
- **语言代码**: 优先 ISO 639-2 格式（如 jpn），无法映射时使用 ISO 639-3（如 fil）
- **轨道名称**: 语言原生名称（如 "日本語", "Filipino"）

## 输出示例

### 实际执行

```
智能匹配模式
源目录: /Users/user/Videos
找到 2 个视频文件
找到 4 个字幕文件

匹配结果:
══════════════════════════════════════════════════════════════════

视频: movie.mkv
  规范化: movie
┏━━━━━━━━━━━┳━━━━━━━━━━━━━━━━━━┳━━━━━━━━┓
┃ 语言      ┃ 字幕文件         ┃ 相似度 ┃
┡━━━━━━━━━━━╇━━━━━━━━━━━━━━━━━━╇━━━━━━━━┩
│ zh-hans   │ movie.zh-Hans.srt│  100.0%│
│ en        │ movie.en.srt     │  100.0%│
└───────────┴──────────────────┴────────┘

══════════════════════════════════════════════════════════════════
总计: 2 个文件
可处理: 2 个文件

开始合并...

检测嵌入字幕语言...

检测: movie.mkv
  字幕轨道 0: ja (置信度: 98.5%)
  ✓ 已设置语言: jpn (日本語)
  字幕轨道 1: ko (置信度: 96.3%)
  ✓ 已设置语言: kor (한국어)

[1/2] 处理: movie.mkv
  ✓ 成功

══════════════════════════════════════════════════════════════════
处理完成:
成功: 2 个文件
```

### 干运行模式

```
智能匹配模式
[ 干运行 - 不会实际执行 ]
源目录: /Users/user/Videos
...

这是干运行模式，未实际执行任何操作

[ 嵌入字幕检测预览 ]
将保留并检测视频中的嵌入字幕语言
```

## 技术细节

### 支持的字幕格式

嵌入字幕格式（MKV 容器内）：
- **SubRip (SRT)** - 文本字幕
- **SubStationAlpha (SSA/ASS)** - 文本字幕
- **WebVTT (VTT)** - 文本字幕

**注意**：图形字幕格式（如 VobSub/SUB/IDX、PGS 蓝光字幕）不支持语言检测，因为这些格式是图像而非文本。

### 检测条件

仅检测满足以下条件之一的嵌入字幕：
1. 语言代码为 'und' (undefined)
2. 没有轨道名称（空字符串）

已正确标记语言的字幕不会被重复检测。

### 语言代码转换

| 检测代码 | 输出代码 | 格式 | 轨道名称 |
|----------|---------|------|---------|
| ja       | jpn     | ISO 639-2 | 日本語   |
| en       | eng     | ISO 639-2 | English |
| zh       | chi     | ISO 639-2 | 中文     |
| yue      | chi     | ISO 639-2 (方言映射) | 粵語     |
| ko       | kor     | ISO 639-2 | 한국어   |
| fr       | fre     | ISO 639-2 | Français|
| de       | ger     | ISO 639-2 | Deutsch |
| es       | spa     | ISO 639-2 | Español |
| ru       | rus     | ISO 639-2 | Русский |
| fil      | fil     | ISO 639-3 (直接传递) | Filipino |

### 字幕提取

使用 `mkvextract` 工具提取字幕内容：
```bash
mkvextract tracks video.mkv 2:subtitle.srt
```

### 元数据修改

使用 `mkvpropedit` 修改字幕轨道元数据：
```bash
mkvpropedit video.mkv \
  --edit track:s1 \
  --set language=jpn \
  --set name="日本語"
```

## 最佳实践

### 1. 推荐工作流

```bash
# 第一步：干运行预览
mkmkv-smart --keep-embedded-subtitles --dry-run ~/Downloads

# 第二步：执行合并
mkmkv-smart --keep-embedded-subtitles ~/Downloads ~/Movies
```

### 2. 配合语言检测

```bash
# 自动检测外部字幕和嵌入字幕的语言（默认启用）
mkmkv-smart --keep-embedded-subtitles ~/Downloads ~/Movies
```

### 3. 仅处理嵌入字幕

如果只想检测和设置嵌入字幕语言，不合并外部字幕：
```python
from mkmkv_smart.audio_editor import AudioTrackEditor
from mkmkv_smart.language_detector import LanguageDetector

editor = AudioTrackEditor()
detector = LanguageDetector()

results = editor.detect_and_set_embedded_subtitle_languages(
    '/path/to/video.mkv',
    language_detector=detector,
    dry_run=False
)

for idx, info in results.items():
    print(f"字幕 {idx}: {info['language_code']} ({info['track_name']})")
```

## 限制说明

### 格式限制

**仅支持 MKV 格式**:
- ✅ MKV 文件：完整支持
- ❌ MP4 文件：不支持嵌入字幕检测
- ❌ AVI 文件：不支持嵌入字幕检测

### 依赖要求

**必需工具**:
- `mkvtoolnix`: 包含 mkvmerge, mkvextract, mkvpropedit
- `langdetect`: Python 语言检测库（默认启用，可通过配置禁用）

```bash
# macOS
brew install mkvtoolnix

# Ubuntu/Debian
sudo apt install mkvtoolnix

# Python 依赖
pip install mkmkv-smart  # 包含 langdetect
```

### 性能考虑

**处理速度**:
- 提取字幕：快速（几秒内完成）
- 语言检测：< 1 秒每个字幕
- 元数据修改：快速（不重新编码）

**临时文件**:
- 自动创建临时文件用于字幕提取
- 检测完成后自动清理
- 不占用永久存储空间

## 故障排除

### 问题 1: mkvextract 未找到

**错误信息**:
```
警告: 嵌入字幕检测失败: mkvextract not found
```

**解决方案**:
```bash
# macOS
brew install mkvtoolnix

# Ubuntu/Debian
sudo apt install mkvtoolnix

# 验证安装
which mkvextract
```

### 问题 2: 语言检测失败

**症状**: 显示 "所有嵌入字幕均已标记语言"，但实际有未标记的字幕

**可能原因**:
1. langdetect 未安装
2. 字幕内容太少（< 10 个字符）
3. 字幕格式不支持文本提取（如图形字幕 PGS）

**解决方案**:
```bash
# 安装 langdetect
pip install langdetect

# 检查字幕轨道信息
mkvinfo video.mkv | grep -A 5 "Track type: subtitles"

# 手动提取字幕测试
mkvextract tracks video.mkv 2:test.srt
cat test.srt
```

### 问题 3: 检测到错误的语言

**症状**: 字幕被识别为错误的语言

**可能原因**:
1. 字幕内容太少，样本不足
2. 多语言混杂
3. 特殊字符或标记干扰

**解决方案**:
```bash
# 手动验证字幕内容
mkvextract tracks video.mkv 2:subtitle.srt
head -50 subtitle.srt

# 如果确认语言，手动设置
mkvpropedit video.mkv \
  --edit track:s1 \
  --set language=jpn \
  --set name="日本語"
```

### 问题 4: 非 MKV 文件被跳过

**症状**: MP4/AVI 文件没有检测嵌入字幕

**原因**: 此功能仅支持 MKV 格式

**解决方案**: 先转换为 MKV 格式
```bash
# 使用 mkvmerge 转换
mkvmerge -o output.mkv input.mp4

# 然后再处理
mkmkv-smart --keep-embedded-subtitles output.mkv ~/Output
```

## API 参考

### AudioTrackEditor 类

#### get_subtitle_tracks_info()

获取视频文件的字幕轨道信息。

```python
def get_subtitle_tracks_info(self, video_file: str) -> list:
    """
    Returns:
        字幕轨道信息列表，每个字典包含:
        - track_id: 轨道 ID
        - codec: 编码格式
        - language: 语言代码
        - track_name: 轨道名称
    """
```

#### extract_subtitle_content()

提取字幕内容到文件。

```python
def extract_subtitle_content(
    self,
    video_file: str,
    track_id: int,
    output_file: Optional[str] = None
) -> Optional[str]:
    """
    Returns:
        字幕文件路径，失败返回 None
    """
```

#### detect_and_set_embedded_subtitle_languages()

检测并设置嵌入字幕的语言。

```python
def detect_and_set_embedded_subtitle_languages(
    self,
    video_file: str,
    language_detector=None,
    dry_run: bool = False
) -> Dict[int, Dict[str, str]]:
    """
    Returns:
        字典，键为轨道索引，值包含:
        - language_code: ISO 639-2 代码（优先），或 ISO 639-3 代码（直接传递）
        - track_name: 原生名称
        - detected_code: 检测到的原始代码
        - confidence: 置信度
    """
```

#### set_subtitle_track_language()

设置单个字幕轨道的语言信息。

```python
def set_subtitle_track_language(
    self,
    video_file: str,
    track_index: int,
    language_code: str,
    track_name: Optional[str] = None
) -> bool:
    """
    Returns:
        True 如果成功
    """
```

### MKVMerger 类

#### merge()

合并视频和字幕，支持保留嵌入字幕。

```python
def merge(
    self,
    video_file: str,
    subtitle_tracks: List[SubtitleTrack],
    output_file: str,
    dry_run: bool = False,
    keep_embedded_subtitles: bool = False,
    extra_args: Optional[List[str]] = None
) -> bool:
    """
    Args:
        keep_embedded_subtitles: 是否保留嵌入字幕
    """
```

---

*文档版本: 1.2.0*
*最后更新: 2025-12-26*
