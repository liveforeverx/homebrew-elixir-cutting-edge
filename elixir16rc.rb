class Erlang18Requirement < Requirement
  fatal true
  default_formula "erlang"

  satisfy do
    erl = which("erl")
    next unless erl
    `#{erl} -noshell -eval 'io:fwrite("~s", [erlang:system_info(otp_release) >= "18"])' -s erlang halt | grep -q '^true'`
    next unless $CHILD_STATUS.exitstatus.zero?
    erl
  end

  def message; <<~EOS
    Erlang 18+ is required to install.
    You can install this with:
      brew install erlang
    Or you can use an official installer from:
      https://www.erlang.org/
    EOS
  end
end

class Elixir16rc < Formula
  desc "Functional metaprogramming aware language built on Erlang VM"
  homepage "https://elixir-lang.org/"
  url "https://github.com/elixir-lang/elixir/archive/v1.6.0-rc.0.tar.gz"
  sha256 "372f7469310453df02ae0fbde560d5827834c92b7f7cfb5c50e80dd453f7da97"

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
