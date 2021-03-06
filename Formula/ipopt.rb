# Copyright (c) 2018, Massachusetts Institute of Technology.
# Copyright (c) 2018, Toyota Research Institute.
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
# * Redistributions of source code must retain the above copyright notice, this
#   list of conditions and the following disclaimer.
#
# * Redistributions in binary form must reproduce the above copyright notice,
#   this list of conditions and the following disclaimer in the documentation
#   and/or other materials provided with the distribution.
#
# * Neither the name of the copyright holder nor the names of its
#   contributors may be used to endorse or promote products derived from
#   this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
# SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
# CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
# OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#
# Copyright (c) 2009-2018, Homebrew contributors.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
# * Redistributions of source code must retain the above copyright notice, this
#   list of conditions and the following disclaimer.
#
# * Redistributions in binary form must reproduce the above copyright notice,
#   this list of conditions and the following disclaimer in the documentation
#   and/or other materials provided with the distribution.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
# SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
# CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
# OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

class Ipopt < Formula
  desc "Interior point optimizer"
  homepage "https://projects.coin-or.org/Ipopt/"
  url "https://drake-homebrew.csail.mit.edu/mirror/ipopt-3.12.10.tar.gz"
  sha256 "4474dea8a69f0c4b4fa146dc256941ee90b56b6acee9a337aebf4518a178b802"
  head "https://projects.coin-or.org/svn/Ipopt/trunk", :using => :svn

  bottle do
    cellar :any
    root_url "https://drake-homebrew.csail.mit.edu/bottles"
    sha256 "12612b951e4971f2a432d0fbca1a85459b6a9a7ca1d8da292f77f27b79877be2" => :high_sierra
    sha256 "c9219b95b0e5df29795cf6b071b2340f2be65ee83867d703c69ef5f3cd4a8625" => :sierra
    sha256 "bab6e03559ae6d1f16f03feb269b53d5680f5cf97122aa6f9d38a0de2dfd749d" => :el_capitan
  end

  depends_on "gcc"
  depends_on "mumps@5.1"
  depends_on "pkg-config" => :build

  def install
    ENV.delete("MPICC")
    ENV.delete("MPICXX")
    ENV.delete("MPIFC")
    ENV.fortran

    args = ["--disable-debug",
            "--disable-dependency-tracking",
            "--enable-shared",
            "--prefix=#{prefix}",
            "--with-mumps-incdir=#{Formula["mumps@5.1"].include}",
            "--with-mumps-lib=-L#{Formula["mumps@5.1"].lib} -ldmumps -lmpiseq -lmumps_common -lpord"]

    system "./configure", *args
    system "make"

    ENV.deparallelize
    system "make", "install"

    inreplace "#{lib}/pkgconfig/ipopt.pc", prefix, opt_prefix
    inreplace "#{lib}/pkgconfig/ipopt.pc", "-framework Accelerate -framework Accelerate", "-framework Accelerate"
  end

  test do
    (testpath/"Version.cpp").write <<~EOS
      #include <cassert>
      #include <IpoptConfig.h>
      int main() {
        assert(IPOPT_VERSION_MAJOR == 3);
        assert(IPOPT_VERSION_MINOR == 12);
        assert(IPOPT_VERSION_RELEASE == 10);
        return 0;
      }
    EOS

    system ENV.cxx, "Version.cpp", "-I#{opt_include}/coin"
    system "./a.out"
  end
end
