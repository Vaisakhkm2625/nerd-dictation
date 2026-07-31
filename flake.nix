{
  description = "nerd-dictation: offline speech to text for desktop Linux";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }:
    let
      systems = [ "x86_64-linux" "aarch64-linux" ];
      forAllSystems = nixpkgs.lib.genAttrs systems;

      vosk = import ./nix/vosk.nix;

      pythonWithVosk = pkgs: pkgs.python3.withPackages (ps: [ (vosk { inherit pkgs; }) ]);

      # Audio recording + input simulation tools that nerd-dictation shells out to.
      #
      # NOTE: `pipewire` (pw-cat) and `pulseaudio` (parec) are intentionally NOT
      # bundled: they're system services on NixOS and drag in a huge closure
      # (ffmpeg/gstreamer/libcamera -> llvm/clang). Both are already on PATH via
      # `services.pipewire` on the target system.
      runtimeTools = pkgs: with pkgs; [ xdotool wtype ydotool dotool sox ];

      nerd-dictation = pkgs: pkgs.stdenv.mkDerivation {
        pname = "nerd-dictation";
        version = "0.0.0";
        src = self;
        nativeBuildInputs = [ pkgs.makeWrapper ];
        installPhase = ''
          runHook preInstall
          mkdir -p $out/bin
          install -m755 nerd-dictation $out/bin/nerd-dictation
          wrapProgram $out/bin/nerd-dictation \
            --prefix PATH : ${pkgs.lib.makeBinPath ([ (pythonWithVosk pkgs) ] ++ runtimeTools pkgs)}
          runHook postInstall
        '';
        meta = {
          description = "Offline Speech to Text for Desktop";
          longDescription = ''
            A single-file utility that provides speech to text for desktop
            Linux using the VOSK-API. User configuration is a Python script
            that can manipulate the recognized text.
          '';
          homepage = "https://github.com/ideasman42/nerd-dictation";
          license = pkgs.lib.licenses.gpl2Plus;
          platforms = pkgs.lib.platforms.linux;
          mainProgram = "nerd-dictation";
        };
      };
    in {
      packages = forAllSystems (system: {
        nerd-dictation = nerd-dictation nixpkgs.legacyPackages.${system};
        default = nerd-dictation nixpkgs.legacyPackages.${system};
      });

      devShells = forAllSystems (system: {
        default = import ./shell.nix { pkgs = nixpkgs.legacyPackages.${system}; };
      });
    };
}
