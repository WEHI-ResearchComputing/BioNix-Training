{bionix}:
with bionix; let
  R = pkgs.rWrapper.override {packages = with pkgs.rPackages; [limma edgeR Mus_musculus RColorBrewer R_utils];};
in
  stage {
    name = "r-ex";

    src = pkgs.fetchurl {
      url = "https://www.ncbi.nlm.nih.gov/geo/download/?acc=GSE63310&format=file";
      sha256 = "sha256-jLII/e+SVNx4Fivb65WOF566fwFXFtdNLUs04S82++g=";
    };

    buildInputs = [R];

    buildCommand = ''
      tar xf $src
      mkdir $out
      Rscript ${./script.R}
    '';
  }
