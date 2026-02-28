# CLAUDE.md — VibeOps Agentic Development Onboarding

## Project Overview

This repo teaches the **VibeOps methodology** — human-AI collaborative software development with verification-first practices. It contains a 5-phase onboarding tutorial and an interactive narrated presentation.

**Related repo:** The [Agentic Development Manifesto](https://github.com/Mariano215/agentic-development-manifesto) is maintained separately and is the living document we're seeking contributors for.

## Key Paths

| Path | Purpose |
|------|---------|
| `presentation/index.html` | 12-slide animated presentation with narrated voice-over |
| `presentation/audio/` | OpenAI TTS audio files (onyx voice, tts-1-hd model) |
| `presentation/narration.json` | Slide narration text, voice config |
| `presentation/timecodes.json` | Whisper STT word-level timestamps for animation sync |
| `presentation/generate-voiceover.py` | Regenerate audio (uses OpenAI TTS API) |
| `presentation/extract-timecodes.py` | Re-extract timecodes (uses OpenAI Whisper API) |
| `presentation/generate-og-image.py` | Regenerate social preview image |
| `presentation/deploy-hostpapa.sh` | Package files for HostPapa upload |
| `onboard.sh` | Master orchestrator for the tutorial system |
| `AGENTIC_DEVELOPMENT_MANIFESTO.md` | Core philosophy document |
| `tutorial-phases/` | 5-phase learning journey (phase0-phase4 dirs) |
| `verification-gates/` | Security, quality, deployment pipelines |

## Presentation Architecture

- **Slide transitions**: JS-controlled (no scroll-snap), slides are `position: absolute` stacked
- **Audio sync**: `requestAnimationFrame` loop checks `audio.currentTime` against `SLIDE_CUES` map
- **Animation cues**: Elements with `data-cue` attributes get `cue-active` class at specific timestamps
- **Timecodes source**: Whisper API word-level STT extraction → mapped to animation triggers
- **Autoplay**: Start overlay required for browser audio policy compliance
- **Slide durations**: Defined in `SLIDE_DURATIONS` array, derived from audio file lengths

## Regenerating Audio/Timecodes

All scripts use the OpenAI API key from `~/.config/openclaw/gateway.env`.

```bash
# Activate venv (required — system Python is externally managed)
cd presentation
python3 -m venv .venv  # only needed once
source .venv/bin/activate
pip install openai pillow  # only needed once

# Regenerate specific slides (delete the files first, script skips existing)
rm audio/slide-06.mp3 audio/slide-07.mp3
python generate-voiceover.py

# Re-extract timecodes after audio changes
python extract-timecodes.py

# Regenerate OG image
python generate-og-image.py
```

After regenerating audio, update `SLIDE_DURATIONS` and `SLIDE_CUES` in `index.html` to match the new timecodes.

## Deployment

- **GitHub Pages**: Auto-deploys via `.github/workflows/pages.yml` on push to main
- **Live URL**: https://mariano215.github.io/agentic-development-onboarding/presentation/
- **HostPapa**: Run `presentation/deploy-hostpapa.sh` → upload zip via cPanel to `public_html/vibeops/`
- **HostPapa URL**: https://matteisystems.com/vibeops/

## Phase Numbering

Phases are numbered **1-5** in the presentation and user-facing content (not 0-4), even though directory names use phase0-phase4.

## Conventions

- Audio files are committed to the repo (not gitignored)
- `.venv/` and `vibeops-deploy.zip` are gitignored
- OG meta tags in `index.html` point to matteisystems.com/vibeops/
- The methodology is AI-tool agnostic; the implementation uses Claude Code
