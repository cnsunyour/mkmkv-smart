# 安装指南

mkmkv-smart 提供多种安装方式，选择最适合你的方式。

## 📦 方式 1: 从 PyPI 安装（推荐）

### 安装最新版本
```bash
pip install mkmkv-smart
```

### 安装指定版本
```bash
pip install mkmkv-smart==1.1.1
```

### 包含音频检测功能
```bash
pip install "mkmkv-smart[audio]"
```

### 升级到最新版本
```bash
pip install --upgrade mkmkv-smart
```

## 📥 方式 2: 从 GitHub 安装

### 安装最新版本
```bash
pip install git+https://github.com/cnsunyour/mkmkv-smart.git
```

### 安装指定版本
```bash
pip install git+https://github.com/cnsunyour/mkmkv-smart.git@v1.1.1
```

### 包含音频检测功能
```bash
pip install "git+https://github.com/cnsunyour/mkmkv-smart.git#egg=mkmkv-smart[audio]"
```

## 📥 方式 3: 下载 Wheel 文件安装

### 下载预构建包
访问 [Releases 页面](https://github.com/cnsunyour/mkmkv-smart/releases/latest) 下载：
- `mkmkv_smart-1.1.1-py3-none-any.whl`

### 安装
```bash
pip install mkmkv_smart-1.1.1-py3-none-any.whl
```

### 离线安装（含依赖）
```bash
# 1. 在有网络的机器上下载依赖
pip download mkmkv-smart -d packages/

# 2. 将 packages/ 目录复制到离线机器

# 3. 离线安装
pip install --no-index --find-links=packages/ mkmkv-smart
```

## 🔧 方式 4: 从源码安装（开发者）

### 克隆仓库
```bash
git clone https://github.com/cnsunyour/mkmkv-smart.git
cd mkmkv-smart
```

### 开发模式安装
```bash
pip install -e .
```

### 包含可选功能
```bash
# 音频检测功能
pip install -e ".[audio]"

# 开发工具
pip install -e ".[dev]"

# 全部功能
pip install -e ".[audio,dev]"
```

## 🐳 方式 5: Docker 容器

### 使用预构建镜像（TODO）
```bash
docker pull ghcr.io/cnsunyour/mkmkv-smart:latest
docker run -v /path/to/videos:/workspace mkmkv-smart --help
```

### 自己构建镜像
创建 `Dockerfile`:
```dockerfile
FROM python:3.11-slim

# 安装 mkvtoolnix
RUN apt-get update && \
    apt-get install -y mkvtoolnix && \
    rm -rf /var/lib/apt/lists/*

# 安装 mkmkv-smart
RUN pip install --no-cache-dir git+https://github.com/cnsunyour/mkmkv-smart.git

WORKDIR /workspace
ENTRYPOINT ["mkmkv-smart"]
CMD ["--help"]
```

构建和运行：
```bash
docker build -t mkmkv-smart .
docker run -v $(pwd):/workspace mkmkv-smart --dry-run .
```

## 🍺 方式 6: Homebrew（macOS，TODO）

```bash
# 待实现
brew tap cnsunyour/tap
brew install mkmkv-smart
```

## 📋 前置依赖

### 必需依赖
- **Python**: 3.8 或更高版本
- **mkvtoolnix**: 提供 `mkvmerge` 命令

### 安装 mkvtoolnix

**macOS:**
```bash
brew install mkvtoolnix
```

**Ubuntu/Debian:**
```bash
sudo apt update
sudo apt install mkvtoolnix
```

**CentOS/RHEL:**
```bash
sudo yum install mkvtoolnix
```

**Windows:**
从 [MKVToolNix 官网](https://mkvtoolnix.download/) 下载安装

### 可选依赖
- **faster-whisper**: 音频语言检测（约 500MB，包括 PyTorch）
  - 仅支持 Python 3.8-3.13（Python 3.14 暂不支持）
  - 推荐 Python 3.11 或 3.12

## ✅ 验证安装

```bash
# 检查版本
mkmkv-smart --version

# 应该显示
# mkmkv-smart 1.1.1

# 检查 mkvmerge
mkvmerge --version

# 运行测试
mkmkv-smart --help
```

## 🆙 更新

### 从 PyPI 更新
```bash
pip install --upgrade mkmkv-smart
```

### 从 GitHub 更新
```bash
pip install --upgrade git+https://github.com/cnsunyour/mkmkv-smart.git
```

### 从 Wheel 更新
```bash
pip install --upgrade mkmkv_smart-1.1.1-py3-none-any.whl
```

### 开发模式更新
```bash
cd mkmkv-smart
git pull origin main
pip install -e . --upgrade
```

## 🗑️ 卸载

```bash
pip uninstall mkmkv-smart
```

## 🔍 故障排除

### 问题：pip install 失败

**错误**：`Could not find a version that satisfies the requirement`

**解决**：
```bash
# 升级 pip
pip install --upgrade pip setuptools wheel

# 重试安装
pip install git+https://github.com/cnsunyour/mkmkv-smart.git
```

### 问题：mkvmerge 命令找不到

**错误**：`mkvmerge not found`

**解决**：
1. 确认已安装 mkvtoolnix（见上方安装说明）
2. 检查 PATH：`which mkvmerge` 或 `where mkvmerge`（Windows）
3. 手动添加到 PATH（如果需要）

### 问题：音频检测安装失败（Python 3.14）

**错误**：`onnxruntime` 不支持 Python 3.14

**解决**：
- 使用 Python 3.11-3.13
- 或不安装音频检测功能：`pip install mkmkv-smart`（不带 [audio]）

### 问题：ImportError

**错误**：`ModuleNotFoundError: No module named 'mkmkv_smart'`

**解决**：
```bash
# 确认安装
pip list | grep mkmkv

# 重新安装
pip uninstall mkmkv-smart
pip install git+https://github.com/cnsunyour/mkmkv-smart.git
```

## 📞 获取帮助

- **文档**: [README.md](README.md)
- **快速开始**: [QUICKSTART.md](QUICKSTART.md)
- **问题反馈**: [GitHub Issues](https://github.com/cnsunyour/mkmkv-smart/issues)
- **贡献指南**: [CONTRIBUTING.md](CONTRIBUTING.md)

## 🎓 下一步

安装完成后，查看：
- [快速开始指南](QUICKSTART.md) - 5 分钟上手教程
- [README.md](README.md) - 完整功能说明
- [examples/](examples/) - 使用示例代码
