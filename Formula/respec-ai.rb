class RespecAi < Formula
  include Language::Python::Virtualenv

  desc "AI-powered spec workflow automation (DEV BUILD - TestPyPI)"
  homepage "https://github.com/mmcclatchy/respec-ai"
  url "https://test-files.pythonhosted.org/packages/cc/0a/b9ec9d8f68e2e051ea0332016676b02fab72f316b83f451f79a839e478f9/respec_ai-0.6.5.tar.gz"
  sha256 "40795c485c70156675b567f0496f4ded70684d759e8ffa918f4e39c970dd05c1"
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
    assert_match "0.6.5", shell_output("#{bin}/respec-ai --version")
  end
end
