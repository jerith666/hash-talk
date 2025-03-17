let
  nixpkgs = import <nixpkgs> { };
in
derivation rec {
  name = "hello";
  src = nixpkgs.fetchurl {
    url = "mirror://gnu/hello/hello-2.12.1.tar.gz";
    hash = "sha256-jZkUKv2SV28wsM18tCqNxoCZmLxdYH2Idh9RLibH2yA=";
  };

  path =
    with nixpkgs;
    lib.concatMapStringsSep ":" (pkg: "${pkg}/bin") [
      gzip
      gnused
      coreutils
      gcc
      gnugrep
      gawk
      gnumake
    ];

  buildScript = nixpkgs.writeText "buildScript" ''
    set -o errexit
    set -o nounset

    PATH=$PATH:${path};

    ${nixpkgs.pkgs.gnutar}/bin/tar xzvf $src
    cd hello*;
    ./configure --prefix=$out
    make
    make install
  '';
  builder = "${nixpkgs.bash}/bin/bash";
  args = [ buildScript ];
  system = builtins.currentSystem;
}
