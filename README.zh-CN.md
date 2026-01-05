# AhaTTS

<p align="center">
  <a href="https://github.com/IHKYoung/AhaTTS/commits/main"><img src="https://img.shields.io/github/last-commit/IHKYoung/AhaTTS?style=flat" alt="Last commit" /></a>
  <a href="LICENSE"><img src="https://img.shields.io/badge/License-CC%20BY--NC%204.0-lightgrey?style=flat&logo=creative-commons&logoColor=white" alt="License: CC BY-NC 4.0" /></a>
  <img src="https://img.shields.io/badge/Python-3.10%2B-3776AB?logo=python&logoColor=white" alt="Python 3.10+" />
  <img src="https://img.shields.io/badge/OpenAI-Compatible-000000?logo=openai&logoColor=white" alt="OpenAI Compatible" />
  <img src="https://img.shields.io/badge/Text--to--Speech-Voice-ff8c00?logo=audacity&logoColor=white" alt="Text-to-Speech" />
</p>

<p align="center">
  <strong>语言：</strong> <a href="README.zh-CN.md">简体中文</a> | <a href="README.md">English</a>
</p>

AhaTTS 是开源、轻部署的语音合成服务，提供 OpenAI 兼容 API 与内置 Web 演示页面。

<p align="center">
  <img src="assets/AhaTTS.png" alt="AhaTTS" width="720" />
</p>

## 亮点
- OpenAI 兼容 API，便于集成
- 内置 `api/web` 演示页面
- CPU / CUDA / MPS 支持
- 多语言与多音色（Kokoro）
- 流式输出与高质量音频

## 快速开始
```bash
./scripts/install.sh --device cpu   # 或 gpu / mac
./scripts/dev.sh
```

访问：
- http://localhost:25288/docs
- http://localhost:25288/web/
