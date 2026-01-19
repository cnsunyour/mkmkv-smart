# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 项目概述

mkmkv-smart 是一个智能视频字幕合并工具，使用 Python 开发，基于先进的模糊匹配算法自动匹配视频和字幕文件并合并为 MKV 容器。

**核心特性**:
- 🎯 **智能匹配**: 使用 rapidfuzz 多算法混合策略（Token Set, Partial, Hybrid 等）
- 🌐 **多语言支持**: 支持 350+ 语言，自动识别语言代码和别名
- 🔍 **语言自动检测**:
  - 字幕语言检测（langdetect，支持简繁体区分）
  - 音频语言检测（Faster-Whisper AI，可选）
- 🎨 **全局最优匹配**: 使用匈牙利算法确保最佳字幕分配
- ⚙️ **灵活配置**: YAML 配置文件 + 命令行参数
- 🎨 **美观输出**: Rich 库彩色表格和进度显示
- 🔍 **干运行模式**: 预览匹配结果
- 📦 **批量处理**: 一次处理整个目录

**技术栈**:
- Python 3.8+ (音频检测需 3.8-3.13)
- rapidfuzz: 模糊匹配
- scipy: 匈牙利算法
- Rich: 终端 UI
- langdetect: 字幕语言检测
- Faster-Whisper: 音频语言检测（可选）
- pytest: 测试框架（275+ 测试用例）

## 常用命令

### 安装

```bash
# 从 PyPI 安装（推荐）
pip install mkmkv-smart

# 包含音频检测功能
pip install "mkmkv-smart[audio]"

# 从 GitHub 安装最新版
pip install git+https://github.com/cnsunyour/mkmkv-smart.git

# 开发模式安装（从源码）
git clone https://github.com/cnsunyour/mkmkv-smart.git
cd mkmkv-smart
pip install -e .

# 安装开发依赖
pip install -e ".[dev]"

# 安装所有功能
pip install -e ".[audio,dev]"
```

### 基本使用

```bash
# 预览匹配结果（干运行）
mkmkv-smart --dry-run ~/Downloads

# 执行合并（输出到源目录）
mkmkv-smart ~/Downloads

# 指定输出目录
mkmkv-smart ~/Downloads ~/Movies

# 自定义相似度阈值
mkmkv-smart ~/Downloads ~/Movies --threshold 50

# 使用配置文件
mkmkv-smart ~/Downloads --config config.yaml

# 指定轨道顺序
mkmkv-smart ~/Downloads --track-order 0:0,0:1,1:0,2:0

# 启用音频语言检测
mkmkv-smart ~/Downloads --detect-audio-language

# 启用字幕语言检测并重命名
mkmkv-smart ~/Downloads --detect-subtitle-language --rename-subtitles
```

### 开发和测试

```bash
# 运行所有测试
pytest

# 运行测试并查看覆盖率
pytest --cov=src/mkmkv_smart --cov-report=term-missing

# 使用测试脚本（推荐）
./run_tests.sh

# 运行特定测试
pytest tests/test_matcher.py -v

# 代码格式化
black src/ tests/

# 类型检查
mypy src/
```

### 构建和发布

```bash
# 清理构建文件
rm -rf dist/ build/ *.egg-info

# 构建分发包
python -m build

# 验证分发包
twine check dist/*

# 发布到测试 PyPI
./publish_to_pypi.sh test

# 发布到正式 PyPI
./publish_to_pypi.sh prod

# 手动上传
twine upload dist/*
```

### 版本管理

```bash
# 更新版本号（需要同时更新两处）
# 1. pyproject.toml: version = "x.y.z"
# 2. src/mkmkv_smart/__init__.py: __version__ = "x.y.z"

# 创建 Git 标签
git tag -a vx.y.z -m "Release vx.y.z"
git push origin vx.y.z

# 创建 GitHub Release
gh release create vx.y.z dist/* \
  --title "mkmkv-smart vx.y.z" \
  --notes-file CHANGELOG.md
```

