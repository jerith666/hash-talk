let
  nixpkgs = import <nixpkgs> { };
in
derivation rec {
  name = "hello";

  src = nixpkgs.fetchurl {
    url = "https://ftp.gnu.org/gnu/hello/hello-2.12.1.tar.gz";
    hash = "sha256-jZkUKv2SV28wsM18tCqNxoCZmLxdYH2Idh9RLibH2yA=";
  };

  path =
    with nixpkgs;
    lib.concatMapStringsSep ":" (pkg: "${pkg}/bin") [
      gnutar
    ];

  buildScript = nixpkgs.writeText "buildScript" ''
    set -o errexit
    set -o nounset

    PATH=$PATH:${path};

    tar xzvf $src
    cd hello-2.12.1;
    ./configure
    make
    make install
  '';

  builder = "${nixpkgs.bash}/bin/bash";
  args = [ buildScript ];

  system = builtins.currentSystem;
}
