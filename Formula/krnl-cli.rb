class KrnlCli < Formula
  desc "CLI for deploying and registering smart contracts across multiple networks"
  homepage "https://github.com/KRNL-Labs/krnl-cli"
  url "https://github.com/KRNL-Labs/homebrew-krnl/releases/download/v1.2.0/krnl-cli-v1.2.0.tar.gz"
  sha256 "3bab1c6eb67b02704edcdc721e4c9c4488527bad277929370a80dcc48a82c618"
  license "MIT"
  head "https://github.com/KRNL-Labs/krnl-cli.git", branch: "main"

  livecheck do
    url :stable
    regex(/^v?(\d+(?:\.\d+)+)$/i)
  end

  depends_on "node@18"

  def install
    # Install dependencies and build the project
    system "npm", "install", "--omit=dev"
    
    # Install to libexec
    libexec.install Dir["*"]

    # Create bin stubs
    (bin/"krnl").write <<~EOS
      #!/bin/bash
      exec "#{Formula["node@18"].opt_bin}/node" "#{libexec}/bin/cli.js" "$@"
    EOS

    # Make bin stub executable
    chmod 0755, bin/"krnl"

    # Install Foundry if not already installed
    foundry_bin = "#{ENV["HOME"]}/.foundry/bin/forge"
    unless File.exist?(foundry_bin)
      ohai "Installing Foundry"
      system "bash", "-c", "curl -L https://foundry.paradigm.xyz | bash"
      
      # Add a note about adding Foundry to PATH
      opoo "Foundry has been installed to ~/.foundry/bin"
      opoo "You may need to add it to your PATH:"
      opoo "  echo 'export PATH=\"$HOME/.foundry/bin:$PATH\"' >> ~/.zshrc"
      opoo "  source ~/.zshrc"
    end
    ohai "KRNL CLI works best with Foundry installed"
    opoo "To install Foundry, run: curl -L https://foundry.paradigm.xyz | bash"
  end

  test do
    assert_match "KRNL Command Line Interface", shell_output("#{bin}/krnl --help")
    assert_match version.to_s, shell_output("#{bin}/krnl --version")
  end
end
