#!/usr/bin/env bash
#
# 测试运行脚本
#
# 用法:
#   ./run_tests.sh           # 运行所有测试
#   ./run_tests.sh -v        # 详细模式
#   ./run_tests.sh -k name   # 运行匹配名称的测试

set -euo pipefail

# 颜色定义
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== mkmkv-smart 测试套件 ===${NC}\n"

# 检查是否在虚拟环境中
if [[ -z "${VIRTUAL_ENV:-}" ]]; then
    echo -e "${YELLOW}警告: 未检测到虚拟环境${NC}"
    echo "建议创建虚拟环境:"
    echo "  python3 -m venv venv"
    echo "  source venv/bin/activate"
    echo ""
fi

# 检查依赖
if ! python3 -c "import pytest" 2>/dev/null; then
    echo -e "${YELLOW}安装测试依赖...${NC}"
    pip install -e ".[dev]"
    echo ""
fi

# 运行测试
echo -e "${GREEN}运行测试...${NC}\n"

# 传递所有参数给 pytest
if [[ $# -eq 0 ]]; then
    # 无参数，运行默认测试
    pytest tests/ -v --cov=src/mkmkv_smart --cov-report=term-missing
else
    # 有参数，传递给 pytest
    pytest tests/ "$@"
fi

# 显示结果
echo ""
if [[ $? -eq 0 ]]; then
    echo -e "${GREEN}✓ 所有测试通过!${NC}"
else
    echo -e "${YELLOW}✗ 部分测试失败${NC}"
    exit 1
fi
