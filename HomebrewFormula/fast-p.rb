class FastP < Formula
  desc "Fast, command-line PDF finder"
  homepage "https://github.com/bellecp/fast-p"
  url "https://github.com/bellecp/fast-p/releases/download/v0.1.9/fast-p_0.1.9_Darwin_x86_64.tar.gz"
  version "0.1.9"
  sha256 "694a61d12a37073f14be83990ce41bec24a34b6c9e5562c34467d3ced567252e"
  
  depends_on "fzf"
  depends_on "coreutils"
  depends_on "findutils"
  depends_on "poppler-utils"
  depends_on "the_silver_searcher"

  def install
    bin.install "program"
  end
end
