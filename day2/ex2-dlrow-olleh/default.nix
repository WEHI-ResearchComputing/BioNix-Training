/*
This exercise demonstrates the first workflow consisting of multiple
steps.  We will build upon the previous example by using the string
produced in exercise 1 as input to this workflow. You can see how other
files can be imported and used in the construction of workflows using
`callBionix`, which imports a file and passes it `bionix` along with
potentially some additional arguments.

Goal: fill out the stage here to reverse the string using the `rev`
program, which reads lines on stdin and writes them to stdout with the
characters reversed. You will need to choose exactly *which* rev you
want to use in `buildInputs`: there are three providers available
(busybox, toybox, utillinux) and you can try them all.

Bonus: change the last line to call rev twice, thereby reversing the
strings back to the original orientation
*/
{bionix}:
with bionix; let
  hello-world = callBionix ../ex1-hello-world {};

  rev = input:
    stage {
      name = "rev";
      buildInputs = [];
      buildCommand = ''
      '';
    };
in
  rev hello-world
