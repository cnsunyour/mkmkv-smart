"""
Pytest 配置和共享 fixtures
"""

import pytest
import tempfile
from pathlib import Path


@pytest.fixture
def temp_dir():
    """创建临时目录的 fixture"""
    with tempfile.TemporaryDirectory() as tmpdir:
        yield Path(tmpdir)


@pytest.fixture
def sample_video_files(temp_dir):
    """创建示例视频文件的 fixture"""
    files = [
        "Movie.2024.1080p.BluRay.x264.mp4",
        "Series.S01E01.720p.WEB-DL.mp4",
        "Documentary.4K.HDR.mp4",
    ]

    for filename in files:
        (temp_dir / filename).touch()

    return [temp_dir / f for f in files]


@pytest.fixture
def sample_subtitle_files(temp_dir):
    """创建示例字幕文件的 fixture"""
    files = [
        "Movie.2024.zh-hans.srt",
        "Movie.2024.en.srt",
        "Series.S01E01.zh.srt",
    ]

    for filename in files:
        (temp_dir / filename).touch()

    return [temp_dir / f for f in files]


@pytest.fixture
def sample_config():
    """创建示例配置的 fixture"""
    from mkmkv_smart.config import Config, MatchConfig, LanguageConfig

    config = Config()
    config.match = MatchConfig(
        threshold=35.0,
        method="hybrid"
    )
    config.language = LanguageConfig(
        priority=["zh-hans", "en", "ja"]
    )

    return config
