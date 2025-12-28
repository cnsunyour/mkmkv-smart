# PyPI 发布指南

本文档说明如何将 mkmkv-smart 发布到 PyPI，让用户可以直接使用 `pip install mkmkv-smart` 安装。

## 📋 前置准备

### 1. 注册 PyPI 账号

**正式 PyPI**（用于正式发布）：
- 访问 https://pypi.org/account/register/
- 注册账号并验证邮箱
- 启用双因素认证（2FA，推荐）

**测试 PyPI**（用于测试上传）：
- 访问 https://test.pypi.org/account/register/
- 注册独立的测试账号

### 2. 创建 API Token

PyPI 不再推荐使用用户名密码上传，而是使用 API Token。

**创建 Token**：
1. 登录 PyPI
2. 访问 https://pypi.org/manage/account/token/
3. 点击 "Add API token"
4. Token 名称：`mkmkv-smart-upload`
5. Scope：选择 "Entire account"（首次上传）或 "Project: mkmkv-smart"（后续上传）
6. 创建后**立即复制并保存** token（只显示一次）

格式：`pypi-AgEIcHlwaS5vcmc...`

### 3. 配置 Twine 认证

创建 `~/.pypirc` 文件：

```ini
[distutils]
index-servers =
    pypi
    testpypi

[pypi]
username = __token__
password = pypi-AgEIcHlwaS5vcmc...（你的 API Token）

[testpypi]
username = __token__
password = pypi-AgEIcHlwaS5vcmc...（测试环境的 API Token）
```

**注意**：
- `username` 固定为 `__token__`
- `password` 填写完整的 API Token（包括 `pypi-` 前缀）
- 设置文件权限：`chmod 600 ~/.pypirc`

## 🧪 测试上传（推荐）

先上传到测试 PyPI 验证包的完整性：

```bash
# 上传到测试 PyPI
twine upload --repository testpypi dist/*

# 验证安装
pip install --index-url https://test.pypi.org/simple/ \
  --extra-index-url https://pypi.org/simple/ \
  mkmkv-smart
```

如果测试成功，删除测试安装：
```bash
pip uninstall mkmkv-smart
```

## 🚀 正式发布

### 1. 最终检查

```bash
# 确认版本号正确
grep "^version" pyproject.toml

# 验证分发包
twine check dist/*

# 查看包内容
tar -tzf dist/mkmkv_smart-1.1.1.tar.gz | head -20
unzip -l dist/mkmkv_smart-1.1.1-py3-none-any.whl | head -20
```

### 2. 上传到 PyPI

```bash
# 上传到正式 PyPI
twine upload dist/*
```

**输出示例**：
```
Uploading distributions to https://upload.pypi.org/legacy/
Uploading mkmkv_smart-1.1.1-py3-none-any.whl
100% ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 54.6/54.6 kB • 00:00
Uploading mkmkv_smart-1.1.1.tar.gz
100% ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 83.5/83.5 kB • 00:00

View at:
https://pypi.org/project/mkmkv-smart/1.1.1/
```

### 3. 验证发布

```bash
# 等待 1-2 分钟让 PyPI 索引更新

# 从 PyPI 安装
pip install mkmkv-smart

# 验证安装
mkmkv-smart --version

# 运行测试
mkmkv-smart --help
```

## 📊 发布后操作

### 1. 更新 GitHub Release

```bash
# 上传新的分发包到 GitHub Release
gh release upload v1.1.1 dist/* --clobber
```

### 2. 更新文档

需要更新以下文档中的安装说明：

**README.md**：
```markdown
## 安装

### 方式 1: 从 PyPI 安装（推荐）
```bash
pip install mkmkv-smart
```

### 方式 2: 从 GitHub 安装
```bash
pip install git+https://github.com/cnsunyour/mkmkv-smart.git
```
```

**INSTALL.md**：
```markdown
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
```

### 3. 提交文档更新

```bash
git add README.md INSTALL.md PyPI_PUBLISH.md
git commit -m "docs: 添加 PyPI 安装方式"
git push origin main
```

