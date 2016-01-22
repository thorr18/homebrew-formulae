class Pyfa < Formula
  desc "Ship fitting tool for EVE Online game"
  homepage "https://github.com/DarkFenX/Pyfa/wiki"
  url "https://github.com/thorr18/Pyfa/archive/1.17.12.tar.gz"
  #version already tagged by repo
  #sha256 "32a598f336cca869180110b51e9149cc2007f0f760c4c5eb8b9e81f73f8abee3"
  bottle do
    cellar :any
    #bottle is empty
  end
  head "https://github.com/thorr18/Pyfa.git", :branch => "master"
  option "with-external", "use Python dependencies installed with Pip instead of bundling"
  deprecated_option "Wx3" => "noWx3"
  option "noWx3", "use Pyfa with wx 2.X"
  if MacOS.version <= :snow_leopard
    depends_on :python
  else
    depends_on :python => [:optional, "framework"]
  end
  if build.with? "external"
    depends_on "wxPython" => [:python, "framework"]
    depends_on "matplotlib" => [:python, :recommended]
    depends_on "numpy" => [:python, :recommended]
    depends_on "python-dateutil" => [:python, "dateutil"] if build.without? "matplotlib"
    depends_on "SQLAlchemy" => :python
    depends_on "requests" => :python
  else
    depends_on "wxPython" => "framework" if build.without? "noWx3"
    depends_on "homebrew/versions/wxPython2.8" => "framework" if build.with? "noWx3"
    depends_on "homebrew/python/matplotlib" => :recommended
    depends_on "homebrew/python/numpy" => :recommended
    resource "python-dateutil" if build.without? "matplotlib" do
      url "https://pypi.python.org/packages/source/p/python-dateutil/python-dateutil-2.4.2.tar.gz"
      sha256 "3e95445c1db500a344079a47b171c45ef18f57d188dffdb0e4165c71bea8eb3d"
    end
    resource "SQLAlchemy" do
      url "https://pypi.python.org/packages/source/S/SQLAlchemy/SQLAlchemy-1.0.11.tar.gz"
      sha256 "0b24729787fa1455009770880ea32b1fa5554e75170763b1aef8b1eb470de8a3"
    end
    resource "requests" do
      url "https://pypi.python.org/packages/source/r/requests/requests-2.6.2.tar.gz"
      sha256 "0577249d4b6c4b11fd97c28037e98664bfaa0559022fee7bcef6b752a106e505"
    end
  end
  def install
    pyver = Language::Python.major_minor_version "python"
    pathsitetail = "lib/python"+pyver+"/site-packages"
    pathvendor = libexec+"vendor"
    pathvendorsite = pathvendor+pathsitetail
    pathsite = libexec+pathsitetail
    ENV.prepend_create_path "PYTHONPATH", pathvendorsite
    resources.each do |r|
      r.stage do
        system "python", *Language::Python.setup_install_args(pathvendor)
      end
    end
    ENV.prepend_create_path "PYTHONPATH", pathsite
    #system "python", *Language::Python.setup_install_args(libexec)
    system "#{python} -c setup-osx.py py2app --prefix=#{libexec}"
    bin.install Dir[libexec/"bin/*"]
    bin.env_script_all_files(libexec/"bin", :PYTHONPATH => ENV["PYTHONPATH"])
    ENV.prepend_create_path "PYTHONPATH", libexec
    %w["somestuff" | "otherstuff" | "iforget"].each do |d|
      libexec.install Dir[d]
    end
  end
  def caveats; <<-EOS.undent
    This formula is still under construction.
  EOS
  end
  test do
    system "#{python} -c import wx; print wx.version()"
    system "#{bin}/Pyfa", "-test"
  end
end
