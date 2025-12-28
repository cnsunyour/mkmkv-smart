# 音频语言检测故障排除指南

## 🔍 常见问题

### 问题 1: 全部检测失败 - "检测失败" 无具体错误

**症状**:
```bash
$ mkmkv-smart --detect-audio-language ~/Downloads/PT
音频语言检测模式
使用模型: small

检测: video1.mp4
  音轨 0: 检测失败

检测: video2.mp4
  音轨 0: 检测失败
```

**诊断步骤**:

#### 1. 检查 faster-whisper 是否安装

```bash
python -c "from faster_whisper import WhisperModel; print('✅ 已安装')"
```

如果显示 `ModuleNotFoundError`:
```bash
pip install mkmkv-smart[audio]
```

#### 2. 检查 Python 版本

```bash
python --version
```

- ✅ **支持**: Python 3.8 - 3.13
- ❌ **不支持**: Python 3.14+ (等待 ML 生态系统更新)

#### 3. 检查 FFmpeg 是否安装

```bash
which ffmpeg
ffmpeg -version
```

如果未安装:
```bash
# macOS
brew install ffmpeg

# Ubuntu/Debian
sudo apt install ffmpeg

# CentOS/RHEL
sudo yum install ffmpeg
```

#### 4. 检查网络代理问题 ⭐ 最常见

如果使用 **SOCKS 代理**（科学上网），会出现此错误：

```
ImportError: Using SOCKS proxy, but the 'socksio' package is not installed.
```

**解决方案**:
```bash
pip install 'httpx[socks]'
```

或者临时禁用代理:
```bash
unset http_proxy https_proxy all_proxy HTTP_PROXY HTTPS_PROXY ALL_PROXY
mkmkv-smart --detect-audio-language ~/Downloads/PT
```

---

### 问题 2: 部分视频检测失败

**症状**:
```bash
检测: video1.mp4
  音轨 0: ja (置信度: 95.14%)  ✅

检测: video2.mp4
  音轨 0: 检测失败  ❌

检测: video3.mp4
  音轨 0: ja (置信度: 82.63%)  ✅
```

**可能原因**:

#### 1. 置信度过低

模型检测到语言但置信度低于阈值（默认 0.7）。

**解决方案**: 降低置信度阈值

```python
from mkmkv_smart.audio_detector import AudioLanguageDetector

detector = AudioLanguageDetector(
    model_size='small',
    min_confidence=0.5  # 降低到 0.5
)
result = detector.detect_video_audio_language('video.mp4')
```

#### 2. 音频质量问题

- 背景音乐太响，覆盖对话
- 音量过低
- 噪音过多
- 前 30 秒没有语音内容

**解决方案**: 提取更长的音频

```python
detector = AudioLanguageDetector(model_size='small')
result = detector.detect_video_audio_language(
    'video.mp4',
    duration=60  # 提取 60 秒而不是默认的 30 秒
)
```

#### 3. 音轨编码问题

检查音轨是否正常:
```bash
ffprobe -v error -select_streams a:0 -show_entries stream=codec_name,channels,sample_rate -of default=noprint_wrappers=1 video.mp4
```

正常输出:
```
codec_name=aac
sample_rate=48000
channels=2
```

---

### 问题 3: 检测结果不准确

**症状**:
```bash
检测: japanese_video.mp4
  音轨 0: nn (置信度: 62.43%)  # 错误：检测为挪威语
```

**原因**: 使用的模型太小（tiny）

**解决方案**: 使用更大的模型

| 模型 | 大小 | 准确率 | CPU 速度 | 推荐场景 |
|------|------|--------|---------|----------|
| tiny | 39MB | ⭐⭐⭐ | 1-2 秒 | ❌ 不推荐（准确率低） |
| base | 142MB | ⭐⭐⭐⭐ | 2-3 秒 | 一般使用 |
| **small** | **466MB** | **⭐⭐⭐⭐⭐** | **3-5 秒** | **✅ 推荐** |
| medium | 1.5GB | ⭐⭐⭐⭐⭐ | 8-12 秒 | 高精度需求 |
| large | 2.9GB | ⭐⭐⭐⭐⭐ | 20-30 秒 | 最高精度 |

使用更好的模型:
```bash
mkmkv-smart --detect-audio-language --audio-model small ~/Downloads
```

---

### 问题 4: 首次使用下载模型失败

**症状**:
```
注意: 首次使用会自动下载模型，可能需要几分钟
ERROR: Failed to reach huggingface.co
```

**原因**: 网络连接问题或防火墙

**解决方案**:

#### 方案 1: 配置镜像源

