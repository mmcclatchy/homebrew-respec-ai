class RespecAi < Formula
  include Language::Python::Virtualenv

  desc "AI-powered spec workflow automation (DEV BUILD - TestPyPI)"
  homepage "https://github.com/mmcclatchy/respec-ai"
  url "https://test-files.pythonhosted.org/packages/3a/98/94f8512456bebfe4c31810d9e16a133bac4739a1bc51ee2876e3ec1848df/respec_ai-0.6.4.tar.gz"
  sha256 "0be5c6e7f06e358dd6443a1d914e8fe7b756053163355d786ff63e916a2d3730"
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
    assert_match "0.6.4", shell_output("#{bin}/respec-ai --version")
  end
end
