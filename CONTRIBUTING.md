# 贡献指南

感谢你对 mkmkv-smart 项目的关注! 我们欢迎各种形式的贡献。

## 📋 目录

- [行为准则](#行为准则)
- [如何贡献](#如何贡献)
- [开发设置](#开发设置)
- [代码规范](#代码规范)
- [提交规范](#提交规范)
- [测试要求](#测试要求)
- [文档更新](#文档更新)

## 行为准则

本项目遵循 [贡献者公约](https://www.contributor-covenant.org/)。参与本项目即表示你同意遵守其条款。

## 如何贡献

### 报告 Bug

在提交 Bug 报告前，请:

1. 检查现有 [Issues](https://github.com/cnsunyour/mkmkv-smart/issues) 是否已有相同问题
2. 确保使用最新版本
3. 准备好复现步骤

提交 Bug 时请包含:

- **标题**: 简明扼要的问题描述
- **环境**: 操作系统、Python 版本、mkvmerge 版本
- **复现步骤**: 详细的步骤说明
- **预期行为**: 应该发生什么
- **实际行为**: 实际发生了什么
- **错误信息**: 完整的错误日志
- **截图**: 如果适用

### 提出新功能

功能请求应包含:

- **用例**: 为什么需要这个功能?
- **建议实现**: 你期望如何使用?
- **替代方案**: 考虑过的其他方案
- **影响**: 对现有功能的影响

### 提交代码

1. **Fork 仓库**
   ```bash
   # 点击 GitHub 上的 Fork 按钮
   ```

2. **克隆你的 Fork**
   ```bash
   git clone https://github.com/YOUR_USERNAME/mkmkv-smart.git
   cd mkmkv-smart
   ```

3. **添加上游仓库**
   ```bash
   git remote add upstream https://github.com/ORIGINAL_OWNER/mkmkv-smart.git
   ```

4. **创建功能分支**
   ```bash
   git checkout -b feature/your-feature-name
   ```

5. **进行更改**
   - 编写代码
   - 添加测试
   - 更新文档

6. **提交更改**
   ```bash
   git add .
   git commit -m "feat: 添加新功能"
   ```

7. **推送到 Fork**
   ```bash
   git push origin feature/your-feature-name
   ```

8. **创建 Pull Request**
   - 在 GitHub 上创建 PR
   - 填写 PR 模板
   - 等待审核

## 开发设置

### 1. 环境准备

```bash
# 安装 Python 3.8+
# macOS
brew install python@3.11

# Ubuntu
sudo apt install python3.11

# 创建虚拟环境
python3 -m venv venv
source venv/bin/activate  # Linux/macOS
# 或
venv\Scripts\activate     # Windows
```

### 2. 安装依赖

```bash
# 安装开发依赖
pip install -e ".[dev]"

# 安装 pre-commit hooks
pip install pre-commit
pre-commit install
```

### 3. 验证设置

```bash
# 运行测试
pytest

# 检查代码格式
black --check src/ tests/

# 类型检查
mypy src/
```

## 代码规范

### Python 代码风格

- 遵循 [PEP 8](https://peps.python.org/pep-0008/)
- 使用 [Black](https://github.com/psf/black) 格式化代码
- 使用类型注解 (PEP 484)
- 最大行长度: 100 字符

### 格式化代码

```bash
# 格式化所有代码
black src/ tests/

# 检查而不修改
black --check src/ tests/
```

### 类型检查

```bash
# 运行 mypy
mypy src/

# 检查单个文件
mypy src/mkmkv_smart/matcher.py
```

### 命名约定

- **类**: `PascalCase` (例: `SmartMatcher`)
- **函数/方法**: `snake_case` (例: `calculate_similarity`)
- **常量**: `UPPER_SNAKE_CASE` (例: `LANGUAGE_MAP`)
- **私有**: 前缀 `_` (例: `_internal_method`)

### 注释规范

```python
def function_name(param1: str, param2: int) -> bool:
    """
    简短描述(一行)

    更详细的描述(可选,多行)

    Args:
        param1: 参数 1 的说明
        param2: 参数 2 的说明

    Returns:
        返回值说明

    Raises:
        ValueError: 何时抛出此异常

    Examples:
        >>> function_name("test", 42)
        True
    """
    pass
```

## 提交规范

使用 [Conventional Commits](https://www.conventionalcommits.org/) 规范:

### 提交类型

- `feat`: 新功能
- `fix`: Bug 修复
- `docs`: 文档更新
- `style`: 代码格式(不影响功能)
- `refactor`: 重构(不是新功能也不是 Bug 修复)
- `test`: 测试相关
- `chore`: 构建/工具配置

### 提交格式

```
<type>(<scope>): <subject>

<body>

<footer>
```

### 示例

```bash
# 新功能
git commit -m "feat(matcher): 添加 WRatio 算法支持"

# Bug 修复
git commit -m "fix(cli): 修复干运行模式输出错误"

# 文档
git commit -m "docs: 更新安装说明"

# 重构
git commit -m "refactor(normalizer): 优化正则表达式性能"
```

## 测试要求

### 编写测试

每个新功能或 Bug 修复都应包含测试:

```python
def test_new_feature():
    """测试新功能"""
    # Arrange - 准备测试数据
    matcher = SmartMatcher()

    # Act - 执行操作
    result = matcher.new_feature()

    # Assert - 验证结果
    assert result == expected_value
```

### 运行测试

```bash
# 运行所有测试
pytest

# 运行特定测试
pytest tests/test_matcher.py

# 带覆盖率
pytest --cov=src/mkmkv_smart --cov-report=term-missing

# 生成 HTML 报告
pytest --cov=src/mkmkv_smart --cov-report=html
```

### 测试覆盖率

- 新代码应有 **≥80%** 的测试覆盖率
- 关键路径应有 **100%** 覆盖
- PR 不应降低整体覆盖率

## 文档更新

### 何时更新文档

- 添加新功能
- 修改 API
- 添加配置选项
- 修复重要 Bug

### 需要更新的文档

1. **README.md**: 主要功能变更
2. **QUICKSTART.md**: 影响基本使用流程
3. **代码注释**: 所有公开 API
4. **示例**: 新功能的使用示例
5. **CHANGELOG.md**: 所有用户可见的变更

### 文档风格

- 使用中文
- 简洁明了
- 包含代码示例
- 使用 Markdown 格式

## Pull Request 检查清单

提交 PR 前请确认:

- [ ] 代码遵循项目风格指南
- [ ] 添加了必要的测试
- [ ] 所有测试通过
- [ ] 更新了相关文档
- [ ] 提交信息遵循规范
- [ ] PR 描述清楚说明了变更内容
- [ ] 解决了所有 review 意见

## 审核流程

1. **自动检查**: CI 运行测试和代码检查
2. **代码审核**: 维护者审核代码
3. **讨论**: 如有问题会留下评论
4. **修改**: 根据反馈修改代码
5. **合并**: 审核通过后合并

## 发布流程

项目使用语义化版本 (SemVer):

- **主版本** (1.0.0): 不兼容的 API 变更
- **次版本** (0.1.0): 向后兼容的新功能
- **修订版本** (0.0.1): 向后兼容的 Bug 修复

## 获取帮助

- **问题**: 在 [Issues](https://github.com/yourusername/mkmkv-smart/issues) 提问
- **讨论**: 在 [Discussions](https://github.com/yourusername/mkmkv-smart/discussions) 交流
- **聊天**: 加入我们的社区频道 (如果有)

## 致谢

感谢所有贡献者! 🎉

你的贡献让 mkmkv-smart 变得更好!
