# AhaTTS

<p align="center">
  <a href="https://github.com/IHKYoung/AhaTTS/stargazers"><img src="https://img.shields.io/github/stars/IHKYoung/AhaTTS?style=flat" alt="GitHub stars" /></a>
  <a href="https://github.com/IHKYoung/AhaTTS/forks"><img src="https://img.shields.io/github/forks/IHKYoung/AhaTTS?style=flat" alt="GitHub forks" /></a>
  <a href="https://github.com/IHKYoung/AhaTTS/issues"><img src="https://img.shields.io/github/issues/IHKYoung/AhaTTS?style=flat" alt="GitHub issues" /></a>
  <a href="https://github.com/IHKYoung/AhaTTS/pulls"><img src="https://img.shields.io/github/issues-pr/IHKYoung/AhaTTS?style=flat" alt="GitHub pull requests" /></a>
  <a href="https://github.com/IHKYoung/AhaTTS/commits/main"><img src="https://img.shields.io/github/last-commit/IHKYoung/AhaTTS?style=flat" alt="Last commit" /></a>
</p>

<p align="center">
  <a href="https://github.com/IHKYoung/AhaTTS/releases"><img src="https://img.shields.io/github/v/release/IHKYoung/AhaTTS?style=flat" alt="Release" /></a>
  <a href="LICENSE"><img src="https://img.shields.io/badge/License-CC%20BY--NC%204.0-lightgrey?style=flat&logo=creative-commons&logoColor=white" alt="License: CC BY-NC 4.0" /></a>
  <img src="https://img.shields.io/badge/Python-3.10%2B-3776AB?logo=python&logoColor=white" alt="Python 3.10+" />
  <img src="https://img.shields.io/badge/OpenAI-Compatible-000000?logo=openai&logoColor=white" alt="OpenAI Compatible" />
  <img src="https://img.shields.io/badge/Text--to--Speech-Voice-ff8c00?logo=audacity&logoColor=white" alt="Text-to-Speech" />
</p>

<p align="center">
  <em>Language: English is open by default. Click the section headers to switch.</em>
</p>

AhaTTS is an open-source, production-ready text-to-speech service with an OpenAI-compatible API and a built-in web demo.

<p align="center">
  <img src="assets/AhaTTS.png" alt="AhaTTS" width="720" />
</p>

<details open>
<summary id="english"><strong>English</strong></summary>

### Highlights
- OpenAI-compatible API for drop-in integration
- Built-in `api/web` demo UI
- CPU / CUDA / MPS support
- Multi-language and multi-voice (Kokoro)
- Streaming output with high-quality audio

### Quickstart
```bash
./scripts/install.sh --device cpu   # or gpu / mac
./scripts/dev.sh
```

Visit:
- http://localhost:25288/docs
- http://localhost:25288/web/

</details>

<details>
<summary id="简体中文"><strong>简体中文</strong></summary>

AhaTTS 是开源、轻部署的语音合成服务，提供 OpenAI 兼容 API 与内置 Web 演示页面。

### 亮点
- OpenAI 兼容 API，便于集成
- 内置 `api/web` 演示页面
- CPU / CUDA / MPS 支持
- 多语言与多音色（Kokoro）
- 流式输出与高质量音频

### 快速开始
```bash
./scripts/install.sh --device cpu   # 或 gpu / mac
./scripts/dev.sh
```

访问：
- http://localhost:25288/docs
- http://localhost:25288/web/
</details>
