# 使用示例

本目录包含 mkmkv-smart 的使用示例,帮助你快速上手和了解高级功能。

## 📁 文件列表

### basic_usage.py
基础使用示例,涵盖核心功能:

- ✅ 文件名规范化
- ✅ 语言代码提取
- ✅ 相似度计算
- ✅ 批量匹配
- ✅ 配置管理
- ✅ 字幕轨道创建

**运行:**
```bash
python examples/basic_usage.py
```

### advanced_usage.py
高级使用示例,深入探索功能:

- ✅ 自定义规范化器
- ✅ 不同算法比较
- ✅ 语言优先级处理
- ✅ 复杂场景匹配
- ✅ 阈值调优
- ✅ 边界情况处理

**运行:**
```bash
python examples/advanced_usage.py
```

### chs_cht_example.py
CHS/CHT 语言代码支持示例:

- ✅ CHS/CHT 语言代码识别
- ✅ 语言别名映射
- ✅ 使用 CHS/CHT 进行匹配
- ✅ 真实场景演示
- ✅ 批量处理示例

**运行:**
```bash
python examples/chs_cht_example.py
```

## 🎯 快速开始

### 1. 安装依赖

```bash
cd /path/to/mkmkv-smart
pip install -e .
```

### 2. 运行基础示例

```bash
python examples/basic_usage.py
```

你会看到各种功能的演示输出,包括:

```
示例 1: 文件名规范化
原始:   Movie.2024.1080p.BluRay.x264.AAC.mp4
规范化: movie 2024

示例 2: 语言代码提取
文件: Movie.2024.zh-hans.srt
语言: zh-hans
...
```

### 3. 探索高级功能

```bash
python examples/advanced_usage.py
```

## 📚 示例说明

### 示例 1: 文件名规范化

**目的**: 了解如何清理文件名以提高匹配准确度

**代码:**
```python
from mkmkv_smart.normalizer import FileNormalizer

normalizer = FileNormalizer()
normalized = normalizer.normalize("Movie.2024.1080p.BluRay.x264.mp4")
print(normalized)  # 输出: movie 2024
```

**学习要点:**
- 自动去除视频标签(分辨率、编码等)
- 统一大小写
- 标准化分隔符

### 示例 2: 相似度计算

**目的**: 理解不同匹配算法的工作原理

**代码:**
```python
from mkmkv_smart.matcher import SmartMatcher

matcher = SmartMatcher()
similarity = matcher.calculate_similarity(
    "Movie.2024.1080p.mp4",
    "Movie.2024.zh.srt"
)
print(f"相似度: {similarity:.1f}%")
```

**学习要点:**
- Token Set: 适合标签多的文件名
- Token Sort: 适合顺序不同的文件名
- Partial: 适合部分匹配
- Hybrid: 综合多种算法

### 示例 3: 批量匹配

**目的**: 一次处理多个视频和字幕

**代码:**
```python
from mkmkv_smart.matcher import SmartMatcher

matcher = SmartMatcher(threshold=30.0)
results = matcher.batch_match(
    videos=["Movie.A.mp4", "Movie.B.mp4"],
    subtitles=["Movie.A.zh.srt", "Movie.B.zh.srt"]
)
```

**学习要点:**
- 自动匹配多个文件
- 语言分组
- 优先级排序

### 示例 4: 自定义配置

**目的**: 根据需求调整匹配行为

**代码:**
```python
from mkmkv_smart.config import Config

config = Config()
config.match.threshold = 35.0
config.match.method = "token_set"
config.language.priority = ["en", "zh-hans"]
config.save("my-config.yaml")
```

**学习要点:**
- 调整相似度阈值
- 选择匹配算法
- 设置语言优先级

## 🔧 自定义示例

你可以基于提供的示例创建自己的脚本:

```python
#!/usr/bin/env python3
from pathlib import Path
from mkmkv_smart.cli import collect_files, run_match

# 收集文件
directory = Path("~/Downloads").expanduser()
videos, subtitles = collect_files(directory)

print(f"找到 {len(videos)} 个视频")
print(f"找到 {len(subtitles)} 个字幕")

# 打印文件列表
for video in videos:
    print(f"  {video.name}")
```

## 💡 实用技巧

### 技巧 1: 调试匹配结果

```python
matcher = SmartMatcher(threshold=30.0)

# 查看规范化结果
video_norm = matcher.normalizer.normalize("Movie.2024.1080p.mp4")
sub_norm = matcher.normalizer.normalize("Movie.2024.zh.srt")

print(f"视频规范化: {video_norm}")
print(f"字幕规范化: {sub_norm}")

# 计算相似度
similarity = matcher.calculate_similarity(video, sub)
print(f"相似度: {similarity:.1f}%")
```

### 技巧 2: 测试不同阈值

```python
thresholds = [20, 30, 40, 50]
for threshold in thresholds:
    matcher = SmartMatcher(threshold=threshold)
    matches = matcher.find_best_match(video, subtitles)
    print(f"阈值 {threshold}: {len(matches)} 个匹配")
```

### 技巧 3: 比较不同算法

```python
methods = ['token_set', 'token_sort', 'partial', 'hybrid']
for method in methods:
    matcher = SmartMatcher(method=method)
    similarity = matcher.calculate_similarity(video, subtitle)
    print(f"{method}: {similarity:.1f}%")
```

## 📖 相关文档

- [README.md](../README.md) - 项目总览
- [QUICKSTART.md](../QUICKSTART.md) - 快速开始
- [CONTRIBUTING.md](../CONTRIBUTING.md) - 贡献指南

## 🤔 常见问题

### Q: 示例程序报错 "No module named 'mkmkv_smart'"

A: 确保已安装项目:
```bash
pip install -e .
```

### Q: 如何修改示例来处理我的文件?

A: 修改文件路径和文件名:
```python
# 修改前
video = "Movie.2024.mp4"

# 修改后
video = "/path/to/your/video.mp4"
```

### Q: 示例可以在实际项目中使用吗?

A: 可以! 这些示例展示了库的正确用法,可以直接在你的项目中使用。

## 💬 反馈

如果你有新的示例想法或发现示例中的问题,请:

1. 提交 Issue
2. 创建 Pull Request
3. 在 Discussions 讨论

---

Happy coding! 🎉
