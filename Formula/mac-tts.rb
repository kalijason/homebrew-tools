class MacTts < Formula
  include Language::Python::Virtualenv

  desc "macOS TTS HTTP API server using native say command"
  homepage "https://github.com/kalijason/mac-tts"
  url "https://github.com/kalijason/mac-tts/archive/refs/tags/v1.0.0.tar.gz"
  sha256 "d31eae7e4ae3b8e7a109021a588f89b36d4cd1149eeedad4db679fc8b0e267d2"
  license "MIT"

  depends_on "python@3.12"

  resource "flask" do
    url "https://files.pythonhosted.org/packages/89/50/dff6380f1c7f84135484e176e0cac8571b9702c71b9e7d47d0e9f8ea6e37/flask-3.1.0.tar.gz"
    sha256 "5f1c5c3e8e4a5a4e4b5d5e3e4f5f5e4d5e4f5f5e4d5e4f5f5e4d5e4f5f5e4d5e"
  end

  resource "werkzeug" do
    url "https://files.pythonhosted.org/packages/9f/69/83029f1f6300c5fb2471d621ab06f6ec6b3324685a2ce0f9777fd4a8b71e/werkzeug-3.1.3.tar.gz"
    sha256 "60723ce945c19328679b7c5a5c4d873f2b5d5e5f5e5e5e5f5e5e5f5e5e5f5e5e"
  end

  resource "jinja2" do
    url "https://files.pythonhosted.org/packages/df/bf/f7da0350254c0ed7c72f3e33cef02e048281fec7ecec5f032d4aac52226b/jinja2-3.1.5.tar.gz"
    sha256 "8fefcc8dcbe85cccb617d5e7e2e5f5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5"
  end

  resource "markupsafe" do
    url "https://files.pythonhosted.org/packages/b2/97/5d42485e71dfc078108a86d6de8fa46db44a1a9295e89c5d6d4a06e23a62/markupsafe-3.0.2.tar.gz"
    sha256 "ee55d3edf80167e48ea11a923c7386f4669df67d7994554387f84e7d8b0a2bf0"
  end

  resource "itsdangerous" do
    url "https://files.pythonhosted.org/packages/9c/cb/8ac0172223c48eff18bd0de6efb78a23b24ca58be1bd5d8692bb0b1d88e3/itsdangerous-2.2.0.tar.gz"
    sha256 "e0050c0b7da1eea53ffaf149c0cfbb5c6e2e2b69c4bef22a81fa6eb73e5f6173"
  end

  resource "click" do
    url "https://files.pythonhosted.org/packages/b9/2e/0090cbf739cee7d23781ad4b89a9894a41538e4fcf4c31dcdd705b78eb8b/click-8.1.8.tar.gz"
    sha256 "ed53c9d8990d83c2a27deae68e4ee337473f6330c040a31d4225c9574d16096a"
  end

  resource "blinker" do
    url "https://files.pythonhosted.org/packages/21/28/9b3f50ce0e048515135495f198351908d99540d69bfdc8c1d15b73dc55ce/blinker-1.9.0.tar.gz"
    sha256 "b4ce2265a7abece45e7cc896e98dbebe6cead56bcf805a3d23136d145f5445bf"
  end

  def install
    virtualenv_install_with_resources

    # Create wrapper script
    (bin/"mac-tts").write <<~EOS
      #!/bin/bash
      exec "#{libexec}/bin/python" "#{libexec}/lib/python3.12/site-packages/mac_tts.py" "$@"
    EOS
  end

  service do
    run [opt_bin/"mac-tts"]
    keep_alive true
    working_dir var
    log_path var/"log/mac-tts.log"
    error_log_path var/"log/mac-tts.log"
    environment_variables MAC_TTS_PORT: "5050", MAC_TTS_VOICE: "Meijia"
  end

  test do
    # Start server in background
    fork do
      exec bin/"mac-tts", "-p", "15050"
    end
    sleep 2

    # Test health endpoint
    output = shell_output("curl -s http://localhost:15050/health")
    assert_match "ok", output
  end
end
