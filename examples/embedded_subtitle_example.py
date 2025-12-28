#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
嵌入字幕检测和保留功能示例

展示如何使用 mkmkv-smart 的嵌入字幕检测功能
"""

import sys
from pathlib import Path

# 添加项目路径
sys.path.insert(0, str(Path(__file__).parent.parent / 'src'))

from mkmkv_smart.audio_editor import AudioTrackEditor
from mkmkv_smart.language_detector import LanguageDetector
from mkmkv_smart.merger import MKVMerger, SubtitleTrack


def example_1_get_subtitle_info():
    """示例 1: 获取视频文件的字幕轨道信息"""
    print("=" * 70)
    print("示例 1: 获取字幕轨道信息")
    print("=" * 70)

    editor = AudioTrackEditor()
    video_file = "/path/to/video.mkv"  # 替换为实际文件路径

    # 获取字幕轨道信息
    subtitle_tracks = editor.get_subtitle_tracks_info(video_file)

    if subtitle_tracks:
        print(f"\n找到 {len(subtitle_tracks)} 个字幕轨道:\n")
        for i, track in enumerate(subtitle_tracks, 1):
            print(f"字幕 {i}:")
            print(f"  轨道 ID: {track['track_id']}")
            print(f"  编码格式: {track['codec']}")
            print(f"  语言代码: {track['language']}")
            print(f"  轨道名称: {track['track_name'] or '(未设置)'}")
            print()
    else:
        print("\n未找到字幕轨道")

    print()


def example_2_detect_and_set():
    """示例 2: 检测并设置嵌入字幕语言"""
    print("=" * 70)
    print("示例 2: 检测并设置嵌入字幕语言")
    print("=" * 70)

    editor = AudioTrackEditor()
    detector = LanguageDetector()
    video_file = "/path/to/video.mkv"  # 替换为实际文件路径

    # 检测并设置（干运行模式）
    print("\n干运行模式 - 仅检测不修改:\n")
    results = editor.detect_and_set_embedded_subtitle_languages(
        video_file,
        language_detector=detector,
        dry_run=True
    )

    if results:
        print(f"检测到 {len(results)} 个需要设置语言的字幕:\n")
        for idx, info in results.items():
            print(f"字幕轨道 {idx}:")
            print(f"  检测代码: {info['detected_code']}")
            print(f"  ISO 639-2: {info['language_code']}")
            print(f"  轨道名称: {info['track_name']}")
            print(f"  置信度: {info['confidence']:.1%}")
            print()

        # 实际设置（取消注释以执行）
        # print("\n实际设置语言:\n")
        # results = editor.detect_and_set_embedded_subtitle_languages(
        #     video_file,
        #     language_detector=detector,
        #     dry_run=False
        # )
        # print("✓ 语言设置完成")
    else:
        print("所有嵌入字幕均已标记语言")

    print()


def example_3_merge_with_embedded():
    """示例 3: 合并外部字幕并保留嵌入字幕"""
    print("=" * 70)
    print("示例 3: 合并外部字幕并保留嵌入字幕")
    print("=" * 70)

    # 准备外部字幕
    external_subtitles = [
        SubtitleTrack(
            file_path="/path/to/subtitle.zh-Hans.srt",
            language_code="zh-hans",
            track_name="简体中文",
            is_default=True
        ),
        SubtitleTrack(
            file_path="/path/to/subtitle.en.srt",
            language_code="en",
            track_name="English",
            is_default=False
        ),
    ]

    # 合并时保留嵌入字幕
    merger = MKVMerger()

    print("\n合并外部字幕并保留嵌入字幕...\n")
    success = merger.merge(
        video_file="/path/to/video.mkv",
        subtitle_tracks=external_subtitles,
        output_file="/path/to/output.mkv",
        keep_embedded_subtitles=True,  # 保留嵌入字幕
        dry_run=True  # 干运行模式
    )

    if success:
        print("\n✓ 合并成功")
        print("\n输出文件将包含:")
        print("  - 原视频")
        print("  - 嵌入字幕（保留）")
        print("  - 外部字幕（新增）")
    else:
        print("\n✗ 合并失败")

    print()


def example_4_complete_workflow():
    """示例 4: 完整工作流 - 检测嵌入字幕 + 合并外部字幕"""
    print("=" * 70)
    print("示例 4: 完整工作流")
    print("=" * 70)

    editor = AudioTrackEditor()
    detector = LanguageDetector()
    merger = MKVMerger()

    video_file = "/path/to/video.mkv"
    output_file = "/path/to/output.mkv"

    # 步骤 1: 检测并设置嵌入字幕语言
    print("\n步骤 1: 检测并设置嵌入字幕语言...\n")
    detected = editor.detect_and_set_embedded_subtitle_languages(
        video_file,
        language_detector=detector,
        dry_run=True  # 实际使用时设为 False
    )

    if detected:
        print(f"✓ 检测到 {len(detected)} 个字幕并设置语言")
        for idx, info in detected.items():
            print(f"  字幕 {idx}: {info['track_name']}")
    else:
        print("✓ 所有嵌入字幕均已标记")

    # 步骤 2: 准备外部字幕
    print("\n步骤 2: 准备外部字幕...\n")
    external_subtitles = [
        SubtitleTrack(
            file_path="/path/to/subtitle.zh-Hans.srt",
            language_code="zh-hans",
            track_name="简体中文",
            is_default=True
        ),
    ]
    print(f"✓ 准备了 {len(external_subtitles)} 个外部字幕")

    # 步骤 3: 合并所有字幕
    print("\n步骤 3: 合并字幕到新文件...\n")
    success = merger.merge(
        video_file=video_file,
        subtitle_tracks=external_subtitles,
        output_file=output_file,
        keep_embedded_subtitles=True,
        dry_run=True  # 实际使用时设为 False
    )

    if success:
        print("✓ 合并完成")
        print(f"\n输出文件: {output_file}")
        print("包含:")
        print("  - 原视频流")
        print("  - 原音频流")
        if detected:
            print(f"  - {len(detected)} 个嵌入字幕（已设置语言）")
        print(f"  - {len(external_subtitles)} 个外部字幕")
    else:
        print("✗ 合并失败")

    print()


def example_5_set_single_subtitle():
    """示例 5: 手动设置单个字幕轨道的语言"""
    print("=" * 70)
    print("示例 5: 手动设置单个字幕轨道语言")
    print("=" * 70)

    editor = AudioTrackEditor()
    video_file = "/path/to/video.mkv"

    # 设置第一个字幕轨道（索引 0）为日语
    print("\n设置字幕轨道 0 为日语...\n")
    success = editor.set_subtitle_track_language(
        video_file=video_file,
        track_index=0,  # 第一个字幕轨道
        language_code="jpn",  # ISO 639-2 代码
        track_name="日本語"  # 原生名称
    )

    if success:
        print("✓ 语言设置成功")
        print("  语言代码: jpn")
        print("  轨道名称: 日本語")
    else:
        print("✗ 语言设置失败")

    print()


def main():
    """主函数"""
    print("\nmkmkv-smart 嵌入字幕检测功能示例\n")

    print("注意: 这些示例需要实际的 MKV 文件才能运行")
    print("请将代码中的 '/path/to/video.mkv' 替换为实际文件路径\n")

    # 运行示例
    try:
        example_1_get_subtitle_info()
        example_2_detect_and_set()
        example_3_merge_with_embedded()
        example_4_complete_workflow()
        example_5_set_single_subtitle()

        print("=" * 70)
        print("所有示例运行完成")
        print("=" * 70)

    except Exception as e:
        print(f"\n错误: {e}")
        import traceback
        traceback.print_exc()


if __name__ == '__main__':
    main()
