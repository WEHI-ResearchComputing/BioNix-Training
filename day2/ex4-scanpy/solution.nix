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
