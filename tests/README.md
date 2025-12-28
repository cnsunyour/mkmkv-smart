# 测试文档

## 测试结构

```
tests/
├── __init__.py          # 测试包初始化
├── conftest.py          # Pytest 配置和共享 fixtures
├── test_normalizer.py   # 文件名规范化测试
├── test_matcher.py      # 智能匹配器测试
├── test_merger.py       # MKV 合并器测试
├── test_config.py       # 配置管理测试
└── test_cli.py          # 命令行界面测试
```

## 运行测试

### 安装依赖

```bash
# 安装开发依赖
pip install -e ".[dev]"
```

### 运行所有测试

```bash
# 运行所有测试
pytest

# 运行所有测试，显示详细输出
pytest -v

# 运行所有测试，显示覆盖率
pytest --cov=src/mkmkv_smart --cov-report=term-missing
```

### 运行特定测试

```bash
# 运行单个测试文件
pytest tests/test_normalizer.py

# 运行特定测试类
pytest tests/test_normalizer.py::TestFileNormalizer

# 运行特定测试方法
pytest tests/test_normalizer.py::TestFileNormalizer::test_normalize_basic

# 运行匹配特定名称的测试
pytest -k "normalize"
```

### 生成覆盖率报告

```bash
# 生成 HTML 覆盖率报告
pytest --cov=src/mkmkv_smart --cov-report=html

# 查看报告（macOS）
open htmlcov/index.html

# 查看报告（Linux）
xdg-open htmlcov/index.html
```

## 测试覆盖

### test_normalizer.py
- ✅ 基本文件名规范化
- ✅ 视频标签去除（分辨率、编码、来源等）
- ✅ 语言代码提取
- ✅ 剧集信息提取
- ✅ 年份提取
- ✅ 文件类型识别
- ✅ 自定义标签过滤
- ✅ 边界情况（空文件名、特殊字符等）

### test_matcher.py
- ✅ 相似度计算（5 种算法）
- ✅ 最佳匹配查找
- ✅ 多语言匹配
- ✅ 批量匹配
- ✅ 语言优先级
- ✅ 真实场景测试

### test_merger.py
- ✅ mkvmerge 可用性检查
- ✅ 语言名称映射
- ✅ 单个文件合并
- ✅ 批量合并
- ✅ 干运行模式
- ✅ 错误处理
- ✅ 命令行参数构建

### test_config.py
- ✅ 配置类初始化
- ✅ YAML 配置加载/保存
- ✅ 部分配置覆盖
- ✅ 默认配置生成
- ✅ 配置验证
- ✅ UTF-8 编码支持

### test_cli.py
- ✅ 文件收集
- ✅ 匹配结果显示
- ✅ 主流程执行
- ✅ 命令行参数解析
- ✅ 干运行模式
- ✅ 配置文件支持
- ✅ 错误处理

## 测试最佳实践

### 1. 使用 fixtures

```python
def test_with_temp_dir(temp_dir):
    """使用临时目录 fixture"""
    (temp_dir / "test.txt").touch()
    assert (temp_dir / "test.txt").exists()
```

### 2. Mock 外部依赖

```python
@patch('mkmkv_smart.merger.subprocess.run')
def test_merge(mock_run):
    """Mock subprocess 调用"""
    mock_run.return_value = Mock(returncode=0)
    # 测试代码...
```

### 3. 参数化测试

```python
@pytest.mark.parametrize("input,expected", [
    ("Movie.2024.mp4", "movie 2024"),
    ("Series.S01E01.mp4", "series s01e01"),
])
def test_normalize(input, expected):
    normalizer = FileNormalizer()
    assert normalizer.normalize(input) == expected
```

### 4. 测试边界情况

```python
def test_empty_input():
    """测试空输入"""
    result = normalizer.normalize("")
    assert result == ""
```

## 持续集成

测试可以集成到 CI/CD 流程中：

```yaml
# .github/workflows/test.yml
name: Tests

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: actions/setup-python@v2
      - run: pip install -e ".[dev]"
      - run: pytest
```

## 故障排除

### 导入错误

```bash
# 确保包已安装
pip install -e .
```

### 覆盖率不准确

```bash
# 清除缓存
pytest --cache-clear
rm -rf .pytest_cache
```

### Mock 不工作

确保 mock 路径正确：
```python
# ❌ 错误
@patch('subprocess.run')

# ✅ 正确
@patch('mkmkv_smart.merger.subprocess.run')
```
