#!/usr/bin/env python3
"""
CHS/CHT 语言代码支持示例

演示 mkmkv-smart 如何处理常见的 CHS (简体中文) 和 CHT (繁体中文) 语言代码。
这些是在中文字幕文件中非常常见的命名方式。
"""

from mkmkv_smart.normalizer import FileNormalizer
from mkmkv_smart.matcher import SmartMatcher


def example_chs_cht_recognition():
    """示例: CHS/CHT 语言代码识别"""
    print("=" * 70)
    print("示例: CHS/CHT 语言代码识别")
    print("=" * 70)

    normalizer = FileNormalizer()

    # 常见的中文字幕文件命名方式
    subtitle_files = [
        # CHS/CHT 格式
        "Movie.2024.CHS.srt",
        "Movie.2024.CHT.srt",
        "Movie.2024.chs.srt",
        "Movie.2024.cht.srt",

        # GB/Big5 格式
        "Series.S01E01.GB.srt",
        "Series.S01E01.Big5.srt",

        # 标准格式
        "Movie.2024.zh-hans.srt",
        "Movie.2024.zh-hant.srt",

        # 混合格式
        "Movie.2024.CHS&ENG.srt",  # 不会识别
        "Movie.CHS.cc.srt",
    ]

    print("字幕文件名 → 识别的语言代码\n")

    for filename in subtitle_files:
        lang_code = normalizer.extract_language_code(filename)
        if lang_code:
            print(f"{filename:<35s} → {lang_code}")
        else:
            print(f"{filename:<35s} → (未识别)")

    print()


def example_language_mapping():
    """示例: 语言代码到语言名称的映射"""
    print("=" * 70)
    print("示例: 语言代码到语言名称的映射")
    print("=" * 70)

    from mkmkv_smart.merger import MKVMerger, LANGUAGE_MAP

    print("支持的中文语言代码及其显示名称:\n")

    chinese_codes = [
        'zh', 'zh-hans', 'zh-hant',
        'chs', 'cht', 'gb', 'big5',
        'zh-cn', 'zh-hk', 'zh-tw'
    ]

    for code in chinese_codes:
        if code in LANGUAGE_MAP:
            name = LANGUAGE_MAP[code]
            print(f"  {code:<10s} → {name}")

    print()


def example_matching_with_chs_cht():
    """示例: 使用 CHS/CHT 进行匹配"""
    print("=" * 70)
    print("示例: 使用 CHS/CHT 进行匹配")
    print("=" * 70)

    matcher = SmartMatcher(threshold=30.0)

    video = "电影名称.2024.1080p.BluRay.mp4"
    subtitles = [
        "电影名称.2024.CHS.srt",
        "电影名称.2024.CHT.srt",
        "电影名称.2024.CHS&CHT.srt",
        "电影名称.2024.GB.srt",
    ]

    print(f"视频: {video}\n")
    print("匹配结果:\n")

    results = matcher.match_by_language(
        video,
        subtitles,
        language_priority=["zh-hans", "zh-hant"]
    )

    for lang, match in results.items():
        print(f"  [{lang}] {match.subtitle_file} (相似度: {match.similarity:.1f}%)")

    print()


def example_real_world_scenario():
    """示例: 真实场景 - 电影字幕"""
    print("=" * 70)
    print("示例: 真实场景 - 电影字幕")
    print("=" * 70)

    matcher = SmartMatcher(threshold=30.0)

    # 模拟一个真实场景
    video = "The.Matrix.1999.1080p.BluRay.x264.mp4"
    subtitles = [
        "The.Matrix.1999.CHS.srt",           # 简体
        "The.Matrix.1999.CHT.srt",           # 繁体
        "The.Matrix.1999.CHS&CHT.srt",       # 双语 (不会识别为单一语言)
        "The.Matrix.1999.720p.CHS.srt",      # 不同分辨率的简体
        "The.Matrix.1999.BluRay.CHT.srt",    # 同来源的繁体
    ]

    print(f"视频: {video}\n")
    print("可用字幕:\n")

    for i, sub in enumerate(subtitles, 1):
        normalizer = FileNormalizer()
        lang = normalizer.extract_language_code(sub)
        similarity = matcher.calculate_similarity(video, sub)
        print(f"  {i}. {sub}")
        print(f"     语言: {lang or '未识别':<10s} 相似度: {similarity:.1f}%")

    print("\n按语言分组匹配:\n")

    results = matcher.match_by_language(
        video,
        subtitles,
        language_priority=["zh-hans", "zh-hant"]
    )

    for lang, match in results.items():
        print(f"  [{lang}] {match.subtitle_file}")
        print(f"         相似度: {match.similarity:.1f}%")

    print()


def example_batch_with_chs_cht():
    """示例: 批量处理 CHS/CHT 字幕"""
    print("=" * 70)
    print("示例: 批量处理 CHS/CHT 字幕")
    print("=" * 70)

    matcher = SmartMatcher(threshold=30.0)

    videos = [
        "Movie.A.2024.1080p.mp4",
        "Movie.B.2024.1080p.mp4",
        "Series.S01E01.720p.mp4",
    ]

    subtitles = [
        "Movie.A.2024.CHS.srt",
        "Movie.A.2024.CHT.srt",
        "Movie.B.2024.CHS.srt",
        "Series.S01E01.CHS.srt",
        "Series.S01E01.CHT.srt",
    ]

    print("批量匹配结果:\n")

    results = matcher.batch_match(
        videos,
        subtitles,
        language_priority=["zh-hans", "zh-hant"]
    )

    for video, matches in results.items():
        print(f"视频: {video}")
        if matches:
            for lang, match in matches.items():
                print(f"  └─ [{lang}] {match.subtitle_file}")
        else:
            print("  └─ (无匹配)")
        print()


def main():
    """运行所有示例"""
    print("\n🎬 CHS/CHT 语言代码支持示例\n")

    examples = [
        example_chs_cht_recognition,
        example_language_mapping,
        example_matching_with_chs_cht,
        example_real_world_scenario,
        example_batch_with_chs_cht,
    ]

    for example in examples:
        example()
        print()


if __name__ == '__main__':
    main()