## 项目结构

```
mkmkv-smart/
├── src/mkmkv_smart/          # 源代码
│   ├── __init__.py           # 包初始化，版本号
│   ├── cli.py                # 命令行入口，参数解析
│   ├── config.py             # 配置管理
│   ├── matcher.py            # 智能匹配算法
│   ├── normalizer.py         # 文件名规范化
│   ├── language_utils.py     # 语言代码映射（350+ 语言）
│   ├── language_detector.py  # 字幕语言检测
│   ├── audio_detector.py     # 音频语言检测
│   ├── audio_editor.py       # 音轨语言设置
│   ├── merger.py             # mkvmerge 封装
│   └── security_utils.py     # 安全检查
├── tests/                    # 测试用例（275+ 测试）
│   ├── test_matcher.py       # 匹配算法测试
│   ├── test_language_detector.py
│   ├── test_audio_detector.py
│   └── ...
├── docs/                     # 技术文档
├── examples/                 # 使用示例
├── pyproject.toml            # 项目配置和依赖
├── config.example.yaml       # 配置文件示例
├── run_tests.sh              # 测试运行脚本
├── publish_to_pypi.sh        # PyPI 发布脚本
└── .pypirc.template          # PyPI 认证模板
```

## 架构设计

### 核心模块

#### 1. CLI 模块 (`cli.py`)
- 命令行参数解析（argparse）
- 配置文件加载（YAML）
- 语言优先级排序（简体中文 > 繁体中文 > 英文）
- 主流程协调

#### 2. 匹配器 (`matcher.py`)
- **5 种匹配算法**:
  - `token_set`: 集合匹配（忽略顺序和重复）
  - `token_sort`: 排序后匹配
  - `partial`: 部分匹配
  - `ratio`: 完整字符串匹配
  - `hybrid`: 混合策略（推荐）
- **全局最优分配**: 使用 scipy 的匈牙利算法
- **相似度阈值**: 默认 30%，可配置

实现示例：
```python
# 计算相似度矩阵
similarity_matrix = []
for video in videos:
    row = []
    for subtitle in subtitles:
        score = calculate_similarity(video, subtitle, method)
        row.append(score)
    similarity_matrix.append(row)

# 匈牙利算法找最优匹配
row_indices, col_indices = linear_sum_assignment(
    -np.array(similarity_matrix)  # 负值转为最小化问题
)
```

#### 3. 规范化器 (`normalizer.py`)
- 去除视频标签：分辨率、编码、来源等
- 保留关键信息：年份、剧集编号
- 统一分隔符为空格
- 大小写统一

规范化流程：
```python
# 输入: "Movie.2024.1080p.BluRay.x264.mp4"
# 输出: "movie 2024"

1. 转小写
2. 去扩展名
3. 移除常见标签（TAGS_TO_REMOVE）
4. 提取并保留年份、剧集编号
5. 统一分隔符
6. 去除多余空格
```

#### 4. 语言检测 (`language_detector.py`)
- 使用 langdetect 库检测字幕语言
- 支持简体中文 vs 繁体中文区分
- 置信度阈值过滤
- 自动重命名功能

检测逻辑：
```python
# 读取字幕文本
text = extract_subtitle_text(subtitle_file)

# langdetect 检测
lang = detect(text)

# 简繁体区分
if lang == "zh-cn":
    if contains_traditional_chars(text):
        lang = "zh-hant"
    else:
        lang = "zh-hans"
```

#### 5. 音频检测 (`audio_detector.py`)
- 基于 Faster-Whisper 的 AI 模型
- 智能多点采样（开头、中间、结尾）
- 支持 99+ 种语言
- 可选功能（需要额外安装）

#### 6. 合并器 (`merger.py`)
- 构建 mkvmerge 命令
- 设置字幕编码、语言代码、轨道名称
- 控制默认轨道标记
- 自定义轨道顺序

