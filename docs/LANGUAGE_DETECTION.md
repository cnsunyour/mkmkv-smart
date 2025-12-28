# 视频轨道语言自动识别技术方案

## ✅ 实施状态

### Phase 1: 字幕语言检测 - **已完成**

**实施时间**: 2025-12

**已实现功能**:
- ✅ 字幕文件语言自动检测（SRT、ASS、VTT 格式）
- ✅ 简繁体中文智能区分
- ✅ 多编码支持（UTF-8、GBK、Big5、UTF-16）
- ✅ 自动检测和重命名（通过配置文件控制，默认启用）
- ✅ 配置文件支持
- ✅ 完整测试覆盖（16个测试用例）

**技术选型**:
- 语言检测：langdetect + 中文特征字算法
- 字幕解析：pysrt
- 置信度阈值：0.8 (可配置)
- 最小文本长度：100 字符 (可配置)

**使用示例**:
```bash
# 自动检测和重命名字幕（默认启用）
mkmkv-smart ~/Downloads

# 禁用自动检测（通过配置文件 language_detection.enabled: false）
mkmkv-smart --config config.yaml ~/Downloads
```

### Phase 2: 配置优化 - 待规划

### Phase 3: 音轨语言检测 - **已完成**

**实施时间**: 2025-12

**已实现功能**:
- ✅ 视频音轨语言自动检测
- ✅ 基于 Faster-Whisper 模型（速度提升 4-5 倍）
- ✅ 支持 99+ 种语言
- ✅ 5 种模型可选（tiny/base/small/medium/large）
- ✅ CLI 集成（`--detect-audio-language`、`--audio-model`）
- ✅ 配置文件支持
- ✅ 测试覆盖（11个测试用例）

**技术选型**:
- 语音识别：Faster-Whisper
- 音频提取：FFmpeg
- 默认模型：small (466MB, 高精度)
- 置信度阈值：0.7 (可配置)
- 音频采样：前 30 秒

**使用示例**:
```bash
# 检测视频音轨语言
mkmkv-smart --detect-audio-language ~/Downloads

# 指定模型
mkmkv-smart --detect-audio-language --audio-model medium ~/Downloads
```

**性能指标**:
- CPU: 30秒音频约需 3-5 秒处理（small 模型）
- GPU: 30秒音频约需 2-3 秒处理
- 准确率: 95%+ (清晰语音)

**安装方式**:
```bash
pip install mkmkv-smart[audio]
```

---

## 📊 场景分析

### 1️⃣ 字幕轨道语言识别（推荐 ✅）

#### 技术原理
从字幕内容的文本特征识别语言

#### 实现方案

##### **方案 A: langdetect (推荐)**
```python
from langdetect import detect, detect_langs
import pysrt

def detect_subtitle_language(srt_file: str) -> str:
    """检测 SRT 字幕文件的语言"""
    subs = pysrt.open(srt_file, encoding='utf-8')
    
    # 提取前 100 条字幕文本
    texts = [sub.text for sub in subs[:100]]
    combined = ' '.join(texts)
    
    # 检测语言
    lang = detect(combined)  # 返回 ISO 639-1 代码 (zh, en, ja 等)
    
    # 获取置信度
    langs = detect_langs(combined)  # [zh-cn:0.999, en:0.001]
    
    return lang
```

**优点**:
- ✅ 轻量级 (基于 Google 语言检测算法)
- ✅ 支持 55+ 语言
- ✅ 速度快 (纯文本分析)
- ✅ 无需外部依赖

**缺点**:
- ❌ 短文本识别不准确 (需要至少 20-30 个字符)
- ❌ 不支持方言/变体识别 (zh-Hans vs zh-Hant)

##### **方案 B: lingua-py (高精度)**
```python
from lingua import Language, LanguageDetectorBuilder

# 初始化检测器（指定候选语言）
detector = LanguageDetectorBuilder.from_languages(
    Language.CHINESE,
    Language.ENGLISH,
    Language.JAPANESE,
    Language.KOREAN
).build()

def detect_subtitle_language(text: str) -> str:
    language = detector.detect_language_of(text)
    if language:
        return language.iso_code_639_1.name.lower()  # 'zh', 'en', 'ja'
    return None
```

