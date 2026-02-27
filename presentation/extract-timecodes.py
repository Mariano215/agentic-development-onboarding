#!/usr/bin/env python3
"""
Extract word-level timestamps from voice-over MP3s using OpenAI Whisper.

Produces timecodes.json with per-slide word timing data that the
presentation uses to sync animations with narration.
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
        print("Error: OPENAI_API_KEY not found")
        sys.exit(1)

    from openai import OpenAI

    client = OpenAI(api_key=api_key)

    script_dir = Path(__file__).parent

    # Load narration metadata
    with open(script_dir / "narration.json") as f:
        narration = json.load(f)

    slides_data = []

    for slide in narration["slides"]:
        slide_num = slide["id"]
        title = slide["title"]
        audio_path = script_dir / slide["file"]

        if not audio_path.exists():
            print(f"  [{slide_num}] {title} — audio not found, skipping")
            slides_data.append({"id": slide_num, "title": title, "duration": 0, "words": [], "segments": []})
            continue

        print(f"  [{slide_num}/12] {title} — transcribing...", end="", flush=True)

        try:
            with open(audio_path, "rb") as af:
                transcript = client.audio.transcriptions.create(
                    model="whisper-1",
                    file=af,
                    response_format="verbose_json",
                    timestamp_granularities=["word", "segment"],
                )

            words = []
            if hasattr(transcript, "words") and transcript.words:
                for w in transcript.words:
                    words.append({
                        "word": w.word.strip(),
                        "start": round(w.start, 3),
                        "end": round(w.end, 3),
                    })

            segments = []
            if hasattr(transcript, "segments") and transcript.segments:
                for seg in transcript.segments:
                    segments.append({
                        "text": seg.text.strip() if hasattr(seg, "text") else seg.get("text", "").strip(),
                        "start": round(seg.start if hasattr(seg, "start") else seg.get("start", 0), 3),
                        "end": round(seg.end if hasattr(seg, "end") else seg.get("end", 0), 3),
                    })

            duration = 0
            if hasattr(transcript, "duration") and transcript.duration:
                duration = round(transcript.duration, 3)
            elif words:
                duration = words[-1]["end"]
            elif segments:
                duration = segments[-1]["end"]

            slides_data.append({
                "id": slide_num,
                "title": title,
                "duration": duration,
                "words": words,
                "segments": segments,
            })

            print(f" done ({len(words)} words, {duration:.1f}s)")

        except Exception as e:
            print(f" FAILED: {e}")
            slides_data.append({"id": slide_num, "title": title, "duration": 0, "words": [], "segments": []})

    # Write timecodes
    output_path = script_dir / "timecodes.json"
    with open(output_path, "w") as f:
        json.dump({"slides": slides_data}, f, indent=2)

    print(f"\nTimecodes saved to: {output_path}")
    total_duration = sum(s["duration"] for s in slides_data)
    print(f"Total narration duration: {total_duration:.1f}s ({total_duration/60:.1f} min)")


if __name__ == "__main__":
    main()
