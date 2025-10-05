#!/usr/bin/env nix-shell
#!nix-shell -i runghc -p "haskellPackages.ghcWithPackages (pkgs: [ pkgs.cryptohash-sha1 ])"

import Crypto.Hash.SHA1 (hash)
import Data.ByteString (ByteString)
import qualified Data.ByteString as BS
import qualified Data.ByteString.Char8 as C8
import Data.List (sortBy)
import Data.Map (Map)
import qualified Data.Map as Map
import Data.Char (toLower, toUpper)
import Numeric (showHex)

-- Convert ByteString to hex string
toHex :: ByteString -> String
toHex = concatMap (\w -> let h = showHex w "" in if length h == 1 then '0':h else h) . BS.unpack

-- Compute SHA1 hash of a name
hashName :: String -> String
hashName = toHex . hash . C8.pack

-- Get the two-character prefix from a hash
getPrefix :: String -> (Char, Char)
getPrefix (c1:c2:_) = (toLower c1, toLower c2)
getPrefix _ = ('0', '0')

-- All possible hex characters
hexChars :: [Char]
hexChars = "0123456789abcdef"

-- Build a map from (char, char) to list of names
buildTable :: [(String, String)] -> Map (Char, Char) [String]
buildTable nameHashes = 
    foldr (\(name, h) m -> Map.insertWith (++) (getPrefix h) [name] m) Map.empty nameHashes

-- Generate HTML table
generateHTML :: Map (Char, Char) [String] -> String
generateHTML table = unlines
    [ "<!DOCTYPE html>"
    , "<html>"
    , "<head>"
    , "  <meta charset='utf-8'>"
    , "  <title>SHA1 Name Distribution</title>"
    , "  <style>"
    , "    table { border-collapse: collapse; margin: 20px; font-family: monospace; }"
    , "    th, td { border: 1px solid #666; padding: 8px; text-align: left; vertical-align: top; }"
    , "    th { background-color: #ddd; font-weight: bold; }"
    , "    .cell-content { max-height: 100px; overflow-y: auto; font-size: 12px; }"
    , "    .name-item { margin: 2px 0; }"
    , "  </style>"
    , "</head>"
    , "<body>"
    , "  <h1>SHA1 Name Distribution Table</h1>"
    , "  <p>Names organized by the first two characters of their SHA1 hash</p>"
    , "  <table>"
    , "    <tr>"
    , "      <th>2nd \\ 1st</th>"
    , concat ["      <th>" ++ [toUpper c] ++ "</th>\n" | c <- hexChars]
    , "    </tr>"
    , concatMap generateRow hexChars
    , "  </table>"
    , "</body>"
    , "</html>"
    ]
  where
    generateRow rowChar = 
        "    <tr>\n" ++
        "      <th>" ++ [toUpper rowChar] ++ "</th>\n" ++
        concatMap (generateCell rowChar) hexChars ++
        "    </tr>\n"
    
    generateCell rowChar colChar =
        let names = Map.findWithDefault [] (colChar, rowChar) table
            content = if null names 
                      then "&nbsp;"
                      else "<div class='cell-content'>" ++ 
                           concatMap (\n -> "<div class='name-item'>" ++ escapeHTML n ++ "</div>") names ++
                           "</div>"
        in "      <td>" ++ content ++ "</td>\n"
    
    escapeHTML = concatMap escapeChar
    escapeChar '<' = "&lt;"
    escapeChar '>' = "&gt;"
    escapeChar '&' = "&amp;"
    escapeChar '"' = "&quot;"
    escapeChar c = [c]

main :: IO ()
main = do
    putStrLn "Enter names (one per line, empty line to finish):"
    names <- readNames
    let nameHashes = [(name, hashName name) | name <- names]
        table = buildTable nameHashes
        html = generateHTML table
    
    putStrLn "\nProcessed names and their SHA1 hashes:"
    mapM_ (\(n, h) -> putStrLn $ n ++ " -> " ++ h) nameHashes
    
    writeFile "output.html" html
    putStrLn "\nHTML table written to output.html"

readNames :: IO [String]
readNames = readNames' []
  where
    readNames' acc = do
        line <- getLine
        if null line
            then return (reverse acc)
            else readNames' (line:acc)