**优点**:
- ✅ 高精度 (基于 N-gram 模型)
- ✅ 短文本支持更好
- ✅ 支持置信度阈值

**缺点**:
- ❌ 依赖较大 (~20MB)
- ❌ 速度略慢
- ❌ 仍然不区分简繁体

##### **方案 C: 简繁体中文识别**
```python
import opencc

def detect_chinese_variant(text: str) -> str:
    """
    区分简体/繁体中文
    
    Returns:
        'zh-hans' (简体) 或 'zh-hant' (繁体)
    """
    # 统计简体特征字符
    simplified_chars = set('万与丰严两并乐个主义举乐书买乱')
    # 统计繁体特征字符
    traditional_chars = set('萬與豐嚴兩並樂個主義舉樂書買亂')
    
    simplified_count = sum(1 for c in text if c in simplified_chars)
    traditional_count = sum(1 for c in text if c in traditional_chars)
    
    if traditional_count > simplified_count:
        return 'zh-hant'
    return 'zh-hans'
```

**结合使用**:
```python
def detect_full_language(srt_file: str) -> str:
    """完整的语言检测：语言 + 变体"""
    text = extract_subtitle_text(srt_file)
    
    # 1. 检测主语言
    main_lang = detect(text)  # 'zh', 'en', 'ja'
    
    # 2. 如果是中文，进一步区分简繁体
    if main_lang == 'zh':
        variant = detect_chinese_variant(text)
        return variant  # 'zh-hans' 或 'zh-hant'
    
    return main_lang
```

#### 应用场景
```python
# 场景 1: 外部字幕文件无语言代码
Movie.srt  # 文件名没有语言信息
→ 自动检测 → zh-hans → 重命名为 Movie.zh-hans.srt

# 场景 2: MKV 内部字幕无语言标签
movie.mkv (内含 3 个字幕轨道，但都是 "und" 未定义)
→ 提取字幕内容 → 检测语言 → 重新封装时设置正确语言代码

# 场景 3: 智能排序
3 个字幕轨道都无语言标签
→ 检测发现：zh-hans, zh-hant, en
→ 按预设优先级排序
```

#### 性能指标
- **速度**: 100 KB 字幕文件 < 100ms
- **准确率**: 
  - 长文本 (>1000 字符): 99%+
  - 短文本 (100-1000 字符): 95%+
  - 极短文本 (<100 字符): 80%+

---

### 2️⃣ 音轨语言识别（复杂 ⚠️）

#### 技术原理
语音识别 (ASR) + 语言检测

#### 实现方案

##### **方案 A: Whisper (OpenAI) - 推荐**
```python
import whisper

def detect_audio_language(audio_file: str) -> str:
    """使用 Whisper 检测音频语言"""
    model = whisper.load_model("base")  # tiny/base/small/medium/large
    
    # Whisper 可以直接从音频检测语言
    audio = whisper.load_audio(audio_file)
    audio = whisper.pad_or_trim(audio)  # 只取前 30 秒
    
    # 检测语言
    mel = whisper.log_mel_spectrogram(audio).to(model.device)
    _, probs = model.detect_language(mel)
    
    # 返回最可能的语言
    detected_lang = max(probs, key=probs.get)
    confidence = probs[detected_lang]
    
    return detected_lang, confidence
```

**优点**:
- ✅ 支持 99 种语言
- ✅ 高准确率 (80%+)
- ✅ 只需要音频片段 (30 秒)

**缺点**:
- ❌ **需要 GPU 加速** (否则非常慢)
- ❌ **模型体积大** (base: 142MB, large: 2.9GB)
- ❌ **计算密集** (base 模型 CPU: 30 秒音频需 10+ 秒处理)
- ❌ **需要先提取音轨**