mkvmerge 命令构建：
```python
cmd = ["mkvmerge", "-o", output_file]

# 添加视频文件
cmd.extend(["--language", "0:und", video_file])

# 添加字幕（按优先级排序）
for i, subtitle in enumerate(subtitles):
    cmd.extend([
        "--language", f"0:{subtitle.lang_code}",
        "--sub-charset", "0:UTF-8",
        "--track-name", f"0:{subtitle.track_name}",
        "--default-track-flag", f"0:{is_default}",
        subtitle.file_path
    ])

# 轨道顺序
if track_order:
    cmd.extend(["--track-order", track_order])
```

### 语言代码系统

#### 语言映射表 (`language_utils.py`)
- 350+ 语言/区域变体
- ISO 639-1, ISO 639-2, ISO 3166-1 标准
- 支持常见别名（CHS/CHT, GB/Big5）

映射示例：
```python
LANGUAGE_MAP = {
    # 中文变体
    "zh": "Chinese",
    "zh-hans": "Chinese (Simplified)",
    "zh-hant": "Chinese (Traditional)",
    "zh-cn": "Chinese (China)",
    "zh-tw": "Chinese (Taiwan)",
    "chs": "Chinese (Simplified)",  # 别名
    "cht": "Chinese (Traditional)",  # 别名

    # 英文变体
    "en": "English",
    "en-us": "English (US)",
    "en-gb": "English (UK)",
    ...
}
```

#### 语言优先级 (`cli.py:_get_language_priority()`)
```python
# 内置优先级
PRIORITY_MAP = {
    # 简体中文（优先级 0）
    "zh-hans", "zh-cn", "zh", "chs", "chi", "sc", "cn",

    # 繁体中文（优先级 1）
    "zh-hant", "zh-tw", "zh-hk", "zh-mo", "cht", "tc", "tw", "hk",

    # 英文（优先级 2）
    "en", "en-us", "en-gb", "en-au", "en-ca", "eng",

    # 其他语言（优先级 999）
}
```

### 安全机制 (`security_utils.py`)

1. **路径验证**: 检查路径遍历攻击
2. **命令注入防护**: 验证 mkvmerge 参数
3. **文件大小限制**: 防止读取超大文件
4. **编码检测**: 安全处理多种字符编码

```python
def validate_path(path: str) -> bool:
    """防止路径遍历攻击"""
    abs_path = os.path.abspath(path)
    if ".." in abs_path:
        raise SecurityError("Path traversal detected")
    return True

def sanitize_mkvmerge_args(args: List[str]) -> List[str]:
    """验证 mkvmerge 参数安全性"""
    dangerous_chars = [";", "`", "$", "|", "&", ">", "<"]
    for arg in args:
        if any(c in arg for c in dangerous_chars):
            raise SecurityError(f"Dangerous character in arg: {arg}")
    return args
```

## 配置文件

### 配置文件位置
1. `./config.yaml` (当前目录)
2. `~/.config/mkmkv-smart/config.yaml` (用户配置)
3. `--config` 参数指定

### 配置示例 (`config.example.yaml`)

```yaml
# 匹配配置
match:
  threshold: 30.0        # 相似度阈值（0-100）
  method: hybrid         # 匹配算法
  keep_year: true        # 保留年份
  keep_episode: true     # 保留剧集编号

# 语言优先级
language:
  priority:
    - zh-hans  # 简体中文
    - zh-hant  # 繁体中文
    - en       # 英文

# 语言检测
language_detection:
  enabled: true
  min_confidence: 0.8
  min_chars: 100

# 音频检测（可选）
audio_detection:
  enabled: false
  model_size: small    # tiny, base, small, medium, large
  device: cpu          # cpu, cuda
  compute_type: int8   # int8, float16, float32
  smart_sampling: true
