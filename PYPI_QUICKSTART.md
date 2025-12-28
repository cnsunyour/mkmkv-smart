# 快速发布到 PyPI

## 🚀 一键发布

### 1. 准备工作（首次）

```bash
# 注册 PyPI 账号
# 测试环境: https://test.pypi.org/account/register/
# 正式环境: https://pypi.org/account/register/

# 创建 API Token
# 测试环境: https://test.pypi.org/manage/account/token/
# 正式环境: https://pypi.org/manage/account/token/

# 配置认证
cp .pypirc.template ~/.pypirc
# 编辑 ~/.pypirc 填入你的 API Token
chmod 600 ~/.pypirc
```

### 2. 测试发布（推荐）

```bash
# 发布到测试 PyPI
./publish_to_pypi.sh test

# 验证安装
pip install --index-url https://test.pypi.org/simple/ \
  --extra-index-url https://pypi.org/simple/ \
  mkmkv-smart

# 测试命令
mkmkv-smart --version

# 卸载测试版本
pip uninstall mkmkv-smart
```

### 3. 正式发布

```bash
# 发布到正式 PyPI
./publish_to_pypi.sh prod

# 验证安装
pip install mkmkv-smart
mkmkv-smart --version
```

## 📝 详细说明

完整的发布流程和故障排除，请查看 [PyPI_PUBLISH.md](PyPI_PUBLISH.md)

## ⚠️ 注意事项

1. **首次发布**: 必须先在测试 PyPI 上验证
2. **版本管理**: PyPI 不允许覆盖已发布的版本
3. **API Token**: 请勿将 ~/.pypirc 提交到 Git
4. **不可撤销**: 正式发布后无法删除或覆盖

## 🔍 故障排除

### 包名冲突
如果 `mkmkv-smart` 已被占用，需要更改包名：
```toml
# pyproject.toml
name = "mkmkv-smart-tool"  # 或其他可用名称
```

### 版本已存在
更新版本号后重新构建：
```bash
# 更新 pyproject.toml 中的 version
rm -rf dist/ build/
python -m build
./publish_to_pypi.sh prod
```

### 认证失败
检查 ~/.pypirc 配置：
```ini
[pypi]
username = __token__  # 必须是 __token__
password = pypi-...   # 完整的 Token（包括 pypi- 前缀）
```

## 📚 相关命令

```bash
# 手动构建
python -m build

# 手动验证
twine check dist/*

# 手动上传（测试）
twine upload --repository testpypi dist/*

# 手动上传（正式）
twine upload dist/*

# 查看包信息
twine show dist/*
```