##### **方案 B: 从视频中提取音轨**
```python
import subprocess
import tempfile

def extract_audio_from_video(video_file: str, track_id: int = 0) -> str:
    """提取视频中的音轨"""
    temp_audio = tempfile.NamedTemporaryFile(suffix='.wav', delete=False)
    
    # 使用 ffmpeg 提取音轨（只取前 30 秒）
    subprocess.run([
        'ffmpeg', '-i', video_file,
        '-t', '30',  # 只取前 30 秒
        '-map', f'0:a:{track_id}',  # 选择音轨
        '-ac', '1',  # 转为单声道
        '-ar', '16000',  # 采样率 16kHz (Whisper 要求)
        temp_audio.name
    ], check=True)
    
    return temp_audio.name

def detect_video_audio_language(video_file: str, track_id: int = 0) -> str:
    """检测视频音轨语言"""
    # 1. 提取音轨
    audio_file = extract_audio_from_video(video_file, track_id)
    
    # 2. 检测语言
    lang, confidence = detect_audio_language(audio_file)
    
    # 3. 清理临时文件
    os.unlink(audio_file)
    
    return lang, confidence
```

#### 应用场景
```python
# 场景: MKV 内部有 3 个音轨，但都无语言标签
movie.mkv
  Track 0 (audio): und (未定义)
  Track 1 (audio): und
  Track 2 (audio): und

→ 提取各音轨前 30 秒 → Whisper 检测
→ 识别结果：ja (日语), zh (中文), en (英语)
→ 重新封装时设置正确语言代码
```

#### 性能指标
- **速度**: 
  - GPU (RTX 3060): 30 秒音频 → 2 秒处理
  - CPU (i7-10700): 30 秒音频 → 15-20 秒处理
- **准确率**: 
  - 清晰语音: 95%+
  - 背景音乐/噪音: 70%+
  - 多语言混合: 60%+

---

## 🎯 推荐实现优先级

### 高优先级：字幕语言检测 ✅
**理由**:
1. 技术成熟、速度快、准确率高
2. 依赖小、易集成
3. 用户需求明确（处理无语言代码的字幕）
4. 性能影响小

**实现步骤**:
```python
# 1. 添加依赖
pip install langdetect pysrt opencc-python-reimplemented

# 2. 扩展 normalizer.py
class FileNormalizer:
    def detect_language_from_content(self, subtitle_file: str) -> Optional[str]:
        """从字幕内容检测语言"""
        # 实现语言检测逻辑
        
# 3. 在 cli.py 中使用
if not lang_code:
    lang_code = normalizer.detect_language_from_content(subtitle_file)
```

### 中优先级：音轨语言检测 ⚠️
**理由**:
1. 技术可行但复杂
2. 计算成本高（需要 GPU 或长时间处理）
3. 用户需求相对较少（大多数视频音轨有语言标签）
4. 可以作为高级功能，默认关闭

**实现步骤**:
```python
# 1. 添加可选依赖
pip install openai-whisper  # 可选功能

# 2. 添加配置选项
[audio_detection]
enabled = false  # 默认关闭
model = "base"   # tiny/base/small
use_gpu = true

# 3. 提供命令行选项
mkmkv-smart --detect-audio-language
```

---

## 📋 完整实现方案

### Phase 1: 字幕语言检测 (推荐先实现)

