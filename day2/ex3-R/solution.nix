{bionix}:
with bionix; let
  R = pkgs.rWrapper.override {packages = with pkgs.rPackages; [edgeR];};

  counts = pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/ucdavis-bioinformatics-training/2018-September-Bioinformatics-Prerequisites/master/friday/counts.tsv";
    sha256 = "sha256-ZmZ+vC4mKnmZKVJqbnEujDngwnSTZAxvQaZaNClUUWE=";
  };
in
  stage {
    inherit counts;
    name = "r-ex";

    buildInputs = [R];

    buildCommand = ''
      Rscript ${./script.R}
    '';
  }
