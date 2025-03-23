let
  nixpkgs = import <nixpkgs> { };
in
derivation rec {
  name = "hello";

  path =
    with nixpkgs;
    lib.concatMapStringsSep ":" (pkg: "${pkg}/bin") [
      curl
    ];

  buildScript = nixpkgs.writeText "buildScript" ''
    set -o errexit
    set -o nounset

    PATH=${path};

    curl https://ftp.gnu.org/gnu/hello/hello-2.12.1.tar.gz -o hello.tar.gz

    tar xzvf hello.tar.gz
    cd hello-2.12.1;
    ./configure
    make
    make install
  '';

  builder = "${nixpkgs.bash}/bin/bash";
  args = [ buildScript ];

  system = builtins.currentSystem;
}
