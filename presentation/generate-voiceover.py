#!/usr/bin/env python3
"""
Generate voice-over MP3 files for the VibeOps presentation.

Uses OpenAI's TTS API (tts-1-hd model, onyx voice) to generate
natural-sounding narration for each slide.

Usage:
    python3 generate-voiceover.py

Requires:
    - OPENAI_API_KEY in ~/.config/openclaw/gateway.env
    - pip install openai (if not already installed)
"""

import json
import os
import sys
from pathlib import Path

def load_env():
    """Load API key from OpenClaw gateway env file."""
    env_path = os.path.expanduser("~/.config/openclaw/gateway.env")
    if not os.path.exists(env_path):
        print(f"Error: {env_path} not found")
        sys.exit(1)

    with open(env_path) as f:
        for line in f:
            line = line.strip()
            if line and not line.startswith("#") and "=" in line:
                key, _, value = line.partition("=")
                os.environ.setdefault(key.strip(), value.strip().strip("'\""))

def main():
    load_env()

    api_key = os.environ.get("OPENAI_API_KEY")
    if not api_key:
        print("Error: OPENAI_API_KEY not found in environment")
        sys.exit(1)

    try:
        from openai import OpenAI
    except ImportError:
        print("Installing openai package...")
        os.system(f"{sys.executable} -m pip install openai")
        from openai import OpenAI

    client = OpenAI(api_key=api_key)

    # Load narration data
    script_dir = Path(__file__).parent
    narration_path = script_dir / "narration.json"

    with open(narration_path) as f:
        narration = json.load(f)

    voice = narration["voice"]
    model = narration["model"]
    audio_dir = script_dir / "audio"
    audio_dir.mkdir(exist_ok=True)

    total = len(narration["slides"])
    print(f"Generating {total} voice-over files...")
    print(f"  Model: {model}")
    print(f"  Voice: {voice}")
    print()

    for slide in narration["slides"]:
        output_path = script_dir / slide["file"]
        slide_num = slide["id"]
        title = slide["title"]

        if output_path.exists():
            print(f"  [{slide_num}/{total}] {title} — already exists, skipping")
            continue

        print(f"  [{slide_num}/{total}] {title} — generating...", end="", flush=True)

        try:
            response = client.audio.speech.create(
                model=model,
                voice=voice,
                input=slide["text"],
                response_format="mp3",
                speed=1.0,
            )

            response.stream_to_file(str(output_path))
            file_size = output_path.stat().st_size / 1024
            print(f" done ({file_size:.0f} KB)")

        except Exception as e:
            print(f" FAILED: {e}")
            continue

    print()
    print("Voice-over generation complete!")
    print(f"Files saved to: {audio_dir}")

    # Verify all files exist
    missing = []
    for slide in narration["slides"]:
        if not (script_dir / slide["file"]).exists():
            missing.append(slide["title"])

    if missing:
        print(f"\nWarning: {len(missing)} files missing:")
        for title in missing:
            print(f"  - {title}")
    else:
        print(f"All {total} audio files generated successfully.")

if __name__ == "__main__":
    main()
