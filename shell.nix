let
  nixpkgs = import (builtins.fetchTarball {
    name = "nixos-with-npm-10-9-2";
    url = "https://github.com/nixos/nixpkgs/archive/21b2f1808e3e22add3044a19fb0623356aafc047.tar.gz";
    sha256 = "1sx0mgmybb63fh1y2mjznp6vcwwwvc04px6a4hf7bnp45hbckbm9";
  }) { };

in
nixpkgs.pkgs.mkShell {
  buildInputs = [ nixpkgs.pkgs.nodejs ];
}
