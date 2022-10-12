{bionix}:
with bionix;
  stage {
    name = "hello-world";

    buildInputs = [pkgs.hello];

    buildCommand = ''
      hello > $out
    '';
  }
