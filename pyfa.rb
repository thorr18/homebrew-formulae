class Pyfa < Formula
  revision 7
  desc "Ship fitting tool for EVE Online game"
  homepage "https://github.com/pyfa-org/Pyfa/wiki"
  ver='1.17.48'
  #version tagged in this repo includes a downstream version identifier (PEP-0440)
  url "https://github.com/thorr18/Pyfa/archive/"+ver+"+thorr."+ver+".tar.gz"
  #sha256 "b7722d9ce4822deefe68cfb8c89d1c69d4147116dc72cccbeed2c16b8869579b"
  bottle do
    cellar :any
    #bottle is empty
  end
  head "https://github.com/thorr18/Pyfa.git", :branch => "master"
  option "with-external", "expect Python dependencies installed with Pip instead of bundling"
  deprecated_option "Wx3" => "noWx3"
  option "noWx3", "use Pyfa with wx 2.X for compatability"
  if MacOS.version <= :snow_leopard
    depends_on :python
  else
    depends_on :python => [:optional, "framework"]
  end
  #depends_on "setuptools" => [:build, :python]
  if build.with? "external"
    depends_on "wxPython" => [:python, "framework"]
    depends_on "matplotlib" => [:python, :recommended]
    depends_on "numpy" => [:python, :recommended]
    depends_on "python-dateutil" => [:python, "dateutil"] if build.without? "matplotlib"
    depends_on "SQLAlchemy" => :python
    depends_on "requests" => :python
  else
    depends_on "wxPython" => "framework" if build.without? "noWx3"
    depends_on "thorr18/formulae/versions/wxPython2.8" => "framework" if build.with? "noWx3"
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
  #patch do if FALSE
    #url "https://raw.githubusercontent.com/thorr18/homebrew-formulae/patches/e223e971/pyfa/setupentrypoints.patch"
    #sha256 "a7881dc25665f284798934ba19092d1eb45ca515a34e5c473accd144aa1a215a"
  #end
  #patch do if FALSE
    #url "https://raw.githubusercontent.com/thorr18/homebrew-formulae/patches/b236e788/pyfa/wximporting.patch"
    #sha256 "a7881dc25665f284798934ba19092d1eb45ca515a34e5c473accd144aa1a215a"
  #end
  #patch do if FALSE
  #url "https://raw.githubusercontent.com/thorr18/homebrew-formulae/patches/f1752cc1/pyfa/configdownstreamversion.patch"
  #sha256 "a7881dc25665f284798934ba19092d1eb45ca515a34e5c473accd144aa1a215a"
  #end
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
    system "python", *Language::Python.setup_install_args(libexec)
    bin.install Dir[libexec/"bin/*"]
    bin.env_script_all_files(libexec/"bin", :PYTHONPATH => ENV["PYTHONPATH"])
    ENV.prepend_create_path "PYTHONPATH", libexec
    %w["imgs" | "otherstuff" | "stuff" | 'imgs/gui'].each do |d|
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
