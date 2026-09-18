# Source of truth for the formula published at iaurg/homebrew-tap (Formula/unport.rb).
# On release: update `url` + `sha256` (see README "Releasing"), then copy to the tap.
class Unport < Formula
  desc "Find, open and kill listening ports from the macOS menu bar"
  homepage "https://github.com/iaurg/unport"
  url "https://github.com/iaurg/unport/archive/refs/tags/v1.0.0.tar.gz"
  sha256 "REPLACE_WITH_TARBALL_SHA256"
  license "MIT"
  head "https://github.com/iaurg/unport.git", branch: "main"

  depends_on macos: :ventura
  uses_from_macos "swift" => :build

  def install
    ENV["VERSION"] = version.to_s
    # Homebrew already sandboxes the build; SwiftPM's nested sandbox fails inside it.
    ENV["SWIFT_BUILD_FLAGS"] = "--disable-sandbox"
    system "./scripts/build-app.sh"

    prefix.install "build/Unport.app"
    bin.write_exec_script prefix/"Unport.app/Contents/MacOS/Unport"
  end

  service do
    run [opt_prefix/"Unport.app/Contents/MacOS/Unport"]
    process_type :interactive
  end

  def caveats
    <<~EOS
      Unport is a menu bar app. Start it now and at every login with:
        brew services start unport

      Or launch it once with:
        open #{opt_prefix}/Unport.app

      If the icon does not show up, your menu bar is full and macOS hid it
      behind the notch: remove or ⌘-drag other items to make room.
    EOS
  end

  test do
    assert_predicate prefix/"Unport.app/Contents/MacOS/Unport", :executable?
    assert_match version.to_s, (prefix/"Unport.app/Contents/Info.plist").read
  end
end