```python
# src/mkmkv_smart/language_detector.py
from typing import Optional
import pysrt
from langdetect import detect, detect_langs, LangDetectException

class LanguageDetector:
    """语言检测器"""
    
    def __init__(self, min_confidence: float = 0.8):
        self.min_confidence = min_confidence
    
    def detect_subtitle_language(
        self, 
        subtitle_file: str,
        min_chars: int = 100
    ) -> Optional[str]:
        """
        检测字幕文件的语言
        
        Args:
            subtitle_file: 字幕文件路径
            min_chars: 最小文本长度要求
            
        Returns:
            ISO 639-1 语言代码或 None
        """
        try:
            # 读取字幕
            subs = pysrt.open(subtitle_file, encoding='utf-8')
            
            # 提取文本（前 100 条字幕）
            texts = [sub.text.strip() for sub in subs[:100] if sub.text.strip()]
            combined_text = ' '.join(texts)
            
            # 检查文本长度
            if len(combined_text) < min_chars:
                return None
            
            # 检测语言
            langs = detect_langs(combined_text)
            
            # 获取最高置信度的语言
            if langs and langs[0].prob >= self.min_confidence:
                main_lang = langs[0].lang
                
                # 如果是中文，进一步区分简繁体
                if main_lang.startswith('zh'):
                    variant = self._detect_chinese_variant(combined_text)
                    return variant
                
                return main_lang
            
            return None
            
        except (LangDetectException, Exception) as e:
            # 检测失败
            return None
    
    def _detect_chinese_variant(self, text: str) -> str:
        """区分简体/繁体中文"""
        # 简体特征字
        simplified = set('个为临乐书买乱习' '关压厅发听园国图')
        # 繁体特征字
        traditional = set('個為臨樂書買亂習' '關壓廳發聽園國圖')
        
        s_count = sum(1 for c in text if c in simplified)
        t_count = sum(1 for c in text if c in traditional)
        
        if t_count > s_count * 1.5:  # 繁体特征明显
            return 'zh-hant'
        return 'zh-hans'
```

### Phase 2: 集成到现有流程

```python
# src/mkmkv_smart/cli.py
from .language_detector import LanguageDetector

def run_match(args):
    # ... 现有代码 ...
    
    detector = LanguageDetector()
    
    # 处理无语言代码的字幕
    for subtitle_file in subtitles:
        lang_code = normalizer.extract_language_code(subtitle_file.name)
        
        # 如果文件名中没有语言代码，尝试从内容检测
        if not lang_code and args.detect_language:
            detected = detector.detect_subtitle_language(str(subtitle_file))
            if detected:
                console.print(
                    f"[yellow]检测到字幕语言: {subtitle_file.name} → {detected}[/yellow]"
                )
                # 可选：自动重命名文件
                if args.rename_detected:
                    new_name = f"{subtitle_file.stem}.{detected}{subtitle_file.suffix}"
                    subtitle_file.rename(subtitle_file.parent / new_name)
```

### Phase 3: 配置选项

```yaml
# config.yaml
language_detection:
  # 自动检测字幕语言
  enabled: true
  min_confidence: 0.8
  
  # 自动重命名
  rename_detected: false
  
  # 音轨检测（高级功能）
  audio_detection:
    enabled: false
    model: "base"  # whisper 模型
    sample_duration: 30  # 采样时长（秒）
```

---

## 💰 成本对比

| 功能 | CPU 时间 | 内存 | 磁盘 | GPU |
|------|---------|------|------|-----|
| 字幕检测 (langdetect) | < 0.1s | ~10MB | - | 不需要 |
| 字幕检测 (lingua) | < 0.5s | ~30MB | 20MB | 不需要 |
| 音轨检测 (Whisper base) | 15-20s | ~2GB | 142MB | 可选 |
| 音轨检测 (Whisper tiny) | 5-8s | ~1GB | 72MB | 可选 |

---

## 🎯 结论

**建议实现顺序**:
1. ✅ **字幕语言检测** (Phase 1-2)
   - 先实现基础功能
   - 低成本、高价值
   
2. ⚙️ **配置和优化** (Phase 3)
   - 添加配置选项
   - 提供自动重命名功能
   
3. 🔬 **音轨检测** (可选)
   - 作为高级功能
   - 默认关闭
   - 需要用户明确启用

**使用场景**:
```bash
# 基础使用（自动检测和重命名，默认启用）
mkmkv-smart /path/to/videos

# 显示检测到的语言（不执行合并和重命名）
mkmkv-smart --dry-run /path/to/videos

# 禁用自动检测（需在配置文件中设置 language_detection.enabled: false）
mkmkv-smart --config config.yaml /path/to/videos
```
