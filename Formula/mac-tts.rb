class MacTts < Formula
  desc "macOS TTS HTTP API server using native say command"
  homepage "https://github.com/kalijason/mac-tts"
  url "https://github.com/kalijason/mac-tts/archive/refs/tags/v1.0.2.tar.gz"
  sha256 "01276c4913cc43b4fd29977df7c303eee04151374d394517141880f043aaf8b3"
  license "MIT"

  depends_on "python@3.12"

  def install
    libexec.install Dir["*"]

    python = Formula["python@3.12"].opt_bin/"python3.12"
    (bin/"mac-tts").write <<~EOS
      #!/bin/bash
      set -e
      PYTHON="#{python}"
      VENV_DIR="#{var}/lib/mac-tts/venv"
      SOURCE_DIR="#{libexec}"

      if [ ! -f "${VENV_DIR}/bin/activate" ]; then
        echo "[mac-tts] First run, installing dependencies..." >&2
        mkdir -p "${VENV_DIR}"
        "${PYTHON}" -m venv "${VENV_DIR}"
        source "${VENV_DIR}/bin/activate"
        pip install --quiet --upgrade pip
        pip install --quiet -r "${SOURCE_DIR}/requirements.txt"
      fi

      source "${VENV_DIR}/bin/activate"
      exec python "${SOURCE_DIR}/mac_tts.py" "$@"
    EOS
    chmod 0755, bin/"mac-tts"
    (var/"log").mkpath
  end

  service do
    run [opt_bin/"mac-tts"]
    keep_alive true
    log_path var/"log/mac-tts.log"
    error_log_path var/"log/mac-tts.error.log"
    environment_variables MAC_TTS_PORT: "5050", MAC_TTS_VOICE: "Meijia"
  end

  test do
    system "python3", "-c", "import ast; ast.parse(open('#{libexec}/mac_tts.py').read())"
  end
end
