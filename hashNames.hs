#!/usr/bin/env nix-shell
#! nix-shell --pure -i runghc -p "haskellPackages.ghcWithPackages (pkgs: with pkgs; [ cryptohash-sha1 base16 bytestring-encoding ])"

import qualified Data.Text as T
import qualified Data.ByteString as BS
import qualified Data.ByteString.Encoding as BE
import qualified Crypto.Hash.SHA1 as SHA1
import Data.Base16.Types (Base16)
import Data.ByteString.Base16 (encodeBase16)

main =
  print $ hash "Kevin"

hash :: String -> Base16 T.Text
hash x =
  encodeBase16 $ SHA1.hash $ BE.encode BE.utf8 $ T.pack x
