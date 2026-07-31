# VOSK-API python package.
#
# Not packaged in nixpkgs, so install the prebuilt manylinux wheel with a
# pinned hash (supply-chain safe). The bundled libvosk.so is RPATH-patched so
# it finds libstdc++ etc. on NixOS.

{ pkgs }:

pkgs.python3.pkgs.buildPythonPackage {
  pname = "vosk";
  version = "0.3.45";
  format = "wheel";
  src = pkgs.fetchurl {
    url = "https://files.pythonhosted.org/packages/fc/ca/83398cfcd557360a3d7b2d732aee1c5f6999f68618d1645f38d53e14c9ff/vosk-0.3.45-py3-none-manylinux_2_12_x86_64.manylinux2010_x86_64.whl";
    sha256 = "25e025093c4399d7278f543568ed8cc5460ac3a4bf48c23673ace1e25d26619f";
  };
  nativeBuildInputs = [ pkgs.autoPatchelfHook ];
  buildInputs = [ pkgs.stdenv.cc.cc.lib ];
  propagatedBuildInputs = with pkgs.python3.pkgs; [ cffi requests tqdm srt websockets ];
  meta.mainProgram = "vosk-transcriber";
}
