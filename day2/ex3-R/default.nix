/*
This example tries to demonstrate that even very simple workflows (this
is only really one computational stage) can benefit from some formalisation
to provide reproducibility. We borrow part of the edgeR example available from
https://ucdavis-bioinformatics-training.github.io/2018-September-Bioinformatics-Prerequisites/friday/limma_biomart_vignettes.html
and specify it in BioNix so that it's easily reproducible.

One key learning goal in this exercise is to understand that Nix only
allows _inputs_ to be referenced during the execution of a build to
prevent side effects from creeping in. In particular, internet access is
forbidden when the build sandbox is enabled (default, but not on Milton
for technical reasons), meaning data cannot be fetched as part of a
build as the original example does.

We therefore fetch the count input as a separate stage and Nix will take
care of downloading it for us. The caveate is that the content of things
fetched from the internet must be verified to give reproducibility. Nix
does this through hashing.

Goal: fill out the below to specify required R packages, execute the
build and observe the hash collision. Update the hash and see if the
build now completes successfully.
*/
{bionix}:
with bionix; let
  R = pkgs.rWrapper.override {packages = with pkgs.rPackages; [];};

  counts = pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/ucdavis-bioinformatics-training/2018-September-Bioinformatics-Prerequisites/master/friday/counts.tsv";
    sha256 = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
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
