class RespecAi < Formula
  include Language::Python::Virtualenv

  desc "AI-powered spec workflow automation (DEV BUILD - TestPyPI)"
  homepage "https://github.com/mmcclatchy/respec-ai"
  url "https://test-files.pythonhosted.org/packages/b2/c7/b92c32c012a5f4f7d9f03061cec92e66734d104ded23fc2996e9cf5b763c/respec_ai-0.5.12.tar.gz"
  sha256 "ee68a4a6b47887f9a805ca3de8fe5f56f09e1859ace44b424c395a648d3f7ae5"
  license "MIT"

  depends_on "python"

  def install
    # Create virtualenv
    venv = virtualenv_create(libexec, "python3")

    # Install package with dependencies (pip fetches dependencies from PyPI as wheels)
    # Must use direct system call instead of pip_install_and_link to avoid --no-deps flag
    system libexec/"bin/pip", "install", "--verbose", buildpath

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
    assert_match "0.5.12", shell_output("#{bin}/respec-ai --version")
  end
end
