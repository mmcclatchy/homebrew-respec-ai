class RespecAi < Formula
  include Language::Python::Virtualenv

  desc "AI-powered spec workflow automation (DEV BUILD - TestPyPI)"
  homepage "https://github.com/mmcclatchy/respec-ai"
  url "https://test-files.pythonhosted.org/packages/9e/82/a588961228aed4514e3d293aaa5a978ec5253a4d225e442ab299341e149b/respec_ai-0.6.3.tar.gz"
  sha256 "7c3c592f1e0598b7666059650fc3ed9a9b87a520e6f567206c466213c9117704"
  license "MIT"

  depends_on "python"

  def install
    # Create virtualenv
    venv = virtualenv_create(libexec, "python3")

    # Install package with dependencies (pip fetches dependencies from PyPI as wheels)
    # Use system pip with --python flag since venv is created --without-pip
    system "python3", "-m", "pip",
           "--python=#{libexec}/bin/python",
           "install",
           buildpath

    # Create symlink to bin
    bin.install_symlink libexec/"bin/respec-ai"
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
    assert_match "0.6.3", shell_output("#{bin}/respec-ai --version")
  end
end
