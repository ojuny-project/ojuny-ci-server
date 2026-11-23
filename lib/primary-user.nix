{ lib, text }:
let
  flat = lib.replaceStrings [ "\n" "\r" ] [ " " " " ] text;

  nested = builtins.match ".*users\\.users *= *\\{ *([A-Za-z0-9_-]+) *=.*" flat;
  direct = builtins.match ".*users\\.users\\.([A-Za-z0-9_-]+) *=.*" flat;
in
if nested != null then
  builtins.head nested
else if direct != null then
  builtins.head direct
else
  "admin"
