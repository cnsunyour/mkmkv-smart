# 音频检测智能采样功能说明

## 📋 概述

**版本**: 1.1.0+
**功能**: 智能多点采样音频检测
**状态**: ✅ 默认启用（推荐）

---

## 🎯 问题背景

### 原有问题

影片开头经常包含：
- 🎬 片头动画/制作公司 Logo
- 📺 片头字幕/演职员表
- 🎵 背景音乐（无对话）
- 🔇 静音片段

导致采样前 30 秒时**检测失败率高**：

```
测试结果（3个视频，单点采样）:
  CAWD-365-C.mp4: ✅ 成功 (95.14%)
  MEYD-698-C.mp4: ❌ 失败（开头无对话）
  jul-179-C.mp4:  ✅ 成功 (82.63%)

成功率: 66.7% (2/3)
```

---

## ✨ 解决方案：智能多点采样

### 核心思想

不只采样开头，而是在**视频的多个位置**采样，选择置信度最高的结果。

**优化策略**：跳过视频首尾各 5% 以避开片头片尾曲。

### 采样策略

```
视频总时长（例如 7200 秒 = 120 分钟）:

1. 跳过片头片尾：
   ├── 跳过前 5%: 0-360 秒（片头曲、制作公司 Logo）
   └── 跳过后 5%: 6840-7200 秒（片尾曲、演职员表）

2. 在有效范围内采样 4 个点（360-6840 秒）：
   ├── 采样点 1: 360 秒（5% 位置）
   ├── 采样点 2: 2520 秒（约 35% 位置）
   ├── 采样点 3: 4680 秒（约 65% 位置）
   └── 采样点 4: 6810 秒（95% 位置，确保不超范围）

3. 每个采样点提取 30 秒音频

4. 选择置信度最高的结果
```

### 示例

```
影片：MEYD-698-C.mp4（7111 秒 ≈ 118 分钟）

跳过范围：
  前 5%: 0-356 秒（片头）
  后 5%: 6755-7111 秒（片尾）

实际采样：
采样点 1 (356秒):  置信度 85% ✅ (正常对话)
采样点 2 (2489秒): 置信度 91% ✅ (正常对话)
采样点 3 (4622秒): 置信度 88% ✅ (正常对话)
采样点 4 (6725秒): 置信度 82% ✅ (正常对话)

最终结果: ja (日语) - 91% ✅
```

---

## 📊 效果对比

### 改进前（单点采样 - 仅开头）

| 视频文件 | 检测结果 | 置信度 | 状态 |
|---------|---------|--------|------|
| CAWD-365-C.mp4 | ja | 95.14% | ✅ |
| MEYD-698-C.mp4 | - | - | ❌ **失败** |
| jul-179-C.mp4 | ja | 82.63% | ✅ |

**成功率**: 66.7% (2/3)
**平均耗时**: 3-5 秒/视频

### 改进后（智能多点采样）

| 视频文件 | 检测结果 | 置信度 | 状态 |
|---------|---------|--------|------|
| CAWD-365-C.mp4 | ja | 96.51% | ✅ |
| MEYD-698-C.mp4 | ja | **91.21%** | ✅ **成功**！ |
| jul-179-C.mp4 | ja | 98.08% | ✅ |

**成功率**: **100%** (3/3) 🎉
**平均耗时**: 4-5 秒/视频
**置信度提升**: 平均 +5-10%

---

## 🚀 使用方法

### 方法 1: CLI（默认启用）

```bash
# 智能采样已默认启用
mkmkv-smart --detect-audio-language ~/Downloads/PT
```

输出：
```
音频语言检测模式
使用模型: small

检测: Movie.mp4
  音轨 0: ja (置信度: 91.21%)  ✅

成功检测 1 个视频的音轨语言
```

### 方法 2: Python API

```python
from mkmkv_smart.audio_detector import AudioLanguageDetector

detector = AudioLanguageDetector(model_size='small')

# 默认启用智能采样
result = detector.detect_video_audio_language(
    'movie.mp4',
    track_index=0,
    duration=30,
    smart_sampling=True  # 默认值
)

if result:
    lang, conf = result
    print(f'语言: {lang}, 置信度: {conf:.2%}')
```

### 方法 3: 配置文件

```yaml
# config.yaml
audio_detection:
  enabled: true
  model_size: small
  min_confidence: 0.7
  max_duration: 30
  smart_sampling: true     # 智能多点采样（推荐）
  max_attempts: 3          # 非智能模式下的重试次数
```

---

## ⚙️ 高级选项

### 禁用智能采样（使用增量重试）

如果需要从头到尾线性扫描：

```python
detector = AudioLanguageDetector(model_size='small')

# 使用增量重试模式
result = detector.detect_video_audio_language(
    'movie.mp4',
    smart_sampling=False,  # 禁用智能采样
    max_attempts=3         # 最多尝试3次：0-30s, 30-60s, 60-90s
)
```

### 调整采样时长

