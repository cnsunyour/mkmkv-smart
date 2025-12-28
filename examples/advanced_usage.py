#!/usr/bin/env python3
"""
高级使用示例

演示自定义规范化、多算法比较、复杂场景处理等高级功能。
"""

from pathlib import Path
from mkmkv_smart.normalizer import FileNormalizer
from mkmkv_smart.matcher import SmartMatcher, MatchResult


def example_custom_normalizer():
    """示例: 自定义规范化器"""
    print("=" * 70)
    print("示例: 自定义规范化器")
    print("=" * 70)

    # 添加自定义标签过滤
    custom_tags = [
        r'\\b(netflix|hulu|disney)\\b',  # 流媒体平台
        r'\\b(extended|uncut|directors\\.cut)\\b',  # 特殊版本
    ]

    normalizer = FileNormalizer(
        custom_tags=custom_tags,
        keep_year=False,  # 不保留年份
        keep_episode=True
    )

    test_file = "Movie.2024.Netflix.Directors.Cut.1080p.mp4"
    normalized = normalizer.normalize(test_file)

    print(f"原始:   {test_file}")
    print(f"规范化: {normalized}")
    print(f"\n说明: 去除了年份、Netflix 和 Directors.Cut 标签")
    print()


def example_algorithm_comparison():
    """示例: 不同算法比较"""
    print("=" * 70)
    print("示例: 不同算法比较")
    print("=" * 70)

    video = "The.Walking.Dead.S01E01.1080p.BluRay.x264.mp4"
    subtitle = "Walking.Dead.S01E01.WEB-DL.zh-hans.srt"

    methods = {
        'token_set': 'Token Set (集合匹配)',
        'token_sort': 'Token Sort (顺序无关)',
        'partial': 'Partial (部分匹配)',
        'ratio': 'Ratio (标准编辑距离)',
        'hybrid': 'Hybrid (混合策略)'
    }

    print(f"视频:   {video}")
    print(f"字幕:   {subtitle}\n")
    print("算法比较:\n")

    for method, name in methods.items():
        matcher = SmartMatcher(threshold=0, method=method)
        similarity = matcher.calculate_similarity(video, subtitle)
        print(f"{name:30s} {similarity:6.2f}%")

    print()


def example_language_priority():
    """示例: 语言优先级处理"""
    print("=" * 70)
    print("示例: 语言优先级处理")
    print("=" * 70)

    matcher = SmartMatcher(threshold=30.0)

    video = "Movie.2024.1080p.mp4"
    subtitles = [
        "Movie.2024.zh-hans.srt",
        "Movie.2024.zh-hant.srt",
        "Movie.2024.en.srt",
        "Movie.2024.ja.srt",
        "Movie.2024.ko.srt",
    ]

    # 不同的语言优先级
    priorities = [
        ["zh-hans", "en", "ja"],      # 简中优先
        ["en", "zh-hans", "ja"],      # 英文优先
        ["ja", "ko", "zh-hans", "en"] # 日文优先
    ]

    for i, priority in enumerate(priorities, 1):
        results = matcher.match_by_language(video, subtitles, priority)
        print(f"优先级 {i}: {' > '.join(priority)}")
        for lang, match in results.items():
            default = "★" if list(results.keys())[0] == lang else " "
            print(f"  {default} [{lang}] {match.subtitle_file}")
        print()


def example_complex_matching():
    """示例: 复杂场景匹配"""
    print("=" * 70)
    print("示例: 复杂场景匹配")
    print("=" * 70)

    matcher = SmartMatcher(threshold=25.0)

    # 模拟复杂场景：不同发布组、不同来源
    scenarios = [
        {
            'name': '场景 1: 不同发布组',
            'video': 'Movie.2024.1080p.BluRay.x264-GROUP1.mp4',
            'subtitle': 'Movie.2024.720p.WEB-DL.x264-GROUP2.zh.srt'
        },
        {
            'name': '场景 2: 缺失年份',
            'video': 'Movie.Name.1080p.BluRay.mp4',
            'subtitle': 'Movie.Name.2024.zh.srt'
        },
        {
            'name': '场景 3: 剧集不同格式',
            'video': 'Series.Name.S01E01.1080p.mp4',
            'subtitle': 'Series.Name.1x01.zh.srt'
        },
    ]

    for scenario in scenarios:
        print(f"\n{scenario['name']}")
        print(f"  视频:   {scenario['video']}")
        print(f"  字幕:   {scenario['subtitle']}")

        similarity = matcher.calculate_similarity(
            scenario['video'],
            scenario['subtitle']
        )

        print(f"  相似度: {similarity:.1f}%")
        print(f"  匹配:   {'✓ 成功' if similarity >= 25 else '✗ 失败'}")

    print()


def example_threshold_tuning():
    """示例: 阈值调优"""
    print("=" * 70)
    print("示例: 阈值调优")
    print("=" * 70)

    video = "Movie.2024.1080p.mp4"
    subtitles = [
        ("Movie.2024.zh.srt", "完全匹配"),
        ("Movie.zh.srt", "缺年份"),
        ("Movie.Name.2024.zh.srt", "多余信息"),
        ("Different.Movie.2024.zh.srt", "不同电影"),
    ]

    thresholds = [20, 30, 40, 50, 60]

    print(f"视频: {video}\n")
    print("阈值影响分析:\n")

    # 打印表头
    print(f"{'字幕文件':<35s} {'类型':<10s}", end="")
    for t in thresholds:
        print(f"{t:>6d}", end="")
    print()
    print("-" * 70)

    # 打印每个字幕在不同阈值下的匹配情况
    matcher = SmartMatcher(threshold=0)
    for sub, desc in subtitles:
        similarity = matcher.calculate_similarity(video, sub)
        print(f"{sub:<35s} {desc:<10s}", end="")

        for threshold in thresholds:
            match = "✓" if similarity >= threshold else "✗"
            print(f"{match:>6s}", end="")
        print(f"  ({similarity:.0f}%)")

    print("\n建议:")
    print("  - 阈值 20-30: 宽松匹配，可能误匹配")
    print("  - 阈值 30-40: 推荐值，平衡准确性和召回率")
    print("  - 阈值 40-50: 严格匹配，可能漏匹配")
    print("  - 阈值 50+:   非常严格，只匹配高度相似")
    print()


def example_edge_cases():
    """示例: 边界情况处理"""
    print("=" * 70)
    print("示例: 边界情况处理")
    print("=" * 70)

    normalizer = FileNormalizer()

    edge_cases = [
        ("", "空文件名"),
        (".mp4", "只有扩展名"),
        ("电影.2024.mp4", "中文文件名"),
        ("Movie@2024#Special!.mp4", "特殊字符"),
        ("Movie....2024...mp4", "多个点"),
        ("MOVIE.2024.MP4", "全大写"),
    ]

    print("边界情况测试:\n")

    for filename, desc in edge_cases:
        try:
            normalized = normalizer.normalize(filename) if filename else "(空)"
            print(f"{desc:<15s} {filename!r:<30s} → {normalized!r}")
        except Exception as e:
            print(f"{desc:<15s} {filename!r:<30s} → 错误: {e}")

    print()


def main():
    """运行所有高级示例"""
    print("\n🚀 mkmkv-smart 高级使用示例\n")

    examples = [
        example_custom_normalizer,
        example_algorithm_comparison,
        example_language_priority,
        example_complex_matching,
        example_threshold_tuning,
        example_edge_cases,
    ]

    for example in examples:
        example()
        print()


if __name__ == '__main__':
    main()
