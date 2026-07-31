# Development/runtime shell for nerd-dictation.
#
#   nix-shell
#
# Provides Python with the VOSK-API, audio recording utilities (parec/sox/pw-cat)
# and input simulation utilities (xdotool/wtype/ydotool/dotool).
#
# The speech model is not bundled. See the shell-hook output for how to get one.

{ pkgs ? import <nixpkgs> { } }:

let
  python = pkgs.python3.withPackages (ps: [ (import ./nix/vosk.nix { inherit pkgs; }) ]);
in
pkgs.mkShell {
  buildInputs = with pkgs; [
    python
    xdotool
    wtype
    ydotool
    dotool
    pulseaudio
    sox
    pipewire
    unzip
  ];

  shellHook = ''
    cat <<'EOF'
    nerd-dictation shell
    ====================

    Audio input:   parec (pulseaudio, default), sox, or pw-cat (pipewire)
    Input output:  xdotool (X11, default), wtype (Wayland), ydotool, or dotool

    The VOSK speech model is required and is NOT bundled:
      wget https://alphacephei.com/kaldi/models/vosk-model-small-en-us-0.15.zip
      unzip vosk-model-small-en-us-0.15.zip
      mv vosk-model-small-en-us-0.15 ~/.config/nerd-dictation/model

    Then run dictation with:
      ./nerd-dictation begin --vosk-model-dir ~/.config/nerd-dictation/model

    Hyprland (Wayland) - use PipeWire + wtype:
      ./nerd-dictation begin --input PW-CAT --simulate-input WTYPE

    Optional keybinds in ~/.config/hypr/hyprland.conf:
      bind = $mod, D, exec, nerd-dictation begin --input PW-CAT --simulate-input WTYPE
      bind = $mod+SHIFT, D, exec, nerd-dictation end
      bind = $mod+CTRL, D, exec, nerd-dictation cancel
    EOF
  '';
}
