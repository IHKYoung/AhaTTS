# AhaTTS

<p align="center">
  <a href="https://github.com/IHKYoung/AhaTTS/commits/main"><img src="https://img.shields.io/github/last-commit/IHKYoung/AhaTTS?style=flat" alt="Last commit" /></a>
  <a href="LICENSE"><img src="https://img.shields.io/badge/License-CC%20BY--NC%204.0-lightgrey?style=flat&logo=creative-commons&logoColor=white" alt="License: CC BY-NC 4.0" /></a>
  <img src="https://img.shields.io/badge/Python-3.10%2B-3776AB?logo=python&logoColor=white" alt="Python 3.10+" />
  <img src="https://img.shields.io/badge/OpenAI-Compatible-000000?logo=openai&logoColor=white" alt="OpenAI Compatible" />
  <img src="https://img.shields.io/badge/Text--to--Speech-Voice-ff8c00?logo=audacity&logoColor=white" alt="Text-to-Speech" />
</p>

<p align="center">
  <strong>Language:</strong> <a href="README.md">English</a> | <a href="README.zh-CN.md">简体中文</a>
</p>

AhaTTS is an open-source, production-ready text-to-speech service with an OpenAI-compatible API and a built-in web demo.

<p align="center">
  <img src="assets/AhaTTS.png" alt="AhaTTS" width="720" />
</p>

## Highlights
- OpenAI-compatible API for drop-in integration
- Built-in `api/web` demo UI
- CPU / CUDA / MPS support
- Multi-language and multi-voice (Kokoro)
- Streaming output with high-quality audio

## Quickstart
```bash
./scripts/install.sh --device cpu   # or gpu / mac
./scripts/dev.sh
```

Visit:
- http://localhost:25288/docs
- http://localhost:25288/web/

## OpenAI Speech API
Request URL: `http(s)://<server-address>:<port>/v1/audio/speech` (POST).

Parameters:
- `model` (string, required): one of `tts-1` or `tts-1-hd`.
- `input` (string, required): text to generate audio from. Max length 4096 characters.
- `voice` (string, required): one of `alloy`, `ash`, `coral`, `echo`, `fable`, `onyx`, `nova`, `sage`, `shimmer`.
- `response_format` (string, optional): audio format, default `mp3`. Supported: `mp3`, `opus`, `aac`, `flac`.
- `speed` (number, optional): audio speed, default `1.0`. Range `0.5` to `2.0`.
