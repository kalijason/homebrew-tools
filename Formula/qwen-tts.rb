class QwenTts < Formula
  desc "Qwen3-TTS HTTP API server for AI-powered text-to-speech"
  homepage "https://github.com/kalijason/qwen-tts-server"
  url "https://github.com/kalijason/qwen-tts-server/archive/refs/tags/v1.0.0.tar.gz"
  sha256 "9f7d04c864c0953ab023a39bd0a55027f7ecb2ab4772f032b770f1cae348da6b"
  license "MIT"

  depends_on "python@3.12"
  depends_on "ffmpeg"

  def install
    libexec.install Dir["*"]

    python = Formula["python@3.12"].opt_bin/"python3.12"
    (bin/"qwen-tts").write <<~EOS
      #!/bin/bash
      set -e
      PYTHON="#{python}"
      VENV_DIR="#{var}/lib/qwen-tts/venv"
      SOURCE_DIR="#{libexec}"

      if [ ! -f "${VENV_DIR}/bin/activate" ]; then
        echo "[qwen-tts] First run, installing dependencies..." >&2
        echo "[qwen-tts] This may take a while (~500MB download)..." >&2
        mkdir -p "${VENV_DIR}"
        "${PYTHON}" -m venv "${VENV_DIR}"
        source "${VENV_DIR}/bin/activate"
        pip install --quiet --upgrade pip
        pip install --quiet -r "${SOURCE_DIR}/requirements.txt"
      fi

      source "${VENV_DIR}/bin/activate"
      exec python "${SOURCE_DIR}/qwen_tts_server.py" "$@"
    EOS
    chmod 0755, bin/"qwen-tts"
    (var/"log").mkpath
  end

  def caveats
    <<~EOS
      Qwen TTS Server installed!

      First run will:
      - Create Python virtual environment
      - Install dependencies (~500MB)
      - Download Qwen3-TTS model (~1GB on first API call)

      Start manually:
        qwen-tts --port 5051

      Or as a service:
        brew services start qwen-tts

      Logs:
        tail -f #{var}/log/qwen-tts.log

      Available voices: serena, vivian, aiden, dylan, eric, ryan, sohee, uncle_fu, ono_anna

      API:
        curl -X POST http://localhost:5051/say \\
          -H "Content-Type: application/json" \\
          -d '{"message": "Hello", "voice": "serena"}'
    EOS
  end

  service do
    run [opt_bin/"qwen-tts", "--port", "5051"]
    keep_alive true
    log_path var/"log/qwen-tts.log"
    error_log_path var/"log/qwen-tts.error.log"
    environment_variables(
      QWEN_TTS_PORT: "5051",
      QWEN_TTS_SPEAKER: "serena",
      QWEN_TTS_CACHE: "#{var}/cache/qwen-tts",
      QWEN_TTS_CACHE_MAX_MB: "500"
    )
  end

  test do
    system "python3", "-c", "import ast; ast.parse(open('#{libexec}/qwen_tts_server.py').read())"
  end
end
