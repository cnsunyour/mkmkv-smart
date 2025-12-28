# 快速开始指南

本指南将帮助你在 5 分钟内开始使用 mkmkv-smart。

## 📦 安装

### 1. 安装依赖

**macOS:**
```bash
# 安装 mkvtoolnix
brew install mkvtoolnix

# 安装 Python 3.8+
brew install python@3.11
```

**Ubuntu/Debian:**
```bash
sudo apt update
sudo apt install python3 python3-pip mkvtoolnix
```

### 2. 安装 mkmkv-smart

```bash
# 克隆仓库
git clone https://github.com/cnsunyour/mkmkv-smart.git
cd mkmkv-smart

# 安装
pip3 install -e .
```

### 3. 验证安装

```bash
mkmkv-smart --version
```

应该显示: `mkmkv-smart 1.1.1`

## 🎯 第一次使用

### 场景: 合并电影和字幕

假设你有以下文件:
```
~/Downloads/
├── Movie.2024.1080p.BluRay.mp4
├── Movie.2024.zh-hans.srt
└── Movie.2024.en.srt
```

### 步骤 1: 预览匹配结果

```bash
mkmkv-smart --dry-run ~/Downloads
```

你会看到类似输出:
```
智能匹配模式
[ 干运行 - 不会实际执行 ]
源目录: /Users/xxx/Downloads
找到 1 个视频文件
找到 2 个字幕文件

匹配结果:
======================================================================

视频: Movie.2024.1080p.BluRay.mp4
  规范化: movie 2024

语言     字幕文件                     相似度
─────────────────────────────────────────────
zh-hans  Movie.2024.zh-hans.srt      100.0%
en       Movie.2024.en.srt           100.0%

======================================================================
总计: 1 个文件
可处理: 1 个文件
```

### 步骤 2: 执行合并

如果匹配结果正确,执行实际合并:

```bash
mkmkv-smart ~/Downloads ~/Movies
```

### 步骤 3: 验证结果

检查输出文件:
```bash
ls -lh ~/Movies/
# 应该看到: Movie.2024.mkv
```

用播放器打开验证字幕是否正确嵌入。

## 📚 常见场景

### 场景 1: 批量处理剧集

```
Series/
├── S01E01.mp4
├── S01E01.zh.srt
├── S01E02.mp4
├── S01E02.zh.srt
└── ...
```

```bash
# 预览
mkmkv-smart --dry-run ~/Series

# 执行
mkmkv-smart ~/Series ~/Series/Output
```

### 场景 2: 不同命名格式

即使命名不完全一致也能匹配:

```
Video: The.Matrix.1999.1080p.BluRay.x264-GROUP1.mp4
Sub:   The.Matrix.1999.WEB-DL.zh-hans.srt
```

```bash
mkmkv-smart --threshold 30 ~/Downloads
```

### 场景 3: 使用配置文件

创建 `my-config.yaml`:
```yaml
match:
  threshold: 35.0
  method: token_set

language:
  priority:
    - en
    - zh-hans
```

使用:
```bash
mkmkv-smart --config my-config.yaml ~/Downloads
```

## 🔧 常见问题

### Q1: 提示 "mkvmerge not found"

**A:** 需要安装 mkvtoolnix:
```bash
# macOS
brew install mkvtoolnix

# Ubuntu/Debian
sudo apt install mkvtoolnix
```

### Q2: 字幕没有匹配上

**A:** 尝试降低阈值:
```bash
mkmkv-smart --threshold 20 ~/Downloads
```

### Q3: 匹配了错误的字幕

**A:** 尝试提高阈值或使用不同的方法:
```bash
mkmkv-smart --threshold 50 --method token_set ~/Downloads
```

### Q4: 想要改变语言优先级

**A:** 创建配置文件:
```yaml
language:
  priority:
    - en      # 英文优先
    - zh-hans
```

### Q5: 如何只预览不执行?

**A:** 使用 `--dry-run`:
```bash
mkmkv-smart --dry-run ~/Downloads
```

## 🎓 进阶技巧

### 技巧 1: 自定义匹配方法

不同场景使用不同方法:

```bash
# 文件名标签很多时
mkmkv-smart --method token_set ~/Downloads

# 文件名顺序不同时
mkmkv-smart --method token_sort ~/Downloads

# 需要部分匹配时
mkmkv-smart --method partial ~/Downloads
```

### 技巧 2: 调整阈值

根据文件命名规范调整:

```bash
# 命名规范: 高阈值
mkmkv-smart --threshold 60 ~/Downloads

# 命名混乱: 低阈值
mkmkv-smart --threshold 20 ~/Downloads
```

### 技巧 3: 组合使用

```bash
mkmkv-smart \
  --dry-run \
  --threshold 35 \
  --method hybrid \
  --config config.yaml \
  ~/Downloads \
  ~/Movies
```

## 📖 下一步

- 阅读完整 [README.md](README.md) 了解所有功能
- 查看 [examples/](examples/) 目录的示例
- 学习如何自定义配置文件

## 💡 提示

1. **始终先使用 `--dry-run`** 预览结果再执行
2. **备份重要文件** 避免意外覆盖
3. **调整阈值** 直到匹配结果满意
4. **使用配置文件** 固定常用设置

---

有问题? 查看 [README.md](README.md) 或提交 Issue!
