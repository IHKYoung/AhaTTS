#!/usr/bin/env python3
"""Download AhaTTS v1.0 model weights from Hugging Face."""

import json
import os
from pathlib import Path
from urllib.request import urlretrieve

from loguru import logger

MODEL_FILE = "kokoro-v1_0.pth"
CONFIG_FILE = "config.json"
MODEL_URL = (
    "https://huggingface.co/hexgrad/Kokoro-82M/resolve/main/kokoro-v1_0.pth"
)


def _verify_config(config_path: str) -> None:
    if not os.path.exists(config_path):
        raise RuntimeError(f"Missing config.json at {config_path}")
    try:
        with open(config_path, encoding="utf-8") as f:
            json.load(f)
    except Exception as exc:
        raise RuntimeError(f"Invalid config.json at {config_path}: {exc}") from exc


def _model_exists(model_path: str) -> bool:
    return os.path.exists(model_path) and os.path.getsize(model_path) > 0


def download_model(output_dir: str, force: bool = False) -> None:
    """Download model file from Hugging Face.

    Args:
        output_dir: Directory to save model file
        force: Whether to force re-download even if the model file exists
    """
    output_path = Path(output_dir)
    if output_path.exists() and not output_path.is_dir():
        raise RuntimeError(f"Output path exists and is not a directory: {output_dir}")

    os.makedirs(output_dir, exist_ok=True)

    model_path = os.path.join(output_dir, MODEL_FILE)
    config_path = os.path.join(output_dir, CONFIG_FILE)

    _verify_config(config_path)

    if _model_exists(model_path) and not force:
        logger.info("Model file already exists and is valid")
        return

    logger.info("Downloading AhaTTS v1.0 model weights")
    logger.info(f"Source: {MODEL_URL}")
    urlretrieve(MODEL_URL, model_path)

    if not _model_exists(model_path):
        raise RuntimeError("Failed to verify downloaded model file")

    logger.info(f"Model file prepared in {output_dir}")


def main() -> None:
    """Main entry point."""
    import argparse

    parser = argparse.ArgumentParser(
        description="Download AhaTTS v1.0 model weights"
    )
    parser.add_argument(
        "--output", required=True, help="Output directory for model files"
    )
    parser.add_argument(
        "--force",
        action="store_true",
        help="Force re-download even if the model file exists",
    )

    args = parser.parse_args()
    download_model(args.output, force=args.force)


if __name__ == "__main__":
    main()
