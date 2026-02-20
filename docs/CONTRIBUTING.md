# Contributing to homebrew-tools

Guidelines for adding new formulas to this tap.

## Formula Template

All formulas should follow this unified template using wrapper scripts for Python dependencies:

```ruby
class ToolName < Formula
  desc "Description of the tool"
  homepage "https://github.com/kalijason/tool-name"
  url "https://github.com/kalijason/tool-name/archive/refs/tags/v#{version}.tar.gz"
  sha256 "SHA256_HASH"
  license "MIT"

  depends_on "python@3.12"
  # Add other dependencies as needed (e.g., ffmpeg)

  def install
    libexec.install Dir["*"]

    (bin/"tool-name").write <<~EOS
      #!/bin/bash
      set -e
      VENV_DIR="#{var}/lib/tool-name/venv"
      SOURCE_DIR="#{libexec}"

      if [ ! -f "${VENV_DIR}/bin/activate" ]; then
        echo "[tool-name] First run, installing dependencies..." >&2
        mkdir -p "${VENV_DIR}"
        python3 -m venv "${VENV_DIR}"
        source "${VENV_DIR}/bin/activate"
        pip install --quiet --upgrade pip
        pip install --quiet -r "${SOURCE_DIR}/requirements.txt"
      fi

      source "${VENV_DIR}/bin/activate"
      exec python3 "${SOURCE_DIR}/main.py" "$@"
    EOS
    chmod 0755, bin/"tool-name"
    (var/"log").mkpath
  end

  # Add service block for daemon-style tools
  service do
    run [opt_bin/"tool-name"]
    keep_alive true
    log_path var/"log/tool-name.log"
    error_log_path var/"log/tool-name.error.log"
    environment_variables TOOL_NAME_PORT: "PORT"
  end

  test do
    system "python3", "-c", "import ast; ast.parse(open('#{libexec}/main.py').read())"
  end
end
```

## Standardized Paths

| Type | Path |
|------|------|
| Virtual Environment | `#{var}/lib/{name}/venv` |
| Log File | `#{var}/log/{name}.log` |
| Error Log | `#{var}/log/{name}.error.log` |
| Cache | `#{var}/cache/{name}` |

## Environment Variable Naming

Use `{TOOL_NAME}_` prefix for all environment variables:
- `MAC_TTS_PORT`
- `QWEN_TTS_SPEAKER`
- `QWEN_TTS_CACHE`

## Project Requirements

Each project needs:
- `requirements.txt` - For Homebrew deployment (wrapper script uses this)
- `pyproject.toml` - Standard Python project configuration
- Main script file (e.g., `main.py`, `app.py`, `*_server.py`)

## Release Process

1. **In the project repository:**
   ```bash
   git tag -a v1.0.0 -m "Release v1.0.0"
   git push origin v1.0.0
   ```

2. **Update formula:**
   ```bash
   cd homebrew-tools
   ./scripts/update-formula.sh tool-name 1.0.0
   ```

3. **Test installation:**
   ```bash
   brew reinstall kalijason/tools/tool-name
   tool-name --help
   brew services start tool-name
   ```

4. **Commit and push:**
   ```bash
   git add Formula/tool-name.rb
   git commit -m "tool-name: update to v1.0.0"
   git push
   ```

## Checklist for New Formulas

- [ ] Formula follows the unified template
- [ ] Uses wrapper script (not `virtualenv_install_with_resources`)
- [ ] Paths follow standardized conventions
- [ ] Environment variables use proper prefix
- [ ] Service block included (if applicable)
- [ ] Test block verifies Python syntax
- [ ] Caveats explain first-run behavior (if needed)
- [ ] README.md updated with new formula
- [ ] Tested with `brew install` and `brew services`
