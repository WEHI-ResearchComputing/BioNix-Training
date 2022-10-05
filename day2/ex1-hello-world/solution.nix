/*
   This first exercise demonstrates how to define a processing stage,
which is just instructions on how to compute an output (the
`buildCommand`) from some inputs (in this case, there are no inputs).
Each stage must minimally define a `name`, shell code to build the
output in `buildCommand`, and any software that's required in
`buildInputs`.  Note that `buildInputs = []` if not defined, meaning no
extra requirements over the standard environment.

Try replacing the echo below with output from the GNU hello program.
Hint:  the GNU hello program is available at `pkgs.hello` and the
executable is called `hello`.
*/
{bionix}:
with bionix;
  stage {
    name = "hello-world";

    buildInputs = [pkgs.hello];

    buildCommand = ''
      hello > $out
    '';
  }
