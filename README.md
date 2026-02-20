# Homebrew Tools

Personal Homebrew tap for various tools.

## Installation

```bash
brew tap kalijason/tools
```

## Available Formulae

### mac-tts

macOS TTS HTTP API server using native `say` command.

```bash
brew install kalijason/tools/mac-tts
brew services start mac-tts
```

**Port:** 5050
**API:** `POST /say {"message": "Hello", "voice": "Meijia"}`

See [mac-tts](https://github.com/kalijason/mac-tts) for more details.

### qwen-tts

Qwen3-TTS HTTP API server for AI-powered text-to-speech.

```bash
brew install kalijason/tools/qwen-tts
brew services start qwen-tts
```

**Port:** 5051
**API:** `POST /say {"message": "Hello", "voice": "serena"}`

Available voices: serena, vivian, aiden, dylan, eric, ryan, sohee, uncle_fu, ono_anna

See [qwen-tts](https://github.com/kalijason/qwen-tts) for more details.

## First Run

Both tools use lazy dependency installation. On first run:
1. A Python virtual environment is created
2. Dependencies are installed from `requirements.txt`
3. (qwen-tts) Model is downloaded on first API call (~1GB)

## Updating Formulas

Use the helper script to update a formula version:

```bash
./scripts/update-formula.sh <formula-name> <version>

# Example:
./scripts/update-formula.sh mac-tts 1.0.3
```

## Directory Structure

```
homebrew-tools/
├── Formula/
│   ├── mac-tts.rb
│   └── qwen-tts.rb
├── scripts/
│   └── update-formula.sh
└── docs/
    └── CONTRIBUTING.md
```

## Contributing

See [CONTRIBUTING.md](docs/CONTRIBUTING.md) for guidelines on adding new formulas.
