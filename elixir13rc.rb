class Erlang18Requirement < Requirement
  fatal true
  env :userpaths
  default_formula "erlang"

  satisfy do
    erl = which("erl")
    next unless erl
    `#{erl} -noshell -eval 'io:fwrite("~s~n", [erlang:system_info(otp_release)]).' -s erlang halt | grep -q '^1[89]'`
    $?.exitstatus == 0
  end

  def message; <<-EOS.undent
    Erlang 18+ is required to install.
    You can install this with:
      brew install erlang
    Or you can use an official installer from:
      http://www.erlang.org/
    EOS
  end
end

class Elixir13rc < Formula
  desc "Functional metaprogramming aware language built on Erlang VM"
  homepage "http://elixir-lang.org/"
  url "https://github.com/elixir-lang/elixir/archive/v1.3.0-rc.0.zip"
  sha256 "5a5af716f6ed8000fc015a97f8b3aa50e926de0638b812e1a275de2cc9e8bf3a"

  head "https://github.com/elixir-lang/elixir.git"

  depends_on Erlang18Requirement

  def install
    system "make"
    bin.install Dir["bin/*"] - Dir["bin/*.{bat,ps1}"]

    Dir.glob("lib/*/ebin") do |path|
      app = File.basename(File.dirname(path))
      (lib/app).install path
    end
  end

  test do
    system "#{bin}/elixir", "-v"
  end
end
