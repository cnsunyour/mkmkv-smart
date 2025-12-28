#!/bin/bash
# PyPI 发布脚本
# 使用方法: ./publish_to_pypi.sh [test|prod]

set -e

MODE=${1:-test}

echo "======================================"
echo "  mkmkv-smart PyPI 发布脚本"
echo "======================================"
echo ""

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 检查 twine 是否安装
if ! command -v twine &> /dev/null; then
    echo -e "${RED}错误: twine 未安装${NC}"
    echo "请运行: pip install twine"
    exit 1
fi

# 检查分发包是否存在
if [ ! -d "dist" ] || [ -z "$(ls -A dist 2>/dev/null)" ]; then
    echo -e "${YELLOW}警告: dist/ 目录不存在或为空${NC}"
    echo "正在构建分发包..."
    rm -rf dist/ build/
    python -m build
    echo -e "${GREEN}✓ 构建完成${NC}"
fi

# 验证分发包
echo ""
echo "验证分发包..."
twine check dist/*
if [ $? -ne 0 ]; then
    echo -e "${RED}✗ 分发包验证失败${NC}"
    exit 1
fi
echo -e "${GREEN}✓ 分发包验证通过${NC}"

# 列出分发包
echo ""
echo "分发包列表:"
ls -lh dist/
echo ""

# 根据模式选择仓库
if [ "$MODE" = "test" ]; then
    REPO="testpypi"
    REPO_URL="https://test.pypi.org/simple/"
    echo -e "${YELLOW}模式: 测试 PyPI (test.pypi.org)${NC}"
    echo ""
    echo "请确保你已经:"
    echo "  1. 在 https://test.pypi.org/ 注册账号"
    echo "  2. 创建 API Token"
    echo "  3. 配置 ~/.pypirc 文件"
    echo ""
elif [ "$MODE" = "prod" ]; then
    REPO="pypi"
    REPO_URL="https://pypi.org/simple/"
    echo -e "${RED}模式: 正式 PyPI (pypi.org)${NC}"
    echo ""
    echo -e "${YELLOW}警告: 这将发布到正式 PyPI，此操作不可撤销！${NC}"
    echo ""
    echo "请确保你已经:"
    echo "  1. 在测试 PyPI 上验证过"
    echo "  2. 更新了 CHANGELOG.md"
    echo "  3. 创建了 Git 标签"
    echo "  4. 在 https://pypi.org/ 创建了 API Token"
    echo "  5. 配置了 ~/.pypirc 文件"
    echo ""
    read -p "确认发布到正式 PyPI? (yes/no): " CONFIRM
    if [ "$CONFIRM" != "yes" ]; then
        echo "已取消"
        exit 0
    fi
else
    echo -e "${RED}错误: 无效的模式 '$MODE'${NC}"
    echo "使用方法: $0 [test|prod]"
    exit 1
fi

# 上传
echo ""
echo "正在上传到 $REPO..."
twine upload --repository $REPO dist/*

if [ $? -eq 0 ]; then
    echo ""
    echo -e "${GREEN}======================================"
    echo "  ✓ 上传成功！"
    echo "======================================${NC}"
    echo ""

    if [ "$MODE" = "test" ]; then
        echo "验证安装:"
        echo "  pip install --index-url https://test.pypi.org/simple/ \\"
        echo "    --extra-index-url https://pypi.org/simple/ \\"
        echo "    mkmkv-smart"
        echo ""
        echo "如果测试成功，运行以下命令发布到正式 PyPI:"
        echo "  ./publish_to_pypi.sh prod"
    else
        echo "验证安装:"
        echo "  pip install mkmkv-smart"
        echo ""
        echo "查看项目页面:"
        echo "  https://pypi.org/project/mkmkv-smart/"
        echo ""
        echo "后续步骤:"
        echo "  1. 测试安装: pip install mkmkv-smart"
        echo "  2. 验证命令: mkmkv-smart --version"
        echo "  3. 更新 GitHub Release: gh release upload v1.1.1 dist/* --clobber"
        echo "  4. 宣传推广"
    fi
else
    echo ""
    echo -e "${RED}======================================"
    echo "  ✗ 上传失败"
    echo "======================================${NC}"
    echo ""
    echo "常见问题:"
    echo "  1. API Token 未配置: 检查 ~/.pypirc"
    echo "  2. 包名已存在: 检查是否已发布过"
    echo "  3. 版本已存在: 需要更新版本号"
    echo ""
    echo "详细说明请查看: PyPI_PUBLISH.md"
    exit 1
fi