```bash
# 设置 Hugging Face 镜像（国内用户）
export HF_ENDPOINT=https://hf-mirror.com
mkmkv-smart --detect-audio-language ~/Downloads
```

#### 方案 2: 手动下载模型

```bash
# 下载 small 模型
wget https://huggingface.co/Systran/faster-whisper-small/resolve/main/model.bin
wget https://huggingface.co/Systran/faster-whisper-small/resolve/main/config.json
wget https://huggingface.co/Systran/faster-whisper-small/resolve/main/vocabulary.txt

# 放置到缓存目录
mkdir -p ~/.cache/huggingface/hub/models--Systran--faster-whisper-small
mv model.bin config.json vocabulary.txt ~/.cache/huggingface/hub/models--Systran--faster-whisper-small/
```

#### 方案 3: 使用代理

```bash
# HTTP 代理
export http_proxy=http://127.0.0.1:7890
export https_proxy=http://127.0.0.1:7890

# SOCKS 代理（需要先安装 httpx[socks]）
pip install 'httpx[socks]'
export all_proxy=socks5://127.0.0.1:1080

mkmkv-smart --detect-audio-language ~/Downloads
```

---

### 问题 5: GPU 检测失败

**症状**:
```
RuntimeError: CUDA not available
```

**原因**: 未安装 GPU 版本的依赖

**解决方案**:

检查是否有 CUDA GPU:
```bash
nvidia-smi
```

安装 GPU 支持:
```bash
# 卸载 CPU 版本
pip uninstall onnxruntime

# 安装 GPU 版本
pip install onnxruntime-gpu

# 使用 GPU
python -c "
from mkmkv_smart.audio_detector import AudioLanguageDetector
detector = AudioLanguageDetector(
    model_size='small',
    device='cuda',
    compute_type='float16'
)
"
```

---

## 🧪 调试技巧

### 1. 启用详细日志

```python
import logging
logging.basicConfig(level=logging.DEBUG)

from mkmkv_smart.audio_detector import AudioLanguageDetector
detector = AudioLanguageDetector(model_size='tiny')
result = detector.detect_video_audio_language('video.mp4')
```

### 2. 分步测试

```python
from mkmkv_smart.audio_detector import AudioLanguageDetector
import os

detector = AudioLanguageDetector(model_size='small')
video = 'video.mp4'

# 步骤 1: 提取音频
print("=== 提取音频 ===")
audio_file = detector.extract_audio_track(video, duration=30)
if audio_file:
    print(f"✅ 音频文件: {audio_file}")
    print(f"   大小: {os.path.getsize(audio_file)} bytes")

    # 步骤 2: 检测语言
    print("\n=== 检测语言 ===")
    result = detector.detect_audio_language(audio_file)
    print(f"结果: {result}")

    # 清理
    os.unlink(audio_file)
else:
    print("❌ 音频提取失败")
```

### 3. 检查音频文件

手动检查提取的音频:
```bash
# 提取音频（不删除）
ffmpeg -i video.mp4 -t 30 -map 0:a:0 -ac 1 -ar 16000 test_audio.wav

# 播放检查
ffplay test_audio.wav

# 查看波形
ffmpeg -i test_audio.wav -filter_complex "showwavespic=s=640x120" -frames:v 1 waveform.png
open waveform.png
```

---

## 📚 参考配置

### 最佳实践配置

```yaml
# config.yaml
audio_detection:
  enabled: true
  model_size: small       # 推荐：平衡准确率和速度
  device: cpu             # cpu 或 cuda
  compute_type: int8      # CPU: int8, GPU: float16
  min_confidence: 0.7     # 置信度阈值
  max_duration: 30        # 音频采样长度（秒）
```

### 针对不同场景的推荐

**快速检测**（牺牲一些准确率）:
```yaml
audio_detection:
  model_size: base
  min_confidence: 0.6
  max_duration: 15
```

**高精度检测**（更慢但更准确）:
```yaml
audio_detection:
  model_size: medium
  min_confidence: 0.8
  max_duration: 60
  device: cuda  # 如果有 GPU
  compute_type: float16
```

**批量处理**（平衡模式）:
```yaml
audio_detection:
  model_size: small
  min_confidence: 0.7
  max_duration: 30
  device: cpu
  compute_type: int8
```

---

## 🔗 相关资源

- [Faster-Whisper GitHub](https://github.com/SYSTRAN/faster-whisper)
- [Whisper 模型文档](https://github.com/openai/whisper)
- [Hugging Face Hub](https://huggingface.co/Systran)
- [FFmpeg 文档](https://ffmpeg.org/documentation.html)

---

*更新时间: 2025-12-26*
*适用版本: mkmkv-smart 1.1.0+*
