/*
This exercise is similar to the previous one, only in python instead of
R for those who are more familar with python. For this example, we will
make the scanpy tutorial notebook[1] reproducible.

Unlike the R ecosysytem, Python dependency management is significantly
more difficult. There is some tooling available for building
reproducible Python environments, most notably mach-nix[2]. We will use
this to provide an environment containing jupyter (for running the
notebook) and scanpy; unfortunately scanpy has some unresolved bugs[2]
and we will avoid them by pinning the anndata dependency to a known
working version.

This expression sets up the build directory to match the layout assumed
by the notebook. Note that it also explicitly sets a Numba cache
directory to the build directory: during a build the only writable
location are the output paths allocated in the nix store and the
(temporary) build directory.  Jupyter is executed to convert the
notebook into a html file, and the output is copied to the store along
with some ancillary h5 blobs produced by the notebook.

Goal: As in exercise 3, the data cannot be fetched during execution as
internet access is not permitted. Furthermore, the notebook itself also
has to be retrieved. Fill out the required hashes for fetching these two
pieces of data. Run the build, and review the output in a browser (e.g.,
with `chromium ./result`).

1: https://scanpy-tutorials.readthedocs.io/en/latest/pbmc3k.html
2: https://github.com/DavHau/mach-nix
*/
{
  bionix,
  mach-nix,
}:
with bionix; let
  python = mach-nix.mkPython {
    requirements = ''
      jupyterlab
      scanpy
      anndata=0.7.8
      leidenalg
    '';
  };
in
  stage {
    name = "scanpy-tutorial.html";
    buildInputs = [python];
    outputs = ["out" "results"];

    src = pkgs.fetchurl {
      url = "http://cf.10xgenomics.com/samples/cell-exp/1.1.0/pbmc3k/pbmc3k_filtered_gene_bc_matrices.tar.gz";
      sha256 = "sha256-hH1uvZoeyado8r5+QMpCy/516+ttdqTCQWcEFpncKLU=";
    };

    notebook = pkgs.fetchurl {
      url = "https://github.com/scverse/scanpy-tutorials/raw/532f755ac31d9baf00116a44243b73174765a6a6/pbmc3k.ipynb";
      sha256 = "sha256-mwIPHKAsDd1F4F9fNnAfrapBehBN3jjEsrLGsI37Igg=";
    };

    buildCommand = ''
      export NUMBA_CACHE_DIR=$TMPDIR
      cp $notebook notebook.ipynb
      mkdir data
      tar -zxf $src -C data
      mkdir write
      jupyter nbconvert  --execute --to html ./notebook.ipynb
      cp notebook.html $out
      cp -r write $results
    '';

    stripStorePaths = false;
  }
