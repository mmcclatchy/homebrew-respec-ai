class RespecAi < Formula
  include Language::Python::Virtualenv

  desc "AI-powered spec workflow automation (DEV BUILD - TestPyPI)"
  homepage "https://github.com/mmcclatchy/respec-ai"
  url "https://test-files.pythonhosted.org/packages/50/9a/1eba7194701e280f171176aa82f4a29b0cfd73e36e9a244f9107a3b4959d/respec_ai-0.5.17.tar.gz"
  sha256 "e61bc98bbc78ba6820860c3c45c0d55e0f829de058d3d9099b3e2d86795b8c12"
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
    assert_match "0.5.17", shell_output("#{bin}/respec-ai --version")
  end
end
