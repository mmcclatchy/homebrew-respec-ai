class RespecAi < Formula
  include Language::Python::Virtualenv

  desc "AI-powered spec workflow automation (DEV BUILD - TestPyPI)"
  homepage "https://github.com/mmcclatchy/respec-ai"
  url "https://test-files.pythonhosted.org/packages/d7/7d/b386840f8853127bd374dac3636a19ef6798c6533999bcb24c3c367962b8/respec_ai-0.5.11.tar.gz"
  sha256 "0c7589242906ff95d0904e39f3a849df6451d49cb845269f317fac9dcd682ac1"
  license "MIT"

  depends_on "python"

  def install
    virtualenv_install_with_resources
  end

  def caveats
    <<~EOS
      ⚠️  DEVELOPMENT VERSION - TestPyPI
      This formula installs from TestPyPI and is for testing purposes only.

      Not recommended for production use. Features may be unstable.

      ⚠️  REQUIRES DOCKER
      macOS/Windows: Install Docker Desktop
        https://www.docker.com/products/docker-desktop

      Linux: Install docker.io or docker-ce via your package manager
        Debian/Ubuntu: sudo apt install docker.io
        Other: See https://docs.docker.com/engine/install/

      Report issues: https://github.com/mmcclatchy/respec-ai/issues
    EOS
  end

  test do
    system "#{bin}/respec-ai", "--version"
    assert_match "0.5.11", shell_output("#{bin}/respec-ai --version")
  end
end
