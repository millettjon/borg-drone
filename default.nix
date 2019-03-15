with import <nixpkgs> {};
let env = bundlerEnv {
      name = "borg-drone-env";
      inherit ruby;
      gemdir = ./.;
    };
    scriptLib = ./lib;
in
stdenv.mkDerivation {
  name = "borg-drone";
  buildInputs = [ env.wrappedRuby borgbackup apg sshfs];
  script = ./bin/borg-drone;
  buildCommand = ''
    install -D -m755 $script $out/bin/borg-drone
    patchShebangs $out/bin/borg-drone
    cp -r ${scriptLib} $out/lib
  '';
}
