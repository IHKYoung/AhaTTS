# AhaTTS 脚本说明

## 环境部署
```bash
./scripts/install.sh                    # 交互式选择设备
./scripts/install.sh --device mac       # Apple Silicon (MPS)
./scripts/install.sh --device cpu       # CPU
./scripts/install.sh --device gpu       # CUDA
./scripts/install.sh --skip-model       # 跳过模型下载
./scripts/install.sh --force-model      # 强制重新下载模型
```

## 启动后端 API
```bash
./scripts/dev.sh
./scripts/dev.sh --device cpu
./scripts/dev.sh --host 127.0.0.1 --port 25288
```

## 手动命令（可选）
```bash
uv venv
uv pip install -e ".[cpu,test]"
uv run --no-sync python -m unidic download
uv run --no-sync python scripts/download_model.py --output api/src/models/v1_0
MODEL_DIR="$PWD/api/src/models" \
VOICES_DIR="$PWD/api/src/voices/v1_0" \
WEB_PLAYER_PATH="$PWD/api/web" \
uv run --no-sync uvicorn api.src.main:app --host 0.0.0.0 --port 25288 --reload
```

访问：
- http://localhost:25288/docs
- http://localhost:25288/web/

## Lint
```bash
./scripts/lint.sh
./scripts/lint.sh fix
```

## 测试
```bash
./scripts/test.sh
./scripts/test.sh -v --cov
./scripts/test.sh test_normalizer.py
```

## 模型地址
kokoro-v1_0.pth：https://huggingface.co/hexgrad/Kokoro-82M/resolve/main/kokoro-v1_0.pth
config.json 已在 `api/src/models/v1_0`，需与模型放同目录
