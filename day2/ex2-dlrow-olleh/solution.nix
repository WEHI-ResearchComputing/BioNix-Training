{bionix}:
with bionix; let
  hello-world = callBionix ../ex1-hello-world {};

  rev = input:
    stage {
      name = "rev";
      buildInputs = [pkgs.toybox];
      buildCommand = ''
        rev < ${input} > $out
      '';
    };
in
  rev (rev hello-world)