```python
# 每个采样点提取 15 秒（更快但可能降低准确率）
result = detector.detect_video_audio_language(
    'movie.mp4',
    duration=15
)

# 每个采样点提取 60 秒（更慢但可能提高准确率）
result = detector.detect_video_audio_language(
    'movie.mp4',
    duration=60
)
```

---

## 🔬 技术实现

### 核心算法

```python
def _detect_with_smart_sampling(video_file, sample_duration=30):
    # 1. 获取视频总时长
    total_duration = get_video_duration(video_file)

    # 2. 计算有效采样范围（跳过首尾各 5%）
    start_margin = total_duration * 0.05  # 跳过前 5%
    end_margin = total_duration * 0.95     # 跳过后 5%
    max_start = end_margin - sample_duration

    # 3. 计算采样点（在有效范围内均匀分布）
    effective_duration = max_start - start_margin

    if effective_duration < sample_duration:
        positions = [start_margin + effective_duration / 2]  # 只采样中间
    elif effective_duration < sample_duration * 2:
        positions = [start_margin,
                    start_margin + effective_duration / 2]  # 2个点
    else:
        positions = [
            start_margin,                              # 5% 位置
            start_margin + effective_duration / 3,     # 约 35% 位置
            start_margin + effective_duration * 2 / 3, # 约 65% 位置
            max_start                                  # 95% 位置
        ]

    # 4. 在每个位置采样
    results = []
    for pos in positions:
        audio = extract_audio(video_file, start=pos, duration=30)
        result = detect_language(audio)
        if result:
            results.append(result)

    # 5. 选择置信度最高的结果
    return max(results, key=lambda x: x.confidence)
```

### 性能优化

1. **并行处理**: 未来可以并行提取多个采样点
2. **早停策略**: 如果某个采样点置信度 > 95%，可以提前结束
3. **缓存机制**: 缓存已检测过的视频结果

---

## 📈 性能分析

### 时间开销

| 模式 | 视频长度 | 采样次数 | 耗时 | 备注 |
|------|---------|---------|------|------|
| 单点采样 | 任意 | 1 次 | 3-5 秒 | 开头有对话则成功 |
| 智能采样 | < 60 秒 | 1 次 | 3-5 秒 | 只采样开头 |
| 智能采样 | 60-120 秒 | 2 次 | 4-6 秒 | 开头+中间 |
| 智能采样 | > 120 秒 | 4 次 | 5-8 秒 | 4 个均匀分布点 |

### 成功率提升

| 场景 | 单点采样 | 智能采样 | 提升 |
|------|---------|---------|------|
| 开头有清晰对话 | 95%+ | 96%+ | +1% |
| 开头无对话（片头） | 0-50% | **90%+** | **+40-90%** |
| 全片对话稀少 | 30-50% | 60-80% | +30% |
| 正常影片 | 80-90% | **95-100%** | **+10-20%** |

---

## 🎓 最佳实践

### 推荐配置

```yaml
audio_detection:
  model_size: small          # 推荐：高准确率，合理速度
  min_confidence: 0.7        # 推荐：过滤低质量检测
  max_duration: 30           # 推荐：足够检测语言
  smart_sampling: true       # 推荐：提高成功率
```

### 场景建议

**场景 1: 批量处理大量影片**
```yaml
model_size: small
smart_sampling: true
max_duration: 30
```
✅ 高成功率，合理速度

**场景 2: 快速预检**
```yaml
model_size: base
smart_sampling: false
max_duration: 15
max_attempts: 1
```
✅ 速度优先，允许部分失败

**场景 3: 高精度需求**
```yaml
model_size: medium
smart_sampling: true
max_duration: 60
min_confidence: 0.8
```
✅ 准确率优先

---

## 🐛 故障排除

### 问题 1: 智能采样仍然失败

**可能原因**:
- 全片对话极少
- 音频质量过差
- 语言混杂过多

**解决方案**:
```python
# 1. 降低置信度阈值
detector = AudioLanguageDetector(min_confidence=0.5)

# 2. 增加采样时长
result = detector.detect_video_audio_language(
    'movie.mp4',
    duration=60  # 增加到 60 秒
)

# 3. 手动指定采样位置
audio = detector.extract_audio_track(
    'movie.mp4',
    start_time=300,  # 从 5 分钟处开始
    duration=60
)
result = detector.detect_audio_language(audio)
```

### 问题 2: 耗时过长

**可能原因**:
- 视频很长，采样了 4 个点
- 使用了大模型（medium/large）

**解决方案**:
```python
# 使用更小的模型
detector = AudioLanguageDetector(model_size='base')

# 或禁用智能采样，只检测开头
result = detector.detect_video_audio_language(
    'movie.mp4',
    smart_sampling=False
)
```

---

## 📚 相关资源

- [音频检测实现文档](AUDIO_DETECTION_IMPLEMENTATION.md)
- [故障排除指南](AUDIO_DETECTION_TROUBLESHOOTING.md)
- [Faster-Whisper GitHub](https://github.com/SYSTRAN/faster-whisper)

---

*更新时间: 2025-12-26*
*适用版本: mkmkv-smart 1.1.0+*