```

## 开发工作流

### 添加新功能

1. **创建分支**:
   ```bash
   git checkout -b feature/new-feature
   ```

2. **编写代码**:
   ```bash
   # 在 src/mkmkv_smart/ 中添加新模块
   # 遵循现有代码风格
   ```

3. **编写测试**:
   ```bash
   # 在 tests/ 中添加对应测试
   # 确保覆盖率 > 70%
   pytest tests/test_new_feature.py -v
   ```

4. **代码质量检查**:
   ```bash
   black src/ tests/              # 格式化
   mypy src/                      # 类型检查
   pytest --cov=src/mkmkv_smart   # 测试覆盖率
   ```

5. **提交更改**:
   ```bash
   git add .
   git commit -m "feat: add new feature"
   git push origin feature/new-feature
   ```

6. **创建 PR**:
   ```bash
   gh pr create --title "feat: add new feature" \
     --body "Description of changes"
   ```

### 发布新版本

参考 [PyPI_PUBLISH.md](PyPI_PUBLISH.md) 完整流程。

快速步骤：

1. **更新版本号**:
   ```bash
   # pyproject.toml
   version = "1.2.0"

   # src/mkmkv_smart/__init__.py
   __version__ = "1.2.0"
   ```

2. **更新 CHANGELOG.md**

3. **测试**:
   ```bash
   ./run_tests.sh
   ```

4. **提交和标签**:
   ```bash
   git add .
   git commit -m "chore: bump version to 1.2.0"
   git tag -a v1.2.0 -m "Release v1.2.0"
   git push origin main --tags
   ```

5. **构建**:
   ```bash
   rm -rf dist/ build/
   python -m build
   twine check dist/*
   ```

6. **发布**:
   ```bash
   # 测试发布（推荐）
   ./publish_to_pypi.sh test

   # 正式发布
   ./publish_to_pypi.sh prod
   ```

7. **GitHub Release**:
   ```bash
   gh release create v1.2.0 dist/* \
     --title "mkmkv-smart v1.2.0" \
     --notes-file CHANGELOG.md
   ```

## 测试策略

### 测试覆盖

- **单元测试**: 每个模块独立测试
- **集成测试**: 端到端流程测试
- **覆盖率目标**: > 78%
- **测试数量**: 275+ 测试用例

### 测试组织

```python
# tests/test_matcher.py
class TestMatcher:
    def test_token_set_matching(self):
        """测试 Token Set 匹配算法"""

    def test_hybrid_matching(self):
        """测试混合匹配策略"""

    def test_hungarian_algorithm(self):
        """测试匈牙利算法分配"""

# tests/test_language_detector.py
class TestLanguageDetector:
    def test_detect_simplified_chinese(self):
        """测试简体中文检测"""

    def test_detect_traditional_chinese(self):
        """测试繁体中文检测"""
```

### 运行测试

```bash
# 所有测试
pytest

# 特定模块
pytest tests/test_matcher.py

# 特定测试
pytest tests/test_matcher.py::TestMatcher::test_hybrid_matching

# 详细输出
pytest -v

# 覆盖率报告
pytest --cov=src/mkmkv_smart --cov-report=html
open htmlcov/index.html
```

## 依赖管理

### 核心依赖 (必需)

在 `pyproject.toml` 的 `dependencies`:
```toml
dependencies = [
    "rapidfuzz>=3.0.0",   # 模糊匹配
    "pyyaml>=6.0",        # 配置文件
    "rich>=13.0.0",       # 终端 UI
    "langdetect>=1.0.9",  # 语言检测
    "scipy>=1.9.0",       # 匈牙利算法
]
```

### 可选依赖

#### 开发依赖 (`dev`)
```toml
dev = [
    "pytest>=7.0.0",
    "pytest-cov>=4.0.0",
    "black>=23.0.0",
    "mypy>=1.0.0",
]
```

#### 音频检测 (`audio`)
```toml
audio = [
    "faster-whisper>=1.0.0",  # AI 音频识别
]
```

### 安装依赖

```bash
# 基础功能
pip install .

# 包含开发工具
pip install ".[dev]"

# 包含音频检测
pip install ".[audio]"

# 所有功能
pip install ".[dev,audio]"
```

## 故障排除

### 问题：找不到 mkvmerge

**错误**: `FileNotFoundError: mkvmerge not found`

**解决**:
```bash
# macOS
brew install mkvtoolnix

# Ubuntu/Debian
sudo apt install mkvtoolnix

# 验证
mkvmerge --version
```

### 问题：字幕匹配失败

**可能原因**:
1. 相似度低于阈值
2. 文件名格式特殊

**解决**:
```bash
# 1. 使用干运行查看相似度
mkmkv-smart --dry-run ~/Downloads

# 2. 降低阈值
mkmkv-smart ~/Downloads --threshold 20

# 3. 使用配置文件
mkmkv-smart ~/Downloads --config config.yaml
```

### 问题：语言检测不准确

**可能原因**: 字幕文本太短或编码问题

**解决**:
```bash
# 检查字幕文件编码
file -I subtitle.srt

# 转换编码为 UTF-8
iconv -f GBK -t UTF-8 subtitle.srt > subtitle_utf8.srt

# 调整检测参数（config.yaml）
language_detection:
  min_confidence: 0.7  # 降低置信度要求
  min_chars: 50        # 降低最小字符数
```

### 问题：音频检测失败

**可能原因**: Python 版本不兼容或依赖未安装

**解决**:
```bash
# 检查 Python 版本（需要 3.8-3.13）
python --version

# 安装音频检测依赖
pip install "mkmkv-smart[audio]"

# 使用 CPU 模式（如果 GPU 有问题）
# config.yaml:
audio_detection:
  device: cpu
  compute_type: int8
```

### 问题：测试失败

**解决**:
```bash
# 清理缓存
rm -rf .pytest_cache htmlcov .coverage

# 重新安装依赖
pip install -e ".[dev]"

# 运行测试
pytest -v
```

## 代码风格

### Python 风格

- **格式化**: Black (line-length=100)
- **类型提示**: 所有公共函数必须有类型注解
- **文档字符串**: Google 风格
- **命名**:
  - 变量/函数: `snake_case`
  - 类: `PascalCase`
  - 常量: `UPPER_SNAKE_CASE`

### 示例

```python
from typing import List, Optional, Tuple

def calculate_similarity(
    video_name: str,
    subtitle_name: str,
    method: str = "hybrid",
    threshold: float = 30.0
) -> float:
    """计算文件名相似度。

    Args:
        video_name: 视频文件名
        subtitle_name: 字幕文件名
        method: 匹配算法
        threshold: 相似度阈值

    Returns:
        相似度分数 (0-100)

    Raises:
        ValueError: 如果 method 不支持
    """
    if method not in SUPPORTED_METHODS:
        raise ValueError(f"Unsupported method: {method}")

    # 实现...
    return score
```

## 性能优化

### 匹配性能

- 使用 rapidfuzz（C 扩展，比 fuzzywuzzy 快 10-100x）
- 缓存规范化结果
- 批量处理文件

### 语言检测优化

- 限制读取字幕文件大小（前 100KB）
- 缓存检测结果
- 跳过过短文本

### 音频检测优化

- 智能采样（多点采样，选最佳结果）
- 限制采样时长（默认 30 秒）
- 使用较小的模型（small > medium > large）

## 相关文档

- [README.md](README.md) - 项目介绍
- [INSTALL.md](INSTALL.md) - 安装指南
- [QUICKSTART.md](QUICKSTART.md) - 快速开始
- [PyPI_PUBLISH.md](PyPI_PUBLISH.md) - PyPI 发布流程
- [CONTRIBUTING.md](CONTRIBUTING.md) - 贡献指南
- [CHANGELOG.md](CHANGELOG.md) - 变更日志

技术文档：
- [docs/LANGUAGE_DETECTION.md](docs/LANGUAGE_DETECTION.md) - 语言检测实现
- [docs/AUDIO_DETECTION_IMPLEMENTATION.md](docs/AUDIO_DETECTION_IMPLEMENTATION.md) - 音频检测实现
- [docs/FEATURE_COMPARISON.md](docs/FEATURE_COMPARISON.md) - 功能对比
