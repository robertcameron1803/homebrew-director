# Copyright 2012-2018 Robot Locomotion Group @ CSAIL. All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
#
#  1. Redistributions of source code must retain the above copyright
#     notice, this list of conditions and the following disclaimer.
#  2. Redistributions in binary form must reproduce the above copyright
#     notice, this list of conditions and the following disclaimer in the
#     documentation and/or other materials provided with the distribution.
#  3. Neither the name of the copyright holder nor the names of its
#     contributors may be used to endorse or promote products derived from
#     this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS
# IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
# THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
# PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR
# CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
# EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
# PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
# PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
# LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
# NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
# SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

class Libdrake < Formula
  desc "Planning, control, analysis toolbox for nonlinear dynamical systems"
  homepage "http://drake.mit.edu/"
  head "https://github.com/RobotLocomotion/drake.git"

  keg_only "vendored dependencies of this software conflict with the bullet, eigen, and fmt formulae"

  needs :cxx14

  depends_on :java
  depends_on "bazel" => :build
  depends_on "boost"
  depends_on "clang-format" => :build
  depends_on "cmake" => :build
  depends_on "dreal" # brew tap dreal/dreal
  depends_on "gflags"
  depends_on "glew"
  depends_on "glib"
  depends_on "ipopt"
  depends_on "libyaml"
  depends_on "lz4"
  depends_on "nlopt"
  depends_on "numpy"
  depends_on "pkg-config" => :build
  depends_on "protobuf"
  depends_on "python"
  depends_on "scipy"
  depends_on "tinyxml"
  depends_on "tinyxml2"
  depends_on "vtk@8.0"
  depends_on "yaml-cpp"

  resource "lxml" do
    url "https://files.pythonhosted.org/packages/e1/4c/d83979fbc66a2154850f472e69405572d89d2e6a6daee30d18e83e39ef3a/lxml-4.1.1.tar.gz"
    sha256 "940caef1ec7c78e0c34b0f6b94fe42d0f2022915ffc78643d28538a5cfd0f40e"
  end

  resource "PyYAML" do
    url "https://files.pythonhosted.org/packages/4a/85/db5a2df477072b2902b0eb892feb37d88ac635d36245a72a6a69b23b383a/PyYAML-3.12.tar.gz"
    sha256 "592766c6303207a20efc445587778322d7f73b161bd994f227adaa341ba212ab"
  end

  def install
    ["lxml", "PyYAML"].each do |r|
      resource(r).stage do
        system "python", *Language::Python.setup_install_args(libexec/"vendor")
      end
    end

    mkdir "build" do
      ENV.deparallelize
      system "cmake", *std_cmake_args, ".."
      system "make"
    end

    libexec.install bin/"drake-visualizer"
    (bin/"drake-visualizer").write_env_script(
      libexec/"drake-visualizer",
      :PYTHONPATH => libexec/"vendor/lib/python2.7/site-packages:${PYTHONPATH}",
    )
  end

  test do
    system "#{bin}/drake-visualizer", "--help"
  end
end