### 4. 宣传推广

在以下平台分享：
- GitHub Release 更新说明中添加 PyPI 链接
- 项目 README.md 顶部添加 PyPI 徽章
- 相关技术社区发布更新（知乎、V2EX、Reddit 等）

## 🔄 后续版本发布

发布新版本时：

1. **更新版本号**：
   ```bash
   # 编辑 pyproject.toml
   version = "1.2.0"

   # 编辑 src/mkmkv_smart/__init__.py
   __version__ = "1.2.0"
   ```

2. **更新 CHANGELOG.md**：
   ```markdown
   ## [1.2.0] - 2025-01-15

   ### 新增
   - 功能描述

   ### 修复
   - Bug 描述
   ```

3. **重新构建**：
   ```bash
   rm -rf dist/ build/
   python -m build
   twine check dist/*
   ```

4. **创建 Git 标签**：
   ```bash
   git add .
   git commit -m "chore: bump version to 1.2.0"
   git tag -a v1.2.0 -m "Release v1.2.0"
   git push origin main --tags
   ```

5. **上传到 PyPI**：
   ```bash
   twine upload dist/*
   ```

6. **创建 GitHub Release**：
   ```bash
   gh release create v1.2.0 dist/* \
     --title "mkmkv-smart v1.2.0" \
     --notes-file CHANGELOG.md
   ```

## 🛠️ 常见问题

### 问题 1: 包名已存在

**错误**：`HTTPError: 403 Forbidden ... The name 'mkmkv-smart' conflicts with an existing project.`

**原因**：PyPI 上已有同名包（包括已删除的包）

**解决**：
- 检查是否是你自己的包：https://pypi.org/project/mkmkv-smart/
- 如果不是你的包，需要更改包名（例如 `mkmkv-smart-tool`）

### 问题 2: 文件已存在

**错误**：`HTTPError: 400 Bad Request ... File already exists`

**原因**：相同版本号已上传过

**解决**：
```bash
# PyPI 不允许覆盖已发布的版本，必须更新版本号
# 编辑 pyproject.toml
version = "1.1.2"

# 重新构建
rm -rf dist/ build/
python -m build
twine upload dist/*
```

### 问题 3: 认证失败

**错误**：`HTTPError: 403 Forbidden ... Invalid or non-existent authentication`

**原因**：API Token 错误或过期

**解决**：
1. 确认 `~/.pypirc` 中的 token 正确
2. 确认 username 是 `__token__`（不是你的用户名）
3. 重新创建 API Token

### 问题 4: 依赖冲突

**错误**：安装时提示依赖冲突

**解决**：
```bash
# 检查 pyproject.toml 中的依赖版本范围
# 放宽版本限制，例如：
dependencies = [
    "rapidfuzz>=3.0.0",  # 而不是 "rapidfuzz==3.9.0"
]
```

## 📚 参考资源

- PyPI 官方文档：https://packaging.python.org/
- Twine 文档：https://twine.readthedocs.io/
- PEP 639（License 字段规范）：https://peps.python.org/pep-0639/
- 项目结构最佳实践：https://packaging.python.org/en/latest/tutorials/packaging-projects/

## ✅ 发布检查清单

发布前确认：

- [ ] 版本号已更新（pyproject.toml 和 __init__.py）
- [ ] CHANGELOG.md 已更新
- [ ] 所有测试通过：`pytest`
- [ ] 代码已提交并推送到 GitHub
- [ ] Git 标签已创建
- [ ] 分发包已构建：`python -m build`
- [ ] 分发包已验证：`twine check dist/*`
- [ ] （可选）已在 test.pypi.org 测试
- [ ] API Token 已配置
- [ ] 已上传到 PyPI：`twine upload dist/*`
- [ ] 已验证安装：`pip install mkmkv-smart`
- [ ] GitHub Release 已创建
- [ ] 文档已更新（README.md, INSTALL.md）
- [ ] 文档更新已提交

---

完成发布后，用户就可以通过 `pip install mkmkv-smart` 直接安装了！🎉
