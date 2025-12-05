class RespecAi < Formula
  include Language::Python::Virtualenv

  desc "AI-powered spec workflow automation (DEV BUILD - TestPyPI)"
  homepage "https://github.com/mmcclatchy/respec-ai"
  url "https://test-files.pythonhosted.org/packages/source/r/respec-ai/respec-ai-0.4.7.tar.gz"
  sha256 "PLACEHOLDER_SHA256"
  license "MIT"

  depends_on "python@3.11"
  depends_on "docker"

  # Dependencies will be added via homebrew-pypi-poet
  # resource "pydantic" do
  #   url "..."
  #   sha256 "..."
  # end

  def install
    virtualenv_install_with_resources
  end

  def caveats
    <<~EOS
      ⚠️  DEVELOPMENT VERSION - TestPyPI
      This formula installs from TestPyPI and is for testing purposes only.

      Not recommended for production use. Features may be unstable.

      Report issues: https://github.com/mmcclatchy/respec-ai/issues
    EOS
  end

  test do
    system "#{bin}/respec-ai", "--version"
    assert_match "0.4.7", shell_output("#{bin}/respec-ai --version")
  end
end
