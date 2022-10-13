/*
This exercise demonstrates how to create declarative shells. You can drop into
the shell specified by this expression with `nix develop`.

Try dropping into a shell and seeing which commands area available. You should
have bwa and samtools, try expanding this expression to include some additional
software you are familar with. Are other commands provided by your host
operating system available? Access to other commands not declared in this
expression are a side-effect and can reduce reproducbility. For example, if BWA
happened to be available on the system and it was not declared here, then on
another computer which didn't already have BWA then it would not be available
and the environment would be different.

Try dropping into a "purer" shell with `nix develop -i`; are other commands that
are not declared still available?

Declarative shells can also be created for more complicated programming environments:
see for example the [R documentation](https://nixos.org/manual/nixpkgs/stable/#r)
and the [mach-nix project](https://github.com/DavHau/mach-nix) for Python. We will
explore these a bit more in later exercises.
*/
{pkgs}:
with pkgs;
  mkShell {
    name = "ex0-declarative-shells";
    buildInputs = [
      samtools
      bwa
    ];
  }
