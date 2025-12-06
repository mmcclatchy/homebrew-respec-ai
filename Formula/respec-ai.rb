class RespecAi < Formula
  include Language::Python::Virtualenv

  desc "AI-powered spec workflow automation (DEV BUILD - TestPyPI)"
  homepage "https://github.com/mmcclatchy/respec-ai"
  url "https://test-files.pythonhosted.org/packages/e3/26/625401399f1d3084f552a223dd650400ab118896e160f1bc8bbee2648eae/respec_ai-0.5.7.tar.gz"
  sha256 "2e892cba35d0fb26e1f5d3006360e80cdbed04cd486dca9a33a417b95c583895"
  license "MIT"

  depends_on "python"  # Uses Homebrew's default Python (3.12+)


  




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
    assert_match "0.5.7", shell_output("#{bin}/respec-ai --version")
  end
end
