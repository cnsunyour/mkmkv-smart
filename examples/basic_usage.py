#!/usr/bin/env python3
"""
基础使用示例

演示如何在 Python 代码中使用 mkmkv-smart 的核心功能。
"""

from pathlib import Path
from mkmkv_smart.normalizer import FileNormalizer
from mkmkv_smart.matcher import SmartMatcher
from mkmkv_smart.merger import MKVMerger, SubtitleTrack
from mkmkv_smart.config import Config


def example_1_normalizer():
    """示例 1: 文件名规范化"""
    print("=" * 70)
    print("示例 1: 文件名规范化")
    print("=" * 70)

    normalizer = FileNormalizer()

    test_files = [
        "Movie.2024.1080p.BluRay.x264.AAC.mp4",
        "Series.S01E01.720p.WEB-DL.H264.mp4",
        "The.Matrix.1999.4K.UHD.HDR.HEVC.mp4",
    ]

    for filename in test_files:
        normalized = normalizer.normalize(filename)
        print(f"原始:   {filename}")
        print(f"规范化: {normalized}")
        print()


def example_2_language_extraction():
    """示例 2: 语言代码提取"""
    print("=" * 70)
    print("示例 2: 语言代码提取")
    print("=" * 70)

    normalizer = FileNormalizer()

    subtitle_files = [
        "Movie.2024.zh-hans.srt",
        "Movie.2024.zh-hant.srt",
        "Movie.2024.en.srt",
        "Movie.2024.ja.ass",
    ]

    for filename in subtitle_files:
        lang_code = normalizer.extract_language_code(filename)
        print(f"文件: {filename}")
        print(f"语言: {lang_code}")
        print()


def example_3_similarity_calculation():
    """示例 3: 相似度计算"""
    print("=" * 70)
    print("示例 3: 相似度计算")
    print("=" * 70)

    matcher = SmartMatcher(threshold=30.0)

    video = "The.Matrix.1999.1080p.BluRay.x264.mp4"
    subtitles = [
        "The.Matrix.1999.zh-hans.srt",
        "The.Matrix.1999.WEB-DL.en.srt",
        "Matrix.Reloaded.2003.zh.srt",  # 不同电影
    ]

    print(f"视频: {video}\n")

    for sub in subtitles:
        similarity = matcher.calculate_similarity(video, sub)
        print(f"字幕: {sub}")
        print(f"相似度: {similarity:.1f}%")
        print(f"匹配: {'✓' if similarity >= 30 else '✗'}")
        print()


def example_4_batch_matching():
    """示例 4: 批量匹配"""
    print("=" * 70)
    print("示例 4: 批量匹配")
    print("=" * 70)

    matcher = SmartMatcher(threshold=30.0)

    videos = [
        "Movie.A.2024.1080p.mp4",
        "Movie.B.2024.1080p.mp4",
    ]

    subtitles = [
        "Movie.A.2024.zh-hans.srt",
        "Movie.A.2024.en.srt",
        "Movie.B.2024.zh-hans.srt",
    ]

    results = matcher.batch_match(
        videos,
        subtitles,
        language_priority=["zh-hans", "en"]
    )

    for video, matches in results.items():
        print(f"视频: {video}")
        for lang, match in matches.items():
            print(f"  [{lang}] {match.subtitle_file} ({match.similarity:.1f}%)")
        print()


def example_5_config():
    """示例 5: 配置管理"""
    print("=" * 70)
    print("示例 5: 配置管理")
    print("=" * 70)

    # 创建配置
    config = Config()
    config.match.threshold = 35.0
    config.match.method = "token_set"
    config.language.priority = ["en", "zh-hans", "ja"]

    print("配置内容:")
    print(f"  阈值: {config.match.threshold}")
    print(f"  方法: {config.match.method}")
    print(f"  语言优先级: {', '.join(config.language.priority)}")
    print()

    # 保存配置
    import tempfile
    with tempfile.NamedTemporaryFile(mode='w', suffix='.yaml', delete=False) as f:
        temp_file = f.name

    config.save(temp_file)
    print(f"配置已保存到: {temp_file}")

    # 加载配置
    loaded_config = Config.load(temp_file)
    print(f"加载的阈值: {loaded_config.match.threshold}")

    # 清理
    Path(temp_file).unlink()


def example_6_subtitle_track():
    """示例 6: 创建字幕轨道"""
    print("=" * 70)
    print("示例 6: 创建字幕轨道")
    print("=" * 70)

    # 创建字幕轨道
    tracks = [
        SubtitleTrack(
            file_path="/path/to/movie.zh-hans.srt",
            language_code="zh-hans",
            track_name="简体中文",
            is_default=True,
            charset="UTF-8"
        ),
        SubtitleTrack(
            file_path="/path/to/movie.en.srt",
            language_code="en",
            track_name="English",
            is_default=False,
            charset="UTF-8"
        ),
    ]

    print("字幕轨道:")
    for i, track in enumerate(tracks, 1):
        print(f"{i}. {track.track_name} ({track.language_code})")
        print(f"   文件: {track.file_path}")
        print(f"   默认: {'是' if track.is_default else '否'}")
        print()


def main():
    """运行所有示例"""
    print("\n🎬 mkmkv-smart 使用示例\n")

    examples = [
        example_1_normalizer,
        example_2_language_extraction,
        example_3_similarity_calculation,
        example_4_batch_matching,
        example_5_config,
        example_6_subtitle_track,
    ]

    for example in examples:
        example()
        print()


if __name__ == '__main__':
    main()
