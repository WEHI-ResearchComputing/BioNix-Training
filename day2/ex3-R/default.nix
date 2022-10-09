/*
This example tries to demonstrate that even very simple workflows (this
is only really one computational stage) can benefit from some
formalisation to provide reproducibility. With help from Hannah Coughlan
the example from Law et al. [1] was adapted and in this exercise we will
fully specify it in BioNix so that it's easily reproducible.

One key learning goal in this exercise is to understand that Nix only
allows _inputs_ to be referenced during the execution of a build to
prevent side effects from creeping in. In particular, internet access is
forbidden when the build sandbox is enabled (default, but not on Milton
for technical reasons), meaning data cannot be fetched as part of a
build as the original example does.

We therefore fetch the count input as a seperate stage and Nix will take
care of downloading it for us. The caveate is that the content of things
fetched from the internet must be verified to give reproducibility. Nix
does this through hashing.

One important thing to note is this analysis does change depending on
annotation, so achieving reproducibility requires some tooling to fix
the software/database stack. Nix does this for us ensuring
reproducibility.

Goal: fill out the below to specify required R packages, execute the
build and observe the hash collision. Update the hash and see if the
build now completes successfully.

Hint: All of CRAN and BioC are available in nixpkgs, however for
convenience periods "." are converted to "_" as "." in the Nix language
is attrset element access.

1: https://www.bioconductor.org/packages/devel/workflows/vignettes/RNAseq123/inst/doc/limmaWorkflow.html
*/
{bionix}:
with bionix; let
  R = pkgs.rWrapper.override {packages = with pkgs.rPackages; [];};
in
  stage {
    name = "r-ex";

    src = pkgs.fetchurl {
      url = "https://www.ncbi.nlm.nih.gov/geo/download/?acc=GSE63310&format=file";
      sha256 = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
    };

    buildInputs = [R];

    buildCommand = ''
      tar xf $src
      mkdir $out
      Rscript ${./script.R}
    '';
  }
