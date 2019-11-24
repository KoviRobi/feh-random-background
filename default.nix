let pkgs = import <nixpkgs> {};
in
{ stdenvNoCC ? pkgs.stdenvNoCC, lib ? pkgs.lib, coreutils ? pkgs.coreutils,
  bash ? pkgs.bash, gnused ? pkgs.gnused, findutils ? pkgs.findutils,
  feh ? pkgs.feh
}:

stdenvNoCC.mkDerivation {
  pname = "feh-random-background";
  version = "1.0";
  src = ./feh-random-background;

  phases = [ "installPhase" "patchPhase" ];

  installPhase = ''
    mkdir -p $out/bin
    cat <<'EOF' > $out/bin/feh-random-background
    #!${bash}/bin/bash
    PATH="${stdenvNoCC.lib.makeBinPath [ coreutils findutils gnused feh ]}:$PATH"
    EOF
    sed 1d < $src >> $out/bin/feh-random-background
    chmod +x $out/bin/feh-random-background
  '';

  meta = with lib; {
    description = "Set random backgrounds using feh, while avoiding the birthday paradox";
    license = licenses.mit;
  };
}
